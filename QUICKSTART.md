# VoiceInk 快速开始指南

> 5 分钟内让 VoiceInk 在你的 Mac 上运行起来

## 前提条件

- ✅ Mac 运行 macOS 13.0 (Ventura) 或更高版本
- ✅ Xcode 15.0 或更高版本已安装
- ✅ （可选）OpenAI API 密钥用于真实转录

---

## 第 1 步：克隆项目

打开终端并运行：

```bash
git clone https://github.com/2023Anita/voiceink.git
cd voiceink
```

---

## 第 2 步：打开项目

```bash
open Package.swift
```

**会发生什么**：
- Xcode 自动启动
- 解析依赖包（KeyboardShortcuts、GRDB）
- 设置构建方案

**等待提示**："Resolving Package Graph" 完成（底部状态栏显示），通常需要 30-60 秒。

---

## 第 3 步：构建并运行

在 Xcode 中：

1. 等待依赖解析完成
2. 选择 **VoiceInk** scheme（左上角 Run 按钮旁边）
3. 按 **⌘R**（或 Product → Run）

**首次构建**需要 2-3 分钟来编译依赖。

**结果**：菜单栏右上角出现一个麦克风图标 🎙️

---

## 第 4 步：授予权限

VoiceInk 需要两个 macOS 权限：

### 4.1 麦克风权限

**自动弹出**（应用首次启动时）：
1. 对话框询问"VoiceInk 想要访问你的麦克风"
2. 点击 **"确定"** 允许

**手动检查**（如果错过了）：
1. 菜单栏图标 → **Permissions**
2. 查看麦克风状态
3. 如果显示"拒绝"，打开 System Settings → Privacy & Security → Microphone
4. 找到 VoiceInk 并勾选

### 4.2 辅助功能权限

**必须手动授予**：
1. 菜单栏图标 → **Permissions**
2. 点击辅助功能旁边的 **"Grant Access"**
3. 系统会打开 System Settings → Privacy & Security → Accessibility
4. 滚动找到 **VoiceInk** 并**勾选**启用
5. 返回 VoiceInk，点击 **"Check Status"** 确认为绿色

**为什么需要**：注入文本到其他应用需要此权限。

---

## 第 5 步：配置（二选一）

### 选项 A：Stub 模式（推荐首次测试）

**无需 API 密钥，快速体验**：

1. 菜单栏图标 → **Settings**
2. 切换到 **General** 标签
3. **启用** "Use Stub Mode"
4. 完成！

**效果**：转录会返回固定的测试文本（包含填充词），可以测试润色和注入功能。

### 选项 B：真实转录（完整功能）

**需要 OpenAI API 密钥**：

1. **获取 API 密钥**：
   - 访问 [platform.openai.com/api-keys](https://platform.openai.com/api-keys)
   - 登录你的 OpenAI 账号
   - 点击 "Create new secret key"
   - **复制密钥**（只显示一次！）

2. **保存到 VoiceInk**：
   - 菜单栏图标 → **Settings** → **API Keys** 标签
   - 粘贴你的 API 密钥
   - 点击 **Save**
   - 密钥会安全存储在 macOS 钥匙串（加密）

3. **禁用 Stub 模式**：
   - 切换到 **General** 标签
   - **关闭** "Use Stub Mode"

---

## 第 6 步：开始使用！

### 基本流程

1. **打开任意文本应用**：
   - Notes（推荐）
   - TextEdit
   - Safari/Chrome 浏览器的文本框
   - Slack、Discord、邮件客户端等

2. **点击文本框**，确保光标在闪烁（获得焦点）

3. **按住 Right Option 键** (⌥)
   - 菜单栏图标变为实心麦克风
   - 表示正在录音

4. **自然说话**：
   - "你好世界，这是一个测试"
   - "嗯，我想说，就是那个，第一点是创建项目，第二点是提交代码"
   
5. **松开 Right Option 键**
   - 菜单栏图标变为沙漏（处理中）

6. **等待 2-3 秒**

7. **文字自动出现**在你的文本框中！
   - 如果用真实 API：去掉了"嗯、就是"等填充词
   - 列表会自动格式化
   - 自我纠正会被修正

---

## 🎉 成功标志

✅ 菜单栏有麦克风图标  
✅ 按住热键时图标变化  
✅ 文字出现在文本框中  
✅ 原剪贴板内容没有丢失  

---

## 🎨 自定义设置

### 更换热键

1. 菜单栏图标 → **Settings** → **Hotkey** 标签
2. 点击录音框
3. 按下你想要的组合键（如 F13、Caps Lock）
4. 自动保存

**建议热键**：
- Right Option (⌥) - 默认，易按
- F13 或更高 - 不与其他应用冲突
- Caps Lock（需要第三方工具重映射）

### 调整润色风格

1. Settings → **General** 标签
2. 选择 **Tone**：
   - **Neutral** - 保持自然语气
   - **Email** - 转换为正式邮件风格
   - **Chat** - 转换为轻松聊天风格

### 指定语言

1. Settings → **General** 标签
2. **Language** 输入框：
   - 留空 - 自动检测
   - `zh` - 中文
   - `en` - 英文
   - `es` - 西班牙语
   - `fr` - 法语

---

## 📜 查看历史记录

1. 菜单栏图标 → **History**
2. 查看所有转录记录：
   - 时间戳
   - 润色后的文本
   - 展开查看原始转录
3. 点击复制图标可复制任意记录
4. 点击垃圾桶图标删除单条记录
5. 点击"Clear All"清空所有历史

**存储位置**：`~/Library/Application Support/VoiceInk/history.db`

---

## 🐛 遇到问题？

### 问题：热键无响应

**解决方案**：
1. 确认辅助功能权限已授予
2. 尝试更换热键（Settings → Hotkey）
3. 重启 VoiceInk

### 问题：录音后没有文字

**检查步骤**：
1. 打开 History 窗口，看是否有记录
   - 有记录：注入失败，确保文本框获得焦点
   - 无记录：转录失败，检查下面的步骤
2. 确认麦克风权限已授予
3. 如果用真实 API，检查 API 密钥是否正确
4. 尝试用 Stub 模式测试

### 问题：API 错误

**常见原因**：
- API 密钥无效
- OpenAI 账号余额不足
- 网络连接问题

**解决方案**：
1. 检查 [platform.openai.com](https://platform.openai.com) 账单页面
2. 验证 API 密钥是否有效（重新创建一个）
3. 先用 Stub 模式测试其他功能

---

## 🚀 下一步

- ✅ 测试成功？查看 [README.md](README.md) 了解高级功能
- 🛠️ 想要自定义？查看 [BUILDING.md](BUILDING.md) 了解构建细节
- 🤝 想要贡献？提交 Issue 或 Pull Request！

---

## 💡 使用技巧

1. **说话自然**：不用刻意停顿，允许"嗯啊"和重复
2. **自我纠正**：直接说"不对，改成 XXX"，AI 会理解
3. **列表格式**：说"第一、第二、第三"会自动格式化
4. **长段落**：一次可以说很长，Whisper 支持 30 秒以上

---

**准备好了吗？按住 Right Option 键，开始说话！** 🎙️✨
