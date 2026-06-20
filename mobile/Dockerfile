FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
RUN flutter pub get
ARG API_BASE_URL=https://legalizaciones-api-production.up.railway.app/api
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
COPY <<EOF /etc/nginx/templates/default.conf.template
server {
  listen ${PORT};
  server_name _;
  root /usr/share/nginx/html;
  index index.html;
  location / { try_files \$uri \$uri/ /index.html; }
}
EOF
ENV PORT=8080
EXPOSE 8080
CMD ["/docker-entrypoint.sh", "nginx", "-g", "daemon off;"]
