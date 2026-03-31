#!/bin/sh
mkdir -p /paperclip/instances/default/logs /paperclip/instances/default/secrets
chown -R node:node /paperclip

rm -f /paperclip/instances/default/config.json

HOST_DOMAIN=$(echo "$PAPERCLIP_BASE_URL" | sed 's|https://||' | sed 's|http://||' | sed 's|/.*||')

cat > /paperclip/instances/default/config.json << CFGEOF
{
  "\$meta": {
    "version": 1,
    "instanceId": "default",
    "updatedAt": "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)",
    "source": "configure"
  },
  "server": {
    "host": "0.0.0.0",
    "port": 3100,
    "deploymentMode": "authenticated",
    "deploymentExposure": "public",
    "baseUrl": "${PAPERCLIP_BASE_URL}",
    "allowedHosts": ["${HOST_DOMAIN}", "localhost"],
    "authUrlMode": "explicit"
  },
  "auth": {
    "baseUrlMode": "explicit",
    "publicBaseUrl": "${PAPERCLIP_BASE_URL}"
  },
  "database": {
    "type": "external"
  },
  "storage": {
    "type": "local_disk"
  },
  "secrets": {
    "type": "local_encrypted",
    "strictMode": false
  },
  "logging": {
    "type": "file",
    "mode": "file"
  }
}
CFGEOF
chown node:node /paperclip/instances/default/config.json

echo "=== Cloning agent instructions ==="
if [ -d /paperclip/agent-instructions/.git ]; then
  cd /paperclip/agent-instructions && git pull --ff-only 2>&1 || true
  cd /app
else
  git clone --depth 1 https://github.com/GTMify/gtmify-config.git /paperclip/agent-instructions 2>&1 || echo "WARN: Failed to clone agent instructions"
fi
chown -R node:node /paperclip/agent-instructions 2>/dev/null || true

echo "=== Config ==="
cat /paperclip/instances/default/config.json
echo "=== Starting ==="

# Start server in background, bootstrap CEO, then bring to foreground
su -s /bin/sh node -c "node --import ./server/node_modules/tsx/dist/loader.mjs server/src/index.ts" &
SERVER_PID=$!

# Wait for server to be ready, then bootstrap CEO invite
sleep 15
echo "=== Bootstrapping CEO ==="
su -s /bin/sh node -c "cd /app && node --import ./server/node_modules/tsx/dist/loader.mjs cli/src/index.ts auth bootstrap-ceo --base-url ${PAPERCLIP_BASE_URL} --force" 2>&1 || true

# Keep server running
wait $SERVER_PID
