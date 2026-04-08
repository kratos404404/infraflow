#!/usr/bin/env bash
set -euo pipefail

# Chargement des variables d'environnement depuis .env
load_environment() {
    local env_file=".env"
    if [[ ! -f $env_file ]]; then
        echo "❌ $env_file introuvable. Copiez .env.example vers .env et ajustez les valeurs."
        exit 1
    fi

    set -o allexport
    # shellcheck source=/dev/null
    source "$env_file"
    set +o allexport

    if [[ -z "${REGISTRY:-}" || -z "${TAG:-}" ]]; then
        echo "❌ REGISTRY ou TAG non défini(e)s dans $env_file"
        exit 1
    fi
}

# Vérifie le CLI minimum nécessaire pour déployer.
check_prerequisites() {
    command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl manquant"; exit 1; }
    command -v helm >/dev/null 2>&1 || { echo "❌ helm manquant"; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo "❌ docker manquant"; exit 1; }
    command -v envsubst >/dev/null 2>&1 || { echo "❌ envsubst manquant (install gettext-base)"; exit 1; }
    echo "✅ Tous les prérequis OK"
}

render_manifests() {
    echo "📄 Application des manifestes Kubernetes..."
    local template_dir="k8s"
    # On évite d'appliquer les fichiers de monitoring via envsubst s'ils n'en ont pas besoin
    find "$template_dir" -type f -name '*.yml' -not -path "*/monitoring/*" -print0 | while IFS= read -r -d '' manifest; do
        envsubst "\${REGISTRY} \${TAG}" < "$manifest" | kubectl apply -f -
    done
}

deploy_monitoring() {
    echo "📊 Installation du stack de monitoring (Helm)..."
    # [cite: 75, 76]
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Installation silencieuse avec timeout pour respecter les 5 mins 
    helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
      --namespace monitoring --create-namespace \
      --wait --timeout 300s

    # Application de ton alerte personnalisée [cite: 79]
    if [[ -f "k8s/monitoring/alerts.yml" ]]; then
        echo "🔔 Configuration des alertes Prometheus..."
        kubectl apply -f k8s/monitoring/alerts.yml
    fi
}

deploy_services() {
    echo "🚀 Préparation du namespace infraflow..."
    kubectl create namespace infraflow --dry-run=client -o yaml | kubectl apply -f -
    
    kubectl create secret docker-registry ghcr-secret \
      --docker-server=ghcr.io \
      --docker-username="${REPO_OWNER}" \
      --docker-password="${PAT}" \
      -n infraflow --dry-run=client -o yaml | kubectl apply -f -

    deploy_monitoring
    render_manifests
}

# Posibilite de modifier le timeout en cas de besoin, surtout si les images sont lourdes ou si la machine est lente.
wait_for_pods() {
    echo "⏳ Attente des pods Ready..."
    kubectl rollout status deployment/api-service -n infraflow --timeout=120s
    kubectl rollout status deployment/web-service -n infraflow --timeout=120s
}

show_urls() {
    echo "🎉 Déploiement terminé !"
    echo "🌐 Web-service : $(minikube service web-service -n infraflow --url 2>/dev/null || echo 'kubectl port-forward svc/web-service 80:80 -n infraflow')"
    echo "📊 Grafana      : kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring"
    echo "🔑 Password Grafana : admin / $(kubectl get secret --namespace monitoring monitoring-grafana -o jsonpath='{.data.admin-password}' | base64 --decode)"
}

main() {
    load_environment
    check_prerequisites
    deploy_services
    wait_for_pods
    show_urls
}

main "$@"
