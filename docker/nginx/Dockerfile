FROM nginx:1.23.4-alpine3.17-slim

RUN rm -f /etc/nginx/conf.d/*

COPY nginx.conf /etc/nginx/conf.d/sample_app_nginx.conf

#CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf