FROM python:3.10-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl=7.* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installation de httpbin et des versions corrigées des dépendances
# On force les versions pour corriger CVE-2020-14343 et CVE-2023-41419
RUN pip install --no-cache-dir \
    gevent==23.9.1 \
    PyYAML==6.0.1 \
    httpbin==0.10.2 \
    gunicorn==21.2.0

RUN useradd -u 1001 -m infrauser
USER 1001

EXPOSE 8080

# 3. Healthcheck robuste utilisant curl
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/get || exit 1

# Lancement avec Gunicorn (plus stable pour la prod)
CMD ["gunicorn", "-b", "0.0.0.0:80", "httpbin:app", "--worker-class", "gevent"]