# InfraFlow - Test Technique DevOps / SRE (BOAZ-STUDY)

## Prérequis
- Docker + Docker Compose
- minikube (ou kind)
- kubectl
- helm

## Démarrage rapide

### Docker Compose
```bash
cp .env.example .env
docker compose up -d
curl http://localhost:8080/status


## Pour Kubernetes + Monitoring (Grafana)

minikube start
chmod +x scripts/deploy.sh
./scripts/deploy.sh

# Monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

kubectl port-forward svc/monitoring-grafana 3000:80 -n monitorings