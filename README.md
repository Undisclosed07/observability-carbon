# observability-carbon

> Stack d'observabilité Kubernetes orientée empreinte carbone — Prometheus + Grafana + Kepler, packagée en Helm.

[![Helm](https://img.shields.io/badge/Helm-3.x-0F1689?logo=helm)](https://helm.sh)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.27%2B-326CE5?logo=kubernetes)](https://kubernetes.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## Pourquoi ce projet

La plupart des stacks d'observabilité Kubernetes mesurent latence, throughput et erreurs. Très peu mesurent **l'empreinte carbone des workloads**. Ce projet comble ce trou : il déploie en un `helm install` une stack qui expose la consommation énergétique (kWh) et les émissions équivalentes (gCO₂eq) par namespace, par pod, et par région cloud.

C'est utile pour :

- comparer le coût carbone d'une même charge sur différentes régions cloud (Suisse, France, Allemagne, US-East...) ;
- attribuer une consommation à une équipe / un service ;
- intégrer un budget carbone dans les SLO.

## Architecture

```
┌─────────────────────────┐
│   Sample app (FastAPI)  │  workload de démo
└───────────┬─────────────┘
            │
┌───────────▼─────────────┐      ┌──────────────────┐
│        Kepler           │ ───► │   Prometheus     │
│ (eBPF-based power est.) │      │  + recording     │
└─────────────────────────┘      │     rules        │
                                 └─────────┬────────┘
                                           │
                                 ┌─────────▼────────┐
                                 │     Grafana      │
                                 │  Carbon Overview │
                                 │     dashboard    │
                                 └──────────────────┘
```

- **Kepler** estime la consommation énergétique des pods via eBPF (RAPL quand disponible, modèle ML sinon).
- **Prometheus** scrape Kepler et applique des `recording rules` qui multiplient les watts par l'intensité carbone de la région (gCO₂eq/kWh).
- **Grafana** rend un dashboard "Carbon Overview" prêt à l'emploi.

## Quick start

### Prérequis

- Cluster Kubernetes 1.27+
- Helm 3.x
- ~2 GiB RAM disponible pour la stack monitoring

### Installation

```bash
# Ajouter les dépendances
helm dependency update charts/observability-carbon

# Installer la stack
helm install obs-carbon charts/observability-carbon \
  --namespace observability \
  --create-namespace \
  --set carbon.region=CH \
  --set carbon.intensityGramsPerKwh=128
```

### Accéder à Grafana

```bash
kubectl -n observability port-forward svc/obs-carbon-grafana 3000:80
# Login: admin / prom-operator (défaut kube-prometheus-stack)
# Dashboard: "Carbon Overview"
```

### Déployer la sample-app

```bash
kubectl apply -f examples/sample-app/k8s-manifest.yaml
# Générer un peu de charge :
kubectl -n demo run loadgen --image=curlimages/curl --restart=Never -- \
  sh -c 'while true; do curl -s sample-app/work; done'
```

Au bout de ~5 minutes le dashboard affichera les premières mesures.

## Configuration

Les valeurs principales dans `charts/observability-carbon/values.yaml` :

| Clé | Description | Défaut |
|---|---|---|
| `carbon.region` | Code région utilisé pour le label Prometheus | `CH` |
| `carbon.intensityGramsPerKwh` | Intensité carbone de la région (gCO₂eq/kWh) | `128` |
| `carbon.regions` | Table de référence multi-régions pour comparer | voir `values.yaml` |
| `kepler.enabled` | Activer Kepler | `true` |
| `kubePrometheusStack.enabled` | Activer kube-prometheus-stack | `true` |

Quelques intensités carbone de référence (sources : ElectricityMaps, RTE, Swissgrid, moyennes 2024) :

| Région | gCO₂eq/kWh |
|---|---|
| Suisse (CH) | ~128 |
| France (FR) | ~56 |
| Allemagne (DE) | ~380 |
| US-East (us-east-1) | ~370 |
| Pologne (PL) | ~635 |

> ⚠️ Ces chiffres varient en temps réel selon le mix électrique. Pour une intensité dynamique, brancher l'API ElectricityMaps (cf. `docs/blog-article-fr.md`).

## Limites connues

- Sur cloud public sans accès RAPL (cas le plus courant), Kepler bascule sur un **modèle d'estimation ML**. Les valeurs sont indicatives, pas absolues. Comparer deux régions reste pertinent ; affirmer un chiffre brut l'est moins.
- L'intensité carbone est ici **statique** par région. Une intégration ElectricityMaps temps réel est laissée en exercice (un exemple est esquissé dans l'article de blog).
- Le PUE du datacenter n'est pas pris en compte. Pour les hébergeurs qui le publient (Infomaniak ~1.09), multiplier l'intensité par le PUE pour une estimation plus réaliste.

## Articles & contexte

- [Article de blog FR : "Mesurer l'empreinte carbone d'une stack Kubernetes sur Infomaniak Public Cloud"](docs/blog-article-fr.md)
- [Lettre de motivation FR (Infomaniak DevOps)](docs/cover-letter-fr.md)

## Roadmap

- [ ] Intégration ElectricityMaps API pour intensité dynamique
- [ ] Support Scaphandre comme alternative à Kepler
- [ ] Helm test pour valider la stack après install
- [ ] Export des métriques vers OpenTelemetry Collector
- [ ] Dashboard de comparaison multi-clusters

## Licence

MIT — voir [LICENSE](LICENSE).
