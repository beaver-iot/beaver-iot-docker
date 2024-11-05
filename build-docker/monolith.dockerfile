ARG DOCKER_REPO=beaver-iot
ARG BASE_SERVER_IMAGE=beaver-iot/server
ARG BASE_WEB_IMAGE=beaver-iot/web

FROM ${BASE_WEB_IMAGE} AS web

FROM ${BASE_SERVER_IMAGE} AS monolith
COPY --from=web /web /web
RUN apk add --no-cache nginx nginx-mod-http-headers-more
COPY nginx/main.conf /etc/nginx/nginx.conf
COPY nginx/http-server.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/bin/sh", "-c", "$(nohup nginx -g 'daemon off;' 2>&1 >/dev/null &) && java -Dloader.path=${HOME}/beaver-iot/plugins ${JAVA_OPTS} -jar /application.jar ${SPRING_OPTS}"]
