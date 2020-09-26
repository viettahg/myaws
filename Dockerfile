FROM nginx:1.15

COPY ./nginx_aws_demo/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./nginx_aws_demo/app /app
