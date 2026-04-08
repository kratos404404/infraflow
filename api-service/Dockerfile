FROM kong/httpbin:0.1.0
# On repasse sur l'utilisateur nobody (UID 65534) pour la sécurité
USER 65534

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD python3 -m httpbin.core get || exit 1

EXPOSE 80