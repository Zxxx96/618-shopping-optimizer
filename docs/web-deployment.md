# 618 Shopping Optimizer - Web 部署备忘

## 架构

```
手机浏览器 (http://IP:8080)
     │
     ├─ GET index.html  ←  python3 -m http.server 8080
     │
     └─ POST /v1/chat/completions  →  Hermes Gateway (PID, 端口 8642)
            │
            └─ 调用 AIAagent.chat() → 加载 618-shopping-optimizer skill → 返回方案
```

## 服务分工

| 服务 | 启动方式 | 端口 | 作用 |
|------|---------|------|------|
| Hermes Gateway | `hermes gateway run`（常驻） | 8642 | API 服务器，处理凑单计算 |
| 网页服务 | `python3 -m http.server 8080` | 8080 | 提供静态网页 |

**关键认知：** Gateway 已经托管了 API 服务器（通过 `config.yaml` 中的 `platforms.api_server` 配置），不需要额外命令。网页服务是独立的，可以随时重启。

## 启动命令

```bash
# 完整启动（一键）
bash ~/.hermes/skills/productivity/618-shopping-optimizer/serve.sh

# 或者手动：
# 1. 确认 gateway 在运行
curl http://localhost:8642/health
# 2. 启动网页
cd ~/.hermes/skills/productivity/618-shopping-optimizer/web
python3 -m http.server 8080 --bind 0.0.0.0 &
```

## 网络配置

**内网访问：** 手机连同一 WiFi，浏览器打开 `http://<本机IP>:8080`

**获取本机 IP：**
```bash
ipconfig getifaddr en0
```

**公网访问：**
```bash
brew install cloudflared
cloudflared tunnel --url http://localhost:8080
```
会生成 `https://xxx.trycloudflare.com` 地址。

## config.yaml 要求

```yaml
platforms:
  api_server:
    enabled: true
    extra:
      host: 0.0.0.0
      port: 8642
      cors_origins: "*"
```

## 常见问题

### 手机显示"未连接"
网页服务挂了，Gateway 还在。重启网页：
```bash
cd ~/.hermes/skills/productivity/618-shopping-optimizer/web
python3 -m http.server 8080 --bind 0.0.0.0 &
```

### 两个服务都挂了
先确认 gateway：`hermes gateway status`，如果没跑就 `hermes gateway run &`，再启动网页。

### 手机连不上但电脑可以
手机和电脑不在同一 WiFi，或者 macOS 防火墙拦截了。检查：系统设置 → 网络 → 防火墙。
