import React, { useEffect } from 'react';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider as PaperProvider, DefaultTheme } from 'react-native-paper';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import * as Linking from 'expo-linking';
import DashboardScreen from './src/screens/DashboardScreen';
import DailyEntryScreen from './src/screens/DailyEntryScreen';
import VehicleSetupScreen from './src/screens/VehicleSetupScreen';
import AuthScreen from './src/screens/AuthScreen';
import SignupScreen from './src/screens/SignupScreen';
import VerifyOTPScreen from './src/screens/VerifyOTPScreen';
import { AuthProvider, useAuth } from './src/contexts/AuthContext';

const Stack = createNativeStackNavigator();

const theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: '#3A6D8C',
    accent: '#EAD8B1',
  },
};

export default function App() {
  // Configure deep linking
  const linking = {
    prefixes: ['transportprofit://'],
    config: {
      screens: {
        Auth: 'auth',
        Dashboard: 'dashboard',
      },
    },
    async getInitialURL() {
      // First, try to get the initial URL used to open the app
      const url = await Linking.getInitialURL();
      if (url != null) {
        return url;
      }
      return null;
    },
    subscribe(listener: (url: string) => void) {
      // Listen to incoming links when app is running
      const subscription = Linking.addEventListener('url', ({ url }) => {
        listener(url);
      });
      return () => {
        subscription.remove();
      };
    },
  };

  return (
    <SafeAreaProvider>
      <PaperProvider theme={theme}>
        <AuthProvider>
          <NavigationContainer linking={linking}>
            <RootNavigator />
          </NavigationContainer>
        </AuthProvider>
      </PaperProvider>
    </SafeAreaProvider>
  );
}

function RootNavigator() {
  const { user, loading } = useAuth();

  if (loading) return null; // or a loading screen

  return (
    <Stack.Navigator initialRouteName={user ? 'Dashboard' : 'Auth'}>
      {user ? (
        <>
          <Stack.Screen name="Dashboard" component={DashboardScreen} />
          <Stack.Screen name="DailyEntry" component={DailyEntryScreen} />
          <Stack.Screen name="VehicleSetup" component={VehicleSetupScreen} />
        </>
      ) : (
        <>
          <Stack.Screen name="Auth" component={AuthScreen} options={{ headerShown: false }} />
          <Stack.Screen name="Signup" component={SignupScreen} options={{ title: 'Create account' }} />
          <Stack.Screen name="VerifyOTP" component={VerifyOTPScreen} options={{ title: 'Verify code' }} />
        </>
      )}
    </Stack.Navigator>
  );
}
