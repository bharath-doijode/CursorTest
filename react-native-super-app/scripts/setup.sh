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