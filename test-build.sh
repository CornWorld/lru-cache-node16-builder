#!/bin/bash

echo "Testing local build process..."

# 获取最新版本
UPSTREAM_VERSION=$(curl -s https://api.github.com/repos/isaacs/node-lru-cache/releases/latest | jq -r '.tag_name' | sed 's/^v//')
echo "Latest upstream version: $UPSTREAM_VERSION"

# 下载源代码
echo "Downloading source code..."
wget -q https://github.com/isaacs/node-lru-cache/archive/v${UPSTREAM_VERSION}.tar.gz
tar -xzf v${UPSTREAM_VERSION}.tar.gz
mv node-lru-cache-${UPSTREAM_VERSION} upstream

# 安装构建依赖
echo "Installing build dependencies..."
npm install --no-save \
  @babel/cli \
  @babel/core \
  @babel/preset-env \
  @babel/preset-typescript \
  @babel/plugin-transform-optional-chaining \
  @babel/plugin-transform-nullish-coalescing-operator \
  typescript \
  esbuild

# 准备 package.json
echo "Preparing package.json..."
cp upstream/package.json package.json
node -e "
const pkg = require('./package.json');
const config = require('./build-config.json');
pkg.name = config.npm.packageName;
pkg.version = '${UPSTREAM_VERSION}-node16';
pkg.description = config.npm.description;
pkg.engines = { node: '>=16' };
delete pkg.scripts;
delete pkg.devDependencies;
delete pkg.tshy;
require('fs').writeFileSync('./package.json', JSON.stringify(pkg, null, 2));
"

# 构建
echo "Building for Node 16..."
mkdir -p dist/commonjs dist/esm

# 编译
npx babel upstream/src --out-dir dist/commonjs --extensions .ts --env commonjs
npx babel upstream/src --out-dir dist/esm --extensions .ts

# 生成类型定义
npx tsc upstream/src/index.ts \
  --declaration \
  --emitDeclarationOnly \
  --outDir dist/commonjs \
  --target es2021 \
  --module commonjs \
  --moduleResolution node \
  --esModuleInterop true \
  --skipLibCheck true

cp dist/commonjs/*.d.ts dist/esm/ || true

# 创建压缩版本
npx esbuild dist/esm/index.js --minify --outfile=dist/esm/index.min.js
npx esbuild dist/commonjs/index.js --minify --outfile=dist/commonjs/index.min.js

# 复制文件
cp upstream/LICENSE LICENSE

echo "Build completed! Check the dist/ directory."
echo "To publish, run: npm publish --dry-run"
