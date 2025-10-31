import React, { useEffect, useRef, useState } from 'react';
import { View, StyleSheet } from 'react-native';
import * as Linking from 'expo-linking';
import authService from '../services/authService';
import { TextInput, Button, Text, HelperText } from 'react-native-paper';
import { useAuth } from '../contexts/AuthContext';

export default function AuthScreen() {
  const { signIn, signUp } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [mode, setMode] = useState<'signIn' | 'signUp'>('signIn');
  const [error, setError] = useState<string | null>(null);
  const [info, setInfo] = useState<string | null>(null);
  const [awaitingConfirmation, setAwaitingConfirmation] = useState(false);
  const [resendCooldown, setResendCooldown] = useState(0);

  const submit = async () => {
    // Input validation
    if (!email.trim()) {
      setError('Please enter your email address');
      return;
    }
    if (mode === 'signIn' && !password.trim()) {
      setError('Please enter your password');
      return;
    }

    setLoading(true);
    setError(null);
    try {
      if (mode === 'signIn') {
        // try password sign-in with rate limiting check
        const res = await signIn(email.trim().toLowerCase(), password);
        if (res?.error) {
          const msg = res.error.message || 'Sign in failed';
          // Enhanced error detection
          if (/confirm|verify/i.test(msg) || /not.*confirm/i.test(msg)) {
            setInfo('Your email address has not been confirmed yet. Check your inbox for a confirmation link.');
            setAwaitingConfirmation(true);
            setError(null);
            return;
          }
          if (/too.*many.*attempts/i.test(msg)) {
            setError('Too many attempts. Please try again later or use OTP sign-in.');
            return;
          }
          setError(msg);
        }
      } else {
        // Start signup using OTP confirmation (email OTP)
        const res = await authService.signUpStart('', email, password);
        // Note: signUpStart accepts fullName; this path does not have full name here. Prefer using dedicated Signup screen.
        if (res?.error) {
          setError(res.error.message || 'Could not send confirmation code');
        } else {
          setInfo('An OTP has been sent to your email. Enter it to complete signup.');
          setAwaitingConfirmation(true);
          setResendCooldown(30);
        }
      }
    } catch (e: any) {
      setError(e?.message || String(e));
    } finally {
      setLoading(false);
    }
  };

  const resendConfirmation = async () => {
    // Validate email before sending
    if (!email.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      setError('Please enter a valid email address');
      return;
    }

    setLoading(true);
    setError(null);
    setInfo(null);
    
    try {
      // Use a more specific error message for rate limiting
      if (resendCooldown > 0) {
        setError(`Please wait ${resendCooldown} seconds before requesting another code`);
        return;
      }

      const res = await authService.sendLoginOtp(email.trim().toLowerCase());
      if (res?.error) {
        const msg = res.error.message || '';
        if (/too.*many.*requests/i.test(msg)) {
          setError('Too many attempts. Please try again in a few minutes.');
        } else {
          setError(msg || 'Could not send confirmation code');
        }
      } else {
        setInfo('A new verification code has been sent to your email.');
        setResendCooldown(30);
        // Clear any existing error message on success
        setError(null);
      }
    } catch (e: any) {
      setError(e?.message || 'Failed to send verification code. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // countdown for resend cooldown
  useEffect(() => {
    if (resendCooldown <= 0) return;
    const t = setInterval(() => setResendCooldown((s) => Math.max(0, s - 1)), 1000);
    return () => clearInterval(t);
  }, [resendCooldown]);

  // helper: try to open common mail apps (gmail, outlook) or fallback
  const openMailApp = async () => {
    const schemes = ['googlegmail://', 'ms-outlook://', 'readdle-spark://', 'mailto:'];
    for (const s of schemes) {
      try {
        const can = await Linking.canOpenURL(s);
        if (can) {
          await Linking.openURL(s);
          return;
        }
      } catch (e) {}
    }
    // fallback: open mailto which opens compose on many devices, but at least user can open mail app manually
    try { await Linking.openURL('mailto:'); } catch (e) {}
  };

  // Enhanced session check with retry mechanism
  const manualConfirmCheck = async () => {
    setLoading(true);
    setError(null);
    
    let retryCount = 0;
    const maxRetries = 3;
    const retryDelay = 2000; // 2 seconds between retries

    const checkSession = async (): Promise<boolean> => {
      try {
        const s = await authService.getSession();
        if (s) {
          setInfo('Session detected. You will be redirected shortly...');
          return true;
        }
        return false;
      } catch (e: any) {
        console.warn('Session check failed:', e);
        return false;
      }
    };

    try {
      while (retryCount < maxRetries) {
        const hasSession = await checkSession();
        if (hasSession) break;

        retryCount++;
        if (retryCount < maxRetries) {
          setInfo(`Checking for session... (Attempt ${retryCount + 1}/${maxRetries})`);
          await new Promise(resolve => setTimeout(resolve, retryDelay));
        }
      }

      if (retryCount === maxRetries) {
        setError(
          'No active session found. Please ensure you:\n' +
          '1. Clicked the most recent verification link\n' +
          '2. Used the link on this same device\n' +
          'You can try requesting a new code if needed.'
        );
      }
    } catch (e: any) {
      setError('Failed to verify session. Please try again.');
      console.error('Session verification error:', e);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>{mode === 'signIn' ? 'Sign in' : 'Create account'}</Text>
      {awaitingConfirmation ? (
        <View>
          <Text style={{ textAlign: 'center', marginBottom: 8 }}>{info}</Text>
          <Button mode="contained" onPress={openMailApp} style={{ marginTop: 8 }}>
            Open email app
          </Button>
          <Button mode="outlined" onPress={manualConfirmCheck} style={{ marginTop: 8 }} loading={loading}>
            I clicked the link — check session
          </Button>
          <Button mode="text" onPress={resendConfirmation} style={{ marginTop: 8 }} disabled={loading || !email || resendCooldown > 0}>
            {resendCooldown > 0 ? `Resend available in ${resendCooldown}s` : 'Resend confirmation / Send OTP'}
          </Button>
          {error ? <HelperText type="error">{error}</HelperText> : null}
        </View>
      ) : (
        <>
          <TextInput label="Email" value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" />
          {mode === 'signIn' ? (
            <TextInput label="Password" secureTextEntry value={password} onChangeText={setPassword} style={{ marginTop: 12 }} />
          ) : null}
          {error ? <HelperText type="error">{error}</HelperText> : null}
          {info ? <HelperText type="info">{info}</HelperText> : null}
          <Button mode="contained" onPress={submit} loading={loading} style={{ marginTop: 12 }}>
            {mode === 'signIn' ? 'Sign in' : 'Sign up'}
          </Button>
          {/* Offer to resend confirmation (via OTP) when user can't sign in due to unconfirmed email */}
          <Button mode="text" onPress={resendConfirmation} style={{ marginTop: 8 }} disabled={loading || !email}>
            Resend confirmation / Send OTP
          </Button>
          {/* Provide explicit OTP sign-in option for sign-in mode */}
          {mode === 'signIn' ? (
            <Button mode="outlined" onPress={async () => {
                setLoading(true); setError(null); setInfo(null);
                try {
                  const r = await authService.sendLoginOtp(email);
                  if (r?.error) setError(r.error.message || 'Could not send OTP');
                  else { setInfo('OTP sent. Check your email.'); setAwaitingConfirmation(true); setResendCooldown(30); }
                } catch (e: any) { setError(e?.message || String(e)); }
                finally { setLoading(false); }
              }} style={{ marginTop: 8 }} disabled={!email || loading}>
                Sign in with OTP
              </Button>
          ) : null}
        </>
      )}
      <Button mode="text" onPress={() => setMode(mode === 'signIn' ? 'signUp' : 'signIn')} style={{ marginTop: 8 }}>
        {mode === 'signIn' ? "Don't have an account? Sign up" : 'Have an account? Sign in'}
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, padding: 16, justifyContent: 'center' },
  title: { fontSize: 22, marginBottom: 12, textAlign: 'center' },
});
