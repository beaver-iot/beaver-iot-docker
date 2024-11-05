FROM node:20.18.0-alpine3.20 AS web-builder

ARG WEB_GIT_REPO_URL
ARG WEB_GIT_BRANCH

VOLUME /beaver-iot-web

WORKDIR /
RUN apk add --no-cache git && git clone ${WEB_GIT_REPO_URL} beaver-iot-web

WORKDIR /beaver-iot-web
RUN git checkout ${WEB_GIT_BRANCH} && npm install -g pnpm && pnpm install && pnpm build


FROM alpine:3.20 AS web
COPY --from=web-builder /beaver-iot-web/apps/web/dist /web
RUN apk add --no-cache nginx nginx-mod-http-headers-more
COPY nginx/main.conf /etc/nginx/nginx.conf
COPY nginx/http-server.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

# Create folder for PID file
RUN mkdir -p /run/nginx

COPY docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
