#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "Building Flutter web..."
flutter build web

echo "Starting server on port 8080..."
kill $(lsof -ti :8080) 2>/dev/null || true
npx serve build/web -p 8080 &>/tmp/serve.log &
disown

sleep 2

echo "Starting Cloudflare tunnel..."
kill $(lsof -ti :20241) 2>/dev/null || true
/home/user/.local/bin/cloudflared tunnel --url http://localhost:8080 &>/tmp/cloudflared.log &
disown

sleep 5

URL=$(grep -oP 'https://[a-z-]+\.trycloudflare\.com' /tmp/cloudflared.log | head -1)

echo ""
echo "  ┌─────────────────────────────────────────────┐"
echo "  │  App running at:                            │"
echo "  │  http://localhost:8080                      │"
echo "  │                                             │"
echo "  │  Tunnel URL:                                │"
echo "  │  $URL │"
echo "  └─────────────────────────────────────────────┘"
echo ""
