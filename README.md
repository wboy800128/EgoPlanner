# EgoPlanner: 2D Real-time Trajectory Optimizer

[![C++](https://img.shields.io/badge/Language-C++-blue.svg)](https://isocpp.org/)
[![Build](https://img.shields.io/badge/Build-CMake-brightgreen.svg)](https://cmake.org/)
[![License](https://img.shields.io/badge/License-MIT-orange.svg)](./LICENSE)

## 📖 项目简介

本项目基于 **Ego-Planner** 后端核心代码进行剥离与封装，实现了一个**纯净版、轻量级**的 B 样条（B-Spline）轨迹优化库。

针对**地面移动机器人**（AGV/AMR）的应用场景，我们将原有的三维轨迹规划算法**降维适配为二维平面**，专注于实现高效、平滑的实时局部路径规划。

**核心特性：**
*   **纯 C++ 实现**：无繁杂依赖，易于集成。
*   **2D 平面适配**：专为地面移动机器人优化。
*   **B 样条优化**：保证轨迹的平滑性与动态可行性。

---

## 🚀 编译与运行 (How to use)

请确保您的环境中已安装 `CMake` 和 `C++` 编译器。

```bash
# 1. 创建构建目录
mkdir build 
cd build

# 2. 编译项目
cmake ..
make

# 3. 运行示例
./EgoPlanCore 
```

---

## 🧭 详细步骤（Windows 可复制命令）

下面给出在 Windows（PowerShell / CMD）环境下的可复制命令，按顺序执行可以完成：配置 -> 构建 -> 运行 -> 创建虚拟环境 -> 安装 matplotlib -> 绘图。

1) PowerShell（推荐）

```powershell
# 切换到仓库根（如果尚未在仓库根）
Set-Location D:\GitHub\EgoPlanner

# 1) 使用 CMake 配置并构建（Release）
cmake -S . -B build
cmake --build build --config Release

# 2) 运行可执行以生成轨迹 CSV
.\build\Release\EgoPlanCore.exe

# 3) 创建并激活虚拟环境（如果首次使用）
py -3 -m venv .venv
# 如果 Activate.ps1 被阻止（策略），可先临时放行：
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
. .\.venv\Scripts\Activate.ps1

# 4) 安装 matplotlib 并运行绘图脚本
python -m pip install -U pip
pip install -r scripts\requirements.txt  # 或: pip install matplotlib
python scripts\plot_trajectory.py

# 5) 验证输出
Test-Path build\trajectory.csv
Test-Path build\trajectory.png
```

如果不想修改 PowerShell 策略，可以不激活 venv，直接调用 venv 的 python：

```powershell
& .\.venv\Scripts\python.exe -m pip install -U pip matplotlib
& .\.venv\Scripts\python.exe scripts\plot_trajectory.py
```

2) CMD（Windows 命令提示符）

```cmd
cd /d D:\GitHub\EgoPlanner
py -3 -m venv .venv
.venv\Scripts\activate.bat
python -m pip install -U pip
pip install -r scripts\requirements.txt
python scripts\plot_trajectory.py
```

3) 一键脚本（仓库提供）

- PowerShell 一键脚本： `scripts/run_all.ps1`（支持参数 `-SkipBuild` 跳过构建）
- 批处理一键脚本： `scripts/run_all.bat`（支持参数 `-SkipBuild`）

在 PowerShell 或 CMD 中运行任一脚本即可完成整个流程：

```powershell
# 完整运行（包含配置、构建、运行与绘图）
.\scripts\run_all.ps1

# 或在 CMD 中
scripts\run_all.bat
```

4) 在 VS Code 中的快捷操作

- 打开命令面板（Ctrl+Shift+P）-> 输入 `Run Task` -> 选择：
  - `CMake: Configure`（执行 cmake -S . -B build）
  - `CMake: Build Release`（执行 cmake --build build --config Release）
  - `Run: EgoPlanCore (Release)`（直接运行可执行）
  - `Plot: Trajectory (Python)`（运行 `python scripts/plot_trajectory.py`，使用当前激活的 Python 环境）
- 按 F5 可以启动 `Launch EgoPlanCore (Release)`（会触发构建然后运行/调试）

5) 常见故障与提示

- 如果 PowerShell 报 "禁止运行脚本"，请使用 `Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned` 临时允许，或使用不需激活的直接调用方法（见上文）。
- 如果 `python` 指向 Windows Store，请使用 `py -3` 来确保使用系统安装的 Python。若遇到 NumPy C-extension 错误，请在 venv 中重新安装依赖而避免全局冲突。
- `.gitignore` 已包含 `build/` 与 `.venv/`，默认不会将生成文件与虚拟环境提交到仓库。


## 📊 可视化轨迹（在本仓库）

仓库包含一个简单的 Python 绘图脚本用于可视化规划结果：`scripts/plot_trajectory.py`。

步骤：

1. 在仓库根或使用 VS Code 任务先完成构建并运行可执行，生成轨迹文件：

```bash
# 在仓库根执行（或使用 VS Code -> Run Task）
mkdir -p build
cmake -S . -B build
cmake --build build --config Release

# 运行可执行以生成 trajectory.csv（生成在 build/）
./build/Release/EgoPlanCore.exe
```

2. 使用系统 `python`（建议进入项目虚拟环境 `.venv`）运行绘图脚本：

```bash
# 推荐：使用虚拟环境
python -m venv .venv
.venv\Scripts\activate   # Windows
pip install -U pip
pip install matplotlib

# 运行绘图脚本（脚本会读取 build/trajectory.csv 并输出 trajectory.png）
python scripts/plot_trajectory.py
```

3. 输出文件： `build/trajectory.png`（以及 HTML 交互图，如果脚本生成）。

如果你想在 VS Code 中直接运行：打开命令面板（Ctrl+Shift+P）-> Run Task -> 选择 `CMake: Build Release` 或 `Plot: Trajectory (Python)`。


## 🖼️ 运行效果 (Demo)

下图展示了算法规划出的二维平滑轨迹：

<p align="center">
  <!-- 注意：建议将图片链接替换为 raw 格式以确保在某些网络环境下正常显示，或者使用相对路径 -->
  <img src="https://github.com/JackJu-HIT/EgoPlanner/raw/master/results.png" alt="Trajectory Optimization Result" width="600" />
</p>

---

## 🔗 参考项目

本项目核心算法源自以下优秀的开源项目，特此致谢：

*   **Ego-Planner**: [ZJU-FAST-Lab/ego-planner](https://github.com/ZJU-FAST-Lab/ego-planner.git)

---

## 📢 更多技术细节

如果您对代码实现细节、算法原理感兴趣，欢迎关注我们的媒体渠道获取更多教程：

*   **微信公众号**：`机器人规划与控制研究所`
*   **Bilibili 视频演示**：[点击观看视频教程](https://www.bilibili.com/video/BV1RgsNz7ETm/)

---
*Created by JackJu-HIT*

