# Build stage for Vite-powered React app
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm ci

COPY . .

# Accept API URL from docker-compose / GitHub Actions
ARG VITE_API_URL
ENV VITE_API_URL=$VITE_API_URL

RUN npm run build

# Production stage: Serve static files with nginx
FROM nginx:stable-alpine
COPY --from=build /app/dist /usr/share/nginx/html

# SPA-reitityksen korjaus: Korvataan Nginxin oletus 404-virhe ohjaamalla index.html:ään
RUN sed -i 's/try_files $uri $uri\/ =404;/try_files $uri $uri\/ \/index.html;/g' /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]