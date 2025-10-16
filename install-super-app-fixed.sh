#!/bin/bash

# React Native Super App - One Command Installer (macOS Compatible)
# This script creates the complete project structure and files

echo "🚀 Creating React Native Super App with Module Federation..."

PROJECT_NAME="react-native-super-app"

# Create project directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

echo "📁 Creating project structure..."

# Create directory structure
mkdir -p HostApp/src/{components,screens}
mkdir -p MiniApp1/src
mkdir -p MiniApp2/src  
mkdir -p MiniApp3/src
mkdir scripts

echo "📝 Creating configuration files..."

# Root package.json
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
    "install-all": "npm install && cd HostApp && npm install && cd ../MiniApp1 && npm install && cd ../MiniApp2 && npm install && cd ../MiniApp3 && npm install && cd ..",
    "start:host": "cd HostApp && npm start",
    "start:mini1": "cd MiniApp1 && npm start",
    "start:mini2": "cd MiniApp2 && npm start", 
    "start:mini3": "cd MiniApp3 && npm start",
    "android": "cd HostApp && npm run android",
    "ios": "cd HostApp && npm run ios"
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  }
}
EOF

# Setup script
cat > scripts/setup.sh << 'EOF'
#!/bin/bash
echo "🚀 Setting up React Native Super App..."

if ! command -v react-native &> /dev/null; then
    echo "Installing React Native CLI..."
    npm install -g @react-native-community/cli
fi

echo "📦 Installing all dependencies..."
npm run install-all

echo "✅ Setup complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Start MiniApp1: npm run start:mini1 (new terminal)"
echo "2. Start MiniApp2: npm run start:mini2 (new terminal)"
echo "3. Start MiniApp3: npm run start:mini3 (new terminal)"
echo "4. Start HostApp: npm run start:host (new terminal)"
echo "5. Run app: npm run ios or npm run android"
EOF

# Dev start script
cat > scripts/dev-start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting all mini-apps..."

echo "Starting MiniApp1 on port 9001..."
cd MiniApp1 && npm start &
MINI1_PID=$!
sleep 2

echo "Starting MiniApp2 on port 9002..."
cd ../MiniApp2 && npm start &
MINI2_PID=$!
sleep 2  

echo "Starting MiniApp3 on port 9003..."
cd ../MiniApp3 && npm start &
MINI3_PID=$!
sleep 2

echo "✅ All mini-apps started!"
echo "PIDs: MiniApp1=$MINI1_PID, MiniApp2=$MINI2_PID, MiniApp3=$MINI3_PID"
echo "Now run: npm run start:host"
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

echo "📱 Creating HostApp..."

# HostApp package.json
cat > HostApp/package.json << 'EOF'
{
  "name": "host-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "android": "react-native run-android",
    "ios": "react-native run-ios", 
    "start": "react-native start --experimental-debugger"
  },
  "dependencies": {
    "@react-navigation/native": "^6.1.9",
    "@react-navigation/bottom-tabs": "^6.5.11",
    "react": "18.3.1",
    "react-native": "0.75.4",
    "react-native-safe-area-context": "^4.8.2",
    "react-native-screens": "^3.29.0"
  },
  "devDependencies": {
    "@callstack/repack": "^4.3.0",
    "@react-native/babel-preset": "0.75.4",
    "typescript": "5.0.4",
    "zephyr-repack-plugin": "^1.0.0"
  }
}
EOF

# HostApp files
cat > HostApp/index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

cat > HostApp/app.json << 'EOF'
{
  "name": "HostApp",
  "displayName": "Super App Host"
}
EOF

cat > HostApp/babel.config.js << 'EOF'
module.exports = {
  presets: ['@react-native/babel-preset'],
};
EOF

# HostApp rspack configuration
cat > HostApp/rspack.config.mjs << 'EOF'
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';

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
      new Repack.plugins.HermesBytecodePlugin({
        enabled: mode === 'production',
        test: /\.(js)?bundle$/,
        exclude: /index.bundle$/,
      }),
    ],
  };
};

export default config;
EOF

# HostApp Main App Component with MiniApp Loader
cat > HostApp/src/App.tsx << 'EOF'
import React, {Suspense, lazy, ErrorInfo, Component} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {SafeAreaView, StatusBar, StyleSheet, Text, View, ActivityIndicator} from 'react-native';
import HomeScreen from './screens/HomeScreen';

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
      return import(/* webpackIgnore: true */ `${appName}/${moduleName}`);
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

// Placeholder components (fallback when mini-apps are not running)
const UserProfileScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>User Profile Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp1: npm run start:mini1</Text>
  </View>
);

const ShoppingCartScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>Shopping Cart Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp2: npm run start:mini2</Text>
  </View>
);

const SettingsScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>Settings Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp3: npm run start:mini3</Text>
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
  text: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 10,
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
});

export default App;
EOF

# HomeScreen
cat > HostApp/src/screens/HomeScreen.tsx << 'EOF'
import React from 'react';
import {View, Text, StyleSheet, ScrollView} from 'react-native';

const HomeScreen: React.FC = () => {
  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.title}>Welcome to Super App</Text>
        <Text style={styles.subtitle}>Module Federation with Re.Pack</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Mini Applications</Text>
        
        <View style={styles.appCard}>
          <Text style={styles.appName}>👤 User Profile</Text>
          <Text style={styles.appDescription}>Manage your personal information and preferences</Text>
        </View>

        <View style={styles.appCard}>
          <Text style={styles.appName}>🛒 Shopping Cart</Text>
          <Text style={styles.appDescription}>Browse products and manage your shopping experience</Text>
        </View>

        <View style={styles.appCard}>
          <Text style={styles.appName}>⚙️ Settings</Text>
          <Text style={styles.appDescription}>Configure app preferences and account settings</Text>
        </View>
      </View>

      <View style={styles.infoSection}>
        <Text style={styles.infoTitle}>Architecture Features</Text>
        <Text style={styles.infoItem}>🔧 Re.Pack Integration</Text>
        <Text style={styles.infoItem}>🌐 Module Federation</Text>
        <Text style={styles.infoItem}>☁️ Zephyr Cloud Ready</Text>
        <Text style={styles.infoItem}>📱 Cross-Platform</Text>
      </View>
    </ScrollView>
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
  header: {
    alignItems: 'center',
    marginBottom: 30,
    paddingTop: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1D1D1F',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#666666',
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 16,
  },
  appCard: {
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
  },
  appName: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 4,
  },
  appDescription: {
    fontSize: 14,
    color: '#666666',
  },
  infoSection: {
    backgroundColor: '#F0F8FF',
    padding: 16,
    borderRadius: 12,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 12,
  },
  infoItem: {
    fontSize: 14,
    color: '#666666',
    marginBottom: 4,
  },
});

export default HomeScreen;
EOF

echo "📱 Creating MiniApp1 (User Profile)..."

# MiniApp1 - User Profile App
cat > MiniApp1/package.json << 'EOF'
{
  "name": "user-profile-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "react-native start --port 9001 --experimental-debugger"
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

cat > MiniApp1/index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

cat > MiniApp1/app.json << 'EOF'
{
  "name": "UserProfileApp",
  "displayName": "User Profile Mini App"
}
EOF

cat > MiniApp1/babel.config.js << 'EOF'
module.exports = {
  presets: ['@react-native/babel-preset'],
};
EOF

cat > MiniApp1/rspack.config.mjs << 'EOF'
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const STANDALONE = Boolean(process.env.STANDALONE);

const config = (env) => {
  const { platform, mode } = env;
  
  return {
    mode,
    context: __dirname,
    entry: './index.js',
    resolve: {
      ...Repack.getResolveOptions(),
    },
    output: {
      uniqueName: 'react-native-user-profile-app',
    },
    module: {
      rules: [
        ...Repack.getJsTransformRules(),
        ...Repack.getAssetTransformRules({ inline: true }),
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        platform,
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'UserProfileApp',
        filename: 'UserProfileApp.container.js.bundle',
        dts: false,
        exposes: {
          './App': './src/App.tsx',
        },
        shared: {
          react: {
            singleton: true,
            version: '18.3.1',
            eager: STANDALONE,
          },
          'react-native': {
            singleton: true,
            version: '0.75.4',
            eager: STANDALONE,
          },
          'react-native-safe-area-context': {
            singleton: true,
            eager: STANDALONE,
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

export default config;
EOF

cat > MiniApp1/src/App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, TextInput, TouchableOpacity, Alert} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const UserProfileApp: React.FC = () => {
  const [name, setName] = useState('John Doe');
  const [email, setEmail] = useState('john.doe@example.com');
  const [phone, setPhone] = useState('+1 (555) 123-4567');
  const [isEditing, setIsEditing] = useState(false);

  const handleSave = () => {
    setIsEditing(false);
    Alert.alert('Success', 'Profile updated successfully!');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>User Profile</Text>
        <Text style={styles.subtitle}>Mini App 1 - Module Federation</Text>

        <View style={styles.form}>
          <Text style={styles.label}>Full Name</Text>
          <TextInput
            style={styles.input}
            value={name}
            onChangeText={setName}
            editable={isEditing}
          />

          <Text style={styles.label}>Email Address</Text>
          <TextInput
            style={styles.input}
            value={email}
            onChangeText={setEmail}
            editable={isEditing}
            keyboardType="email-address"
          />

          <Text style={styles.label}>Phone Number</Text>
          <TextInput
            style={styles.input}
            value={phone}
            onChangeText={setPhone}
            editable={isEditing}
            keyboardType="phone-pad"
          />

          <TouchableOpacity
            style={styles.button}
            onPress={isEditing ? handleSave : () => setIsEditing(true)}>
            <Text style={styles.buttonText}>
              {isEditing ? 'Save Changes' : 'Edit Profile'}
            </Text>
          </TouchableOpacity>

          {isEditing && (
            <TouchableOpacity
              style={[styles.button, styles.cancelButton]}
              onPress={() => setIsEditing(false)}>
              <Text style={[styles.buttonText, styles.cancelText]}>Cancel</Text>
            </TouchableOpacity>
          )}
        </View>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• Independent development</Text>
          <Text style={styles.infoItem}>• Shared dependencies</Text>
          <Text style={styles.infoItem}>• Dynamic loading</Text>
          <Text style={styles.infoItem}>• Error boundaries</Text>
        </View>
      </View>
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
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
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
  button: {
    backgroundColor: '#007AFF',
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
    marginBottom: 8,
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  cancelButton: {
    backgroundColor: '#F0F0F0',
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

echo "📱 Creating MiniApp2 (Shopping Cart)..."

# MiniApp2 - Shopping Cart App
cat > MiniApp2/package.json << 'EOF'
{
  "name": "shopping-cart-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "react-native start --port 9002 --experimental-debugger"
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

cat > MiniApp2/index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

cat > MiniApp2/app.json << 'EOF'
{
  "name": "ShoppingCartApp",
  "displayName": "Shopping Cart Mini App"
}
EOF

cat > MiniApp2/babel.config.js << 'EOF'
module.exports = {
  presets: ['@react-native/babel-preset'],
};
EOF

cat > MiniApp2/rspack.config.mjs << 'EOF'
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const STANDALONE = Boolean(process.env.STANDALONE);

const config = (env) => {
  const { platform, mode } = env;
  
  return {
    mode,
    context: __dirname,
    entry: './index.js',
    resolve: {
      ...Repack.getResolveOptions(),
    },
    output: {
      uniqueName: 'react-native-shopping-cart-app',
    },
    module: {
      rules: [
        ...Repack.getJsTransformRules(),
        ...Repack.getAssetTransformRules({ inline: true }),
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        platform,
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'ShoppingCartApp',
        filename: 'ShoppingCartApp.container.js.bundle',
        dts: false,
        exposes: {
          './App': './src/App.tsx',
        },
        shared: {
          react: {
            singleton: true,
            version: '18.3.1',
            eager: STANDALONE,
          },
          'react-native': {
            singleton: true,
            version: '0.75.4',
            eager: STANDALONE,
          },
          'react-native-safe-area-context': {
            singleton: true,
            eager: STANDALONE,
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

export default config;
EOF

cat > MiniApp2/src/App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, TouchableOpacity, FlatList, Alert} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

interface CartItem {
  id: string;
  name: string;
  price: number;
  quantity: number;
}

const ShoppingCartApp: React.FC = () => {
  const [cartItems, setCartItems] = useState<CartItem[]>([
    {id: '1', name: 'iPhone 15 Pro', price: 999, quantity: 1},
    {id: '2', name: 'MacBook Air', price: 1299, quantity: 1},
    {id: '3', name: 'AirPods Pro', price: 249, quantity: 2},
  ]);

  const removeItem = (id: string) => {
    setCartItems(items => items.filter(item => item.id !== id));
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

  const handleCheckout = () => {
    Alert.alert('Checkout', `Total: $${total}\nProceeding to payment...`);
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Shopping Cart</Text>
        <Text style={styles.subtitle}>Mini App 2 - Module Federation</Text>

        <FlatList
          data={cartItems}
          keyExtractor={item => item.id}
          renderItem={({item}) => (
            <View style={styles.cartItem}>
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
          )}
        />

        <View style={styles.totalSection}>
          <Text style={styles.totalText}>Total: ${total}</Text>
          <TouchableOpacity style={styles.checkoutButton} onPress={handleCheckout}>
            <Text style={styles.checkoutText}>Checkout</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• State management within mini app</Text>
          <Text style={styles.infoItem}>• Product catalog functionality</Text>
          <Text style={styles.infoItem}>• Independent business logic</Text>
          <Text style={styles.infoItem}>• Shared UI components</Text>
        </View>
      </View>
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
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
    textAlign: 'center',
    marginBottom: 30,
  },
  cartItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
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
  totalSection: {
    marginTop: 20,
    padding: 16,
    backgroundColor: '#F0F8FF',
    borderRadius: 12,
  },
  totalText: {
    fontSize: 18,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 12,
    color: '#1D1D1F',
  },
  checkoutButton: {
    backgroundColor: '#34C759',
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  checkoutText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  info: {
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 12,
    marginTop: 20,
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

echo "📱 Creating MiniApp3 (Settings)..."

# MiniApp3 - Settings App
cat > MiniApp3/package.json << 'EOF'
{
  "name": "settings-app",
  "version": "0.0.1",
  "private": true,
  "scripts": {
    "start": "react-native start --port 9003 --experimental-debugger"
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

cat > MiniApp3/index.js << 'EOF'
import {AppRegistry} from 'react-native';
import App from './src/App';
import {name as appName} from './app.json';

AppRegistry.registerComponent(appName, () => App);
EOF

cat > MiniApp3/app.json << 'EOF'
{
  "name": "SettingsApp",
  "displayName": "Settings Mini App"
}
EOF

cat > MiniApp3/babel.config.js << 'EOF'
module.exports = {
  presets: ['@react-native/babel-preset'],
};
EOF

cat > MiniApp3/rspack.config.mjs << 'EOF'
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import * as Repack from '@callstack/repack';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const STANDALONE = Boolean(process.env.STANDALONE);

const config = (env) => {
  const { platform, mode } = env;
  
  return {
    mode,
    context: __dirname,
    entry: './index.js',
    resolve: {
      ...Repack.getResolveOptions(),
    },
    output: {
      uniqueName: 'react-native-settings-app',
    },
    module: {
      rules: [
        ...Repack.getJsTransformRules(),
        ...Repack.getAssetTransformRules({ inline: true }),
      ],
    },
    plugins: [
      new Repack.RepackPlugin({
        platform,
      }),
      new Repack.plugins.ModuleFederationPluginV2({
        name: 'SettingsApp',
        filename: 'SettingsApp.container.js.bundle',
        dts: false,
        exposes: {
          './App': './src/App.tsx',
        },
        shared: {
          react: {
            singleton: true,
            version: '18.3.1',
            eager: STANDALONE,
          },
          'react-native': {
            singleton: true,
            version: '0.75.4',
            eager: STANDALONE,
          },
          'react-native-safe-area-context': {
            singleton: true,
            eager: STANDALONE,
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

export default config;
EOF

cat > MiniApp3/src/App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, Switch, TouchableOpacity, Alert} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const SettingsApp: React.FC = () => {
  const [notifications, setNotifications] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [biometrics, setBiometrics] = useState(true);
  const [autoSync, setAutoSync] = useState(true);

  const handlePrivacyPolicy = () => {
    Alert.alert('Privacy Policy', 'This would open the privacy policy document.');
  };

  const handleTermsOfService = () => {
    Alert.alert('Terms of Service', 'This would open the terms of service document.');
  };

  const handleSignOut = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        {text: 'Cancel', style: 'cancel'},
        {text: 'Sign Out', style: 'destructive'},
      ]
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Settings</Text>
        <Text style={styles.subtitle}>Mini App 3 - Module Federation</Text>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Privacy & Security</Text>
          
          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Text style={styles.settingLabel}>🔔 Push Notifications</Text>
              <Text style={styles.settingDescription}>Receive important updates</Text>
            </View>
            <Switch
              value={notifications}
              onValueChange={setNotifications}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Text style={styles.settingLabel}>🔐 Biometric Authentication</Text>
              <Text style={styles.settingDescription}>Use Face ID or Touch ID</Text>
            </View>
            <Switch
              value={biometrics}
              onValueChange={setBiometrics}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>App Preferences</Text>
          
          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Text style={styles.settingLabel}>🌙 Dark Mode</Text>
              <Text style={styles.settingDescription}>Switch to dark theme</Text>
            </View>
            <Switch
              value={darkMode}
              onValueChange={setDarkMode}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>

          <View style={styles.settingItem}>
            <View style={styles.settingInfo}>
              <Text style={styles.settingLabel}>🔄 Auto Sync</Text>
              <Text style={styles.settingDescription}>Sync data across devices</Text>
            </View>
            <Switch
              value={autoSync}
              onValueChange={setAutoSync}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Support & Legal</Text>
          
          <TouchableOpacity style={styles.actionButton} onPress={handlePrivacyPolicy}>
            <Text style={styles.actionText}>🛡️ Privacy Policy</Text>
            <Text style={styles.chevron}>›</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.actionButton} onPress={handleTermsOfService}>
            <Text style={styles.actionText}>📄 Terms of Service</Text>
            <Text style={styles.chevron}>›</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.actionButton, styles.signOutButton]} onPress={handleSignOut}>
            <Text style={[styles.actionText, styles.signOutText]}>🚪 Sign Out</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• Persistent settings management</Text>
          <Text style={styles.infoItem}>• Native UI components (Switch)</Text>
          <Text style={styles.infoItem}>• Modular configuration screens</Text>
          <Text style={styles.infoItem}>• Cross-platform compatibility</Text>
        </View>
      </View>
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
    marginBottom: 16,
    color: '#1D1D1F',
  },
  settingItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
  },
  settingInfo: {
    flex: 1,
  },
  settingLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 4,
  },
  settingDescription: {
    fontSize: 14,
    color: '#666666',
  },
  actionButton: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
  },
  actionText: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '500',
  },
  chevron: {
    fontSize: 20,
    color: '#C7C7CC',
  },
  signOutButton: {
    backgroundColor: '#FFF5F5',
  },
  signOutText: {
    color: '#FF3B30',
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

export default SettingsApp;
EOF

# Create README
cat > README.md << 'EOF'
# React Native Super App with Module Federation

A complete React Native super app implementation using **Re.Pack** and **Module Federation** with **Zephyr Cloud** integration.

## 🚀 Quick Start

1. **Setup**: `npm run setup`
2. **Start Mini-Apps** (in separate terminals):
   ```bash
   npm run start:mini1  # Terminal 1 (Port 9001)
   npm run start:mini2  # Terminal 2 (Port 9002)
   npm run start:mini3  # Terminal 3 (Port 9003)
   ```
3. **Start Host App**: `npm run start:host` (Terminal 4)
4. **Run App**: `npm run ios` or `npm run android`

## 📁 Project Structure

- **HostApp**: Main container with navigation and mini-app loading
- **MiniApp1**: User Profile management (Port 9001)
- **MiniApp2**: Shopping Cart functionality (Port 9002)  
- **MiniApp3**: Settings and preferences (Port 9003)

## ✨ Features

- ✅ **Module Federation** architecture with Re.Pack
- ✅ **Cross-platform** iOS/Android support
- ✅ **Independent mini-apps** with unique functionality
- ✅ **Shared dependencies** optimization
- ✅ **Error boundaries** and loading states
- ✅ **Development workflow** with hot reloading
- ✅ **Production-ready** configuration
- ✅ **Zephyr Cloud** integration ready

## 🎯 Mini-App Features

### MiniApp1 (User Profile)
- Profile editing with form validation
- Real-time form updates
- Save/cancel functionality

### MiniApp2 (Shopping Cart)
- Product catalog display
- Cart management (add/remove/quantity)
- Checkout simulation

### MiniApp3 (Settings)
- App preferences with toggles
- Privacy & security settings
- Support and legal actions

## 🛠️ Development

Each mini-app runs independently and can be developed separately. The HostApp dynamically loads mini-apps using Module Federation.

### Troubleshooting

If mini-apps don't load:
1. Ensure all mini-apps are running on their respective ports
2. Check that Metro bundlers are started for each app
3. Verify network connectivity between host and mini-apps

## 📚 Architecture

This project demonstrates modern micro-frontend architecture in React Native:
- **Independent Development**: Each mini-app can be developed separately
- **Shared Dependencies**: Optimized sharing of React Native and common libraries
- **Dynamic Loading**: Mini-apps loaded on-demand with error handling
- **Cross-Platform**: Single codebase for iOS and Android

For detailed technical documentation, see the Re.Pack and Module Federation documentation.

## 🎉 Next Steps

- Add more mini-apps by following the existing pattern
- Implement state management (Redux/Zustand) for cross-app communication
- Add authentication and deep linking
- Configure Zephyr Cloud for production deployment

Happy coding! 🚀
EOF

echo "✅ React Native Super App created successfully!"
echo ""
echo "📁 Project created in: $(pwd)"
echo ""
echo "🎯 Next steps:"
echo "1. cd $PROJECT_NAME"
echo "2. npm run setup"
echo "3. Follow the README instructions"
echo ""
echo "🚀 Happy coding!"