FROM nginx:1.25-alpine

# Copie de la config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# On s'assure juste que l'utilisateur par défaut de l'image est non-root
USER 65534

# Healthcheck pour pointer sur le port 8080
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/status || exit 1

EXPOSE 8080