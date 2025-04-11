#!/bin/ash

# -----------------------------------------------------------------------------
# This file is part of the Shalmaka project.
#
# Copyright (c) 2025 Shalmaka
#
# This source code is licensed under the MIT License.
# See the LICENSE file in the root directory of this project for details.
# -----------------------------------------------------------------------------


set -euo pipefail

# Default to port 80 if neither HTTP nor HTTPS is defined
if [ -z "${INTERFACE_HTTP_PORT:-}" ] && [ -z "${INTERFACE_HTTPS_PORT:-}" ]; then
  INTERFACE_HTTP_PORT=80
  echo "No HTTP or HTTPS port specified. Defaulting to INTERFACE_HTTP_PORT=80"
fi

# Required variable
REQUIRED_VARS="SERVER_NAME"

# If HTTPS is enabled, require cert info
if [ -n "${INTERFACE_HTTPS_PORT:-}" ]; then
  REQUIRED_VARS="$REQUIRED_VARS CERT_FILENAME KEY_FILENAME"
fi

# Validate required variables
for var in $REQUIRED_VARS; do
  eval "value=\$$var"
  if [ -z "$value" ]; then
    echo "Error: Environment variable '$var' is not defined"
    exit 1
  fi
done

# Build listen directives
HTTP_LISTEN_DIRECTIVE=""
HTTPS_LISTEN_DIRECTIVE=""
SSL_CONFIG_DIRECTIVE=""

if [ -n "${INTERFACE_HTTP_PORT:-}" ]; then
  HTTP_LISTEN_DIRECTIVE="listen ${INTERFACE_HTTP_PORT};"
fi

if [ -n "${INTERFACE_HTTPS_PORT:-}" ]; then
  HTTPS_LISTEN_DIRECTIVE="listen ${INTERFACE_HTTPS_PORT} ssl;"
  SSL_CONFIG_DIRECTIVE="
    ssl_certificate       /usr/share/nginx/certs/${CERT_FILENAME};
    ssl_certificate_key   /usr/share/nginx/certs/${KEY_FILENAME};
    ssl_protocols         TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ecdh_curve        secp521r1:secp384r1:prime256v1;
    ssl_session_tickets   off;
    ssl_session_cache     none;
    ssl_buffer_size       4k;"
fi

# Export for envsubst
export HTTP_LISTEN_DIRECTIVE HTTPS_LISTEN_DIRECTIVE SSL_CONFIG_DIRECTIVE SERVER_NAME

# Generate NGINX server config
envsubst '${HTTP_LISTEN_DIRECTIVE} ${HTTPS_LISTEN_DIRECTIVE} ${SSL_CONFIG_DIRECTIVE} ${SERVER_NAME}' \
  < /etc/nginx/nginx.template > /etc/nginx/conf.d/server.conf

# Start NGINX
exec nginx -g 'daemon off;'
