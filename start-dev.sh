#!/bin/bash

echo "🍹 启动 MoodMix 开发环境..."

# 清理旧进程
killall -9 node 2>/dev/null
sleep 1

# 启动后端
echo ""
echo "📡 启动后端服务 (端口 3001)..."
node server/llmProxy.js &
SERVER_PID=$!

# 等待后端启动
sleep 3

# 检查后端是否成功启动
if ! kill -0 $SERVER_PID 2>/dev/null; then
    echo "❌ 后端启动失败"
    exit 1
fi

echo "✅ 后端已启动 (PID: $SERVER_PID)"

# 启动前端
echo ""
echo "🎨 启动前端服务 (端口 3000)..."
echo "   (首次启动可能需要 30-60 秒编译...)"
echo ""

# 使用 npx 直接运行，避免 npm 脚本问题
BROWSER=none npx react-scripts start &
FRONTEND_PID=$!

# 等待前端编译
echo "⏳ 等待前端编译完成..."
for i in {1..30}; do
    sleep 2
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000 2>/dev/null)
    if [ "$STATUS" = "200" ] || [ "$STATUS" = "000" ]; then
        echo ""
        echo "✅ 前端已启动 (PID: $FRONTEND_PID)"
        break
    fi
    echo -n "."
done

echo ""
echo "═══════════════════════════════════════"
echo "🎉 MoodMix 已启动！"
echo "═══════════════════════════════════════"
echo ""
echo "   访问地址: http://localhost:3000"
echo ""
echo "   后端日志: tail -f server.log"
echo ""
echo "   按 Ctrl+C 停止服务"
echo "═══════════════════════════════════════"

# 捕获退出信号
trap "echo ''; echo '🛑 正在停止服务...'; kill $SERVER_PID $FRONTEND_PID 2>/dev/null; exit" INT

# 保持运行
wait
