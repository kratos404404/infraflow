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
    local template_dir="k8s"
    while IFS= read -r -d '' manifest; do
        envsubst '${REGISTRY} ${TAG}' < "$manifest" | kubectl apply -f -
    done < <(find "$template_dir" -type f -name '*.yml' -print0)
}

deploy_services() {
    echo "🚀 Création du namespace infraflow..."
    kubectl create namespace infraflow --dry-run=client -o yaml | kubectl apply -f -
    
    # Ajout automatique du secret (si les variables sont dans ton .env)
    kubectl create secret docker-registry ghcr-secret \
      --docker-server=ghcr.io \
      --docker-username="${REPO_OWNER}" \
      --docker-password="${PAT}" \
      -n infraflow --dry-run=client -o yaml | kubectl apply -f -

    echo "🚀 Déploiement des manifestes..."
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
    echo "🌐 Web-service : $(minikube service web-service -n infraflow --url 2>/dev/null || echo 'utilise kubectl port-forward')"
    echo "📊 Grafana : http://localhost:3000"
}

main() {
    load_environment
    check_prerequisites
    deploy_services
    wait_for_pods
    show_urls
}

main "$@"
