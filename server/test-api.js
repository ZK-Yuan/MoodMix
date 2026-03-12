/**
 * 火山引擎豆包 API 测试脚本
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

// 手动解析 .env 文件
function parseEnvFile(filePath) {
  const envContent = fs.readFileSync(filePath, 'utf-8');
  const env = {};
  envContent.split('\n').forEach(line => {
    const match = line.match(/^([A-Z_]+)=(.+)$/);
    if (match) {
      env[match[1]] = match[2].replace(/^["']|["']$/g, '');
    }
  });
  return env;
}

const envPath = path.resolve(__dirname, '..', '.env');
const env = parseEnvFile(envPath);

const API_KEY = env.VOLCENGINE_API_KEY || 'c361dd0b-231b-48e0-92c2-61061f1d042e';
const ENDPOINT = env.VOLCENGINE_ENDPOINT;
const API_URL = 'https://ark.cn-beijing.volces.com/api/v3/chat/completions';

console.log('=== 火山引擎豆包 API 测试 ===\n');
console.log('配置信息:');
console.log('  API URL:', API_URL);
console.log('  API Key:', API_KEY ? `${API_KEY.substring(0, 20)}...` : '❌ 未配置');
console.log('  Endpoint ID:', ENDPOINT || '❌ 未配置 (请在火山方舟控制台创建推理接入点)');
console.log('');

if (!API_KEY || API_KEY === 'your_key_here') {
  console.error('❌ 错误: VOLCENGINE_API_KEY 未配置');
  process.exit(1);
}

if (!ENDPOINT || ENDPOINT === 'your-endpoint-id-here') {
  console.error('❌ 错误: VOLCENGINE_ENDPOINT 未配置');
  console.log('\n如何获取 Endpoint ID:');
  console.log('  1. 登录 https://console.volcengine.com/ark/region:ark+cn-beijing/endpoint');
  console.log('  2. 点击「创建推理接入点」');
  console.log('  3. 选择豆包模型（如 doubao-pro-32k）');
  console.log('  4. 创建完成后，复制 Endpoint ID（格式如：ep-xxxxxxxxxx 或 doubao-xxxxxxxx）');
  console.log('  5. 将 Endpoint ID 填入 .env 文件的 VOLCENGINE_ENDPOINT');
  process.exit(1);
}

// 测试 API 调用
async function testAPI() {
  const testPrompt = '你好，请回复"火山引擎API测试成功"这几个字，不要添加其他内容。';
  
  console.log('正在发送测试请求...\n');
  
  const requestBody = JSON.stringify({
    model: ENDPOINT,
    messages: [
      { role: 'user', content: testPrompt }
    ],
    temperature: 0.5,
    max_tokens: 100
  });

  const options = {
    hostname: 'ark.cn-beijing.volces.com',
    port: 443,
    path: '/api/v3/chat/completions',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${API_KEY}`,
      'Content-Length': Buffer.byteLength(requestBody)
    }
  };

  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      
      console.log('响应状态:', res.statusCode, res.statusMessage);
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log('\n原始响应内容:');
        console.log(data);
        
        if (res.statusCode === 200) {
          try {
            const result = JSON.parse(data);
            const content = result.choices?.[0]?.message?.content;
            
            console.log('\n✅ API 测试成功!');
            console.log('\n模型回复:', content);
            console.log('\n响应信息:');
            console.log('  model:', result.model);
            console.log('  usage:', JSON.stringify(result.usage));
            resolve(result);
          } catch (e) {
            console.error('\n❌ 解析响应失败:', e.message);
            reject(e);
          }
        } else {
          console.error('\n❌ API 请求失败，状态码:', res.statusCode);
          try {
            const error = JSON.parse(data);
            console.error('错误详情:', JSON.stringify(error, null, 2));
          } catch {
            console.error('原始响应:', data);
          }
          reject(new Error(`HTTP ${res.statusCode}`));
        }
      });
    });

    req.on('error', (error) => {
      console.error('\n❌ 请求异常:', error.message);
      reject(error);
    });

    req.write(requestBody);
    req.end();
  });
}

testAPI().catch(() => process.exit(1));
