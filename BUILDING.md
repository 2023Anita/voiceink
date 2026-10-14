# VoiceInk 构建指南

> 详细的 macOS 构建说明，适用于开发者和贡献者

---

## 📋 系统要求

### 必需
- **macOS**: 13.0 (Ventura) 或更高版本
- **Xcode**: 15.0 或更高版本
- **Swift**: 5.9+ (包含在 Xcode 中)
- **磁盘空间**: 至少 2 GB 可用空间

### 可选
- **Git**: 用于版本控制（macOS 自带）
- **Command Line Tools**: `xcode-select --install`

---

## 🔧 安装 Xcode

### 方法 1：App Store（推荐）

1. 打开 **App Store**
2. 搜索 "**Xcode**"
3. 点击 **Get** 或 **Install**
4. 等待下载（12+ GB，需要 20-30 分钟）

### 方法 2：Apple Developer

1. 访问 [developer.apple.com/download](https://developer.apple.com/download)
2. 登录 Apple ID
3. 下载 Xcode 15.x .xip 文件
4. 解压并移动到 `/Applications`

### 安装后配置

```bash
# 设置命令行工具路径
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer

# 接受许可协议
sudo xcodebuild -runFirstLaunch
```

**验证安装**：
```bash
xcodebuild -version
# 输出示例：Xcode 15.0
#          Build version 15A240d
```

---

## 📦 获取源代码

### 从 GitHub 克隆

```bash
# 克隆仓库
git clone https://github.com/2023Anita/voiceink.git

# 进入目录
cd voiceink

# 查看项目结构
ls -la
```

**预期输出**：
```
Package.swift           # Swift Package Manager 配置
Sources/                # 源代码
Tests/                  # 单元测试
docs/                   # 文档和图片
README.md
LICENSE
```

---

## 🏗️ 构建项目

### 方法 1：使用 Xcode（推荐）

#### 1. 打开项目

```bash
open Package.swift
```

或：
- 启动 Xcode
- File → Open
- 选择 `Package.swift` 文件

#### 2. 等待依赖解析

Xcode 会自动解析依赖：
- **KeyboardShortcuts** v2.0.0+（全局热键）
- **GRDB.swift** v6.0.0+（SQLite 数据库）

**进度提示**：底部状态栏显示 "Resolving Package Graph..."

**耗时**：30-60 秒（首次）

#### 3. 配置签名（重要）

1. 选择 **VoiceInk** target（左侧导航栏）
2. 切换到 **Signing & Capabilities** 标签
3. 选择你的 **Team**：
   - 如果有付费 Apple Developer 账号：选择你的团队
   - 如果没有：选择你的 Apple ID（个人团队）
   - Xcode 会自动创建免费的临时描述文件

**注意**：免费描述文件的应用只能在你的 Mac 上运行 7 天，之后需要重新构建。

#### 4. 构建

按 **⌘B** 或 Product → Build

**首次构建时间**：2-3 分钟（编译依赖）  
**后续构建时间**：10-20 秒（增量编译）

#### 5. 运行

按 **⌘R** 或 Product → Run

**结果**：菜单栏出现麦克风图标

---

### 方法 2：命令行构建

适用于 CI/CD 或无 GUI 环境。

#### 1. 解析依赖

```bash
swift package resolve
```

#### 2. 构建 Debug 版本

```bash
swift build
```

**输出位置**：`.build/debug/VoiceInk`

#### 3. 构建 Release 版本（优化）

```bash
swift build -c release
```

**输出位置**：`.build/release/VoiceInk`

#### 4. 运行（命令行）

```bash
.build/debug/VoiceInk
```

**限制**：命令行构建的二进制文件：
- 无应用程序 bundle 结构
- 无 Info.plist（权限描述缺失）
- 菜单栏图标可能不显示
- 不适合最终用户

**推荐**：开发和分发都使用 Xcode 构建。

---

## 🧪 运行测试

### 在 Xcode 中

按 **⌘U** 或 Product → Test

**测试内容**：
- Stub 转录服务（无 API 调用）
- Passthrough 润色服务（透传）
- 设置持久化（UserDefaults）
- 钥匙串存储（保存/读取/删除）
- 历史记录 CRUD（SQLite）

**测试覆盖率**：核心服务约 70%

### 命令行测试

```bash
swift test
```

**输出示例**：
```
Test Suite 'All tests' passed at 2026-10-14 02:00:00.
     Executed 5 tests, with 0 failures (0 unexpected) in 0.234 (0.235) seconds
```

---

## 📱 创建分发版本

### 为个人使用打包（免费账号）

#### 1. Archive

在 Xcode 中：
1. Product → Archive
2. 等待归档完成（2-3 分钟）

#### 2. 导出

在 Organizer 窗口中：
1. 选择刚创建的 Archive
2. 点击 **Distribute App**
3. 选择 **Copy App**
4. 点击 **Next** → **Export**
5. 选择保存位置

#### 3. 安装

将导出的 `VoiceInk.app` 拖到 `/Applications` 文件夹。

**限制**：
- 只能在你的 Mac 上运行
- 7 天后需要重新构建和安装
- 首次打开需要右键 → Open（绕过 Gatekeeper）

---

### 为公开分发打包（付费账号）

需要 [Apple Developer Program](https://developer.apple.com/programs/) ($99/年)

#### 1. 配置 App ID

在 [developer.apple.com](https://developer.apple.com) 中：
1. Certificates, Identifiers & Profiles
2. 创建 App ID: `com.yourname.voiceink`
3. 启用所需能力（Keychain Sharing 等）

#### 2. 在 Xcode 中配置

1. 选择 VoiceInk target
2. Signing & Capabilities
3. 选择你的付费 Team
4. 确保 Bundle Identifier 匹配

#### 3. Archive 和签名

1. Product → Archive
2. Distribute App → **Developer ID**
3. 选择 Distribution 证书
4. 勾选 "Upload to Apple for notarization"
5. 提交并等待（5-10 分钟）

#### 4. 下载公证后的应用

1. Xcode → Window → Organizer → Archives
2. 选择公证成功的 Archive
3. Export Notarized App
4. 获得签名 + 公证的 `VoiceInk.app`

**公证后的优势**：
- 用户无需右键打开
- 可在任意 macOS 设备上运行
- 不会被 Gatekeeper 阻止

---

## 🐛 构建故障排除

### 问题：Package.resolved 损坏

**症状**：
```
error: 'voiceink' /Package.resolved file is corrupted or malformed
```

**解决方案**：
```bash
rm Package.resolved
swift package resolve
```

---

### 问题：依赖解析失败

**症状**：
```
error: failed to resolve dependencies
```

**解决方案**：

1. **检查网络连接**（需要访问 GitHub）
2. **清理缓存**：
   ```bash
   swift package reset
   swift package resolve
   ```
3. **在 Xcode 中**：
   - File → Packages → Reset Package Caches
   - File → Packages → Resolve Package Versions

---

### 问题：找不到模块

**症状**：
```
error: no such module 'KeyboardShortcuts'
```

**解决方案**：

依赖未正确下载。在 Xcode 中：
1. 关闭项目
2. 删除 `.build` 和 `Package.resolved`：
   ```bash
   rm -rf .build Package.resolved
   ```
3. 重新打开 `Package.swift`
4. 等待依赖解析

---

### 问题：AVFoundation 编译错误

**症状**：
```
error: cannot find 'AVAudioRecorder' in scope
```

**原因**：选择了错误的构建目标（如 iOS Simulator）

**解决方案**：
1. 在 Xcode 顶部工具栏
2. 确保选择 **My Mac** 作为构建目标
3. 不要选择任何 iPhone 或 iPad 模拟器

---

### 问题：签名失败

**症状**：
```
error: Signing for "VoiceInk" requires a development team.
```

**解决方案**：
1. Xcode → Preferences → Accounts
2. 添加你的 Apple ID（免费）或 Apple Developer 账号
3. 返回 Signing & Capabilities
4. 选择你的 Team

---

### 问题：构建超时/卡住

**解决方案**：

1. **清理构建文件夹**：
   - Product → Clean Build Folder (⌘⇧K)
   
2. **删除 DerivedData**：
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

3. **重启 Xcode**

4. **重新打开项目**

---

## 📊 构建配置

### Debug 构建（开发）

**特点**：
- 包含调试符号
- 无优化（编译快）
- 二进制体积大
- 支持断点和变量检查

```bash
swift build  # 默认 debug
```

---

### Release 构建（分发）

**特点**：
- 优化编译（-O）
- 体积小 30-50%
- 执行速度快
- 无调试信息

```bash
swift build -c release
```

---

### 架构说明

#### Apple Silicon (M1/M2/M3)

默认构建为 **arm64** 原生架构。

```bash
swift build --arch arm64
```

#### Intel Mac

默认构建为 **x86_64** 架构。

```bash
swift build --arch x86_64
```

#### Universal Binary（通用二进制）

同时支持 Intel 和 Apple Silicon：

```bash
swift build -c release --arch arm64 --arch x86_64
```

**体积**：约为单架构的 2 倍。

---

## 🔍 构建产物位置

### Swift Package Manager 构建

```
.build/
├── debug/
│   └── VoiceInk              # Debug 二进制
└── release/
    └── VoiceInk              # Release 二进制
```

### Xcode 构建

```
~/Library/Developer/Xcode/DerivedData/VoiceInk-<hash>/Build/Products/
├── Debug/
│   └── VoiceInk.app         # Debug 应用 bundle
└── Release/
    └── VoiceInk.app         # Release 应用 bundle
```

---

## 📦 依赖说明

### KeyboardShortcuts

- **版本**: 2.0.0+
- **用途**: 全局热键注册和管理
- **许可证**: MIT
- **仓库**: [github.com/sindresorhus/KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts)

**特性**：
- 原生 macOS API 封装
- 自动处理权限
- 内置设置 UI 组件

### GRDB.swift

- **版本**: 6.0.0+
- **用途**: SQLite 数据库 ORM
- **许可证**: MIT
- **仓库**: [github.com/groue/GRDB.swift](https://github.com/groue/GRDB.swift)

**特性**：
- 类型安全的 SQL 查询
- Swift Concurrency (async/await) 支持
- 自动数据库迁移

---

## 🚀 性能优化

### 编译优化

在 `Package.swift` 中已配置：
- **SwiftSettings**: `-O`（优化）
- **LinkerSettings**: Strip symbols（移除符号表）

### 应用优化

- **延迟加载**: 窗口只在需要时创建
- **后台处理**: 录音/转录/润色在后台线程
- **内存管理**: 音频文件处理后立即删除

---

## 📝 开发工作流

### 推荐流程

1. **Clone** → 克隆仓库
2. **Open** → `open Package.swift`
3. **Wait** → 等待依赖解析
4. **Sign** → 配置签名（首次）
5. **Build** → ⌘B 构建
6. **Run** → ⌘R 运行
7. **Test** → ⌘U 测试
8. **Commit** → 提交更改
9. **Archive** → 归档分发

### 代码规范

- 遵循 [Swift Style Guide](https://google.github.io/swift/)
- 使用 SwiftFormat 格式化代码
- 为新功能添加单元测试
- 更新相关文档

---

## 🔗 相关资源

- [Swift Package Manager 文档](https://swift.org/package-manager/)
- [Xcode 用户指南](https://developer.apple.com/documentation/xcode)
- [Code Signing 指南](https://developer.apple.com/support/code-signing/)
- [App Notarization 流程](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)

---

## 📬 获取帮助

遇到构建问题？

1. 查看 [GitHub Issues](https://github.com/2023Anita/voiceink/issues)
2. 搜索相似问题
3. 提交新 Issue（附带完整错误日志）

---

**构建状态**: ⚠️ 目标环境 macOS 13+ / Xcode 15+；首次在 Mac 上构建时请反馈任何编译问题

**最后更新**: 2026-10-14
