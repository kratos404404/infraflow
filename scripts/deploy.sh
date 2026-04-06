#!/usr/bin/env bash
set -euo pipefail

# Script de déploiement pour InfraFlow
# On verife les prérequis, on déploie les services, on attend qu\'ils soient prêts, puis on affiche les URLs d\'accès.
check_prerequisites() {
    command -v kubectl >/dev/null 2>&1 || { echo "❌ kubectl manquant"; exit 1; }
    command -v helm >/dev/null 2>&1 || { echo "❌ helm manquant"; exit 1; }
    command -v docker >/dev/null 2>&1 || { echo "❌ docker manquant"; exit 1; }
    echo "✅ Tous les prérequis OK"
}

deploy_services() {
    echo "🚀 Création du namespace infraflow..."
    kubectl create namespace infraflow --dry-run=client -o yaml | kubectl apply -f -
    echo "🚀 Déploiement des manifestes..."
    kubectl apply -f k8s/
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
    check_prerequisites
    deploy_services
    wait_for_pods
    show_urls
}

main "$@"