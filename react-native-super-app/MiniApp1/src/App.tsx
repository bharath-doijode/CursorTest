import React, {useState} from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Image,
  Alert,
} from 'react-native';
import {SafeAreaView} from 'react-native-safe-area-context';

interface UserProfile {
  name: string;
  email: string;
  phone: string;
  bio: string;
  avatar: string;
}

const UserProfileApp: React.FC = () => {
  const [isEditing, setIsEditing] = useState(false);
  const [profile, setProfile] = useState<UserProfile>({
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1 (555) 123-4567',
    bio: 'Software developer passionate about React Native and mobile technologies.',
    avatar: 'https://via.placeholder.com/120/007AFF/FFFFFF?text=JD',
  });

  const [editedProfile, setEditedProfile] = useState<UserProfile>(profile);

  const handleSave = () => {
    setProfile(editedProfile);
    setIsEditing(false);
    Alert.alert('Success', 'Profile updated successfully!');
  };

  const handleCancel = () => {
    setEditedProfile(profile);
    setIsEditing(false);
  };

  const ProfileField = ({
    label,
    value,
    onChangeText,
    multiline = false,
  }: {
    label: string;
    value: string;
    onChangeText: (text: string) => void;
    multiline?: boolean;
  }) => (
    <View style={styles.fieldContainer}>
      <Text style={styles.fieldLabel}>{label}</Text>
      {isEditing ? (
        <TextInput
          style={[styles.fieldInput, multiline && styles.multilineInput]}
          value={value}
          onChangeText={onChangeText}
          multiline={multiline}
          numberOfLines={multiline ? 3 : 1}
        />
      ) : (
        <Text style={styles.fieldValue}>{value}</Text>
      )}
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>User Profile</Text>
          <Text style={styles.subtitle}>Mini App 1 - Module Federation</Text>
        </View>

        {/* Avatar Section */}
        <View style={styles.avatarSection}>
          <Image source={{uri: profile.avatar}} style={styles.avatar} />
          <TouchableOpacity style={styles.changeAvatarButton}>
            <Text style={styles.changeAvatarText}>Change Photo</Text>
          </TouchableOpacity>
        </View>

        {/* Profile Fields */}
        <View style={styles.formSection}>
          <ProfileField
            label="Full Name"
            value={editedProfile.name}
            onChangeText={text => setEditedProfile({...editedProfile, name: text})}
          />

          <ProfileField
            label="Email Address"
            value={editedProfile.email}
            onChangeText={text => setEditedProfile({...editedProfile, email: text})}
          />

          <ProfileField
            label="Phone Number"
            value={editedProfile.phone}
            onChangeText={text => setEditedProfile({...editedProfile, phone: text})}
          />

          <ProfileField
            label="Bio"
            value={editedProfile.bio}
            onChangeText={text => setEditedProfile({...editedProfile, bio: text})}
            multiline
          />
        </View>

        {/* Action Buttons */}
        <View style={styles.buttonSection}>
          {isEditing ? (
            <View style={styles.editButtonContainer}>
              <TouchableOpacity
                style={[styles.button, styles.cancelButton]}
                onPress={handleCancel}>
                <Text style={styles.cancelButtonText}>Cancel</Text>
              </TouchableOpacity>
              <TouchableOpacity
                style={[styles.button, styles.saveButton]}
                onPress={handleSave}>
                <Text style={styles.saveButtonText}>Save Changes</Text>
              </TouchableOpacity>
            </View>
          ) : (
            <TouchableOpacity
              style={[styles.button, styles.editButton]}
              onPress={() => setIsEditing(true)}>
              <Text style={styles.editButtonText}>Edit Profile</Text>
            </TouchableOpacity>
          )}
        </View>

        {/* Mini App Info */}
        <View style={styles.infoSection}>
          <Text style={styles.infoTitle}>Mini App Information</Text>
          <Text style={styles.infoText}>
            This is a federated mini app running independently with its own
            bundle. It demonstrates:
          </Text>
          <View style={styles.featureList}>
            <Text style={styles.featureItem}>• Independent development</Text>
            <Text style={styles.featureItem}>• Shared dependencies</Text>
            <Text style={styles.featureItem}>• Dynamic loading</Text>
            <Text style={styles.featureItem}>• Error boundaries</Text>
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
  avatarSection: {
    alignItems: 'center',
    marginBottom: 30,
  },
  avatar: {
    width: 120,
    height: 120,
    borderRadius: 60,
    marginBottom: 12,
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
  formSection: {
    marginBottom: 30,
  },
  fieldContainer: {
    marginBottom: 20,
  },
  fieldLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1D1D1F',
    marginBottom: 8,
  },
  fieldValue: {
    fontSize: 16,
    color: '#333333',
    padding: 12,
    backgroundColor: '#F8F9FA',
    borderRadius: 8,
    minHeight: 44,
  },
  fieldInput: {
    fontSize: 16,
    color: '#333333',
    padding: 12,
    backgroundColor: '#FFFFFF',
    borderRadius: 8,
    borderWidth: 1,
    borderColor: '#E0E0E0',
    minHeight: 44,
  },
  multilineInput: {
    minHeight: 80,
    textAlignVertical: 'top',
  },
  buttonSection: {
    marginBottom: 30,
  },
  editButtonContainer: {
    flexDirection: 'row',
    gap: 12,
  },
  button: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  editButton: {
    backgroundColor: '#007AFF',
  },
  editButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  saveButton: {
    backgroundColor: '#34C759',
  },
  saveButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#FFFFFF',
  },
  cancelButton: {
    backgroundColor: '#F0F0F0',
  },
  cancelButtonText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666666',
  },
  infoSection: {
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
  infoText: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 20,
    marginBottom: 12,
  },
  featureList: {
    gap: 4,
  },
  featureItem: {
    fontSize: 14,
    color: '#666666',
    lineHeight: 20,
  },
});

export default UserProfileApp;