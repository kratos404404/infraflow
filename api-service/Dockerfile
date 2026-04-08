FROM python:3.10-slim-bookworm

# 1. Installation de curl et dépendances (Consolidé pour Hadolint)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl=7.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir \
    gevent==23.9.1 \
    PyYAML==6.0.1 \
    httpbin==0.10.2 \
    gunicorn==21.2.0 \
    && useradd -u 1001 -m infrauser

USER 1001
# On définit le répertoire de travail pour éviter des soucis de chemins
WORKDIR /home/infrauser

EXPOSE 8080

# 3. Healthcheck : On pointe sur /get qui est une route standard de httpbin
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://127.0.0.1:8080/get || exit 1

# 4. Commande de lancement : On utilise explicitement le module httpbin:app
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "httpbin:app", "--worker-class", "gevent", "--workers", "2"]