# 项目路径变量
REGISTRY_DIR=registry
CACHE_DIR=$(REGISTRY_DIR)/cache
CONFIG_FILE=$(REGISTRY_DIR)/config.yml
CLEANUP_SCRIPT=$(REGISTRY_DIR)/cleanup_cache.sh
INIT_SCRIPT=$(REGISTRY_DIR)/init_cache.sh
CRON_LOG=/var/log/registry-cleanup.log

# 可调整最大缓存大小（单位：GB）
MAX_CACHE_GB=10

.PHONY: all init up down cleanup cron status

all: init up

## 初始化缓存目录结构
init:
	@echo "[init] Creating registry cache structure..."
	mkdir -p $(CACHE_DIR)/docker/registry/v2/blobs/sha256
	mkdir -p $(CACHE_DIR)/docker/registry/v2/repositories
	chown -R 1000:1000 $(CACHE_DIR)
	@echo "[init] Done."

## 启动 Docker Compose 服务
up:
	docker compose up -d

## 停止 Docker Compose 服务
down:
	docker compose down

## 手动清理缓存（限制大小）
cleanup:
	@echo "[cleanup] Checking cache size..."
	@used=$$(du -s --block-size=1G $(CACHE_DIR)/docker/registry/v2/blobs/sha256 | cut -f1); \
	if [ $$used -gt $(MAX_CACHE_GB) ]; then \
		echo "[cleanup] Used: $$used GB > $(MAX_CACHE_GB) GB. Cleaning..."; \
		find $(CACHE_DIR)/docker/registry/v2/blobs/sha256 -type f -printf '%T@ %p\n' | \
		sort -n | head -n 1000 | cut -d' ' -f2- | xargs rm -f; \
		echo "[cleanup] Done."; \
	else \
		echo "[cleanup] Used: $$used GB <= $(MAX_CACHE_GB) GB. No cleanup needed."; \
	fi

## 安装定时清理任务到 crontab（每天凌晨 3 点）
cron:
	@echo "[cron] Installing cleanup cron job..."
	@(crontab -l 2>/dev/null; echo "0 3 * * * make -C $$(pwd) cleanup >> $(CRON_LOG) 2>&1") | crontab -
	@echo "[cron] Installed."

## 显示当前服务状态
status:
	docker compose ps
