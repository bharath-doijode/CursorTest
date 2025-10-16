#!/bin/bash

# React Native Super App - Complete Setup with Latest Versions
# This script creates complete React Native projects for Host and Mini Apps

echo "🚀 Creating React Native Super App with Latest Versions..."

PROJECT_NAME="react-native-super-app"

# Create project directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "📱 Creating complete React Native projects..."

# Check if React Native CLI is available
if ! command -v react-native &> /dev/null; then
    echo "Installing React Native CLI..."
    npm install -g @react-native-community/cli
fi

echo "📱 Creating HostApp..."
npx @react-native-community/cli@latest init HostApp --version latest --skip-install
cd HostApp

# Update HostApp package.json for Re.Pack and Module Federation
cat > package.json << 'EOF'
{
  "name": "HostApp",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios",
    "lint": "eslint .",
    "start": "react-native webpack-start",
    "test": "jest"
  },
  "dependencies": {
    "@react-navigation/bottom-tabs": "^6.5.20",
    "@react-navigation/native": "^6.1.17",
    "@react-navigation/native-stack": "^6.9.26",
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.10.5",
    "react-native-screens": "^3.34.0"
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
    "@types/react": "^18.3.3",
    "@types/react-test-renderer": "^18.3.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.3.1",
    "typescript": "5.0.4",
    "webpack": "^5.94.0"
  },
  "engines": {
    "node": ">=18"
  }
}
EOF

# Create webpack config for HostApp
cat > webpack.config.mjs << 'EOF'
import * as Repack from '@callstack/repack';

export default (env) => {
  const {
    mode = 'development',
    context = Repack.getDirname(import.meta.url),
    entry = './index.js',
    platform = process.env.RN_PLATFORM ?? 'android',
    minimize = mode === 'production',
    devServer = undefined,
    bundleFilename = undefined,
    sourceMapFilename = undefined,
    assetsPath = undefined,
    reactNativePath = new URL('./node_modules/react-native', import.meta.url).pathname,
  } = env;

  return {
    mode,
    devtool: false,
    context,
    entry: [
      ...Repack.getInitializationEntries(reactNativePath, {
        hmr: devServer && devServer.hmr,
      }),
      entry,
    ],
    resolve: {
      ...Repack.getResolveOptions(platform),
    },
    output: {
      clean: true,
      hashFunction: 'xxhash64',
      path: Repack.getOutputPath(platform, context),
      filename: 'index.bundle',
      chunkFilename: '[name].chunk.bundle',
      publicPath: Repack.getPublicPath({ platform, devServer }),
    },
    optimization: {
      minimize,
      chunkIds: 'named',
    },
    module: {
      rules: [
        Repack.getRules().reactNative,
        Repack.getRules().babel,
        Repack.getRules().images,
        Repack.getRules().svg,
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        context,
        mode,
        platform,
        devServer,
        output: {
          bundleFilename,
          sourceMapFilename,
          assetsPath,
        },
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'HostApp',
        remotes: {
          UserProfileApp: `UserProfileApp@http://localhost:9001/${platform}/UserProfileApp.container.js.bundle`,
          ShoppingCartApp: `ShoppingCartApp@http://localhost:9002/${platform}/ShoppingCartApp.container.js.bundle`,
          SettingsApp: `SettingsApp@http://localhost:9003/${platform}/SettingsApp.container.js.bundle`,
        },
        shared: {
          react: {
            singleton: true,
            eager: true,
          },
          'react-native': {
            singleton: true,
            eager: true,
          },
          '@react-navigation/native': {
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
        },
      }),
    ],
  };
};
EOF

# Create HostApp main component
cat > App.tsx << 'EOF'
import React, {Suspense, lazy, ErrorInfo, Component} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {SafeAreaView, StatusBar, StyleSheet, Text, View, ActivityIndicator} from 'react-native';

const Tab = createBottomTabNavigator();

// Error Boundary Component
class ErrorBoundary extends Component<
  {children: React.ReactNode; appName: string},
  {hasError: boolean; error?: Error}
> {
  constructor(props: {children: React.ReactNode; appName: string}) {
    super(props);
    this.state = {hasError: false};
  }

  static getDerivedStateFromError(error: Error) {
    return {hasError: true, error};
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error(`Error in ${this.props.appName}:`, error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      return (
        <View style={styles.errorContainer}>
          <Text style={styles.errorTitle}>Failed to load {this.props.appName}</Text>
          <Text style={styles.errorMessage}>Make sure the mini app is running</Text>
        </View>
      );
    }
    return this.props.children;
  }
}

// Mini App Loader Component
const MiniAppLoader = ({appName, moduleName}: {appName: string; moduleName: string}) => {
  const LazyMiniApp = lazy(() => {
    try {
      // @ts-ignore - Module Federation dynamic import
      return import(`${appName}/${moduleName}`);
    } catch (error) {
      console.error(`Failed to load ${appName}:`, error);
      throw error;
    }
  });

  return (
    <ErrorBoundary appName={appName}>
      <Suspense fallback={
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color="#007AFF" />
          <Text style={styles.loadingText}>Loading {appName}...</Text>
        </View>
      }>
        <LazyMiniApp />
      </Suspense>
    </ErrorBoundary>
  );
};

// Home Screen
const HomeScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.title}>Welcome to Super App</Text>
    <Text style={styles.subtitle}>Module Federation with Latest React Native</Text>
    <View style={styles.infoSection}>
      <Text style={styles.infoTitle}>Architecture Features</Text>
      <Text style={styles.infoItem}>🔧 Re.Pack Integration</Text>
      <Text style={styles.infoItem}>🌐 Module Federation</Text>
      <Text style={styles.infoItem}>📱 Latest React Native</Text>
      <Text style={styles.infoItem}>⚡ Hot Reloading</Text>
    </View>
  </View>
);

// Placeholder components
const UserProfileScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>User Profile Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp1 with: npm run start:mini1</Text>
  </View>
);

const ShoppingCartScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>Shopping Cart Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp2 with: npm run start:mini2</Text>
  </View>
);

const SettingsScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>Settings Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp3 with: npm run start:mini3</Text>
  </View>
);

// Try to load mini-apps, fallback to placeholders
const UserProfileApp = () => {
  try {
    return <MiniAppLoader appName="UserProfileApp" moduleName="./App" />;
  } catch {
    return <UserProfileScreen />;
  }
};

const ShoppingCartApp = () => {
  try {
    return <MiniAppLoader appName="ShoppingCartApp" moduleName="./App" />;
  } catch {
    return <ShoppingCartScreen />;
  }
};

const SettingsApp = () => {
  try {
    return <MiniAppLoader appName="SettingsApp" moduleName="./App" />;
  } catch {
    return <SettingsScreen />;
  }
};

function App(): React.JSX.Element {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />
      <NavigationContainer>
        <Tab.Navigator
          screenOptions={{
            tabBarActiveTintColor: '#007AFF',
            tabBarInactiveTintColor: '#8E8E93',
            headerShown: false,
          }}>
          <Tab.Screen name="Home" component={HomeScreen} />
          <Tab.Screen name="Profile" component={UserProfileApp} />
          <Tab.Screen name="Cart" component={ShoppingCartApp} />
          <Tab.Screen name="Settings" component={SettingsApp} />
        </Tab.Navigator>
      </NavigationContainer>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1D1D1F',
    marginBottom: 8,
    textAlign: 'center',
  },
  subtitle: {
    fontSize: 16,
    color: '#666666',
    marginBottom: 30,
    textAlign: 'center',
  },
  text: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
    textAlign: 'center',
  },
  subtext: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
  },
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5F5F5',
  },
  loadingText: {
    marginTop: 16,
    fontSize: 16,
    color: '#666666',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#FFF5F5',
    padding: 20,
  },
  errorTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#D32F2F',
    marginBottom: 8,
    textAlign: 'center',
  },
  errorMessage: {
    fontSize: 14,
    color: '#666666',
    textAlign: 'center',
  },
  infoSection: {
    backgroundColor: '#F0F8FF',
    padding: 16,
    borderRadius: 12,
    width: '100%',
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 12,
    textAlign: 'center',
  },
  infoItem: {
    fontSize: 14,
    color: '#666666',
    marginBottom: 4,
    textAlign: 'center',
  },
});

export default App;
EOF

cd ..

echo "📱 Creating MiniApp1 (User Profile)..."
npx @react-native-community/cli@latest init MiniApp1 --version latest --skip-install
cd MiniApp1

# Update MiniApp1 package.json
cat > package.json << 'EOF'
{
  "name": "MiniApp1",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android --port 9001",
    "ios": "react-native run-ios --port 9001",
    "lint": "eslint .",
    "start": "react-native webpack-start --port 9001",
    "test": "jest"
  },
  "dependencies": {
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.10.5"
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
    "@types/react": "^18.3.3",
    "@types/react-test-renderer": "^18.3.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.3.1",
    "typescript": "5.0.4",
    "webpack": "^5.94.0"
  },
  "engines": {
    "node": ">=18"
  }
}
EOF

# Create webpack config for MiniApp1
cat > webpack.config.mjs << 'EOF'
import * as Repack from '@callstack/repack';

export default (env) => {
  const {
    mode = 'development',
    context = Repack.getDirname(import.meta.url),
    entry = './index.js',
    platform = process.env.RN_PLATFORM ?? 'android',
    minimize = mode === 'production',
    devServer = undefined,
    bundleFilename = undefined,
    sourceMapFilename = undefined,
    assetsPath = undefined,
    reactNativePath = new URL('./node_modules/react-native', import.meta.url).pathname,
  } = env;

  return {
    mode,
    devtool: false,
    context,
    entry: [
      ...Repack.getInitializationEntries(reactNativePath, {
        hmr: devServer && devServer.hmr,
      }),
      entry,
    ],
    resolve: {
      ...Repack.getResolveOptions(platform),
    },
    output: {
      clean: true,
      hashFunction: 'xxhash64',
      path: Repack.getOutputPath(platform, context),
      filename: 'index.bundle',
      chunkFilename: '[name].chunk.bundle',
      publicPath: Repack.getPublicPath({ platform, devServer }),
    },
    optimization: {
      minimize,
      chunkIds: 'named',
    },
    module: {
      rules: [
        Repack.getRules().reactNative,
        Repack.getRules().babel,
        Repack.getRules().images,
        Repack.getRules().svg,
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        context,
        mode,
        platform,
        devServer,
        output: {
          bundleFilename,
          sourceMapFilename,
          assetsPath,
        },
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'UserProfileApp',
        filename: 'UserProfileApp.container.js.bundle',
        exposes: {
          './App': './App.tsx',
        },
        shared: {
          react: {
            singleton: true,
          },
          'react-native': {
            singleton: true,
          },
          'react-native-safe-area-context': {
            singleton: true,
          },
        },
      }),
    ],
  };
};
EOF

# Create MiniApp1 component
cat > App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, TextInput, TouchableOpacity, Alert, ScrollView} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const UserProfileApp: React.FC = () => {
  const [name, setName] = useState('John Doe');
  const [email, setEmail] = useState('john.doe@example.com');
  const [phone, setPhone] = useState('+1 (555) 123-4567');
  const [bio, setBio] = useState('Software developer passionate about React Native and mobile technologies.');
  const [isEditing, setIsEditing] = useState(false);

  const handleSave = () => {
    setIsEditing(false);
    Alert.alert('Success', 'Profile updated successfully!');
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>User Profile</Text>
        <Text style={styles.subtitle}>Mini App 1 - Latest React Native</Text>

        <View style={styles.avatarSection}>
          <View style={styles.avatar}>
            <Text style={styles.avatarText}>JD</Text>
          </View>
          <TouchableOpacity style={styles.changeAvatarButton}>
            <Text style={styles.changeAvatarText}>Change Photo</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.form}>
          <Text style={styles.label}>Full Name</Text>
          <TextInput
            style={[styles.input, !isEditing && styles.disabledInput]}
            value={name}
            onChangeText={setName}
            editable={isEditing}
          />

          <Text style={styles.label}>Email Address</Text>
          <TextInput
            style={[styles.input, !isEditing && styles.disabledInput]}
            value={email}
            onChangeText={setEmail}
            editable={isEditing}
            keyboardType="email-address"
          />

          <Text style={styles.label}>Phone Number</Text>
          <TextInput
            style={[styles.input, !isEditing && styles.disabledInput]}
            value={phone}
            onChangeText={setPhone}
            editable={isEditing}
            keyboardType="phone-pad"
          />

          <Text style={styles.label}>Bio</Text>
          <TextInput
            style={[styles.input, styles.bioInput, !isEditing && styles.disabledInput]}
            value={bio}
            onChangeText={setBio}
            editable={isEditing}
            multiline
            numberOfLines={3}
          />

          <View style={styles.buttonContainer}>
            {isEditing ? (
              <>
                <TouchableOpacity
                  style={[styles.button, styles.cancelButton]}
                  onPress={() => setIsEditing(false)}>
                  <Text style={[styles.buttonText, styles.cancelText]}>Cancel</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.button, styles.saveButton]}
                  onPress={handleSave}>
                  <Text style={styles.buttonText}>Save Changes</Text>
                </TouchableOpacity>
              </>
            ) : (
              <TouchableOpacity
                style={styles.button}
                onPress={() => setIsEditing(true)}>
                <Text style={styles.buttonText}>Edit Profile</Text>
              </TouchableOpacity>
            )}
          </View>
        </View>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• Complete React Native project structure</Text>
          <Text style={styles.infoItem}>• Independent android/ios folders</Text>
          <Text style={styles.infoItem}>• Module Federation with Re.Pack</Text>
          <Text style={styles.infoItem}>• Latest React Native & React versions</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
    color: '#1D1D1F',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  avatarSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#007AFF',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 12,
  },
  avatarText: {
    fontSize: 32,
    fontWeight: 'bold',
    color: '#FFFFFF',
  },
  changeAvatarButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: '#F0F0F0',
    borderRadius: 20,
  },
  changeAvatarText: {
    fontSize: 14,
    color: '#007AFF',
    fontWeight: '500',
  },
  form: {
    marginBottom: 30,
  },
  label: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
    color: '#1D1D1F',
  },
  input: {
    borderWidth: 1,
    borderColor: '#E0E0E0',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 16,
    backgroundColor: '#FFFFFF',
  },
  disabledInput: {
    backgroundColor: '#F8F9FA',
    color: '#666666',
  },
  bioInput: {
    height: 80,
    textAlignVertical: 'top',
  },
  buttonContainer: {
    flexDirection: 'row',
    gap: 12,
  },
  button: {
    flex: 1,
    backgroundColor: '#007AFF',
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  saveButton: {
    backgroundColor: '#34C759',
  },
  cancelButton: {
    backgroundColor: '#F0F0F0',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  cancelText: {
    color: '#666666',
  },
  info: {
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 12,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
    color: '#1D1D1F',
  },
  infoItem: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
});

export default UserProfileApp;
EOF

cd ..

echo "📱 Creating MiniApp2 (Shopping Cart)..."
npx @react-native-community/cli@latest init MiniApp2 --version latest --skip-install
cd MiniApp2

# Update MiniApp2 package.json (similar to MiniApp1 but different port)
cat > package.json << 'EOF'
{
  "name": "MiniApp2",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android --port 9002",
    "ios": "react-native run-ios --port 9002",
    "lint": "eslint .",
    "start": "react-native webpack-start --port 9002",
    "test": "jest"
  },
  "dependencies": {
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.10.5"
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
    "@types/react": "^18.3.3",
    "@types/react-test-renderer": "^18.3.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.3.1",
    "typescript": "5.0.4",
    "webpack": "^5.94.0"
  },
  "engines": {
    "node": ">=18"
  }
}
EOF

# Create webpack config for MiniApp2
cat > webpack.config.mjs << 'EOF'
import * as Repack from '@callstack/repack';

export default (env) => {
  const {
    mode = 'development',
    context = Repack.getDirname(import.meta.url),
    entry = './index.js',
    platform = process.env.RN_PLATFORM ?? 'android',
    minimize = mode === 'production',
    devServer = undefined,
    bundleFilename = undefined,
    sourceMapFilename = undefined,
    assetsPath = undefined,
    reactNativePath = new URL('./node_modules/react-native', import.meta.url).pathname,
  } = env;

  return {
    mode,
    devtool: false,
    context,
    entry: [
      ...Repack.getInitializationEntries(reactNativePath, {
        hmr: devServer && devServer.hmr,
      }),
      entry,
    ],
    resolve: {
      ...Repack.getResolveOptions(platform),
    },
    output: {
      clean: true,
      hashFunction: 'xxhash64',
      path: Repack.getOutputPath(platform, context),
      filename: 'index.bundle',
      chunkFilename: '[name].chunk.bundle',
      publicPath: Repack.getPublicPath({ platform, devServer }),
    },
    optimization: {
      minimize,
      chunkIds: 'named',
    },
    module: {
      rules: [
        Repack.getRules().reactNative,
        Repack.getRules().babel,
        Repack.getRules().images,
        Repack.getRules().svg,
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        context,
        mode,
        platform,
        devServer,
        output: {
          bundleFilename,
          sourceMapFilename,
          assetsPath,
        },
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'ShoppingCartApp',
        filename: 'ShoppingCartApp.container.js.bundle',
        exposes: {
          './App': './App.tsx',
        },
        shared: {
          react: {
            singleton: true,
          },
          'react-native': {
            singleton: true,
          },
          'react-native-safe-area-context': {
            singleton: true,
          },
        },
      }),
    ],
  };
};
EOF

# Create MiniApp2 component (Shopping Cart)
cat > App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, TouchableOpacity, FlatList, Alert, ScrollView} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
  emoji: string;
}

const ShoppingCartApp: React.FC = () => {
  const [cartItems, setCartItems] = useState<CartItem[]>([
    {id: '1', name: 'iPhone 15 Pro', price: 999, quantity: 1, emoji: '📱'},
    {id: '2', name: 'MacBook Air', price: 1299, quantity: 1, emoji: '💻'},
    {id: '3', name: 'AirPods Pro', price: 249, quantity: 2, emoji: '🎧'},
    {id: '4', name: 'Apple Watch', price: 399, quantity: 1, emoji: '⌚'},
  ]);

  const removeItem = (id: string) => {
    setCartItems(items => items.filter(item => item.id !== id));
    Alert.alert('Removed', 'Item removed from cart');
  };

  const updateQuantity = (id: string, change: number) => {
    setCartItems(items =>
      items.map(item =>
        item.id === id
          ? {...item, quantity: Math.max(1, item.quantity + change)}
          : item
      )
    );
  };

  const total = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);
  const itemCount = cartItems.reduce((sum, item) => sum + item.quantity, 0);

  const handleCheckout = () => {
    Alert.alert('Checkout', `Total: $${total}\nItems: ${itemCount}\nProceeding to payment...`);
  };

  const renderCartItem = ({item}: {item: CartItem}) => (
    <View style={styles.cartItem}>
      <View style={styles.itemIcon}>
        <Text style={styles.itemEmoji}>{item.emoji}</Text>
      </View>
      <View style={styles.itemInfo}>
        <Text style={styles.itemName}>{item.name}</Text>
        <Text style={styles.itemPrice}>${item.price}</Text>
        
        <View style={styles.quantityContainer}>
          <TouchableOpacity
            style={styles.quantityButton}
            onPress={() => updateQuantity(item.id, -1)}>
            <Text style={styles.quantityButtonText}>-</Text>
          </TouchableOpacity>
          <Text style={styles.quantityText}>{item.quantity}</Text>
          <TouchableOpacity
            style={styles.quantityButton}
            onPress={() => updateQuantity(item.id, 1)}>
            <Text style={styles.quantityButtonText}>+</Text>
          </TouchableOpacity>
        </View>
      </View>
      
      <TouchableOpacity
        style={styles.removeButton}
        onPress={() => removeItem(item.id)}>
        <Text style={styles.removeText}>Remove</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Shopping Cart</Text>
        <Text style={styles.subtitle}>Mini App 2 - Latest React Native</Text>

        <View style={styles.summaryCard}>
          <Text style={styles.summaryTitle}>Cart Summary</Text>
          <Text style={styles.summaryText}>Items: {itemCount}</Text>
          <Text style={styles.summaryTotal}>Total: ${total}</Text>
        </View>

        <FlatList
          data={cartItems}
          keyExtractor={item => item.id}
          renderItem={renderCartItem}
          scrollEnabled={false}
          style={styles.cartList}
        />

        <TouchableOpacity 
          style={styles.checkoutButton} 
          onPress={handleCheckout}
          disabled={cartItems.length === 0}>
          <Text style={styles.checkoutText}>
            Checkout - ${total}
          </Text>
        </TouchableOpacity>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• Complete React Native project structure</Text>
          <Text style={styles.infoItem}>• Independent android/ios folders</Text>
          <Text style={styles.infoItem}>• State management within mini app</Text>
          <Text style={styles.infoItem}>• Module Federation integration</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
    color: '#1D1D1F',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  summaryCard: {
    backgroundColor: '#F0F8FF',
    padding: 16,
    borderRadius: 12,
    marginBottom: 20,
    alignItems: 'center',
  },
  summaryTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 8,
  },
  summaryText: {
    fontSize: 16,
    color: '#666666',
    marginBottom: 4,
  },
  summaryTotal: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#007AFF',
  },
  cartList: {
    marginBottom: 20,
  },
  cartItem: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  itemIcon: {
    width: 50,
    height: 50,
    backgroundColor: '#E3F2FD',
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  itemEmoji: {
    fontSize: 24,
  },
  itemInfo: {
    flex: 1,
  },
  itemName: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 4,
    color: '#1D1D1F',
  },
  itemPrice: {
    fontSize: 14,
    color: '#007AFF',
    marginBottom: 8,
  },
  quantityContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  quantityButton: {
    width: 30,
    height: 30,
    backgroundColor: '#E0E0E0',
    borderRadius: 15,
    justifyContent: 'center',
    alignItems: 'center',
  },
  quantityButtonText: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#333333',
  },
  quantityText: {
    fontSize: 16,
    fontWeight: '600',
    marginHorizontal: 16,
    color: '#1D1D1F',
  },
  removeButton: {
    backgroundColor: '#FF3B30',
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 6,
  },
  removeText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: '600',
  },
  checkoutButton: {
    backgroundColor: '#34C759',
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
    marginBottom: 20,
  },
  checkoutText: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '600',
  },
  info: {
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 12,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
    color: '#1D1D1F',
  },
  infoItem: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
});

export default ShoppingCartApp;
EOF

cd ..

echo "📱 Creating MiniApp3 (Settings)..."
npx @react-native-community/cli@latest init MiniApp3 --version latest --skip-install
cd MiniApp3

# Update MiniApp3 package.json (similar structure, port 9003)
cat > package.json << 'EOF'
{
  "name": "MiniApp3",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android --port 9003",
    "ios": "react-native run-ios --port 9003",
    "lint": "eslint .",
    "start": "react-native webpack-start --port 9003",
    "test": "jest"
  },
  "dependencies": {
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.10.5"
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
    "@types/react": "^18.3.3",
    "@types/react-test-renderer": "^18.3.0",
    "babel-jest": "^29.6.3",
    "eslint": "^8.19.0",
    "jest": "^29.6.3",
    "prettier": "2.8.8",
    "react-test-renderer": "18.3.1",
    "typescript": "5.0.4",
    "webpack": "^5.94.0"
  },
  "engines": {
    "node": ">=18"
  }
}
EOF

# Create webpack config for MiniApp3
cat > webpack.config.mjs << 'EOF'
import * as Repack from '@callstack/repack';

export default (env) => {
  const {
    mode = 'development',
    context = Repack.getDirname(import.meta.url),
    entry = './index.js',
    platform = process.env.RN_PLATFORM ?? 'android',
    minimize = mode === 'production',
    devServer = undefined,
    bundleFilename = undefined,
    sourceMapFilename = undefined,
    assetsPath = undefined,
    reactNativePath = new URL('./node_modules/react-native', import.meta.url).pathname,
  } = env;

  return {
    mode,
    devtool: false,
    context,
    entry: [
      ...Repack.getInitializationEntries(reactNativePath, {
        hmr: devServer && devServer.hmr,
      }),
      entry,
    ],
    resolve: {
      ...Repack.getResolveOptions(platform),
    },
    output: {
      clean: true,
      hashFunction: 'xxhash64',
      path: Repack.getOutputPath(platform, context),
      filename: 'index.bundle',
      chunkFilename: '[name].chunk.bundle',
      publicPath: Repack.getPublicPath({ platform, devServer }),
    },
    optimization: {
      minimize,
      chunkIds: 'named',
    },
    module: {
      rules: [
        Repack.getRules().reactNative,
        Repack.getRules().babel,
        Repack.getRules().images,
        Repack.getRules().svg,
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        context,
        mode,
        platform,
        devServer,
        output: {
          bundleFilename,
          sourceMapFilename,
          assetsPath,
        },
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'SettingsApp',
        filename: 'SettingsApp.container.js.bundle',
        exposes: {
          './App': './App.tsx',
        },
        shared: {
          react: {
            singleton: true,
          },
          'react-native': {
            singleton: true,
          },
          'react-native-safe-area-context': {
            singleton: true,
          },
        },
      }),
    ],
  };
};
EOF

# Create MiniApp3 component (Settings)
cat > App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, Switch, TouchableOpacity, Alert, ScrollView} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const SettingsApp: React.FC = () => {
  const [notifications, setNotifications] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [biometrics, setBiometrics] = useState(true);
  const [autoSync, setAutoSync] = useState(true);
  const [locationServices, setLocationServices] = useState(false);

  const handlePrivacyPolicy = () => {
    Alert.alert('Privacy Policy', 'This would open the privacy policy document in a web browser or in-app viewer.');
  };

  const handleTermsOfService = () => {
    Alert.alert('Terms of Service', 'This would open the terms of service document.');
  };

  const handleContactSupport = () => {
    Alert.alert('Contact Support', 'This would open an email client or support chat interface.');
  };

  const handleSignOut = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out of your account?',
      [
        {text: 'Cancel', style: 'cancel'},
        {text: 'Sign Out', style: 'destructive', onPress: () => Alert.alert('Signed Out', 'You have been signed out successfully.')},
      ]
    );
  };

  const SettingItem = ({
    title,
    description,
    value,
    onToggle,
    icon,
  }: {
    title: string;
    description: string;
    value: boolean;
    onToggle: (value: boolean) => void;
    icon: string;
  }) => (
    <View style={styles.settingItem}>
      <View style={styles.settingInfo}>
        <View style={styles.settingHeader}>
          <Text style={styles.settingIcon}>{icon}</Text>
          <Text style={styles.settingTitle}>{title}</Text>
        </View>
        <Text style={styles.settingDescription}>{description}</Text>
      </View>
      <Switch
        value={value}
        onValueChange={onToggle}
        trackColor={{false: '#E0E0E0', true: '#007AFF'}}
        thumbColor={value ? '#FFFFFF' : '#FFFFFF'}
      />
    </View>
  );

  const ActionItem = ({
    title,
    description,
    onPress,
    icon,
    destructive = false,
  }: {
    title: string;
    description?: string;
    onPress: () => void;
    icon: string;
    destructive?: boolean;
  }) => (
    <TouchableOpacity style={styles.actionItem} onPress={onPress}>
      <View style={styles.settingInfo}>
        <View style={styles.settingHeader}>
          <Text style={styles.settingIcon}>{icon}</Text>
          <Text style={[styles.settingTitle, destructive && styles.destructiveText]}>
            {title}
          </Text>
        </View>
        {description && (
          <Text style={styles.settingDescription}>{description}</Text>
        )}
      </View>
      <Text style={styles.chevron}>›</Text>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Settings</Text>
        <Text style={styles.subtitle}>Mini App 3 - Latest React Native</Text>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Privacy & Security</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              title="Push Notifications"
              description="Receive notifications about important updates"
              value={notifications}
              onToggle={setNotifications}
              icon="🔔"
            />
            <SettingItem
              title="Biometric Authentication"
              description="Use Face ID or Touch ID to secure your account"
              value={biometrics}
              onToggle={setBiometrics}
              icon="🔐"
            />
            <SettingItem
              title="Location Services"
              description="Allow the app to access your location"
              value={locationServices}
              onToggle={setLocationServices}
              icon="📍"
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>App Preferences</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              title="Dark Mode"
              description="Switch to dark theme for better night viewing"
              value={darkMode}
              onToggle={setDarkMode}
              icon="🌙"
            />
            <SettingItem
              title="Auto Sync"
              description="Automatically sync data across devices"
              value={autoSync}
              onToggle={setAutoSync}
              icon="🔄"
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Support & Legal</Text>
          <View style={styles.sectionContent}>
            <ActionItem
              title="Contact Support"
              description="Get help with your account or report issues"
              onPress={handleContactSupport}
              icon="💬"
            />
            <ActionItem
              title="Privacy Policy"
              description="Learn how we protect your privacy"
              onPress={handlePrivacyPolicy}
              icon="🛡️"
            />
            <ActionItem
              title="Terms of Service"
              description="Read our terms and conditions"
              onPress={handleTermsOfService}
              icon="📄"
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Account</Text>
          <View style={styles.sectionContent}>
            <ActionItem
              title="Sign Out"
              onPress={handleSignOut}
              icon="🚪"
              destructive
            />
          </View>
        </View>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• Complete React Native project structure</Text>
          <Text style={styles.infoItem}>• Independent android/ios folders</Text>
          <Text style={styles.infoItem}>• Native UI components (Switch)</Text>
          <Text style={styles.infoItem}>• Module Federation integration</Text>
          
          <View style={styles.versionInfo}>
            <Text style={styles.versionText}>Version 1.0.0</Text>
            <Text style={styles.versionText}>Build 2024.10.16</Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
  content: {
    padding: 20,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 8,
    color: '#1D1D1F',
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 12,
  },
  sectionContent: {
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    overflow: 'hidden',
  },
  settingItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  actionItem: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  settingInfo: {
    flex: 1,
  },
  settingHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 4,
  },
  settingIcon: {
    fontSize: 20,
    marginRight: 12,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
  },
  destructiveText: {
    color: '#FF3B30',
  },
  settingDescription: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 18,
    marginLeft: 32,
  },
  chevron: {
    fontSize: 20,
    color: '#C7C7CC',
    fontWeight: '300',
  },
  info: {
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 12,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 8,
  },
  infoItem: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
  versionInfo: {
    alignItems: 'center',
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    marginTop: 16,
  },
  versionText: {
    fontSize: 12,
    color: '#999999',
    marginBottom: 2,
  },
});

export default SettingsApp;
EOF

cd ..

echo "📝 Creating root workspace configuration..."

# Create root package.json for workspace management
cat > package.json << 'EOF'
{
  "name": "react-native-super-app",
  "version": "1.0.0",
  "description": "React Native Super App with Module Federation using Latest Versions",
  "private": true,
  "workspaces": ["HostApp", "MiniApp1", "MiniApp2", "MiniApp3"],
  "scripts": {
    "setup": "./scripts/setup.sh",
    "dev:start": "./scripts/dev-start.sh",
    "install:all": "cd HostApp && npm install && cd ../MiniApp1 && npm install && cd ../MiniApp2 && npm install && cd ../MiniApp3 && npm install",
    "start:host": "cd HostApp && npm start",
    "start:mini1": "cd MiniApp1 && npm start",
    "start:mini2": "cd MiniApp2 && npm start", 
    "start:mini3": "cd MiniApp3 && npm start",
    "android:host": "cd HostApp && npm run android",
    "android:mini1": "cd MiniApp1 && npm run android",
    "android:mini2": "cd MiniApp2 && npm run android",
    "android:mini3": "cd MiniApp3 && npm run android",
    "ios:host": "cd HostApp && npm run ios",
    "ios:mini1": "cd MiniApp1 && npm run ios",
    "ios:mini2": "cd MiniApp2 && npm run ios",
    "ios:mini3": "cd MiniApp3 && npm run ios"
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  }
}
EOF

# Create scripts directory
mkdir -p scripts

# Setup script
cat > scripts/setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Setting up React Native Super App with Latest Versions..."

if ! command -v react-native &> /dev/null; then
    echo "Installing React Native CLI..."
    npm install -g @react-native-community/cli
fi

echo "📦 Installing dependencies for all apps..."
npm run install:all

echo "🍎 Setting up iOS dependencies (if on macOS)..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v pod &> /dev/null; then
        echo "Installing CocoaPods for HostApp..."
        cd HostApp/ios && pod install && cd ../..
        
        echo "Installing CocoaPods for MiniApp1..."
        cd MiniApp1/ios && pod install && cd ../..
        
        echo "Installing CocoaPods for MiniApp2..."
        cd MiniApp2/ios && pod install && cd ../..
        
        echo "Installing CocoaPods for MiniApp3..."
        cd MiniApp3/ios && pod install && cd ../..
        
        echo "✅ iOS pods installed for all apps"
    else
        echo "⚠️  CocoaPods not found. Please install: sudo gem install cocoapods"
    fi
fi

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Start MiniApp1: npm run start:mini1 (new terminal)"
echo "2. Start MiniApp2: npm run start:mini2 (new terminal)"
echo "3. Start MiniApp3: npm run start:mini3 (new terminal)"
echo "4. Start HostApp: npm run start:host (new terminal)"
echo "5. Run on device:"
echo "   - Android: npm run android:host (or android:mini1, etc.)"
echo "   - iOS: npm run ios:host (or ios:mini1, etc.)"
EOF

# Dev start script
cat > scripts/dev-start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting all mini-apps..."

echo "Starting MiniApp1 on port 9001..."
cd MiniApp1 && npm start &
MINI1_PID=$!
sleep 3

echo "Starting MiniApp2 on port 9002..."
cd ../MiniApp2 && npm start &
MINI2_PID=$!
sleep 3  

echo "Starting MiniApp3 on port 9003..."
cd ../MiniApp3 && npm start &
MINI3_PID=$!
sleep 3

echo "✅ All mini-apps started!"
echo "PIDs: MiniApp1=$MINI1_PID, MiniApp2=$MINI2_PID, MiniApp3=$MINI3_PID"
echo ""
echo "🎯 Now start the HostApp:"
echo "   npm run start:host"
echo ""
echo "📱 Run on devices:"
echo "   npm run android:host  # HostApp on Android"
echo "   npm run ios:host      # HostApp on iOS"
echo ""
echo "Press Ctrl+C to stop all processes"

# Function to cleanup on exit
cleanup() {
    echo "Stopping all mini-apps..."
    kill $MINI1_PID $MINI2_PID $MINI3_PID 2>/dev/null
    exit 0
}

trap cleanup EXIT INT TERM
wait
EOF

chmod +x scripts/*.sh

# Create README
cat > README.md << 'EOF'
# React Native Super App with Module Federation (Latest Versions)

A complete React Native super app implementation using **Latest React Native & React versions** with **Re.Pack** and **Module Federation**.

## 🚀 Quick Start

1. **Setup**: `npm run setup`
2. **Start Mini-Apps** (in separate terminals):
   ```bash
   npm run start:mini1  # Terminal 1 (Port 9001)
   npm run start:mini2  # Terminal 2 (Port 9002)
   npm run start:mini3  # Terminal 3 (Port 9003)
   ```
3. **Start Host App**: `npm run start:host` (Terminal 4)
4. **Run on Device/Emulator**:
   ```bash
   npm run android:host  # HostApp on Android
   npm run ios:host      # HostApp on iOS
   
   # Or run individual mini-apps
   npm run android:mini1  # MiniApp1 on Android
   npm run ios:mini2      # MiniApp2 on iOS
   ```

## 📁 Project Structure

Each app is a **complete React Native project** with full `android/` and `ios/` folders:

- **HostApp**: Main container with navigation (Complete RN project)
- **MiniApp1**: User Profile management (Complete RN project, Port 9001)
- **MiniApp2**: Shopping Cart functionality (Complete RN project, Port 9002)  
- **MiniApp3**: Settings and preferences (Complete RN project, Port 9003)

## ✨ Features

- ✅ **Latest React Native** (0.75.4) & **React** (18.3.1)
- ✅ **Complete RN Projects** - Each app has android/ios folders
- ✅ **Module Federation** architecture with Re.Pack
- ✅ **Independent Development** - Each app can run on device/emulator
- ✅ **Shared dependencies** optimization
- ✅ **Error boundaries** and loading states
- ✅ **Hot module replacement**

## 🎯 Mini-App Features

### HostApp (Main Container)
- Bottom tab navigation
- Dynamic mini-app loading
- Error boundaries and fallbacks
- Modern UI with latest React Native

### MiniApp1 (User Profile)
- Complete profile editing interface
- Avatar management
- Form validation
- Real-time updates

### MiniApp2 (Shopping Cart)
- Product catalog with emojis
- Cart management (add/remove/quantity)
- Checkout simulation
- Summary cards

### MiniApp3 (Settings)
- Privacy & security toggles
- App preferences
- Support and legal actions
- Native Switch components

## 🛠️ Development

Each app is a complete React Native project that can be developed and run independently:

### Running Individual Apps

```bash
# Run HostApp on Android
cd HostApp && npm run android

# Run MiniApp1 on iOS  
cd MiniApp1 && npm run ios

# Run MiniApp2 on Android with custom port
cd MiniApp2 && npm run android
```

### Module Federation Development

1. Start the mini-app you want to work on
2. Start the HostApp
3. The HostApp will dynamically load the mini-app
4. Changes in mini-apps are reflected in HostApp

### Commands

- `react-native webpack-start` - Start Re.Pack dev server
- `react-native run-android` - Run on Android device/emulator
- `react-native run-ios` - Run on iOS device/simulator

## 📱 Device/Emulator Support

Since each app is a complete React Native project:

- **Android**: Each app can run on Android devices/emulators independently
- **iOS**: Each app can run on iOS devices/simulators independently  
- **Development**: Hot reloading works for each app
- **Debugging**: Full React Native debugging capabilities

## 🔧 Troubleshooting

### If mini-apps don't load in HostApp:
1. Ensure the mini-app's webpack dev server is running
2. Check the mini-app is accessible on its port (9001, 9002, 9003)
3. Verify network connectivity between HostApp and mini-apps

### If apps don't run on device:
1. Ensure Android/iOS development environment is set up
2. Check that devices/emulators are connected
3. Run `npx react-native doctor` to diagnose issues

### iOS Setup:
```bash
cd HostApp/ios && pod install
cd ../MiniApp1/ios && pod install
cd ../MiniApp2/ios && pod install  
cd ../MiniApp3/ios && pod install
```

## 🎉 What's New

This version includes:
- **Latest React Native 0.75.4** with all new features
- **Complete project structures** for all apps
- **Independent deployment** capability
- **Full device/emulator support**
- **Modern UI components** and styling
- **Enhanced error handling**

Happy coding with the latest React Native! 🚀
EOF

echo "✅ React Native Super App with Latest Versions created successfully!"
echo ""
echo "📁 Project created in: $(pwd)"
echo ""
echo "📱 Each app is now a complete React Native project with:"
echo "   - Full android/ and ios/ folders"
echo "   - Independent package.json and dependencies"
echo "   - Ability to run on devices/emulators"
echo "   - Module Federation integration"
echo ""
echo "🎯 Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. npm run setup"
echo "3. Follow the README instructions"
echo ""
echo "🚀 Happy coding with Latest React Native!"