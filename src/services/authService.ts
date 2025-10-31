import supabase from './supabaseClient';

/**
 * Production-ready auth service for OTP-based flows (email OTP)
 * Provides:
 *  - signUpStart: registers user and triggers email OTP (signup confirmation)
 *  - sendLoginOtp: sends OTP to email for sign-in
 *  - verifyOtp: verifies an OTP (signup or login) and returns session
 *  - signInWithPassword / signOut / getSession / onAuthStateChange helpers
 *
 * Note: This implementation expects Supabase project to have Email OTP / confirmation enabled
 * and that verifyOtp is supported for the chosen auth configuration.
 */

// Start a sign-up: create user server-side and rely on Supabase to send the signup OTP
export async function signUpStart(fullName: string, email: string, password: string) {
  try {
    // signUp will create a user and (depending on your Supabase settings) send a confirmation OTP
    const res = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName },
      },
    });
    return res;
  } catch (error) {
    return { error } as any;
  }
}

// Send OTP for passwordless sign-in
export async function sendLoginOtp(email: string) {
  try {
    const res = await supabase.auth.signInWithOtp({ email });
    return res;
  } catch (error) {
    return { error } as any;
  }
}

// Verify an OTP. 'type' should be 'signup' for signup confirmation or 'otp' for login OTP.
export async function verifyOtp(email: string, token: string, type: 'signup' | 'otp' = 'signup') {
  try {
    // verifyOtp returns session on success in many Supabase setups
  const res = await supabase.auth.verifyOtp({ email, token, type: type as any });
    return res;
  } catch (error) {
    return { error } as any;
  }
}

export async function signInWithPassword(email: string, password: string) {
  try {
    return await supabase.auth.signInWithPassword({ email, password });
  } catch (error) {
    return { error } as any;
  }
}

export async function signOut() {
  return supabase.auth.signOut();
}

export async function getSession() {
  const { data } = await supabase.auth.getSession();
  return data.session;
}

export function onAuthStateChange(callback: (event: any, session: any) => void) {
  return supabase.auth.onAuthStateChange((event: any, session: any) => callback(event, session));
}

export default {
  signUpStart,
  sendLoginOtp,
  verifyOtp,
  signInWithPassword,
  signOut,
  getSession,
  onAuthStateChange,
};
