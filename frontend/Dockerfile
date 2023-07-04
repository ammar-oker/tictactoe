FROM nginx:1.23-alpine-slim

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx/nginx.conf /etc/nginx/conf.d

COPY dist/ /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
