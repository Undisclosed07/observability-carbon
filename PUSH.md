# Comment pusher ce projet sur GitHub

Le sandbox Cowork ne peut pas s'authentifier auprès de GitHub. Tu dois faire le push toi-même depuis ta machine. Voici les commandes exactes.

## 1. Ouvre PowerShell dans le dossier du projet

```powershell
cd C:\Users\ALBAN\infomaniak\infomaniak
```

## 2. Nettoie le `.git` cassé créé par le sandbox

```powershell
Remove-Item -Recurse -Force .git
```

## 3. Initialise un repo propre et commit

```powershell
git init -b main
git config user.email "albanmayunga01@gmail.com"
git config user.name "Alban Mayunga"
git add .
git commit -m "Initial commit: observability-carbon stack"
```

## 4. Ajoute le remote et push

```powershell
git remote add origin https://github.com/Undisclosed07/observability-carbon.git
git push -u origin main
```

GitHub te demandera tes credentials (login + token PAT). Si ce n'est pas fait, génère un Personal Access Token avec scope `repo` ici : <https://github.com/settings/tokens>.

## 5. Vérifie

Va sur <https://github.com/Undisclosed07/observability-carbon> — tu dois voir le README rendu, le Helm chart sous `charts/`, l'article et la lettre sous `docs/`.

## (Optionnel) Première release

Une fois pushé :

```powershell
git tag v0.1.0
git push --tags
```

Et active GitHub Actions dans Settings → Actions → General pour faire tourner le workflow CI.
