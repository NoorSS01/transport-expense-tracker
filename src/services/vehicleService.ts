import AsyncStorage from '@react-native-async-storage/async-storage';
import { defaultVehicleSettings } from '../utils/constants';

const KEY = 'vehicle_settings_v1';

export type VehicleSettings = typeof defaultVehicleSettings;

export async function saveVehicleSettings(settings: Partial<VehicleSettings>) {
  try {
    const currentRaw = await AsyncStorage.getItem(KEY);
    const current = currentRaw ? JSON.parse(currentRaw) : {};
    const merged = { ...current, ...settings };
    await AsyncStorage.setItem(KEY, JSON.stringify(merged));
    return merged as VehicleSettings;
  } catch (err) {
    console.warn('Failed to save vehicle settings', err);
    return null;
  }
}

export async function getVehicleSettings(): Promise<VehicleSettings> {
  try {
    const raw = await AsyncStorage.getItem(KEY);
    if (!raw) return defaultVehicleSettings;
    return { ...defaultVehicleSettings, ...(JSON.parse(raw) || {}) } as VehicleSettings;
  } catch (err) {
    console.warn('Failed to load vehicle settings', err);
    return defaultVehicleSettings;
  }
}

export async function clearVehicleSettings() {
  await AsyncStorage.removeItem(KEY);
}

export default { saveVehicleSettings, getVehicleSettings, clearVehicleSettings };
