# 周报（2026-01-29 ～ 2026-02-05）

## 1. 范围与数据口径

- **范围**：父仓库（Orchestrator）+ 两个 Git Submodule：`uav_telemetry`、`uav-media-info`
- **统计口径**：以 2026-02-05 为截止，按 `git log --since='7 days ago'`（即 2026-01-29～2026-02-05）统计
- **提交量**：
  - Orchestrator：12 commits
  - `uav_telemetry`：12 commits
  - `uav-media-info`：9 commits

## 2. 本周交付概览（面向接手/部署）

### 2.1 一键启动（DB + 双服务）落地

- 提供 Docker Compose 一键启动方案：PostgreSQL + 两个 FastAPI 服务联动启动
- 服务镜像只安装依赖，业务代码通过 bind mount 挂载，便于“升级代码不重建镜像”
- 端口与配置集中到根目录 `.env`（模板 `.env.example`），部署时只需要改一处
- 数据库安全策略：DB 端口绑定在 `127.0.0.1`（避免公网暴露）

### 2.2 Submodule 管理流程工程化

- Orchestrator 仓库将两个 submodule 明确配置为 **跟踪 `master`**（`.gitmodules` 增加 `branch = master`）
- 补齐“同步更新 + 重新部署”的 Runbook（README 新增章节），方便接手同学按步骤操作

### 2.3 文档与变更治理

- README：完善接手/部署说明、端口/安全建议、子模块工作流
- CHANGELOG：按 Keep a Changelog + SemVer 规范整理
- CONTRIBUTING：规定变更提交流程（尤其是 submodule 指针 bump 的工作流）
- 补充 API 文档、移除过时说明（例如 deprecated 的播放相关说明）

## 3. 子项目进展摘要

### 3.1 `uav_telemetry`（回放/播放能力与稳定性）

- 播放/回放能力增强：播放控制（倍速、暂停、继续等）
- 数据与模型一致性：强化 `device_type` 贯穿 writer/reader/DB 的一致性
- 稳定性修复：session 清理死锁等问题修正
- 可测试性与工程化：补齐测试覆盖；新增 CI/CD、容器化与测试工作流

### 3.2 `uav-media-info`（hook/录像入库稳定性与 CI）

- 兼容性修复：忽略未注册 stream 的 record hook（避免错误写库/异常）
- 清理不再使用/不稳定接口：禁用 `play-url` endpoint
- 去除 import-time 单例副作用：禁用未使用的 `zlm_service` 模块级 singleton
- 工程化：补齐业务流测试；增加 CI/CD（Python 3.12）

## 4. 部署与验证状态（本周落地项）

- 服务部署方式：`docker compose -f docker-compose.full.yml up -d --build --remove-orphans`
- 常用验证方式：
  - `docker compose -f docker-compose.full.yml ps`
  - `curl -fsSI http://localhost:${TELEMETRY_PORT}/docs`
  - `curl -fsSI http://localhost:${MEDIA_PORT}/docs`

> 备注：数据库初始化 SQL 仅在首次创建数据卷时执行；需要重置 DB 时要删除数据卷（会丢数据）。

## 5. 风险与待办（面向下周）

- **发布可控性**：submodule 虽配置跟踪 `master`，但实际“发布版本”仍由 Orchestrator 里 submodule 指针决定；建议固定使用 README 里的 Runbook 做 bump 与部署。
- **数据库初始化**：schema 变更建议引入迁移机制（如 Alembic），避免靠 init.sql 处理增量。
- **配置/密钥治理**：继续保持 `.env` 不入库；如需对公网开放，建议在网关层做 TLS/鉴权。
- **CI 覆盖**：可以考虑为 Orchestrator 增加基础 CI（lint + compose 校验 + 简单 smoke test）。

## 6. 附录：本周提交列表（按仓库）

### 6.1 Orchestrator（backend）

- abdda90 docs: remove deprecated play-url
- b21df48 docs: add API documentation
- 3cd3bfe docs: add sync-and-redeploy runbook
- c4d0630 chore: track submodules on master
- 8b63ba7 chore: bump submodules
- 877e4c6 docs: adopt changelog best practices
- f09e3f7 docs: add changelog
- 02fc859 docs: set default ZLM_HOST in env example
- 3cfcbd1 docs: update env file references
- 0d03bd3 chore: centralize env config
- 39d352d chore: comment out unused ZLM env vars
- 773c93f chore: initial backend orchestrator

### 6.2 `uav_telemetry`

- 1b0e3a1 Merge pull request #8 from CHZarles/refactor/playback-and-introduce-deviceType
- 7f886ca 修正配置/资源清理；统一 gps_origin；清理 Pydantic 遗留
- a4b3c19 补齐测试覆盖（playback/DB/history/错误分支）
- 08bb782 新增 CI/CD 工作流、容器化与测试
- 7ccff49 更新 README；统一时间戳为毫秒 int
- 758d722 Fix session cleanup deadlock, tighten CORS/static, and validate telemetry
- eb6339e refactor: enforce device_type consistency in update_device method
- f45d793 feat: implement playback control (speed, pause, resume)
- 5d14e3f feat: upgrade test client and improve backend playback stability
- daa0e8d refractor: Replace rate_hz with device_type; propagate through writer/reader/DB
- 7551759 feat(playback): improve FileReader and add Player; integrate playback sessions
- 800a7e3 refactor: 回退代码到 b03ac38，保留历史记录

### 6.3 `uav-media-info`

- 472d822 Merge pull request #1 from CHZarles/fix/ignore-unregistered-record-mp4
- ad023b5 chore: disable unused zlm_service singleton
- 45a435c chore: disable play-url endpoint
- bdea244 docs: refresh README to match code
- 8d40be3 ci: run docker workflow on master and main
- 7bd5efd ci: run tests on python 3.12 only
- 223217e test: cover main business flows
- 139130b ci: add GitHub Actions CI/CD
- 7a83537 fix: ignore record hook for unregistered streams
