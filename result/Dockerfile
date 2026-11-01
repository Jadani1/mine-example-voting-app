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

# Create a non-root system user and group (Debian/slim syntax)
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -r -g appgroup -s /sbin/nologin appuser

# Own app files and the moved node_modules tree
RUN chown -R appuser:appgroup /usr/local/app /node_modules

USER appuser

ENV PORT=80
EXPOSE 80

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
