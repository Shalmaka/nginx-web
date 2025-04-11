# -----------------------------------------------------------------------------
# This file is part of the Shalmaka project.
#
# Copyright (c) 2025 Shalmaka
#
# This source code is licensed under the MIT License.
# See the LICENSE file in the root directory of this project for details.
# -----------------------------------------------------------------------------
FROM nginx:1.27.4-alpine-slim

# Install required packages (minimal)
RUN apk add --no-cache curl && apk upgrade --no-cache

# Remove default HTML files
RUN rm -rf /usr/share/nginx/html/*

# Copy entrypoint and set correct permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh && \
    chown nginx:nginx /entrypoint.sh

# Copy base and template NGINX configs
COPY nginx.base.conf /etc/nginx/nginx.conf
COPY nginx.template.conf /etc/nginx/nginx.template

# Leave /usr/share/nginx/html owned by nginx, but writeable externally via volume
RUN mkdir -p /usr/share/nginx/html && \
    chown -R nginx:nginx /usr/share/nginx/html

# Prepare log files and ownership
RUN touch /var/log/nginx/error.log && \
    touch /var/log/nginx/access.log && \
    chown -R nginx:nginx /var/log/nginx/

# Prepare NGINX runtime dirs and certs
RUN mkdir -p /var/cache/nginx /usr/share/nginx/certs && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx.pid /etc/nginx /usr/share/nginx/certs

# Set user (non-root)
USER nginx

# Entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]
