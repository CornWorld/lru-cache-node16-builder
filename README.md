# LRU Cache Node.js 16 Builder

This repository automatically builds and publishes Node.js 16 compatible versions of [lru-cache](https://github.com/isaacs/node-lru-cache) to npm as `lru-cache-mp`.

## How it works

1. GitHub Actions monitors the upstream repository for new releases
2. When a new release is detected, it automatically:
   - Downloads the source code
   - Compiles it for Node.js 16 compatibility using Babel
   - Publishes to npm with a `-node16` version suffix

## Published Package

- **Package name**: `lru-cache-mp`
- **Compatible with**: Node.js 16+, WeChat MiniProgram
- **npm**: https://www.npmjs.com/package/lru-cache-mp

## Usage

```bash
npm install lru-cache-mp
```

```javascript
import { LRUCache } from 'lru-cache-mp'
// or
const { LRUCache } = require('lru-cache-mp')
```

## License

The original lru-cache is licensed under ISC. This builder maintains the same license.
