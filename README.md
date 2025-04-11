# 🔐 NGINX Web Server (Secure Docker Image)

This project provides a lightweight, production-hardened NGINX image for serving static content in standalone Docker environments. It emphasizes **security, immutability, and clean configuration**, without relying on Kubernetes.

## ⚙️ Features

- Static web server with optional HTTPS support  
- Security-first design: `read-only`, `cap_drop`, `tmpfs`  
- Dynamic server configuration via `entrypoint.sh`  
- Environment variable-based configuration  
- Built-in healthcheck with HTTP/HTTPS fallback  
- Runs as non-root (`nginx` user)  
- Modular-friendly (external volumes/networks)  

---

## 🧱 Project Structure

<pre>
web/
├── .env.base                # Example base environment file
├── docker-compose.yml       # Main Compose file
├── docker-compose.override.yml # Optional local override
├── Dockerfile               # Builds the hardened NGINX image
├── entrypoint.sh            # Generates server config at runtime
├── nginx.base.conf          # Base (global) NGINX configuration
├── nginx.template.conf      # Server block template
└── README.md                # You're here
</pre>

---

## 🚀 Getting Started

<pre>
1. Copy .env.base to .env and configure your environment variables.
2. Ensure that external volumes and networks are defined elsewhere (modular setup).
3. Start the container:

   docker compose up -d
</pre>

---

## 🛠️ Environment Variables

These are loaded from `.env` and injected into your template during container startup.

| Variable               | Description                                               |
|------------------------|-----------------------------------------------------------|
| `SERVER_NAME`          | Domain used in the `server_name` directive                |
| `INTERFACE_HTTP_PORT`  | Internal HTTP port (defaults to `80` if none specified)   |
| `INTERFACE_HTTPS_PORT` | Internal HTTPS port (optional)                            |
| `CERT_FILENAME`        | TLS certificate file (inside `/www/certs`)                |
| `KEY_FILENAME`         | TLS private key file (inside `/www/certs`)                |

> ℹ️ If neither port is defined, `INTERFACE_HTTP_PORT=80` will be used by default.

---

## 🩺 Healthcheck (Recommended)

<pre>
healthcheck:
  test: >
    CMD-SHELL
    (curl -fs http://localhost/ || curl -kfs https://localhost/) || exit 1
  interval: 30s
  timeout: 5s
  retries: 3
  start_period: 10s
</pre>

---

## 🔐 Security Hardened

- Runs as `nginx` (non-root)  
- Filesystem set to read-only (`read_only: true`)  
- Minimal privileges (`cap_drop: ALL`, `cap_add: NET_BIND_SERVICE`)  
- `no-new-privileges: true` to block privilege escalation  
- Uses `tmpfs` for cache, logs, PID, and config generation  

---

## 📄 License

This project is open source and licensed under the <a href="LICENSE">MIT License</a>.
