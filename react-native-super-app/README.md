# React Native Super App with Module Federation

A complete React Native super app implementation using **Re.Pack** and **Module Federation** with **Zephyr Cloud** integration. This project demonstrates how to build a modular mobile application where different features are developed as independent mini-apps and dynamically loaded at runtime.

## 🏗️ Architecture Overview

This super app consists of:

- **HostApp**: The main container app that loads and orchestrates mini-apps
- **MiniApp1 (User Profile)**: Independent user profile management mini-app
- **MiniApp2 (Shopping Cart)**: E-commerce functionality mini-app  
- **MiniApp3 (Settings)**: App configuration and preferences mini-app

### Key Technologies

- **React Native 0.75.4**: Cross-platform mobile development
- **Re.Pack**: Rspack-based bundler replacing Metro
- **Module Federation**: Dynamic loading of micro-frontends
- **Zephyr Cloud**: Remote bundle deployment and management
- **TypeScript**: Type-safe development

## 📋 Prerequisites

Before getting started, ensure you have:

- **Node.js** >= 18.0.0
- **npm** >= 8.0.0
- **React Native CLI** installed globally
- **Ruby** >= 3.3.2 (for iOS development)
- **Android Studio** (for Android development)
- **Xcode** (for iOS development on macOS)

## 🚀 Quick Start

### 1. Clone and Install Dependencies

```bash
# Clone the repository
git clone <repository-url>
cd react-native-super-app

# Install all dependencies for all apps
npm run install-all
```

### 2. Development Setup

#### Start All Mini Apps (Development Mode)

```bash
# Terminal 1: Start MiniApp1 (User Profile)
cd MiniApp1
npm start

# Terminal 2: Start MiniApp2 (Shopping Cart)  
cd MiniApp2
npm start

# Terminal 3: Start MiniApp3 (Settings)
cd MiniApp3
npm start

# Terminal 4: Start HostApp
cd HostApp
npm start
```

#### Run the Host App

```bash
# For iOS
npm run ios

# For Android
npm run android
```

## 📱 App Structure

### HostApp
- **Port**: Default React Native port (8081)
- **Role**: Container app with navigation and mini-app loading
- **Features**: 
  - Bottom tab navigation
  - Dynamic mini-app loading with error boundaries
  - Shared dependency management

### MiniApp1 (User Profile)
- **Port**: 9001
- **Features**:
  - User profile editing
  - Avatar management
  - Form validation
  - Persistent state management

### MiniApp2 (Shopping Cart)
- **Port**: 9002  
- **Features**:
  - Product catalog
  - Shopping cart functionality
  - Quantity management
  - Checkout simulation

### MiniApp3 (Settings)
- **Port**: 9003
- **Features**:
  - App preferences
  - Privacy & security settings
  - Support & legal links
  - Account management

## 🔧 Configuration Details

### Module Federation Setup

Each app has its own `rspack.config.mjs` with Module Federation configuration:

#### HostApp Configuration
```javascript
remotes: {
  UserProfileApp: `UserProfileApp@http://localhost:9001/${platform}/UserProfileApp.container.js.bundle`,
  ShoppingCartApp: `ShoppingCartApp@http://localhost:9002/${platform}/ShoppingCartApp.container.js.bundle`, 
  SettingsApp: `SettingsApp@http://localhost:9003/${platform}/SettingsApp.container.js.bundle`,
}
```

#### MiniApp Configuration
```javascript
exposes: {
  './App': './src/App.tsx',
}
```

### Shared Dependencies

All apps share these critical dependencies:
- `react` & `react-native` (marked as singletons)
- Navigation libraries
- UI components
- Native modules

## ☁️ Zephyr Cloud Integration

### Environment Configuration

The project supports different build modes:

- **Development**: Uses localhost URLs for mini-apps
- **Production**: Uses Zephyr Cloud URLs for remote bundles

### Building for Zephyr

```bash
# Bundle all apps for Zephyr deployment
npm run zephyr:bundle:all

# Or bundle individually with ZC=1 flag
ZC=1 npm run bundle:mini1
ZC=1 npm run bundle:mini2  
ZC=1 npm run bundle:mini3
ZC=1 npm run bundle:host
```

### Production Deployment

1. **Bundle Mini Apps for Zephyr**:
```bash
# Bundle MiniApp1
ZC=1 cd MiniApp1 && npm run bundle:ios && npm run bundle:android

# Bundle MiniApp2
ZC=1 cd MiniApp2 && npm run bundle:ios && npm run bundle:android

# Bundle MiniApp3  
ZC=1 cd MiniApp3 && npm run bundle:ios && npm run bundle:android
```

2. **Bundle Host App**:
```bash
ZC=1 cd HostApp && npm run bundle:ios && npm run bundle:android
```

3. **Build Release APK/IPA**:
```bash
# Android
cd HostApp/android
ZC=1 ./gradlew assembleRelease

# iOS (via Xcode)
# Set ZC=1 in build environment and build through Xcode
```

## 🛠️ Development Workflow

### Adding a New Mini App

1. **Create Mini App Directory**:
```bash
mkdir MiniApp4
cd MiniApp4
```

2. **Setup Package.json**:
```json
{
  "name": "new-mini-app",
  "scripts": {
    "start": "react-native start --port 9004",
    "bundle:ios": "react-native bundle --platform ios --dev false --entry-file index.js",
    "bundle:android": "react-native bundle --platform android --dev false --entry-file index.js"
  }
}
```

3. **Configure Rspack**:
```javascript
// rspack.config.mjs
new Repack.plugins.ModuleFederationPluginV2({
  name: 'NewMiniApp',
  filename: 'NewMiniApp.container.js.bundle',
  exposes: {
    './App': './src/App.tsx',
  },
  // ... shared dependencies
})
```

4. **Update HostApp**:
```javascript
// Add to HostApp rspack.config.mjs remotes
NewMiniApp: `NewMiniApp@http://localhost:9004/${platform}/NewMiniApp.container.js.bundle`
```

### Error Handling

The HostApp includes comprehensive error boundaries:
- **Loading States**: Shows loading indicators while mini-apps load
- **Error States**: Graceful fallbacks when mini-apps fail to load
- **Network Issues**: Handles connectivity problems

## 🧪 Testing

### Running Tests

```bash
# Test all apps
npm run test

# Test individual apps
cd HostApp && npm test
cd MiniApp1 && npm test
cd MiniApp2 && npm test
cd MiniApp3 && npm test
```

### Manual Testing Checklist

- [ ] All mini-apps load correctly in HostApp
- [ ] Navigation between tabs works
- [ ] Each mini-app functions independently
- [ ] Error boundaries work when mini-apps fail
- [ ] Production builds work with Zephyr URLs

## 🐛 Troubleshooting

### Common Issues

1. **Mini-app fails to load**:
   - Ensure the mini-app server is running on correct port
   - Check network connectivity
   - Verify Module Federation configuration

2. **Shared dependency conflicts**:
   - Ensure all apps use same versions of shared dependencies
   - Check singleton configuration in rspack configs

3. **Build failures**:
   - Clear node_modules and reinstall: `rm -rf node_modules && npm install`
   - Clear React Native cache: `npx react-native start --reset-cache`

4. **Zephyr deployment issues**:
   - Verify ZC=1 environment variable is set
   - Check Zephyr Cloud credentials and project configuration

### Debug Mode

Enable verbose logging:
```bash
# Start with debug logs
DEBUG=* npm start

# Or for specific mini-app
cd MiniApp1
DEBUG=* npm start
```

## 📚 Key Concepts Explained

### Module Federation Benefits
- **Independent Development**: Teams can work on mini-apps separately
- **Dynamic Loading**: Mini-apps loaded on-demand, reducing initial bundle size
- **Shared Dependencies**: Efficient sharing of common libraries
- **Hot Updates**: Update mini-apps without rebuilding entire app

### Re.Pack Advantages
- **Better Performance**: Rspack is faster than Metro bundler
- **Module Federation Support**: Native support for micro-frontends
- **Advanced Caching**: Better build caching and optimization
- **Web Compatibility**: Easier to share code with web applications

### Zephyr Cloud Features
- **Remote Deployment**: Deploy bundles to cloud without app store updates
- **A/B Testing**: Test different versions of mini-apps
- **Rollback Capability**: Quickly revert to previous versions
- **Analytics**: Monitor mini-app performance and usage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-miniapp`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Callstack Team** for Re.Pack development and Zephyr integration
- **Module Federation Team** for the micro-frontend architecture
- **React Native Community** for the amazing ecosystem

---

## 📞 Support

If you encounter any issues or have questions:

1. Check the troubleshooting section above
2. Review the [Re.Pack documentation](https://re-pack.dev)
3. Check [Zephyr Cloud documentation](https://docs.zephyr-cloud.io)
4. Open an issue in this repository

Happy coding! 🚀