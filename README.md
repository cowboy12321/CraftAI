# 使用说明书
# 匠知 - 基于容器化的古建筑智能缺陷检测与报告系统 


> **版本**：2025 年版
> **Copyright © 2025 匠知项目组. All Rights Reserved.**

---

## 目录

- [1. 项目简介](#1-项目简介)
- [2. 环境准备](#2-环境准备-prerequisites)
- [3. 系统部署与启动](#3-系统部署与启动-installation--setup)
  - [第一步：启动后端与数据库](#第一步启动后端与数据库-docker)
  - [第二步：初始化数据库 (首次运行必做)](#第二步初始化数据库首次运行必做)
  - [第三步：启动前端界面](#第三步启动前端界面-flutter-web)
- [4. 功能操作指南](#4-功能操作指南-user-guide)
  - [4.1 注册与登录](#41-注册与登录)
  - [4.2 工作台概览](#42-工作台概览)
  - [4.3 进行病害检测 (核心流程)](#43-进行病害检测-核心流程)
  - [4.4 历史查询与报告导出](#44-历史查询与报告导出)
- [5. 常见问题](#5-常见问题-troubleshooting)
- [6. 开发维护命令](#6-开发维护命令)
- [7. 安全与部署建议](#7-安全与部署建议-补充)
- [8. 已修正的问题与建议更改记录](#8-已修正的问题与建议更改记录)

---

## 1. 项目简介

匠知 (CraftAI) 是一个面向古建筑预防性保护的专业级软件平台。系统基于容器化微服务架构，集成计算机视觉（YOLO）与大语言模型技术，实现对古建筑病害（裂缝、剥落、色差等）的智能化识别、历史档案管理及专业修复报告自动生成。

目标用户：文物保护单位、修复工程师、科研机构与项目管理人员。

---

## 2. 环境准备 

在运行系统前，请确保您的 Windows 电脑已安装并配置以下软件：

- **Docker Desktop**（必须安装并运行）
  - 用于运行后端 API 和 PostgreSQL 数据库。
  - 请确保 Docker Engine 已启动（系统托盘右下角 Docker 图标为绿色或显示 "Engine running"）。
  - **建议**：在 Windows 上使用 WSL2 后端以获得更稳定的 Linux 容器体验。若需要 GPU 加速，请安装并配置 NVIDIA Container Toolkit（见第 7 节 GPU 指南）。

- **Flutter SDK**（用于运行前端 Web 界面）
  - 建议版本：**3.0+** 或更高（用于开发调试时的兼容性）。
  - 请已正确设置 `PATH` 环境变量，并能在终端运行 `flutter --version`。

- **Microsoft Edge 浏览器**（用于显示系统界面）
  - 开发时工具链默认使用 Edge 打开 Web 预览；生产部署可使用任意现代浏览器（Edge/Chrome/Firefox）。

- **可选但推荐**：Git（用于版本控制）与文本编辑器（VSCode 等）。

**注意（路径与权限）**：Windows 路径中包含空格时请使用引号，例如 `cd "E:\CraftAI app\CraftAI"`。

---

## 3. 系统部署与启动 (Installation & Setup)

> 请严格按照以下顺序执行命令。

### 第一部：启动后端与数据库 (Docker)

1. 打开 PowerShell。
2. 进入项目根目录（示例）：

```powershell
# 进入项目根目录
cd "E:\CraftAI app\CraftAI"
```

3. 启动容器服务（后端 + 数据库）：

```powershell
# 使用 docker compose v2 语法（推荐）
docker compose up --build -d

# 若仍使用 docker-compose (旧版)，可执行：
docker-compose up --build -d
```

> 说明：`--build` 确保重新构建镜像，`-d` 表示后台运行。

4. 验证容器状态：

```powershell
# 列出服务与状态
docker compose ps
# 或（兼容旧版）
docker-compose ps
```

确保关键服务（如 `jiangzhi_backend`、`postgres` 等）状态为 `Up` 或 `Running`。

**提示**：如果容器未启动或频繁重启，请检查 `docker compose logs` 或 `docker logs -f <container_name>` 获取详细错误信息。


### 第二步：初始化数据库 (首次运行必做)

容器启动后，数据库为空，需要执行初始化脚本创建表结构与初始数据。

**推荐方式（使用 docker compose exec）**：

```powershell
# 在项目根目录执行：
# 注意：`jiangzhi_backend` 必须与 docker-compose.yml 中后端服务名称一致
docker compose exec jiangzhi_backend python app/SQL/init_db.py
```

**替代方式（使用 docker exec）**：

1. 先查找容器 ID：

```powershell
docker ps --filter "name=jiangzhi_backend"
```

2. 使用容器 ID 执行：

```powershell
docker exec -it <container_id_or_name> python app/SQL/init_db.py
```

**成功提示**：终端输出 `数据库表结构创建成功！` 表示已完成。

> 注意：如果容器服务名不一致，请替换为实际容器名称或容器 ID。


### 第三步：启动前端界面 (Flutter Web)

1. 保持 Docker 后端运行，打开新的 PowerShell 窗口。
2. 进入前端源码目录：

```powershell
cd "E:\CraftAI app\CraftAI\App\frontend\frontend"
```

3. 以 Web 模式启动应用（开发模式，使用 Edge 浏览器）：

```powershell
flutter run -d edge
```

等待编译完成后，系统会自动在 Edge 打开登录页面。

**生产发布**：若要发布为静态 Web 内容，请执行：

```powershell
# 构建生产版本
flutter build web
# 将 build/web 文件夹的内容部署到 Nginx、Apache 或其他静态站点服务
```

---

## 4. 功能操作指南 (User Guide)

### 4.1 注册与登录

**注册账号**：

- 在登录页点击右下角 “注册新用户”。
- 输入用户名（如 `admin`）和密码，点击 “注册”。

> 注意：若数据库已重置，旧账号需重新注册。

**登录系统**：

- 输入注册账号与密码后点击 “登录”。
- 登录成功后将跳转至 “匠知工作台”（Dashboard）。


### 4.2 工作台概览

工作台显示四大核心功能卡片：

- **智能检测**：核心业务入口，跳转至图片上传与分析页面。
- **历史档案**：查看过往所有检测记录列表。
- **生成报告**：针对特定检测记录导出 PDF 文档。
- **个人中心**：账户管理与安全设置。


### 4.3 进行病害检测 (核心流程)

1. 在 Dashboard 点击 **智能检测** 卡片进入作业页面。

2. **上传图片**：
   - 点击左侧大框或右侧控制面板的 “重新上传图片” 按钮。
   - 在弹窗中选择一张古建筑病害照片（支持 JPG / PNG）。
   - **建议**：前端应限制上传文件大小（例如 10 MB）并显示上传进度与错误提示。

3. **选择参数**：
   - 在右侧控制面板的 “1. 选择检测病害类型” 区域，点击标签进行多选（如：色差、表面剥落、过大缝隙）。

4. **执行分析**：
   - 点击 “开始检测” 按钮。
   - 系统会调用后端模型进行推理并在左侧显示带红框标注的 "AI 标注结果" 图片。
   - **注意**：推理时间受硬件（CPU / GPU）、模型大小及并发量影响，通常 **1–3 秒** 仅为示例，服务器端真实耗时可能更长。

5. **查看详情**：
   - 检测完成后，右侧底部出现 “查看完整报告” 按钮，点击跳转至检测详情页。


### 4.4 历史查询与报告导出

**历史档案**：

- 点击侧边栏或主页的 “历史档案”。
- 列表展示所有检测记录，支持下拉刷新以获取最新数据。
- 点击任意记录可以进入详情页查看标注图与检测结果。

**生成报告**：

- 在检测详情页点击 “生成报告” 按钮。系统将调用大模型生成修复建议。
- 生成完毕后，用户可点击“下载结果”保存单张图片，或点击 PDF 图标下载完整修复报告（PDF）。

---

## 5. 常见问题 (Troubleshooting)

**问题 A：`docker-compose` 命令报错？**

- 解决：检查 Docker Desktop 是否已启动并运行。确认当前目录中存在 `docker-compose.yml` 或使用新版 `docker compose` 命令。
- 若 PowerShell 报找不到命令，确保 Docker 已在 PATH 中并重启终端。


**问题 B：上传图片报错 `Image.file is not supported`？**

- 解决：前端需在 Web 环境使用 `XFile` 或 `Uint8List` 等兼容方法，避免在 Web 端使用 `dart:io` 的 `File`。
- 确保使用 `image_picker_for_web` 或在前端实现基于 `<input type="file">` 的上传逻辑。


**问题 C：数据库报错或无法登录？**

- 解决步骤：
  1. 确认已执行初始化脚本：`docker compose exec jiangzhi_backend python app/SQL/init_db.py`。
  2. 检查数据库容器日志：`docker compose logs postgres` 或 `docker logs -f <postgres_container>`。
  3. 若需要重置数据，请停止容器并删除 `db_data` 挂载目录（注意：删除将丢失数据）。


**其他常见排查命令**：

```powershell
# 查看所有容器状态
docker ps -a

# 查看某服务日志（替换为实际服务名）
docker compose logs -f jiangzhi_backend

# 查看端口占用（Windows）
netstat -ano | findstr :<PORT>
```

---

## 6. 开发维护命令

- **停止所有服务**：

```powershell
# 使用 docker compose v2
docker compose down
# 或（旧版）
docker-compose down
```

- **查看后端日志（实时）**：

```powershell
docker logs -f jiangzhi_backend
# 或
docker compose logs -f jiangzhi_backend
```

- **前端热重启（开发时）**：

```text
# 在运行 flutter 的终端按 R（大写）进行热重启
# 按 r（小写）是热重载
```

- **查看容器内文件或执行命令**：

```powershell
# 进入容器 shell（若镜像有 bash）
docker compose exec jiangzhi_backend /bin/bash
# 或
docker exec -it <container_id_or_name> /bin/bash
```



### 附：常见命令速查表

```text
# 启动服务（开发）
docker compose up --build -d

# 停止并移除容器
docker compose down

# 查看日志
docker compose logs -f jiangzhi_backend

# 初始化数据库 (容器内运行)
docker compose exec jiangzhi_backend python app/SQL/init_db.py

# 构建前端生产包
cd App/frontend/frontend
flutter build web
```