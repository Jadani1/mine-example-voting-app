FROM node:18-slim

# add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon

COPY package*.json ./

RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

COPY . .

# 1. Create a non-root system user and group (Debian/slim uses groupadd/useradd)
RUN groupadd -r appuser && useradd -r -g appuser appuser

# 2. Change ownership of app dirs to the non-root user
RUN chown -R appuser:appuser /usr/local/app /node_modules

# 3. Switch from root to the non-root user
USER appuser

# Non-root cannot bind privileged ports (<1024); use 8080 inside the container
ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
