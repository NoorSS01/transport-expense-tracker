import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY = 'daily_entries_v1';

export type DailyEntry = {
  id: string;
  date: string;
  kms: number;
  income: number;
  fuelCost: number;
  fixedExpensesPerDay: number;
  extraExpenses?: number;
  profit: number;
  notes?: string;
  createdAt: string;
};

export async function saveDailyEntry(entry: DailyEntry) {
  try {
    const raw = await AsyncStorage.getItem(KEY);
    const arr: DailyEntry[] = raw ? JSON.parse(raw) : [];
    arr.unshift(entry); // latest first
    await AsyncStorage.setItem(KEY, JSON.stringify(arr));
    return true;
  } catch (err) {
    console.warn('Failed to save entry', err);
    return false;
  }
}

export async function getAllDailyEntries(): Promise<DailyEntry[]> {
  try {
    const raw = await AsyncStorage.getItem(KEY);
    const arr: DailyEntry[] = raw ? JSON.parse(raw) : [];
    return arr as DailyEntry[];
  } catch (err) {
    console.warn('Failed to load entries', err);
    return [];
  }
}

export async function clearAllEntries() {
  await AsyncStorage.removeItem(KEY);
}

export default { saveDailyEntry, getAllDailyEntries, clearAllEntries };
