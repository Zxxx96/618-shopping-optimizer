# 🛒 618 Shopping Optimizer (618 购物凑单助手)

> AI-powered shopping optimizer for Chinese e-commerce mega-sales (618, Double 11, Double 12).
> Know what you want to buy? Let AI crunch the numbers and find the optimal combination to maximize your discounts.

[中文说明](#中文说明) | [Quick Start](#quick-start) | [How It Works](#how-it-works) | [Deploy](#deploy)

---

## What is this?

During China's mega shopping festivals (618 in June, Singles' Day 11/11), platforms like Taobao, JD.com, Pinduoduo, and Douyin run complex tiered-discount promotions (e.g., "every ¥300 you spend, save ¥50"). Manually splitting your cart into optimal orders is tedious and error-prone. This tool does it for you.

### Three core scenarios

| Scenario | What it does |
|----------|-------------|
| **Gap-filling** (补差凑单) | You're ¥11 short of the next ¥300 threshold. Should you add a filler item? The tool calculates exactly how much the filler actually costs you after the extra discount. |
| **Order splitting** (分单优化) | You have 8 items across one platform. What's the optimal way to split them into separate orders to hit exactly the right thresholds? |
| **Cross-store stacking** (跨店满减) | Items spread across different stores on the same platform. How do you stack cross-store discounts + store-specific coupons for maximum savings? |

### Platform support

- **Taobao / Tmall** (淘宝/天猫) — cross-store tiered discount, 88VIP
- **JD.com** (京东) — cross-store tiered discount, PLUS membership
- **Pinduoduo** (拼多多) — direct discounts, group-buy
- **Douyin Shop** (抖音商城) — live-stream discounts

---

## Quick Start

### Install

```bash
# Clone the repo
git clone https://github.com/Zxxx96/618-shopping-optimizer.git
cd 618-shopping-optimizer
```

### Option 1: Use as a Hermes Agent skill (local)

Copy the skill to your Hermes skills directory:

```bash
# Copy the skill
cp SKILL.md ~/.hermes/skills/productivity/618-shopping-optimizer/
cp -r web ~/.hermes/skills/productivity/618-shopping-optimizer/
cp serve.sh ~/.hermes/skills/productivity/618-shopping-optimizer/
mkdir -p ~/.hermes/skills/productivity/618-shopping-optimizer/docs
cp docs/web-deployment.md ~/.hermes/skills/productivity/618-shopping-optimizer/docs/
```

Then in Hermes CLI, just say:

```
我想买一双鞋 459 和一件外套 389，都在淘宝，帮我算 618 怎么买最划算
```

### Option 2: Run the web version (share with others)

Requires [Hermes Agent](https://github.com/nousresearch/hermes-agent) with Gateway running.

```bash
# Start the web server
bash serve.sh
```

Then open `http://localhost:8080` on your phone or computer.

**Share on LAN:** Others on the same WiFi can open `http://<YOUR_IP>:8080`.

**Share publicly:** Use Cloudflare Tunnel (free):

```bash
brew install cloudflared
cloudflared tunnel --url http://localhost:8080
```

---

## How It Works

### Algorithm

```
USER INPUT: items with prices + platform
      │
      ▼
STEP 1: Confirm platform rules (user-provided or searched)
      │
      ├─ Fallback rules (stable across 4+ years):
      │   Taobao/JD: every ¥300 → save ¥50, cross-store
      │   Pinduoduo: direct discounts
      │   Douyin: every ¥200 → save ¥30
      │
      ▼
STEP 2: Select algorithm
      │
      ├── Gap-filling: target_price = M - (total % M)
      │                  effective_cost = target_price - discount
      │
      ├── Order splitting: greedy allocation + local optimization
      │    ≤ 10 items → exhaustive search
      │    > 10 items → greedy + hill climbing
      │
      └── Cross-store: group by store → per-store coupon optimization
                       → remaining items → cross-store pool
      │
      ▼
STEP 3: Output 2-3 optimal plans with comparison
```

### Key design decisions

- **Never scrapes real-time prices.** Users input their own prices.
- **Prefer user-provided rules over web search.** The user's phone app is the most accurate and fastest source of promotion rules. Web search is a fallback.
- **Robust fallback rules.** 618 cross-store "every ¥300 save ¥50" rule has been stable for 4+ years. When search fails (Chinese e-commerce pages are JS-rendered SPAs that don't work with curl), the tool falls back to historical rules and proceeds — no blocking.

---

## Project Structure

```
618-shopping-optimizer/
├── SKILL.md              # Core algorithm documentation & skill definition
├── README.md             # You are here
├── LICENSE               # MIT
├── serve.sh              # Web launcher script
├── web/
│   └── index.html        # Mobile-first web UI (520 lines, vanilla JS)
└── docs/
    └── web-deployment.md # Deployment guide
```

### Web UI features

- 📱 Mobile-first, responsive design
- 🔴 618-themed red UI with gold accents
- ⚡ Streaming text responses (typing effect)
- 🎯 Quick-action buttons for common scenarios
- ⚙️ Configurable API endpoint (settings modal)
- 🔄 Auto connection check on load
- 👆 No dependencies — pure HTML/CSS/JavaScript

---

## Requirements

- **Hermes Agent** (for the skill / web backend)
- **Python 3** (for the web server)
- **Node.js** (if using browser-based search; works with nvm — see docs)

---

## Configuration

In `~/.hermes/config.yaml`:

```yaml
platforms:
  api_server:
    enabled: true
    extra:
      host: 0.0.0.0      # Allow LAN access
      port: 8642
      cors_origins: "*"   # Allow web frontend CORS
```

---

## Pitfalls (lessons learned)

1. **Taobao/Tmall pages can't be scraped with curl.** They're JS-rendered SPAs. Don't waste time — use fallback rules or ask the user.
2. **Search engines may timeout behind firewalls.** Give up after 30s and use fallback rules.
3. **Hermes browser module needs `chromium` channel on macOS**, not `chrome`. Also needs Node.js in PATH (nvm users: add to `config.yaml` env.PATH).
4. **Gateway API is auto-started** via `config.yaml` config — no `--platform` flag needed.

---

## License

MIT — see [LICENSE](LICENSE)

---

# 中文说明

## 这是什么？

618 购物凑单助手是一个 AI 驱动的购物优化工具，帮助你在 618、双11、双12 等大促期间，把想买的商品拆分成最优订单组合，最大化利用满减优惠。

### 三种核心场景

| 场景 | 说明 |
|------|------|
| **补差凑单** | 差 11 元到满减门槛？算出凑单品实际成本（可能倒赚） |
| **分单优化** | 同一平台多件商品，如何拆分成最优的几个订单？ |
| **跨店满减** | 不同店铺的商品，如何同时用跨店满减 + 店铺券？ |

### 支持平台

淘宝/天猫、京东、拼多多、抖音商城

## 快速开始

### 方式一：Hermes Agent Skill（本地使用）

```bash
git clone https://github.com/Zxxx96/618-shopping-optimizer.git
cd 618-shopping-optimizer
cp SKILL.md ~/.hermes/skills/productivity/618-shopping-optimizer/
cp -r web ~/.hermes/skills/productivity/618-shopping-optimizer/
cp serve.sh ~/.hermes/skills/productivity/618-shopping-optimizer/
```

然后在 Hermes CLI 里说：

```
我想在淘宝买键盘499、鼠标299、显示器1399，预算2000，帮我搭配最优方案
```

### 方式二：启动网页版（分享给朋友用）

```bash
bash serve.sh
# 手机打开 http://你的电脑IP:8080
```

## 核心设计

- **不爬取实时价格** —— 用户手动输入
- **优先问用户规则** —— 用户看一眼手机 App 活动页比联网搜快 10 倍且绝对准确
- **兜底规则足够可靠** —— 618「每满300减50」已连续四年未变
- **搜索失败不阻塞流程** —— 超时或抓不到页面时自动启用兜底规则继续计算

## 项目结构

```
618-shopping-optimizer/
├── SKILL.md              # 核心算法文档
├── README.md             # 本文件
├── LICENSE               # MIT 许可证
├── serve.sh              # 一键启动脚本
├── web/
│   └── index.html        # 移动端网页界面（520行，纯HTML/CSS/JS）
└── docs/
    └── web-deployment.md # 部署文档
```

## 依赖

- Hermes Agent（Skill 模式 / Web 后端）
- Python 3（网页服务）
- Node.js（浏览器搜索模式可选）

## 配置

在 `~/.hermes/config.yaml` 中：

```yaml
platforms:
  api_server:
    enabled: true
    extra:
      host: 0.0.0.0
      port: 8642
      cors_origins: "*"
```

## 许可证

MIT
