# Complete React Native Super App - Manual Setup Guide

If you can't download the archive directly, follow this guide to recreate the entire project manually.

## Step 1: Create Project Structure

```bash
mkdir react-native-super-app
cd react-native-super-app

# Create main directories
mkdir -p HostApp/src/{components,screens}
mkdir -p MiniApp1/src
mkdir -p MiniApp2/src  
mkdir -p MiniApp3/src
mkdir scripts
```

## Step 2: Root Package.json

Create `package.json` in root directory:

```json
{
  "name": "react-native-super-app",
  "version": "1.0.0",
  "description": "React Native Super App with Module Federation using Re.Pack and Zephyr",
  "private": true,
  "workspaces": [
    "HostApp",
    "MiniApp1", 
    "MiniApp2",
    "MiniApp3"
  ],
  "scripts": {
    "setup": "./scripts/setup.sh",
    "dev:start": "./scripts/dev-start.sh",
    "build:all": "./scripts/build-all.sh",
    "build:zephyr": "./scripts/build-all.sh --zephyr",
    "install-all": "npm install && npm run install:host && npm run install:mini1 && npm run install:mini2 && npm run install:mini3",
    "install:host": "cd HostApp && npm install",
    "install:mini1": "cd MiniApp1 && npm install", 
    "install:mini2": "cd MiniApp2 && npm install",
    "install:mini3": "cd MiniApp3 && npm install",
    "start": "npm run start:host",
    "start:host": "cd HostApp && npm start",
    "start:mini1": "cd MiniApp1 && npm start",
    "start:mini2": "cd MiniApp2 && npm start", 
    "start:mini3": "cd MiniApp3 && npm start",
    "bundle:all": "npm run bundle:mini1 && npm run bundle:mini2 && npm run bundle:mini3 && npm run bundle:host",
    "bundle:host": "cd HostApp && npm run bundle",
    "bundle:mini1": "cd MiniApp1 && npm run bundle",
    "bundle:mini2": "cd MiniApp2 && npm run bundle",
    "bundle:mini3": "cd MiniApp3 && npm run bundle",
    "zephyr:bundle:all": "ZC=1 npm run bundle:all",
    "android": "cd HostApp && npm run android",
    "ios": "cd HostApp && npm run ios",
    "test": "npm run test:host && npm run test:mini1 && npm run test:mini2 && npm run test:mini3",
    "test:host": "cd HostApp && npm test",
    "test:mini1": "cd MiniApp1 && npm test",
    "test:mini2": "cd MiniApp2 && npm test",
    "test:mini3": "cd MiniApp3 && npm test",
    "lint": "npm run lint:host && npm run lint:mini1 && npm run lint:mini2 && npm run lint:mini3",
    "lint:host": "cd HostApp && npm run lint",
    "lint:mini1": "cd MiniApp1 && npm run lint",
    "lint:mini2": "cd MiniApp2 && npm run lint",
    "lint:mini3": "cd MiniApp3 && npm run lint",
    "clean": "npm run clean:host && npm run clean:mini1 && npm run clean:mini2 && npm run clean:mini3",
    "clean:host": "cd HostApp && rm -rf node_modules && npm install",
    "clean:mini1": "cd MiniApp1 && rm -rf node_modules && npm install",
    "clean:mini2": "cd MiniApp2 && rm -rf node_modules && npm install",
    "clean:mini3": "cd MiniApp3 && rm -rf node_modules && npm install"
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=8.0.0"
  }
}
```

## Step 3: HostApp Configuration

### HostApp/package.json
```json
{
  "name": "host-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "lint": "eslint .",
    "start": "react-native start --experimental-debugger",
    "test": "jest",
    "bundle": "npm run bundle:ios && npm run bundle:android",
    "bundle:ios": "react-native bundle --platform ios --dev false --entry-file index.js",
    "bundle:android": "react-native bundle --platform android --dev false --entry-file index.js"
  },
  "dependencies": {
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/native-stack": "^6.9.17",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.8.2",
    "react-native-screens": "^3.29.0",
    "react-native-vector-icons": "^10.0.3"
  },
  "devDependencies": {
    "@babel/core": "^7.20.0",
    "@babel/preset-env": "^7.20.0",
    "@babel/runtime": "^7.20.0",
    "@callstack/repack": "^4.3.0",
    "@react-native/babel-preset": "0.75.4",
    "@react-native/eslint-config": "0.75.4",
    "@react-native/metro-config": "0.75.4",
    "@react-native/typescript-config": "0.75.4",
    "@types/react": "^18.2.6",
    "@types/react-test-renderer": "^18.0.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.3.1",
    "typescript": "5.0.4",
    "zephyr-repack-plugin": "^1.0.0"
  },
  "engines": {
    "node": ">=18"
  }
}
```

### HostApp/rspack.config.mjs
```javascript
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';
import { withZephyr } from 'zephyr-repack-plugin';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const USE_ZEPHYR = Boolean(process.env.ZC);

const config = (env) => {
  const { platform, mode } = env;
  
  return {
    context: __dirname,
    entry: './index.js',
    resolve: {
      ...Repack.getResolveOptions(),
    },
    output: {
      uniqueName: 'react-native-host-app',
    },
    module: {
      rules: [
        ...Repack.getJsTransformRules(),
        ...Repack.getAssetTransformRules(),
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        platform,
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'HostApp',
        filename: 'HostApp.container.js.bundle',
        dts: false,
        remotes: {
          UserProfileApp: `UserProfileApp@http://localhost:9001/${platform}/UserProfileApp.container.js.bundle`,
          ShoppingCartApp: `ShoppingCartApp@http://localhost:9002/${platform}/ShoppingCartApp.container.js.bundle`,
          SettingsApp: `SettingsApp@http://localhost:9003/${platform}/SettingsApp.container.js.bundle`,
        },
        shared: {
          react: {
            singleton: true,
            version: '18.3.1',
            eager: true,
          },
          'react-native': {
            singleton: true,
            version: '0.75.4',
            eager: true,
          },
          '@react-navigation/native': {
            singleton: true,
            eager: true,
          },
          '@react-navigation/native-stack': {
            singleton: true,
            eager: true,
          },
          '@react-navigation/bottom-tabs': {
            singleton: true,
            eager: true,
          },
          'react-native-safe-area-context': {
            singleton: true,
            eager: true,
          },
          'react-native-screens': {
            singleton: true,
            eager: true,
          },
          'react-native-vector-icons': {
            singleton: true,
            eager: true,
          },
        },
      }),
      new Repack.plugins.HermesBytecodePlugin({
        enabled: mode === 'production',
        test: /\.(js)?bundle$/,
        exclude: /index.bundle$/,
      }),
    ],
  };
};

export default USE_ZEPHYR ? withZephyr()(config) : config;
```

## Step 4: Continue with remaining files...

This guide is getting long. Would you like me to:

1. **Create a GitHub repository** with all the files so you can clone it
2. **Provide the files in smaller chunks** that you can copy-paste
3. **Create individual files** one by one for you to copy
4. **Try a different download method**

Which option would work best for you?