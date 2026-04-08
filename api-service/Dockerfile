FROM kennethreitz/httpbin:latest
USER root
RUN apt-get update \
    && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*
USER nobody
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/get || exit 1
EXPOSE 80
