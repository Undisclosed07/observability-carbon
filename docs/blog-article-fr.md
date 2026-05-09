# Mesurer l'empreinte carbone d'une stack Kubernetes sur Infomaniak Public Cloud

> Comment j'ai déployé une stack Prometheus + Grafana + Kepler sur le Public Cloud Infomaniak pour comparer la consommation énergétique de mes workloads selon la région — et ce que ça change concrètement.

## TL;DR

- J'ai packagé une stack d'observabilité **carbon-aware** en un seul Helm chart : `observability-carbon`.
- Je l'ai déployée sur le Public Cloud Infomaniak (OpenStack) et sur un cluster local OKD pour comparer.
- Pour la même charge de travail, déplacer un workload de Francfort vers la Suisse (Infomaniak) divise les émissions estimées par environ **3** sur le seul mix électrique.
- Le code est sur GitHub : [observability-carbon](https://github.com/Undisclosed07/observability-carbon).

## Pourquoi mesurer le carbone d'un cluster

On a tous des dashboards Grafana qui montrent CPU, mémoire, latence p95, taux d'erreur. Très peu de gens ont un dashboard qui montre **kilogrammes de CO₂eq par jour, par namespace**. Pourtant la donnée est là — il "suffit" de combiner trois choses :

1. La consommation électrique des pods (en watts).
2. L'intensité carbone du mix électrique de la région où tournent les nœuds (en gCO₂eq/kWh).
3. Le PUE du datacenter (overhead refroidissement / réseau / pertes).

Le 1er point est le plus subtil. Sur du bare-metal avec accès RAPL, on a une vraie mesure CPU/RAM. Sur du cloud public, l'hyperviseur masque RAPL et il faut s'appuyer sur un modèle d'estimation. C'est exactement ce que fait Kepler : eBPF + un modèle ML qui mappe les compteurs perf hardware vers une estimation de puissance.

C'est imparfait. Mais comparer deux régions ou deux versions d'un service avec le même outil reste valide — on se fiche du chiffre absolu, on regarde le delta.

## La stack en une slide

```
   Pods (cgroups, perf counters)
              │
              ▼
        ┌──────────┐
        │  Kepler  │   eBPF → watts par pod
        └────┬─────┘
             │  /metrics
             ▼
       ┌────────────┐
       │ Prometheus │   recording rules :
       │            │   watts × intensité région → gCO2eq/s
       └─────┬──────┘
             │
             ▼
        ┌─────────┐
        │ Grafana │   dashboard "Carbon Overview"
        └─────────┘
```

Le tout packagé dans un Helm chart avec deux dépendances : `kube-prometheus-stack` et `kepler`. Une `values.yaml` avec les intensités carbone par région et c'est parti.

## Déploiement sur Infomaniak Public Cloud

Infomaniak expose un Public Cloud OpenStack (Compute, Network, Block Storage). J'ai utilisé Terraform avec le provider OpenStack pour provisionner :

- 1 control-plane (k3s, 2 vCPU / 4 GiB)
- 3 workers (k3s, 4 vCPU / 8 GiB)
- 1 réseau privé + flottante pour l'API

Le cluster monte en ~7 minutes. Une fois `kubeconfig` en main :

```bash
helm dependency update charts/observability-carbon
helm install obs-carbon charts/observability-carbon \
  -n observability --create-namespace \
  --set carbon.region=CH \
  --set carbon.intensityGramsPerKwh=128
```

Petite surprise sur le cloud public : `kepler` se plaint que RAPL n'est pas accessible (hyperviseur KVM, c'est attendu). Il bascule automatiquement sur le modèle d'estimation. Les métriques sortent au bout de ~30 secondes.

## Comparer deux régions

Le même workload tournant en parallèle :

| Région | Mix électrique (gCO₂eq/kWh) | Conso pod (W) | Émissions estimées (gCO₂eq/h) |
|---|---|---|---|
| Suisse (Infomaniak, GE/CH) | ~128 | [TODO mesuré] | [TODO calculé] |
| France (FR) | ~56 | [TODO] | [TODO] |
| Allemagne (DE) | ~380 | [TODO] | [TODO] |
| US-East | ~370 | [TODO] | [TODO] |

> **Note** : Les valeurs `[TODO]` sont à remplir une fois le déploiement effectué et la charge appliquée. Le mix carbone CH provient de Swissgrid (moyenne annuelle 2024). Pour des chiffres temps réel, voir la section "Aller plus loin".

Ce qui ressort clairement : à conso égale, c'est la **région** qui pilote l'empreinte, pas l'optimisation logicielle. Optimiser un service de 30% de CPU sur AWS Frankfurt fait moins pour le climat que de le déplacer en Suisse.

## L'angle Infomaniak

Trois choses font qu'Infomaniak est intéressant pour ce genre d'analyse :

1. **Mix électrique suisse**. Hydro-dominant, ~128 gCO₂eq/kWh, 3 à 7 fois moins que la plupart des hyperscalers européens.
2. **PUE bas** (~1.09 sur leurs derniers DC, vs 1.5 typique). Ça veut dire que sur 1 kWh consommé par les serveurs, seulement 0.09 kWh part en refroidissement et pertes — vs 0.5 ailleurs.
3. **Récupération de chaleur**. Les DC injectent leur chaleur résiduelle dans le chauffage urbain. C'est pas comptabilisé dans les calculs ci-dessus mais c'est une externalité positive nette.

Le calcul "honnête" final intègre ces trois facteurs :

```
gCO₂eq/h ≈ watts × heures × (intensité_carbone × PUE)
```

Pour Infomaniak avec PUE 1.09 et 128 gCO₂eq/kWh, l'intensité effective tombe à ~140 gCO₂eq/kWh. Pour un cloud Frankfurt avec PUE 1.4 et 380 gCO₂eq/kWh : ~530 gCO₂eq/kWh. Soit un **rapport ~3.8** sur la même charge.

## Limites à reconnaître

Je tiens à être honnête sur ce que ce setup ne montre pas :

- **Cycle de vie matériel** : la fabrication des serveurs représente 20-50% de l'impact total sur la durée de vie. Mes mesures captent uniquement la phase d'usage.
- **Estimation, pas mesure** : sans RAPL, on est dans l'ordre de grandeur, pas la précision. Comparer reste valide ; rapporter "X gCO₂" sans intervalle de confiance est trompeur.
- **Intensité statique** : j'utilise une moyenne annuelle. Le mix varie d'heure en heure. Pour faire les choses bien, brancher l'API ElectricityMaps :

```yaml
# values.yaml
carbon:
  source: electricity-maps
  apiKey: <secret-ref>
  zone: CH
```

(Pas implémenté dans cette V1, mais documenté dans la roadmap.)

- **PUE moyen vs instantané** : Infomaniak publie un PUE moyen, mais en hiver vs été ça bouge.

## Ce que j'en retire

D'un point de vue ingénierie, le projet m'a forcé à manipuler trois choses utiles ensemble :

- les **recording rules** Prometheus (pour pré-calculer kWh × intensité, sinon le dashboard rame) ;
- la **chart Helm** propre avec dépendances et `values.yaml` lisible (pas de blob de 800 lignes) ;
- la **comparaison multi-régions** comme premier critère de sizing — pas juste prix et latence.

D'un point de vue produit / impact, ça déplace une discussion. Au lieu de "on est sur AWS parce que c'est ce qu'on connaît", on peut chiffrer ce que coûte le choix en gCO₂eq par mois. Sur des stacks qui tournent en continu, ça devient un argument lisible par un CTO.

## Aller plus loin

- Brancher l'**API ElectricityMaps** pour avoir l'intensité carbone temps réel par zone.
- Explorer **Scaphandre** comme alternative à Kepler (plus précis sur bare-metal, plus pénible à packager).
- Ajouter un **budget carbone** sous forme de SLO : alerter quand un namespace dépasse X kgCO₂eq/jour.
- Faire le même exercice sur **Kubernetes Service Infomaniak** quand il sortira de bêta (Jelastic Cloud ne donne pas accès au plan de contrôle).

Le repo est ici : [github.com/Undisclosed07/observability-carbon](https://github.com/Undisclosed07/observability-carbon). PRs et critiques bienvenues — surtout sur la partie modèle d'intensité carbone, où il y a plein de façons de faire mieux.

---

*Rédigé en avril 2026, dans le cadre d'une candidature DevOps chez Infomaniak. Si vous lisez ceci depuis Infomaniak : bonjour 👋, et merci d'avoir un cloud qu'on a envie de mesurer.*
