#!/bin/bash

# MoodMix 启动脚本

echo "🍹 启动 MoodMix..."

# 清理旧进程
echo "1. 清理旧进程..."
kill -9 $(lsof -ti:3001) 2>/dev/null
kill -9 $(lsof -ti:3000) 2>/dev/null
sleep 1

# 检查 node_modules
if [ ! -d "node_modules/react-scripts" ]; then
    echo "❌ 依赖缺失，正在安装..."
    npm install --legacy-peer-deps --ignore-scripts
fi

# 启动后端
echo "2. 启动后端服务 (端口 3001)..."
node server/llmProxy.js &
SERVER_PID=$!
sleep 2

# 启动前端
echo "3. 启动前端服务 (端口 3000)..."
BROWSER=none npx react-scripts start &
FRONTEND_PID=$!

# 等待启动
sleep 5

echo ""
echo "✅ 服务已启动！"
echo "   前端: http://localhost:3000"
echo "   后端: http://localhost:3001"
echo ""
echo "按 Ctrl+C 停止所有服务"

# 捕获退出信号
trap "kill $SERVER_PID $FRONTEND_PID 2>/dev/null; exit" INT

# 保持运行
wait
