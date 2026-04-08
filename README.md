# InfraFlow - Test Technique DevOps (BOAZ-STUDY)

Ce projet déploie une architecture microservices sécurisée avec un pipeline CI/CD complet, un déploiement Kubernetes auto-scalable et un stack de monitoring (Prometheus/Grafana).
## 🛠 Prérequis

    - Docker & Docker Compose

    - Minikube (recommandé) ou un cluster Kubernetes local

    - kubectl, helm, envsubst (paquet gettext)

## ⚙️ Configuration

    Copiez le fichier d'exemple : 
```bash
    cp .env.example .env
```

    Ajustez les variables dans le .env (notamment votre PAT GitHub et le REGISTRY).

## 🚀 Démarrage Rapide
### 1. Test Local (Docker Compose)

    Idéal pour valider rapidement le fonctionnement des services.
    Bash

```bash
docker compose up -d
# Test de l'API
curl http://localhost:8081/get
```

### 2. Déploiement Kubernetes & Monitoring

    Une seule commande déploie toute l'infrastructure (Namespace, Secrets, Services, HPA et Stack Monitoring).
    Bash

```bash
# Lancement du cluster (si minikube)
minikube start

# Déploiement automatisé
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 📊 Monitoring & Observabilité

    Le stack Prometheus + Grafana est installé automatiquement dans le namespace monitoring.

Accès à Grafana

### 1. Lancez le tunnel pour accéder à l'interface :
```Bash
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring
```

### 2. Connectez-vous sur http://localhost:3000 :

    - User : admin

    - Password : (affiché à la fin du script deploy.sh) ou via :
```bash
    kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```

## Validation du Test

### 1. Dashboards : Importez l'ID 15760 et filtrez sur le namespace infraflow pour voir les métriques CPU/RAM.

### 2. Alerting : Une règle d'alerte PodDown est configurée par défaut dans k8s/monitoring/alerts.yml.