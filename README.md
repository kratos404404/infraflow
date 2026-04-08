# InfraFlow - Test Technique DevOps (BOAZ-STUDY)

## Prérequis
- Docker + Docker Compose
- minikube (ou kind)
- kubectl
- helm

## Configuration a faire en local une fois les Prérequis Installé
- Demander le fichier .env au responsable

## Démarrage rapide

### Docker Compose
```bash
cp .env.example .env
docker compose up -d
curl http://localhost:8080/status
```


### Pour Kubernetes + Monitoring (Grafana)
```bash
minikube start
chmod +x scripts/deploy.sh
./scripts/deploy.sh

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace

kubectl port-forward svc/monitoring-grafana 3000:80 -n monitorings
```

#### Post Execution
- Apres ces execution de ces commandes vous allez pouvoir acceder au UI grafana via port 3000
- D'ou on va vous demander le login et le password. Le login est *admin* et pour avoir password vous devez executer cette commande :

```bash
kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
```
