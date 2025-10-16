import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Switch,
  Alert,
  Linking,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

interface SettingsState {
  notifications: boolean;
  darkMode: boolean;
  biometrics: boolean;
  autoSync: boolean;
  locationServices: boolean;
  analytics: boolean;
}

const SettingsApp: React.FC = () => {
  const [settings, setSettings] = useState<SettingsState>({
    notifications: true,
    darkMode: false,
    biometrics: true,
    autoSync: true,
    locationServices: false,
    analytics: true,
  });

  const toggleSetting = (key: keyof SettingsState) => {
    setSettings(prev => ({
      ...prev,
      [key]: !prev[key],
    }));
  };

  const handlePrivacyPolicy = () => {
    Alert.alert(
      'Privacy Policy',
      'This would typically open the privacy policy in a web browser or in-app browser.',
    );
  };

  const handleTermsOfService = () => {
    Alert.alert(
      'Terms of Service',
      'This would typically open the terms of service in a web browser or in-app browser.',
    );
  };

  const handleContactSupport = () => {
    Alert.alert(
      'Contact Support',
      'This would typically open an email client or support chat.',
    );
  };

  const handleSignOut = () => {
    Alert.alert(
      'Sign Out',
      'Are you sure you want to sign out?',
      [
        {text: 'Cancel', style: 'cancel'},
        {text: 'Sign Out', style: 'destructive', onPress: () => {}},
      ],
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
    onToggle: () => void;
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
          <Text
            style={[
              styles.settingTitle,
              destructive && styles.destructiveText,
            ]}>
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
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Settings</Text>
          <Text style={styles.subtitle}>Mini App 3 - Module Federation</Text>
        </View>

        {/* Privacy & Security Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>Privacy & Security</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              title="Push Notifications"
              description="Receive notifications about important updates"
              value={settings.notifications}
              onToggle={() => toggleSetting('notifications')}
              icon="🔔"
            />
            <SettingItem
              title="Biometric Authentication"
              description="Use Face ID or Touch ID to secure your account"
              value={settings.biometrics}
              onToggle={() => toggleSetting('biometrics')}
              icon="🔐"
            />
            <SettingItem
              title="Location Services"
              description="Allow the app to access your location"
              value={settings.locationServices}
              onToggle={() => toggleSetting('locationServices')}
              icon="📍"
            />
            <SettingItem
              title="Analytics & Crash Reports"
              description="Help improve the app by sharing usage data"
              value={settings.analytics}
              onToggle={() => toggleSetting('analytics')}
              icon="📊"
            />
          </View>
        </View>

        {/* App Preferences Section */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>App Preferences</Text>
          <View style={styles.sectionContent}>
            <SettingItem
              title="Dark Mode"
              description="Switch to dark theme for better night viewing"
              value={settings.darkMode}
              onToggle={() => toggleSetting('darkMode')}
              icon="🌙"
            />
            <SettingItem
              title="Auto Sync"
              description="Automatically sync data across devices"
              value={settings.autoSync}
              onToggle={() => toggleSetting('autoSync')}
              icon="🔄"
            />
          </View>
        </View>

        {/* Support Section */}
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

        {/* Account Section */}
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

        {/* Mini App Info */}
        <View style={styles.infoSection}>
          <Text style={styles.infoTitle}>Mini App Information</Text>
          <Text style={styles.infoText}>
            This settings mini app demonstrates:
          </Text>
          <View style={styles.featureList}>
            <Text style={styles.featureItem}>• Persistent settings management</Text>
            <Text style={styles.featureItem}>• Native UI components (Switch)</Text>
            <Text style={styles.featureItem}>• Modular configuration screens</Text>
            <Text style={styles.featureItem}>• Cross-platform compatibility</Text>
          </View>
          
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
  header: {
    alignItems: 'center',
    marginBottom: 30,
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1D1D1F',
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: '#666666',
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
  infoSection: {
    backgroundColor: '#F8F9FA',
    padding: 16,
    borderRadius: 12,
    marginBottom: 20,
  },
  infoTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 20,
    marginBottom: 12,
  },
  featureList: {
    gap: 4,
    marginBottom: 16,
  },
  featureItem: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 20,
  },
  versionInfo: {
    alignItems: 'center',
    paddingTop: 16,
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
  },
  versionText: {
    fontSize: 12,
    color: '#999999',
    marginBottom: 2,
  },
});

export default SettingsApp;