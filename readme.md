# docker-registry-proxy


教程：https://www.hackeradar.com/posts/docker/docker-registry-proxy

## 维护

初始化 + 启动服务
```bash
make init
make up
```

手动清理缓存
```bash
make cleanup
```

设置每日自动清理
```bash
make cron
```

停止服务
```bash
make down
```
