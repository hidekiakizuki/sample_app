FROM nginx:1.23.4-alpine3.17-slim

RUN rm -f /etc/nginx/conf.d/*

COPY nginx.conf /etc/nginx/conf.d/app_nginx.conf

ENV TZ=Asia/Tokyo
