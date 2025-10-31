import React, { createContext, useContext, useEffect, useState } from 'react';
import authService from '../services/authService';

type AuthContextType = {
  user: any | null;
  session: any | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<any>;
  signUp: (email: string, password: string) => Promise<any>;
  signOut: () => Promise<any>;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<any | null>(null);
  const [session, setSession] = useState<any | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let mounted = true;

    // Initial session check
    (async () => {
      const s = await authService.getSession();
      if (!mounted) return;
      setSession(s || null);
      setUser(s?.user || null);
      setLoading(false);
    })();

    // Listen for auth state changes
    const { data: authSub } = authService.onAuthStateChange((_, newSession) => {
      setSession(newSession || null);
      setUser(newSession?.user || null);
      setLoading(false);
    }) as any;

    return () => {
      mounted = false;
      try { authSub?.unsubscribe && authSub.unsubscribe(); } catch (e) {}
    };
  }, []);

  const signIn = async (email: string, password: string) => {
    const res = await authService.signInWithPassword(email, password);
    if (res?.data?.session) {
      setSession(res.data.session);
      setUser(res.data.session.user);
    }
    return res;
  };

  // Keep a backward-compatible signUp signature (email,password).
  // Internally this will start signup; prefer calling signUpStart(fullName, email, password) from Signup screen.
  const signUp = async (email: string, password: string) => {
    const res = await authService.signUpStart('', email, password);
    return res;
  };

  const signOut = async () => {
    const res = await authService.signOut();
    setSession(null);
    setUser(null);
    return res;
  };

  return (
    <AuthContext.Provider value={{ user, session, loading, signIn, signUp, signOut }}>
      {children}
    </AuthContext.Provider>
  );
};

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within an AuthProvider');
  return ctx;
}

export default AuthContext;
