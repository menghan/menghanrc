#!/usr/bin/env bash

go clean -cache          # ~/.cache/go-build
go clean -modcache       # ~/go/pkg/mod（确认不需要离线构建再执行）
npm cache clean --force  # ~/.npm/_cacache
pip cache purge          # ~/.cache/pip
uv cache clean           # ~/.cache/uv
bun pm cache rm          # ~/.bun/install/cache
pnpm store prune         # 只清未被引用的包，安全
