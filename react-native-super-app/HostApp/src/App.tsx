import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import {
  SafeAreaView,
  StatusBar,
  StyleSheet,
  Text,
  View,
  ActivityIndicator,
} from 'react-native';

// Import Mini Apps using Module Federation
import {MiniAppLoader} from './components/MiniAppLoader';
import HomeScreen from './screens/HomeScreen';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

// Mini App Components with error boundaries
const UserProfileApp = () => (
  <MiniAppLoader
    appName="UserProfileApp"
    moduleName="./App"
    fallbackComponent={<Text>Loading User Profile...</Text>}
  />
);

const ShoppingCartApp = () => (
  <MiniAppLoader
    appName="ShoppingCartApp"
    moduleName="./App"
    fallbackComponent={<Text>Loading Shopping Cart...</Text>}
  />
);

const SettingsApp = () => (
  <MiniAppLoader
    appName="SettingsApp"
    moduleName="./App"
    fallbackComponent={<Text>Loading Settings...</Text>}
  />
);

function MainTabs(): React.JSX.Element {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#8E8E93',
        headerShown: false,
      }}>
      <Tab.Screen
        name="Home"
        component={HomeScreen}
        options={{
          tabBarLabel: 'Home',
        }}
      />
      <Tab.Screen
        name="Profile"
        component={UserProfileApp}
        options={{
          tabBarLabel: 'Profile',
        }}
      />
      <Tab.Screen
        name="Cart"
        component={ShoppingCartApp}
        options={{
          tabBarLabel: 'Cart',
        }}
      />
      <Tab.Screen
        name="Settings"
        component={SettingsApp}
        options={{
          tabBarLabel: 'Settings',
        }}
      />
    </Tab.Navigator>
  );
}

function App(): React.JSX.Element {
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" backgroundColor="#FFFFFF" />
      <NavigationContainer>
        <Stack.Navigator screenOptions={{headerShown: false}}>
          <Stack.Screen name="MainTabs" component={MainTabs} />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FFFFFF',
  },
});

export default App;