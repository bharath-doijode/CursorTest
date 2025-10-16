#!/bin/bash

# Build script for all apps
echo "🏗️  Building React Native Super App for production..."

# Set Zephyr flag if provided
if [ "$1" = "--zephyr" ]; then
    export ZC=1
    echo "☁️  Building for Zephyr Cloud deployment"
else
    echo "🏠 Building for local deployment"
fi

# Function to build an app
build_app() {
    local app_name=$1
    local app_dir=$2
    
    echo "Building $app_name..."
    cd $app_dir
    
    # Build for both platforms
    npm run bundle:ios
    if [ $? -ne 0 ]; then
        echo "❌ Failed to build $app_name for iOS"
        exit 1
    fi
    
    npm run bundle:android
    if [ $? -ne 0 ]; then
        echo "❌ Failed to build $app_name for Android"
        exit 1
    fi
    
    echo "✅ $app_name built successfully"
    cd ..
}

# Build all mini-apps first
build_app "MiniApp1 (UserProfile)" "MiniApp1"
build_app "MiniApp2 (ShoppingCart)" "MiniApp2"
build_app "MiniApp3 (Settings)" "MiniApp3"

# Build host app last
build_app "HostApp" "HostApp"

echo "🎉 All apps built successfully!"

if [ "$ZC" = "1" ]; then
    echo "☁️  Bundles deployed to Zephyr Cloud"
    echo "🚀 Ready for production deployment"
else
    echo "📦 Local bundles created"
    echo "🧪 Ready for testing"
fi