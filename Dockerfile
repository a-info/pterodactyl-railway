FROM ghcr.io/pterodactyl/panel:latest

LABEL maintainer="a-info"
LABEL description="Pterodactyl Panel All-in-One Template with Embedded MariaDB & Redis for Railway"

# Install MariaDB and Redis inside container for standalone cloud hosting
USER root
RUN apk add --no-cache mariadb mariadb-client redis netcat-openbsd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV APP_ENV="production"
ENV APP_ENVIRONMENT_ONLY="false"
ENV APP_URL="https://host.onlinevbs.dpdns.org"
ENV APP_TIMEZONE="UTC"
ENV DB_HOST="127.0.0.1"
ENV DB_PORT="3306"
ENV DB_DATABASE="panel"
ENV DB_USERNAME="pterodactyl"
ENV DB_PASSWORD="PteroSecretPass123!"
ENV CACHE_DRIVER="redis"
ENV SESSION_DRIVER="redis"
ENV QUEUE_CONNECTION="redis"
ENV REDIS_HOST="127.0.0.1"
ENV REDIS_PORT="6379"

ENTRYPOINT ["/bin/ash", "/entrypoint.sh"]
