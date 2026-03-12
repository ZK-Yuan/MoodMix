#!/bin/bash

echo "🔍 诊断 MoodMix 服务状态..."
echo ""

echo "1. 检查端口占用情况："
echo "   端口 3000 (前端):"
lsof -ti:3000 | xargs -I {} ps -p {} -o comm= 2>/dev/null && echo "      ✅ 已运行" || echo "      ❌ 未运行"

echo ""
echo "   端口 3001 (后端):"
lsof -ti:3001 | xargs -I {} ps -p {} -o comm= 2>/dev/null && echo "      ✅ 已运行" || echo "      ❌ 未运行"

echo ""
echo "2. 测试后端 API："
curl -s --max-time 5 http://localhost:3001/api/analyze_mood -X POST \
  -H "Content-Type: application/json" \
  -d '{"user_input":"test"}' | head -c 100
echo ""

echo ""
echo "3. 检查前端构建文件："
if [ -f "build/index.html" ]; then
    echo "   ✅ build/index.html 存在"
else
    echo "   ⚠️  build/index.html 不存在（需要运行 npm run build）"
fi

echo ""
echo "4. 检查依赖："
if [ -d "node_modules/react-scripts" ]; then
    echo "   ✅ react-scripts 已安装"
else
    echo "   ❌ react-scripts 未安装（需要运行 npm install）"
fi

echo ""
echo "5. 最近的错误日志："
tail -5 server.log 2>/dev/null || echo "   无日志文件"
