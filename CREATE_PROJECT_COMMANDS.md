# React Native Super App - Copy-Paste Creation Commands

Run these commands in your terminal to create the complete project:

## Step 1: Create Project Structure
```bash
mkdir react-native-super-app
cd react-native-super-app

# Create directories
mkdir -p HostApp/src/{components,screens}
mkdir -p MiniApp1/src
mkdir -p MiniApp2/src  
mkdir -p MiniApp3/src
mkdir scripts
```

## Step 2: Create Root Files

### Root package.json
```bash
cat > package.json << 'EOF'
{
  "name": "react-native-super-app",
  "version": "1.0.0",
  "description": "React Native Super App with Module Federation using Re.Pack and Zephyr",
  "private": true,
  "workspaces": ["HostApp", "MiniApp1", "MiniApp2", "MiniApp3"],
  "scripts": {
    "setup": "./scripts/setup.sh",
    "dev:start": "./scripts/dev-start.sh",
    "build:all": "./scripts/build-all.sh",
    "build:zephyr": "./scripts/build-all.sh --zephyr",
    "install-all": "npm install && npm run install:host && npm run install:mini1 && npm run install:mini2 && npm run install:mini3",
    "start": "npm run start:host",
    "start:host": "cd HostApp && npm start",
    "start:mini1": "cd MiniApp1 && npm start",
    "start:mini2": "cd MiniApp2 && npm start", 
    "start:mini3": "cd MiniApp3 && npm start",
    "android": "cd HostApp && npm run android",
    "ios": "cd HostApp && npm run ios"
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=8.0.0"
  }
}
EOF
```

### Setup Script
```bash
cat > scripts/setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Setting up React Native Super App..."

NODE_VERSION=$(node --version)
echo "Node.js version: $NODE_VERSION"

if ! command -v react-native &> /dev/null; then
    echo "❌ React Native CLI not found. Installing..."
    npm install -g @react-native-community/cli
else
    echo "✅ React Native CLI found"
fi

echo "📦 Installing dependencies..."
npm install
cd HostApp && npm install && cd ..
cd MiniApp1 && npm install && cd ..
cd MiniApp2 && npm install && cd ..
cd MiniApp3 && npm install && cd ..

echo "✅ Setup complete!"
echo "🎯 Next steps:"
echo "1. Start mini-apps: npm run dev:start"
echo "2. Start host app: cd HostApp && npm start"
echo "3. Run app: npm run ios or npm run android"
EOF

chmod +x scripts/setup.sh
```

## Step 3: Create HostApp

### HostApp package.json
```bash
cat > HostApp/package.json << 'EOF'
{
  "name": "host-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "start": "react-native start --experimental-debugger",
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
    "@callstack/repack": "^4.3.0",
    "@react-native/babel-preset": "0.75.4",
    "typescript": "5.0.4",
    "zephyr-repack-plugin": "^1.0.0"
  }
}
EOF
```

### HostApp Configuration Files
```bash
# HostApp index.js
cat > HostApp/index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

# HostApp app.json
cat > HostApp/app.json << 'EOF'
{
  "name": "HostApp",
  "displayName": "Super App Host"
}
EOF

# HostApp babel.config.js
cat > HostApp/babel.config.js << 'EOF'
module.exports = {
  presets: ['@react-native/babel-preset'],
};
EOF
```

## Step 4: Create MiniApp Configurations

### MiniApp1 (User Profile)
```bash
cat > MiniApp1/package.json << 'EOF'
{
  "name": "user-profile-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "react-native start --port 9001 --experimental-debugger",
    "bundle": "npm run bundle:ios && npm run bundle:android",
    "bundle:ios": "react-native bundle --platform ios --dev false --entry-file index.js",
    "bundle:android": "react-native bundle --platform android --dev false --entry-file index.js"
  },
  "dependencies": {
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.8.2"
  },
  "devDependencies": {
    "@callstack/repack": "^4.3.0",
    "@react-native/babel-preset": "0.75.4",
    "typescript": "5.0.4",
    "zephyr-repack-plugin": "^1.0.0"
  }
}
EOF

cat > MiniApp1/app.json << 'EOF'
{
  "name": "UserProfileApp",
  "displayName": "User Profile Mini App"
}
EOF

cat > MiniApp1/index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

cat > MiniApp1/babel.config.js << 'EOF'
module.exports = {
  presets: ['@react-native/babel-preset'],
};
EOF
```

### MiniApp2 & MiniApp3 (Similar structure)
```bash
# MiniApp2 (Shopping Cart)
cat > MiniApp2/package.json << 'EOF'
{
  "name": "shopping-cart-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "react-native start --port 9002 --experimental-debugger",
    "bundle": "npm run bundle:ios && npm run bundle:android",
    "bundle:ios": "react-native bundle --platform ios --dev false --entry-file index.js",
    "bundle:android": "react-native bundle --platform android --dev false --entry-file index.js"
  },
  "dependencies": {
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.8.2"
  },
  "devDependencies": {
    "@callstack/repack": "^4.3.0",
    "@react-native/babel-preset": "0.75.4",
    "typescript": "5.0.4",
    "zephyr-repack-plugin": "^1.0.0"
  }
}
EOF

# Similar files for MiniApp2 and MiniApp3...
```

## Step 5: Quick Start

After creating the basic structure:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run setup
npm run setup

# Start development
# Terminal 1: Start mini-apps
npm run dev:start

# Terminal 2: Start host app  
cd HostApp && npm start

# Terminal 3: Run the app
npm run ios  # or npm run android
```

---

## 🚀 Alternative: One-Command Setup

If the above is too much, I can create a single script that generates everything:

```bash
curl -o create-super-app.sh https://raw.githubusercontent.com/[repo]/create-super-app.sh
chmod +x create-super-app.sh
./create-super-app.sh
```

**Would you prefer:**
1. **Continue with the copy-paste commands** (I'll provide the remaining files)
2. **A single setup script** that creates everything automatically
3. **Individual file contents** that you can copy one by one
4. **A different approach** entirely

Let me know which method works best for you!