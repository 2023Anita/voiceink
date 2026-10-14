# 发布到 GitHub 指南

本文档提供将 VoiceInk 发布到公共 GitHub 仓库 `2023Anita/voiceink` 的详细步骤。

---

## ✅ 准备工作（已完成）

- [x] 完整的 Swift 项目代码
- [x] 双语 README（中文 + 英文）
- [x] Hero、Pipeline、Architecture 图片
- [x] QUICKSTART.md 和 BUILDING.md
- [x] MIT LICENSE
- [x] .gitignore 配置正确
- [x] 所有更改已提交到 git

---

## 🚀 发布步骤

### 方法 1：使用 GitHub CLI（推荐）

#### 1. 认证 GitHub CLI

```bash
gh auth login
```

按照提示：
1. 选择 **GitHub.com**
2. 选择 **HTTPS** 协议
3. 登录方式选择 **Login with a web browser**
4. 复制显示的 one-time code
5. 按 Enter 打开浏览器
6. 粘贴 code 并授权

**重要**：确保以 **2023Anita** 账号登录 GitHub。

#### 2. 创建公共仓库并推送

```bash
cd /workspace
gh repo create 2023Anita/voiceink --public --source=. --remote=github --push
```

**参数说明**：
- `--public`: 创建公开仓库
- `--source=.`: 使用当前目录
- `--remote=github`: 添加名为 github 的远程仓库
- `--push`: 立即推送所有分支

#### 3. 验证

```bash
gh repo view 2023Anita/voiceink --web
```

浏览器会打开 https://github.com/2023Anita/voiceink

---

### 方法 2：手动创建（备选）

如果 GitHub CLI 不可用或遇到问题：

#### 1. 在 GitHub 网站创建仓库

1. 访问 https://github.com/new
2. 确保以 **2023Anita** 身份登录
3. **Repository name**: `voiceink`
4. **Visibility**: ✅ Public
5. **不要勾选** "Initialize this repository with:"
   - 不要添加 README
   - 不要添加 .gitignore
   - 不要选择 license
6. 点击 **Create repository**

#### 2. 添加远程仓库

```bash
cd /workspace
git remote add github https://github.com/2023Anita/voiceink.git
```

#### 3. 推送代码

```bash
git push github main
```

如果提示需要认证：
```bash
# 使用 personal access token
git push https://[TOKEN]@github.com/2023Anita/voiceink.git main
```

#### 4. 验证

访问 https://github.com/2023Anita/voiceink 确认代码已上传。

---

## 📋 发布后检查清单

发布成功后，确保：

- [ ] 仓库可见性为 **Public**
- [ ] README.md 正确显示（包括图片）
- [ ] Hero 图片显示在 README 顶部
- [ ] 所有文档文件存在（QUICKSTART.md, BUILDING.md 等）
- [ ] docs/images/ 包含 3 张图片
- [ ] LICENSE 文件存在
- [ ] 可以 `git clone https://github.com/2023Anita/voiceink.git`

---

## 🔧 设置仓库描述和主题

在 GitHub 仓库页面：

### 1. 添加描述

点击右上角 ⚙️ **Settings** → **General**：

**Description**:
```
Open-source macOS menu bar app for AI voice dictation with smart text polishing and seamless injection
```

**Website**: 留空或添加演示链接

**Topics** (标签):
```
macos, swift, swiftui, voice-input, ai, whisper, gpt, dictation, speech-to-text, 
menu-bar-app, productivity, open-source
```

### 2. 启用 Issues 和 Discussions

Settings → Features:
- [x] Issues
- [x] Discussions（可选，用于社区讨论）

---

## 📢 创建首个 Release（可选）

### 1. 打标签

```bash
git tag -a v1.0.0 -m "VoiceInk v1.0.0 - Initial public release"
git push github v1.0.0
```

### 2. 在 GitHub 创建 Release

1. 访问 https://github.com/2023Anita/voiceink/releases/new
2. **Choose a tag**: v1.0.0
3. **Release title**: VoiceInk v1.0.0 - AI Voice Dictation for macOS
4. **Describe this release**:

```markdown
## 🎉 首次公开发布

VoiceInk 是一个开源的 macOS 菜单栏应用，提供 AI 驱动的语音输入功能。

### ✨ 核心功能
- 🎙️ 全局热键录音（默认 Right Option）
- 🤖 Whisper AI 语音转文字
- ✨ GPT-4o-mini 智能文本润色
- ⚡ 通用应用文本注入
- 📦 本地 SQLite 历史记录
- 🔒 钥匙串安全存储

### 📋 系统要求
- macOS 13.0 (Ventura) 或更高
- Xcode 15.0 或更高
- OpenAI API 密钥（或使用 Stub 模式测试）

### 🚀 快速开始
```bash
git clone https://github.com/2023Anita/voiceink.git
cd voiceink
open Package.swift
# 在 Xcode 中按 ⌘R
```

详见 [README.md](https://github.com/2023Anita/voiceink#readme)

---

**完整更改日志**: https://github.com/2023Anita/voiceink/commits/v1.0.0
```

5. 点击 **Publish release**

---

## 🎨 优化 README 图片显示

确保图片在 GitHub 上正确显示：

### 检查图片路径

README.md 中的图片使用相对路径：
```markdown
![VoiceInk Hero](docs/images/hero.jpg)
```

GitHub 会自动渲染这些图片。

### 如果图片不显示

1. 确认文件存在：
   ```bash
   ls -lh docs/images/
   ```

2. 确认文件已提交：
   ```bash
   git ls-files docs/images/
   ```

3. 如果缺失，重新添加并推送：
   ```bash
   git add docs/images/*.jpg
   git commit -m "Add missing images"
   git push github main
   ```

---

## 📱 添加 Social Preview 图片（可选）

在 GitHub 仓库设置中设置社交预览图：

1. Settings → General → Social preview
2. 点击 **Edit**
3. 上传 `docs/images/hero.jpg`
4. Save

这会让分享链接时显示漂亮的预览卡片。

---

## 🌟 推广和分享

发布后，可以在以下平台分享：

- [ ] Reddit r/swift, r/macapps
- [ ] Hacker News (Show HN: VoiceInk)
- [ ] Twitter/X (with @2023Anita or relevant hashtags)
- [ ] Product Hunt
- [ ] 知乎、V2EX（中文社区）

**分享模板**：

```
🎙️ VoiceInk - Open-source AI voice dictation for macOS

Just released VoiceInk, a native macOS menu bar app that lets you 
dictate text with your voice in any application:

✨ Whisper AI transcription
🧹 GPT-powered text polishing (removes filler words)
⚡ Seamless injection into any app
📦 Local history, secure keychain storage
🔓 100% open source (MIT)

GitHub: https://github.com/2023Anita/voiceink
```

---

## 🐛 故障排除

### 问题：推送被拒绝

**错误**:
```
! [rejected]        main -> main (fetch first)
```

**解决方案**：
```bash
git pull github main --rebase
git push github main
```

### 问题：图片不显示

**原因**：GitHub Pages 或缓存问题

**解决方案**：
1. 强制刷新浏览器（Ctrl+F5）
2. 检查文件大小（GitHub 限制单个文件 100MB）
3. 清除浏览器缓存

### 问题：权限被拒绝

**错误**:
```
ERROR: Permission to 2023Anita/voiceink.git denied to [other-user]
```

**解决方案**：
- 确保以 **2023Anita** 身份认证
- 检查 GitHub token 权限
- 重新运行 `gh auth login`

---

## 📊 成功指标

发布成功的标志：

✅ 仓库 URL 可访问：https://github.com/2023Anita/voiceink  
✅ README 完整显示，包括图片  
✅ 可以克隆：`git clone https://github.com/2023Anita/voiceink.git`  
✅ 在 Mac 上 `open Package.swift` 可以打开 Xcode  
✅ Xcode 可以成功构建（⌘B）  
✅ 运行后菜单栏显示图标（⌘R）  

---

## 🎉 完成！

恭喜！VoiceInk 现已公开发布。

**最终 URL**: https://github.com/2023Anita/voiceink

**克隆命令**:
```bash
git clone https://github.com/2023Anita/voiceink.git
```

---

**有问题？** 提交 [GitHub Issue](https://github.com/2023Anita/voiceink/issues/new)
