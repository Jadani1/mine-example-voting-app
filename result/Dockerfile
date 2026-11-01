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
# 1. Create a non-root system user and group for Alpine
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# 2. Change ownership of the application directory to the non-root user
RUN chown -R appuser:appuser /usr/src/app

# 3. Switch from root to the non-root user
USER appuser


ENV PORT=80
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
