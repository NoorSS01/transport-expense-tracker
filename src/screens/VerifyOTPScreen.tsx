import React, { useState } from 'react';
import { View, StyleSheet, TextInput as RNTextInput, KeyboardAvoidingView, Platform } from 'react-native';
import { Text, Button, HelperText } from 'react-native-paper';
import { useNavigation, useRoute } from '@react-navigation/native';
import authService from '../services/authService';

// Simple OTP input that splits into 6 boxes
function OTPInputs({ value, onChange }: { value: string; onChange: (v: string) => void }) {
  const inputs = Array.from({ length: 6 }, (_, i) => i);
  return (
    <View style={styles.otpRow}>
      {inputs.map((idx) => (
        <RNTextInput
          key={idx}
          style={styles.otpBox}
          keyboardType="number-pad"
          maxLength={1}
          value={value[idx] || ''}
          onChangeText={(t) => {
            const arr = value.split('');
            arr[idx] = t;
            const next = arr.join('');
            onChange(next);
          }}
        />
      ))}
    </View>
  );
}

export default function VerifyOTPScreen() {
  const nav = useNavigation();
  const route: any = useRoute();
  const { email, mode = 'signup' } = route.params || {};
  const [code, setCode] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const verify = async () => {
    setError(null);
    if (code.length < 6) { setError('Please enter the 6-digit code'); return; }
    setLoading(true);
    try {
      // call verifyOtp wrapper (type: 'signup' for signup confirmation, 'otp' for login)
      const res = await authService.verifyOtp(email, code, mode === 'signup' ? 'signup' : 'otp');
      if (res?.error) {
        // Supabase returns error objects; show friendly message
        setError((res.error && res.error.message) || 'Verification failed');
      } else {
        // If verification returned a session, auth state will be updated. Navigate to Dashboard.
        nav.navigate('Dashboard' as never);
      }
    } catch (e: any) {
      setError(e?.message || String(e));
    } finally {
      setLoading(false);
    }
  };

  return (
    <KeyboardAvoidingView behavior={Platform.OS === 'ios' ? 'padding' : undefined} style={styles.container}>
      <Text style={styles.title}>Verify your email</Text>
      <Text style={{ textAlign: 'center', marginBottom: 12 }}>We've sent a verification code to {email}</Text>
      <OTPInputs value={code} onChange={setCode} />
      {error ? <HelperText type="error">{error}</HelperText> : null}
      <Button mode="contained" onPress={verify} loading={loading} style={{ marginTop: 16 }}>Verify OTP</Button>
    </KeyboardAvoidingView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: '#F5F7FA', padding: 20, justifyContent: 'center' },
  title: { fontSize: 22, textAlign: 'center', marginBottom: 8 },
  otpRow: { flexDirection: 'row', justifyContent: 'space-between', marginTop: 12 },
  otpBox: { width: 44, height: 52, borderRadius: 8, backgroundColor: '#fff', textAlign: 'center', fontSize: 20, borderWidth: 1, borderColor: '#E6EAF0' },
});
