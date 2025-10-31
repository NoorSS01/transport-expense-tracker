declare module '@react-navigation/native' {
  export * from 'react';
  export const NavigationContainer: any;
  export function useNavigation(): any;
  export function useRoute(): any;
}

declare module '@react-navigation/native-stack' {
  import React from 'react';
  export function createNativeStackNavigator(): any;
}
