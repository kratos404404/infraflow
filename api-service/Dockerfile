FROM kennethreitz/httpbin:test

USER root

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl=7.58.0-2ubuntu3.24 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# On repasse sur l'utilisateur nobody (UID 65534) pour la sécurité
USER 65534
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/get || exit 1

EXPOSE 80