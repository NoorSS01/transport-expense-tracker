import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { TextInput, Button, Text, HelperText, IconButton, ActivityIndicator } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import authService from '../services/authService';

// Simple email regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
// Password: min 8, one uppercase, one lowercase, one number
const PASSWORD_REGEX = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$/;

export default function SignupScreen() {
  const nav = useNavigation();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [visible, setVisible] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const validate = () => {
    if (!fullName.trim()) return 'Full name is required';
    if (!EMAIL_REGEX.test(email)) return 'Please enter a valid email address';
    if (!PASSWORD_REGEX.test(password)) return 'Password must be at least 8 chars, include upper, lower and a number';
    return null;
  };

  const onContinue = async () => {
    setError(null);
    const v = validate();
    if (v) { setError(v); return; }

    setLoading(true);
    try {
      // Start signup and send OTP to the user's email. The Supabase project must be configured
      // to send a numeric OTP for signup confirmation (email confirmation).
      const res = await authService.signUpStart(fullName.trim(), email.trim().toLowerCase(), password);
      if (res?.error) {
        setError(res.error.message || 'Could not start signup.');
      } else {
        // Navigate to OTP screen where user can enter the 6-digit code
        (nav as any).navigate('VerifyOTP', { email: email.trim().toLowerCase(), mode: 'signup' });
      }
    } catch (e: any) {
      setError(e?.message || String(e));
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Create account</Text>

      <TextInput
        mode="outlined"
        label="Full name"
        value={fullName}
        onChangeText={setFullName}
        style={styles.input}
        placeholder="Jane Doe"
      />

      <TextInput
        mode="outlined"
        label="Email"
        value={email}
        onChangeText={setEmail}
        style={styles.input}
        keyboardType="email-address"
        autoCapitalize="none"
      />

      <TextInput
        mode="outlined"
        label="Password"
        value={password}
        onChangeText={setPassword}
        style={styles.input}
        secureTextEntry={!visible}
        right={<TextInput.Icon icon={visible ? 'eye-off' : 'eye'} onPress={() => setVisible(v => !v)} />}
      />

      {error ? <HelperText type="error">{error}</HelperText> : null}

      <Button mode="contained" onPress={onContinue} style={styles.button} disabled={loading}>
        {loading ? <ActivityIndicator animating size={18} color="#fff" /> : 'Continue'}
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F7FA', padding: 20, justifyContent: 'center' },
  title: { fontSize: 24, textAlign: 'center', marginBottom: 24 },
  input: { marginBottom: 12, backgroundColor: '#fff', borderRadius: 8 },
  button: { marginTop: 12, paddingVertical: 6, borderRadius: 8 },
});
