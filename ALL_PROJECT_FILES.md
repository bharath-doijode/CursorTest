# React Native Super App - Complete File Contents

Copy each file content below to recreate the project locally.

## Project Structure
```
react-native-super-app/
├── package.json
├── README.md
├── ARCHITECTURE.md
├── PROJECT_SUMMARY.md
├── .gitignore
├── zephyr.config.js
├── scripts/
│   ├── setup.sh
│   ├── dev-start.sh
│   └── build-all.sh
├── HostApp/
│   ├── package.json
│   ├── rspack.config.mjs
│   ├── babel.config.js
│   ├── tsconfig.json
│   ├── app.json
│   ├── index.js
│   └── src/
│       ├── App.tsx
│       ├── components/
│       │   └── MiniAppLoader.tsx
│       └── screens/
│           └── HomeScreen.tsx
├── MiniApp1/ (User Profile)
│   ├── package.json
│   ├── rspack.config.mjs
│   ├── babel.config.js
│   ├── tsconfig.json
│   ├── app.json
│   ├── index.js
│   └── src/
│       └── App.tsx
├── MiniApp2/ (Shopping Cart)
│   ├── package.json
│   ├── rspack.config.mjs
│   ├── babel.config.js
│   ├── tsconfig.json
│   ├── app.json
│   ├── index.js
│   └── src/
│       └── App.tsx
└── MiniApp3/ (Settings)
    ├── package.json
    ├── rspack.config.mjs
    ├── babel.config.js
    ├── tsconfig.json
    ├── app.json
    ├── index.js
    └── src/
        └── App.tsx
```

## Quick Setup Instructions

1. Create the directory structure above
2. Copy each file content from the sections below
3. Run: `chmod +x scripts/*.sh`
4. Run: `npm run setup`
5. Follow the README instructions

---

## 📁 ROOT FILES

### package.json
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

### .gitignore
```
# React Native
# OSX
.DS_Store

# Xcode
build/
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
xcuserdata
*.xccheckout
*.moved-aside
DerivedData
*.hmap
*.ipa
*.xcuserstate
project.xcworkspace

# Android/IntelliJ
build/
.idea
.gradle
local.properties
*.iml
*.hprof
.cxx/

# node.js
node_modules/
npm-debug.log
yarn-error.log

# BUCK
buck-out/
\.buckd/
*.keystore
!debug.keystore

# Bundle artifacts
*.jsbundle

# Re.Pack
.rspack-cache/
dist/

# Zephyr
.zephyr/

# CocoaPods
/ios/Pods/

# Expo
.expo/
web-build/

# Flipper
ios/Flipper/

# Temporary files created by Metro to check the health of the file watcher
.metro-health-check*

# Testing
coverage/

# Logs
logs
*.log

# Environment variables
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.vscode/
.idea/

# OS generated files
Thumbs.db
```

---

## 📁 SCRIPTS

### scripts/setup.sh
```bash
#!/bin/bash

# React Native Super App Setup Script
echo "🚀 Setting up React Native Super App..."

# Check Node.js version
NODE_VERSION=$(node --version)
echo "Node.js version: $NODE_VERSION"

# Check if React Native CLI is installed
if ! command -v react-native &> /dev/null; then
    echo "❌ React Native CLI not found. Installing..."
    npm install -g @react-native-community/cli
else
    echo "✅ React Native CLI found"
fi

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install

# Install HostApp dependencies
echo "📦 Installing HostApp dependencies..."
cd HostApp
npm install
cd ..

# Install MiniApp1 dependencies
echo "📦 Installing MiniApp1 dependencies..."
cd MiniApp1
npm install
cd ..

# Install MiniApp2 dependencies
echo "📦 Installing MiniApp2 dependencies..."
cd MiniApp2
npm install
cd ..

# Install MiniApp3 dependencies
echo "📦 Installing MiniApp3 dependencies..."
cd MiniApp3
npm install
cd ..

# Setup iOS dependencies (if on macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Setting up iOS dependencies..."
    cd HostApp/ios
    if command -v pod &> /dev/null; then
        pod install
        echo "✅ iOS pods installed for HostApp"
    else
        echo "⚠️  CocoaPods not found. Please install it manually: sudo gem install cocoapods"
    fi
    cd ../..
fi

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Start the mini-apps: npm run start:mini1 (in separate terminals for each)"
echo "2. Start the host app: npm run start:host"
echo "3. Run the app: npm run ios or npm run android"
echo ""
echo "📚 See README.md for detailed instructions"
```

### scripts/dev-start.sh
```bash
#!/bin/bash

# Development startup script for React Native Super App
echo "🚀 Starting React Native Super App in development mode..."

# Function to start a mini-app in background
start_miniapp() {
    local app_name=$1
    local app_dir=$2
    local port=$3
    
    echo "Starting $app_name on port $port..."
    cd $app_dir
    npm start &
    echo $! > "../.$app_name.pid"
    cd ..
}

# Function to cleanup background processes
cleanup() {
    echo "🛑 Stopping all mini-apps..."
    
    if [ -f ".MiniApp1.pid" ]; then
        kill $(cat .MiniApp1.pid) 2>/dev/null
        rm .MiniApp1.pid
    fi
    
    if [ -f ".MiniApp2.pid" ]; then
        kill $(cat .MiniApp2.pid) 2>/dev/null
        rm .MiniApp2.pid
    fi
    
    if [ -f ".MiniApp3.pid" ]; then
        kill $(cat .MiniApp3.pid) 2>/dev/null
        rm .MiniApp3.pid
    fi
    
    echo "✅ All mini-apps stopped"
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

# Start all mini-apps
start_miniapp "MiniApp1" "MiniApp1" "9001"
sleep 2
start_miniapp "MiniApp2" "MiniApp2" "9002"
sleep 2
start_miniapp "MiniApp3" "MiniApp3" "9003"
sleep 2

echo "✅ All mini-apps started!"
echo "📱 Mini-apps running on:"
echo "   - UserProfile: http://localhost:9001"
echo "   - ShoppingCart: http://localhost:9002"
echo "   - Settings: http://localhost:9003"
echo ""
echo "🎯 Now start the HostApp:"
echo "   cd HostApp && npm start"
echo ""
echo "Press Ctrl+C to stop all mini-apps"

# Keep script running
wait
```

---

**This file is getting quite long. Would you prefer if I:**

1. **Create separate files** for each component (HostApp, MiniApp1, etc.) so you can copy them individually?
2. **Provide a simple copy-paste method** where I give you the commands to create each file?
3. **Upload to a public GitHub repository** that you can clone?
4. **Continue with the current approach** but break it into smaller parts?

Which method would be most convenient for you to get the complete project?