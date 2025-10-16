#!/bin/bash

# React Native Super App - One Command Installer
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

cd MiniApp1 && npm start &
sleep 2
cd ../MiniApp2 && npm start &
sleep 2  
cd ../MiniApp3 && npm start &
sleep 2

echo "✅ All mini-apps started!"
echo "Now run: npm run start:host"
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

# HostApp Main App Component
cat > HostApp/src/App.tsx << 'EOF'
import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {SafeAreaView, StatusBar, StyleSheet, Text, View} from 'react-native';
import HomeScreen from './screens/HomeScreen';

const Tab = createBottomTabNavigator();

// Placeholder components for mini-apps
const UserProfileScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>User Profile Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp1 on port 9001</Text>
  </View>
);

const ShoppingCartScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>Shopping Cart Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp2 on port 9002</Text>
  </View>
);

const SettingsScreen = () => (
  <View style={styles.centered}>
    <Text style={styles.text}>Settings Mini-App</Text>
    <Text style={styles.subtext}>Start MiniApp3 on port 9003</Text>
  </View>
);

function App(): React.JSX.Element {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />
      <NavigationContainer>
        <Tab.Navigator>
          <Tab.Screen name="Home" component={HomeScreen} />
          <Tab.Screen name="Profile" component={UserProfileScreen} />
          <Tab.Screen name="Cart" component={ShoppingCartScreen} />
          <Tab.Screen name="Settings" component={SettingsScreen} />
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
          <Text style={styles.appDescription}>Manage your personal information</Text>
        </View>

        <View style={styles.appCard}>
          <Text style={styles.appName}>🛒 Shopping Cart</Text>
          <Text style={styles.appDescription}>Browse and purchase products</Text>
        </View>

        <View style={styles.appCard}>
          <Text style={styles.appName}>⚙️ Settings</Text>
          <Text style={styles.appDescription}>Configure app preferences</Text>
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

echo "📱 Creating MiniApps..."

# Create MiniApp1 (User Profile)
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

cat > MiniApp1/src/App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, TextInput, TouchableOpacity} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const UserProfileApp: React.FC = () => {
  const [name, setName] = useState('John Doe');
  const [email, setEmail] = useState('john.doe@example.com');
  const [isEditing, setIsEditing] = useState(false);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>User Profile</Text>
        <Text style={styles.subtitle}>Mini App 1 - Module Federation</Text>

        <View style={styles.form}>
          <Text style={styles.label}>Name</Text>
          <TextInput
            style={styles.input}
            value={name}
            onChangeText={setName}
            editable={isEditing}
          />

          <Text style={styles.label}>Email</Text>
          <TextInput
            style={styles.input}
            value={email}
            onChangeText={setEmail}
            editable={isEditing}
          />

          <TouchableOpacity
            style={styles.button}
            onPress={() => setIsEditing(!isEditing)}>
            <Text style={styles.buttonText}>
              {isEditing ? 'Save' : 'Edit Profile'}
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.info}>
          <Text style={styles.infoTitle}>Mini App Features</Text>
          <Text style={styles.infoItem}>• Independent development</Text>
          <Text style={styles.infoItem}>• Shared dependencies</Text>
          <Text style={styles.infoItem}>• Dynamic loading</Text>
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
  },
  input: {
    borderWidth: 1,
    borderColor: '#E0E0E0',
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    marginBottom: 16,
  },
  button: {
    backgroundColor: '#007AFF',
    padding: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#FFFFFF',
    fontSize: 16,
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
  },
  infoItem: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
});

export default UserProfileApp;
EOF

# Create similar structure for MiniApp2 and MiniApp3
cp -r MiniApp1/* MiniApp2/
cp -r MiniApp1/* MiniApp3/

# Update MiniApp2 for Shopping Cart
sed -i 's/user-profile-app/shopping-cart-app/g' MiniApp2/package.json
sed -i 's/9001/9002/g' MiniApp2/package.json
sed -i 's/UserProfileApp/ShoppingCartApp/g' MiniApp2/app.json
sed -i 's/User Profile Mini App/Shopping Cart Mini App/g' MiniApp2/app.json

cat > MiniApp2/src/App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, TouchableOpacity, FlatList} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const ShoppingCartApp: React.FC = () => {
  const [cartItems, setCartItems] = useState([
    {id: '1', name: 'iPhone 15', price: 999, quantity: 1},
    {id: '2', name: 'MacBook Air', price: 1299, quantity: 1},
  ]);

  const removeItem = (id: string) => {
    setCartItems(items => items.filter(item => item.id !== id));
  };

  const total = cartItems.reduce((sum, item) => sum + (item.price * item.quantity), 0);

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
          <TouchableOpacity style={styles.checkoutButton}>
            <Text style={styles.checkoutText}>Checkout</Text>
          </TouchableOpacity>
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
  },
  itemPrice: {
    fontSize: 14,
    color: '#007AFF',
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
});

export default ShoppingCartApp;
EOF

# Update MiniApp3 for Settings
sed -i 's/shopping-cart-app/settings-app/g' MiniApp3/package.json
sed -i 's/9002/9003/g' MiniApp3/package.json
sed -i 's/ShoppingCartApp/SettingsApp/g' MiniApp3/app.json
sed -i 's/Shopping Cart Mini App/Settings Mini App/g' MiniApp3/app.json

cat > MiniApp3/src/App.tsx << 'EOF'
import React, {useState} from 'react';
import {View, Text, StyleSheet, Switch, TouchableOpacity} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

const SettingsApp: React.FC = () => {
  const [notifications, setNotifications] = useState(true);
  const [darkMode, setDarkMode] = useState(false);
  const [biometrics, setBiometrics] = useState(true);

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Settings</Text>
        <Text style={styles.subtitle}>Mini App 3 - Module Federation</Text>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Preferences</Text>
          
          <View style={styles.settingItem}>
            <Text style={styles.settingLabel}>Push Notifications</Text>
            <Switch
              value={notifications}
              onValueChange={setNotifications}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>

          <View style={styles.settingItem}>
            <Text style={styles.settingLabel}>Dark Mode</Text>
            <Switch
              value={darkMode}
              onValueChange={setDarkMode}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>

          <View style={styles.settingItem}>
            <Text style={styles.settingLabel}>Biometric Authentication</Text>
            <Switch
              value={biometrics}
              onValueChange={setBiometrics}
              trackColor={{false: '#E0E0E0', true: '#007AFF'}}
            />
          </View>
        </View>

        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Account</Text>
          
          <TouchableOpacity style={styles.actionButton}>
            <Text style={styles.actionText}>Privacy Policy</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.actionButton}>
            <Text style={styles.actionText}>Terms of Service</Text>
          </TouchableOpacity>

          <TouchableOpacity style={[styles.actionButton, styles.signOutButton]}>
            <Text style={[styles.actionText, styles.signOutText]}>Sign Out</Text>
          </TouchableOpacity>
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
  settingLabel: {
    fontSize: 16,
    color: '#1D1D1F',
  },
  actionButton: {
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 8,
    marginBottom: 12,
  },
  actionText: {
    fontSize: 16,
    color: '#007AFF',
    textAlign: 'center',
  },
  signOutButton: {
    backgroundColor: '#FFF5F5',
  },
  signOutText: {
    color: '#FF3B30',
  },
});

export default SettingsApp;
EOF

# Create README
cat > README.md << 'EOF'
# React Native Super App with Module Federation

A complete React Native super app implementation using Re.Pack and Module Federation with Zephyr Cloud integration.

## Quick Start

1. **Setup**: `npm run setup`
2. **Start Mini-Apps**: 
   - Terminal 1: `npm run start:mini1`
   - Terminal 2: `npm run start:mini2` 
   - Terminal 3: `npm run start:mini3`
3. **Start Host**: `npm run start:host`
4. **Run App**: `npm run ios` or `npm run android`

## Project Structure

- **HostApp**: Main container with navigation
- **MiniApp1**: User Profile management (Port 9001)
- **MiniApp2**: Shopping Cart functionality (Port 9002)  
- **MiniApp3**: Settings and preferences (Port 9003)

## Features

- ✅ Module Federation architecture
- ✅ Re.Pack integration
- ✅ Cross-platform support
- ✅ Independent mini-app development
- ✅ Shared dependency management
- ✅ Zephyr Cloud ready

## Development

Each mini-app runs on its own port and can be developed independently. The HostApp dynamically loads mini-apps using Module Federation.

For detailed documentation, see the generated ARCHITECTURE.md file.
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