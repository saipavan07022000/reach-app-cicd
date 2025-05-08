FROM node:18-alpine as build

WORKDIR /app

# First copy only package files for better caching
COPY package.json package-lock.json ./
RUN npm install

# Then copy all source files
COPY public/ ./public/
COPY src/ ./src/

# Build the application
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]