# UAV Backend（Orchestrator Repo + Submodules）

这是一个“编排/部署”仓库：通过 **Git Submodule** 引入两个子项目，并提供一键启动（DB + 两个服务）的 Docker Compose。

- **uav_telemetry**：无人机遥测接入/转换/实时与回放推送（WebSocket）
- **uav-media-info**：ZLMediaKit WebHook 接入、在线流状态、录像归档入库与查询 API
- **PostgreSQL**：共享库 `uav`，包含两张表：`flight_records`、`video_recordings`

本 README 面向“接手开发/部署”的同学，优先给出 **Docker 一键启动** 的开发部署方式（代码不写死在镜像里，便于升级）。

---

## 获取代码（包含子模块）

首次克隆务必带上子模块：

```bash
git clone --recurse-submodules <your-backend-orchestrator-repo-url>
cd backend
```

如果你已经 clone 过但没拉子模块：

```bash
git submodule update --init --recursive
```

更新代码时：

- 更新到编排仓库记录的子模块版本（可复现）：

```bash
git pull
git submodule update --init --recursive
```

- 如果你要把子模块升级到最新远端版本（需要提交子模块指针变更）：

```bash
git submodule update --remote --merge
```

---

## 目录结构

```
backend/
  .env.example                  # 示例环境变量（复制为 .env；不要提交）
  docker-compose.full.yml        # DB + 两个服务一键启动（推荐）
  docker-compose.db.yml          # 仅 DB（可选）
  docker/                        # 编排仓库维护的 dev 镜像 Dockerfile（只安装依赖，不包含业务代码）
    Dockerfile.uav_telemetry.dev
    Dockerfile.uav_media_info.dev
  db-docker/
    .env.example                 # DB 配置示例（历史保留，可不使用）
    init/001_schema.sql          # 初始化表结构（首次创建数据卷时执行）
  docker-config/
    uav_telemetry.appsettings.json  # uav_telemetry 的容器内配置覆盖

  uav_telemetry/                 # 遥测服务
    appsettings.json
    ...

  uav-media-info/                # 媒体/录像服务
    .env
    ...
```

---

## 运行方式（推荐）：Docker 一键启动（DB + 两个服务）

### 0) 前置依赖

- Docker Engine + Docker Compose v2（支持 `docker compose`）
- Git

> 本仓库已经在 Linux 上验证通过。

### 1) 启动

在仓库根目录：

```bash
cd /home/ubuntu/backend

# 首次使用：创建本地环境变量配置（不要提交包含密码的 .env）
cp .env.example .env
```

可选：如果你要对接真实 ZLMediaKit，在根目录 `.env` 里配置 `ZLM_HOST` / `ZLM_SECRET`（当前后端流程未使用，预留给未来集成）。

```bash
cd /home/ubuntu/backend

# 一键启动：DB + uav_telemetry + uav-media-info
# --build：首次会构建两个“依赖镜像”（只装 pip 依赖，不包含代码）
docker compose -f docker-compose.full.yml up -d --build
```

说明：Compose 默认会读取仓库根目录的 `.env`（本仓库推荐方式）。

启动成功后：

- DB：`localhost:5433`（宿主机端口，容器内是 5432）
- 遥测服务：`http://localhost:8000/docs`
- 媒体服务：`http://localhost:8001/docs`

说明：如果端口冲突，可在根目录 `.env` 里改 `TELEMETRY_PORT` / `MEDIA_PORT`。

快速验证（可选）：

```bash
curl -fsSI http://localhost:8000/docs | head -n 5
curl -fsSI http://localhost:8001/docs | head -n 5
```

### 2) 停止

```bash
cd /home/ubuntu/backend

docker compose -f docker-compose.full.yml down
```

### 3) 开发/升级代码（不重新 build 镜像）

这套 Compose 使用 **bind mount** 把源码目录挂到容器内：

- 修改代码：直接在本机编辑 `uav_telemetry/` 或 `uav-media-info/`
- 容器内 `uvicorn --reload` 会自动热加载（适合开发）

升级代码（例如 `git pull`）后通常只需要重启服务容器：

```bash
cd /home/ubuntu/backend

git pull

# 重启两个服务（DB 不动）
docker compose -f docker-compose.full.yml restart uav_telemetry uav_media_info
```

如果改动了 `requirements.txt`，才需要重新 build：

```bash
docker compose -f docker-compose.full.yml up -d --build
```

---

## 子模块开发方式（把两个项目当成 sub repo）

这个仓库只负责编排与部署；业务代码分别在两个子模块仓库中：

- `uav_telemetry`：https://github.com/CHZarles/uav_telemetry
- `uav-media-info`：https://github.com/CHZarles/uav-media-info

典型工作流：

1) 进入子模块开发并 push 到子模块仓库：

```bash
cd uav_telemetry
git checkout -b feat/xxx
# edit...
git commit -am "..."
git push -u origin feat/xxx
```

2) 回到编排仓库提交“子模块指针”变更（让别人 clone 时拿到你更新的 commit）：

```bash
cd /home/ubuntu/backend
git add uav_telemetry uav-media-info
git commit -m "bump submodules"
git push
```

---

## 数据库（PostgreSQL）说明

### 配置位置

- 环境变量：根目录 `.env`
  - `POSTGRES_DB`（默认 `uav`）
  - `POSTGRES_USER`（默认 `uav_user`）
  - `POSTGRES_PASSWORD`（默认 `change_me`）
  - `POSTGRES_PORT`（默认 `5433`，避免占用宿主机已有的 5432）

### 初始化逻辑

- **首次创建数据卷时**，Postgres 会自动执行：`db-docker/init/001_schema.sql`
- 该脚本创建两张表（幂等）：
  - `flight_records`（uav_telemetry）
  - `video_recordings`（uav-media-info）

### 常用排查/操作

查看 DB 容器状态：

```bash
docker ps --filter name=uav-postgres
```

查看表：

```bash
docker exec -e PGPASSWORD=change_me uav-postgres psql -U uav_user -d uav -c "\\dt"
```

重置数据库（会删除所有数据！）

```bash
cd /home/ubuntu/backend

docker compose -f docker-compose.full.yml down
# 删除数据卷（危险操作）
docker volume rm backend_uav_postgres_data

# 再次启动会重新初始化 schema
docker compose -f docker-compose.full.yml up -d --build
```

---

## 服务配置说明

### uav_telemetry

- **配置来源**：容器内的 `appsettings.json`
- Compose 会用 `docker-config/uav_telemetry.appsettings.json` 覆盖挂载（指向 `db:5432`）

说明：Docker 一键启动时不要依赖修改子模块里的 `uav_telemetry/appsettings.json`；容器内实际生效的是覆盖文件。

容器外（宿主机）访问：

- Swagger：`http://localhost:8000/docs`
- 静态页面：`http://localhost:8000/static/websocket_client.html`

### uav-media-info

- **配置来源**：环境变量（支持 `.env`）
- Compose 直接注入：
  - `DATABASE_URL=postgresql://uav_user:change_me@db:5432/uav`
  - （可选）`ZLM_HOST` / `ZLM_SECRET`（默认空值）

说明：Docker 一键启动时不需要（也不建议）编辑子模块里的 `uav-media-info/.env`；优先通过 Compose 环境变量控制。

容器外（宿主机）访问：

- Swagger：`http://localhost:8001/docs`

---

## 仅启动 DB（可选）

如果你想用本机 Python/Conda 运行服务，只用 Docker 提供 DB：

```bash
cd /home/ubuntu/backend

docker compose -f docker-compose.db.yml up -d
```

此时 DB 在宿主机端口 `5433`，连接串示例：

```
postgresql://uav_user:change_me@localhost:5433/uav
```

---

## 常见问题（Troubleshooting）

---

## 外网访问（公网服务器）

当前一键启动后，这两个服务已经监听在宿主机端口：

- 遥测服务：`8000`（`http://<公网IP>:8000/docs`）
- 媒体服务：`8001`（`http://<公网IP>:8001/docs`）

如果外网访问不到，通常是“云厂商安全组/防火墙”没放行。

### 1) 放开云安全组（必做）

在你的云厂商控制台（安全组/防火墙规则）放行入站 TCP：

- `8000/tcp`
- `8001/tcp`

（可选）如果你之后要用域名 + HTTPS，通常只需要放行 `80/tcp` 和 `443/tcp`。

### 2) 放开服务器本机防火墙（如果你启用了 UFW）

```bash
sudo ufw status
sudo ufw allow 8000/tcp
sudo ufw allow 8001/tcp
```

### 3) 验证端口在公网可达

在你自己电脑上：

```bash
curl -fsSI http://<公网IP>:8000/docs | head -n 5
curl -fsSI http://<公网IP>:8001/docs | head -n 5
```

### 4) 安全建议（强烈）

- 不要把数据库端口暴露到公网。
  - 本仓库的 Compose 已将 Postgres 绑定到 `127.0.0.1:${POSTGRES_PORT}`（只允许本机访问），容器间仍通过 Docker 网络访问 DB。
- 如果你需要给公网用户长期开放，建议再加一层反向代理（Nginx/Caddy）走 `80/443`，并开启 TLS。
  - 注意：这台机器上 **80/443 可能已被其它容器占用**，需要在现有网关里加路由，或选择不同端口。

### 5) 浏览器跨域（CORS）

用 `curl`/后端服务调用不会受影响；但如果你在浏览器里从其它域名访问 API，可能会被 CORS 拦截。

- `uav_telemetry` 的允许来源在 `docker-config/uav_telemetry.appsettings.json` 的 `Cors.allow_origins`
- 需要把你的前端域名（例如 `https://your.domain`）加入 allow_origins

### 1) DB 端口冲突

- 现象：`address already in use`（例如宿主机已有 Postgres 占用 5432）
- 解决：使用 `db-docker/.env` 把 `POSTGRES_PORT` 改为未占用端口（例如 5433/5434），然后重启 compose。

### 2) DB 初始化脚本没生效

- 现象：表不存在
- 原因：Postgres **数据卷已存在** 时会跳过 `/docker-entrypoint-initdb.d`
- 解决：确认是否需要清库，按“重置数据库”删除数据卷后再启动。

### 3) 服务启动但访问不到

- 先看容器状态：

```bash
docker ps --filter name=uav-
```

- 看日志：

```bash
docker logs -n 200 uav-telemetry
docker logs -n 200 uav-media-info
```

### 4) 想切换为生产运行（不使用 reload）

当前 Compose 面向开发，服务使用 `uvicorn --reload`。
如需生产版（gunicorn/uvicorn workers、关闭 reload、限制资源、加反向代理等），可以在此基础上新增 `docker-compose.prod.yml`。

---

## 下一步建议

- 为两个服务加健康检查 `/healthz`（compose 中可依赖 health 状态）
- 增加生产 Compose（非 reload、带日志与资源限制）
