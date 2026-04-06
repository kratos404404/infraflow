FROM kennethreitz/httpbin:latest
USER nobody
HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/get || exit 1
EXPOSE 80