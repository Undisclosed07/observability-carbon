# Lettre de motivation — Ingénieur DevOps / SRE chez Infomaniak

**Alban Mayunga**
albanmayunga01@gmail.com
[github.com/Undisclosed07](https://github.com/Undisclosed07)

À l'attention de l'équipe Infrastructure / Cloud d'Infomaniak,

---

Je vous écris pour le poste d'**Ingénieur DevOps** ouvert chez Infomaniak. Plutôt que de paraphraser mon CV, je préfère vous parler de ce que j'ai construit pour cette candidature et de pourquoi votre boîte m'intéresse spécifiquement.

## Le projet que je vous adresse en même temps

J'ai réalisé un mini-projet open-source que je publie en parallèle de cette lettre : **observability-carbon**, une stack Helm qui déploie Prometheus + Grafana + Kepler en cinq minutes, avec un dashboard "Carbon Overview" qui mesure la consommation énergétique et les émissions estimées (gCO₂eq) des workloads Kubernetes — par namespace, par pod, par région.

- Repo : [github.com/Undisclosed07/observability-carbon](https://github.com/Undisclosed07/observability-carbon)
- Article qui documente le déploiement sur votre Public Cloud : [voir blog-article-fr.md](./blog-article-fr.md)

Pourquoi j'ai fait ça : parce que la plupart des stacks d'observabilité K8s mesurent latence, throughput, erreurs — et passent à côté du carbone. Or c'est exactement le terrain sur lequel un cloud comme le vôtre, avec un mix électrique suisse à ~128 gCO₂eq/kWh et un PUE ~1.09, vaut numériquement 3 à 4 fois mieux qu'un hyperscaler européen moyen. Encore faut-il que ce soit mesurable et lisible. C'est ce que ce projet rend possible.

## Pourquoi Infomaniak, concrètement

Trois choses, dans cet ordre :

1. **Vous prenez la souveraineté et l'écologie au sérieux comme contraintes d'architecture, pas comme argument marketing.** Le PUE 1.09, la récupération de chaleur, l'énergie renouvelable certifiée — ce sont des décisions d'ingénierie qui transparaissent jusque dans les choix de hardware et de site. C'est rare, et c'est exactement le contexte dans lequel j'ai envie de bosser.

2. **Votre stack est intéressante techniquement.** OpenStack pour le Public Cloud, Jelastic pour le PaaS, et un Kubernetes managé en cours de déploiement. Trois plans d'abstraction différents, trois publics différents, et la nécessité de garder la cohérence (réseau, identité, observabilité) entre les trois. C'est le genre de challenge qui me parle.

3. **Vous êtes suisses, indépendants, et vous tenez sur la durée.** Pas une scale-up sous pression VC. Ça change la qualité du travail qu'on peut faire — moins de feature factory, plus de bonnes décisions long terme.

## Ce que je sais faire et qui me semble pertinent ici

- **Kubernetes en production** : Helm, GitOps (Argo CD), upgrades, désastres maîtrisés.
- **Observabilité** : Prometheus, Grafana, Loki, alerting orienté SLO. Le projet ci-dessus en est une démo concrète.
- **OpenStack** : provisioning Terraform, networking (Neutron), Block Storage (Cinder).
- **CI/CD** : GitLab CI et GitHub Actions, focus sur les pipelines reproductibles et signés.
- **Linux** : 10 ans d'usage quotidien, à l'aise avec systemd, eBPF côté usage (perf, bcc, bpftrace), networking de bas niveau.
- **Langues** : français natif, anglais technique courant.

## Ce que je propose

Si l'idée vous parle, je serais ravi d'avoir un échange de 30 minutes pour creuser deux choses :

- ce que vous attendez vraiment du poste DevOps ouvert (souvent plus précis que la fiche) ;
- comment je pourrais contribuer dès les 90 premiers jours sur des sujets qui comptent (un plan rapide est d'ailleurs joint dans le repo).

Merci pour le temps que vous accorderez à cette candidature, et merci surtout de faire un cloud qu'on a envie de mesurer plutôt que de fuir.

À très bientôt, j'espère.

Alban Mayunga
