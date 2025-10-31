# Cap Windows 开发环境设置指南

## 问题诊断总结

在 Windows 上编译 Cap 桌面应用时遇到的所有 "program not found" 错误，根本原因是：

### 🔍 已发现的问题

1. **TAURI_CONFIG 环境变量设置错误** ✅ 已修复
   - 被错误设置为文件名 `"tauri.windows.conf.json"`
   - 导致 JSON 解析错误：`expected ident at line 1 column 2`

2. **PATH 环境变量配置不完整** ✅ 已修复
   - Cargo：已在 PATH ✓
   - LLVM/Clang：未在 PATH ✗ → 已添加
   - CMake：未在 PATH ✗ → 已添加

3. **LIBCLANG_PATH 未设置** ✅ 已修复
   - whisper-rs-sys 需要此环境变量来找到 libclang.dll

4. **PowerShell 子进程继承问题** ✅ 已理解
   - 临时设置的环境变量不会被子进程继承
   - 必须永久添加到注册表（用户或系统级别）

---

## 🛠️ 完整解决方案

### 步骤 1：运行 PATH 修复脚本

```powershell
powershell -ExecutionPolicy Bypass -File fix-path-simple.ps1
```

这个脚本会：
- ✓ 检查所有必需工具是否已安装
- ✓ 将 Cargo、LLVM、CMake 添加到用户 PATH
- ✓ 设置 LIBCLANG_PATH 环境变量
- ✓ 清除错误的 TAURI_CONFIG 环境变量

### 步骤 2：重启终端

**重要：** 必须关闭所有 PowerShell/终端窗口并重新打开，环境变量更改才会生效。

### 步骤 3：验证工具

在新的终端窗口中运行：

```powershell
cargo --version   # 应显示: cargo 1.90.0 (...)
clang --version   # 应显示: clang version 21.0.0
cmake --version   # 应显示: cmake version 3.x.x
```

### 步骤 4：启动开发服务器

#### 方法 A：使用启动脚本（推荐）

```powershell
.\dev-desktop.ps1
```

#### 方法 B：直接运行

```powershell
pnpm dev:desktop
```

---

## 📋 必需的工具清单

| 工具 | 版本要求 | 安装位置 | 状态 |
|------|---------|---------|------|
| Rust/Cargo | 1.88.0+ | `C:\Users\Administrator\.cargo\bin` | ✅ 已安装 |
| LLVM/Clang | 最新版 | `C:\Program Files\LLVM\bin` | ✅ 已安装 |
| CMake | 3.x+ | `C:\Program Files\CMake\bin` | ✅ 已安装 |
| Node.js | 20.x | - | ⚠️ 当前 22.x（兼容但有警告）|
| pnpm | 8.10.5+ | - | ✅ 已安装 |
| Visual Studio Build Tools | 2022 | - | ✅ 已安装 |

---

## 🎯 为什么之前会反复失败？

1. **环境变量隔离**
   ```
   注册表（持久化） → PowerShell 会话 → 子进程（pnpm/tauri）
   ```
   - 临时修改 `$env:PATH` 只影响当前会话
   - 子进程只能读取注册表中的持久化环境变量
   - 因此每次运行都失败

2. **缺失的工具路径**
   - LLVM 和 CMake 虽然已安装，但未添加到 PATH
   - 每次手动添加只是临时修复

3. **错误的环境变量**
   - TAURI_CONFIG 被错误设置为文件名而不是 JSON 内容

---

## 🚀 后续使用

现在环境已正确配置，以后只需：

1. 打开终端
2. 运行 `pnpm dev:desktop` 或 `.\dev-desktop.ps1`

环境变量已永久保存，不需要每次都重新配置。

---

## ⚠️ 常见问题

### Q: 仍然显示 "program not found"
A: 确保已经**重启了终端窗口**。环境变量更改只在新进程中生效。

### Q: Node 版本警告
A: 项目要求 Node 20，当前使用 Node 22。这只是警告，不影响功能。可选择安装 nvm-windows 来管理多个 Node 版本。

### Q: 编译时间很长
A: 首次编译 Rust 项目会编译所有依赖（whisper、ffmpeg 等），需要 10-30 分钟。后续编译会快很多。

---

## 📝 文件说明

- `fix-path-simple.ps1` - PATH 修复脚本（一次性运行）
- `dev-desktop.ps1` - 开发环境启动脚本（可重复使用）
- `SETUP-WINDOWS.md` - 本文档

