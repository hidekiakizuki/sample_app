FROM nginx:1.23.4-alpine3.17-slim as production

RUN apk add --no-cache curl

RUN rm -f /etc/nginx/conf.d/*

RUN sed -i 's/\[$time_local\]/\[$time_iso8601\]/' /etc/nginx/nginx.conf

COPY nginx.conf /etc/nginx/conf.d/app_nginx.conf

ENV TZ=Asia/Tokyo
