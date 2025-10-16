import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Dimensions,
} from 'react-native';

const {width} = Dimensions.get('window');

const HomeScreen: React.FC = () => {
  const miniApps = [
    {
      name: 'User Profile',
      description: 'Manage your personal information and preferences',
      color: '#007AFF',
      icon: '👤',
    },
    {
      name: 'Shopping Cart',
      description: 'Browse products and manage your shopping experience',
      color: '#FF9500',
      icon: '🛒',
    },
    {
      name: 'Settings',
      description: 'Configure app preferences and account settings',
      color: '#34C759',
      icon: '⚙️',
    },
  ];

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      <View style={styles.header}>
        <Text style={styles.title}>Welcome to Super App</Text>
        <Text style={styles.subtitle}>
          A modular React Native app using Module Federation
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Mini Applications</Text>
        <Text style={styles.sectionDescription}>
          Each mini app is independently developed and dynamically loaded
        </Text>

        {miniApps.map((app, index) => (
          <TouchableOpacity key={index} style={styles.appCard}>
            <View style={[styles.appIcon, {backgroundColor: app.color}]}>
              <Text style={styles.appIconText}>{app.icon}</Text>
            </View>
            <View style={styles.appInfo}>
              <Text style={styles.appName}>{app.name}</Text>
              <Text style={styles.appDescription}>{app.description}</Text>
            </View>
          </TouchableOpacity>
        ))}
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Architecture Features</Text>
        <View style={styles.featureList}>
          <FeatureItem
            icon="🔧"
            title="Re.Pack Integration"
            description="Uses Rspack instead of Metro for better performance"
          />
          <FeatureItem
            icon="🌐"
            title="Module Federation"
            description="Dynamic loading of micro-frontends"
          />
          <FeatureItem
            icon="☁️"
            title="Zephyr Cloud"
            description="Remote bundle deployment and management"
          />
          <FeatureItem
            icon="📱"
            title="Cross-Platform"
            description="Automatic iOS/Android platform resolution"
          />
        </View>
      </View>
    </ScrollView>
  );
};

interface FeatureItemProps {
  icon: string;
  title: string;
  description: string;
}

const FeatureItem: React.FC<FeatureItemProps> = ({icon, title, description}) => (
  <View style={styles.featureItem}>
    <Text style={styles.featureIcon}>{icon}</Text>
    <View style={styles.featureContent}>
      <Text style={styles.featureTitle}>{title}</Text>
      <Text style={styles.featureDescription}>{description}</Text>
    </View>
  </View>
);

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
    textAlign: 'center',
    lineHeight: 22,
  },
  section: {
    marginBottom: 30,
  },
  sectionTitle: {
    fontSize: 22,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 8,
  },
  sectionDescription: {
    fontSize: 14,
    color: '#666666',
    marginBottom: 20,
    lineHeight: 20,
  },
  appCard: {
    flexDirection: 'row',
    backgroundColor: '#F8F9FA',
    borderRadius: 12,
    padding: 16,
    marginBottom: 12,
    alignItems: 'center',
  },
  appIcon: {
    width: 50,
    height: 50,
    borderRadius: 25,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  appIconText: {
    fontSize: 24,
  },
  appInfo: {
    flex: 1,
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
    lineHeight: 18,
  },
  featureList: {
    gap: 16,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
  },
  featureIcon: {
    fontSize: 20,
    marginRight: 12,
    marginTop: 2,
  },
  featureContent: {
    flex: 1,
  },
  featureTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 4,
  },
  featureDescription: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 18,
  },
});

export default HomeScreen;