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