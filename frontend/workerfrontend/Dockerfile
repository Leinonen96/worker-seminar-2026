# Build stage for Vite-powered React app
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .

ARG VITE_API_URL
ARG VITE_AUTH_DOMAIN
ARG VITE_AUTH_CLIENT_ID
ARG VITE_AUTH_AUDIENCE
ARG VITE_GOOGLE_MAPS_API_KEY
ARG VITE_DISABLE_AUTH0

ENV VITE_API_URL=$VITE_API_URL
ENV VITE_AUTH_DOMAIN=$VITE_AUTH_DOMAIN
ENV VITE_AUTH_CLIENT_ID=$VITE_AUTH_CLIENT_ID
ENV VITE_AUTH_AUDIENCE=$VITE_AUTH_AUDIENCE
ENV VITE_GOOGLE_MAPS_API_KEY=$VITE_GOOGLE_MAPS_API_KEY
ENV VITE_DISABLE_AUTH0=$VITE_DISABLE_AUTH0

RUN npm run build

# Production stage: Serve static files with nginx
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html

# Korvataan sed-komento kunnollisella Nginx-konfiguraatiolla
# Tämä hoitaa SPA-reitityksen JA ohjaa /api-kutsut backend-kontille
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://worker-backend:8080; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]