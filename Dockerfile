FROM ghcr.io/pterodactyl/panel:latest

LABEL maintainer="a-info"
LABEL description="Pterodactyl Panel Optimized One-Click Template for Railway"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV APP_ENV="production"
ENV APP_ENVIRONMENT_ONLY="false"
ENV APP_URL="https://host.onlinevbs.dpdns.org"
ENV APP_TIMEZONE="UTC"
ENV CACHE_DRIVER="redis"
ENV SESSION_DRIVER="redis"
ENV QUEUE_CONNECTION="redis"

ENTRYPOINT ["/bin/ash", "/entrypoint.sh"]
