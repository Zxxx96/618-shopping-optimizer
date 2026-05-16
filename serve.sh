#!/bin/bash
# 618 Shopping Optimizer - Web Server Launcher
# Starts the Hermes API server + serves the web frontend

set -e

PORT="${PORT:-8080}"
API_PORT="${API_PORT:-8642}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_FILE="$SCRIPT_DIR/web/index.html"

echo "========================================"
echo "  618 购物助手 Web 版"
echo "========================================"
echo ""
echo "  网页地址:  http://$(hostname -s 2>/dev/null || echo 'localhost'):$PORT"
echo "  API 端口:  $API_PORT"
echo ""
echo "  手机打开上面的地址就能用"
echo "  按 Ctrl+C 停止"
echo ""
echo "  启动 API 服务器..."
echo ""

# Check if gateway is already running
if curl -s http://localhost:$API_PORT/health > /dev/null 2>&1; then
  echo "  ✓ API 服务器已在运行 (端口 $API_PORT)"
else
  echo "  ⚠ API 服务器未运行，请先启动 Hermes gateway:"
  echo "    hermes gateway run"
  exit 1
fi

echo ""
echo "  启动网页服务..."
echo ""

# Serve the HTML file
cd "$SCRIPT_DIR/web"
python3 -m http.server $PORT --bind 0.0.0.0 2>/dev/null &
WEB_PID=$!

echo "  ✓ 全部就绪"
echo ""
echo "  手机 / 电脑浏览器打开:"
echo "  http://$(ipconfig getifaddr en0 2>/dev/null || echo 'YOUR_IP'):$PORT"
echo ""

# Cleanup on exit
cleanup() {
  echo ""
  echo "正在停止网页服务..."
  kill $WEB_PID 2>/dev/null || true
  echo "已停止"
}
trap cleanup EXIT INT TERM

# Wait for web server
wait $WEB_PID 2>/dev/null
