import React, { useState } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { Title, Button, Text } from 'react-native-paper';
import InputField from '../components/InputField';
import { calculateDailyFromInputs } from '../services/calculationService';
import { saveDailyEntry } from '../services/storageService';
import { getVehicleSettings } from '../services/vehicleService';

export default function DailyEntryScreen({ navigation }: any) {
  const [kms, setKms] = useState('');
  const [extraExpenses, setExtraExpenses] = useState('');
  const [notes, setNotes] = useState('');

  const [settings, setSettings] = React.useState<any>(null);

  React.useEffect(() => {
    (async () => {
      const s = await getVehicleSettings();
      setSettings(s);
    })();
  }, []);

  const onSave = async () => {
    const kmsNum = parseFloat(kms || '0');
    const extraNum = parseFloat(extraExpenses || '0');
    if (!kmsNum || kmsNum <= 0) {
      Alert.alert('Validation', 'Please enter kilometers traveled (number > 0)');
      return;
    }

    const calc = calculateDailyFromInputs(kmsNum, settings || undefined);
    // incorporate extra expenses into the totals
    const fuelCost = calc.fuelCost;
    const fixed = calc.fixedExpensesPerDay;
    const income = calc.income;
    const profit = Math.round(income - (fuelCost + extraNum + fixed));

    const entry = {
      id: `${Date.now()}`,
      date: new Date().toLocaleDateString(),
      kms: kmsNum,
      income,
      fuelCost,
      fixedExpensesPerDay: fixed,
      extraExpenses: extraNum,
      profit,
      notes: notes || undefined,
      createdAt: new Date().toISOString(),
    };

    const ok = await saveDailyEntry(entry as any);
    if (ok) {
      Alert.alert('Saved', 'Daily entry saved locally');
      navigation.navigate('Dashboard');
    } else {
      Alert.alert('Error', 'Could not save entry');
    }
  };

  return (
    <View style={styles.container}>
      <Title style={{ marginBottom: 12 }}>Daily Entry</Title>
      <InputField label="Kilometers (km)" value={kms} onChangeText={setKms} keyboardType="numeric" />
      <InputField label="Other expenses (₹)" value={extraExpenses} onChangeText={setExtraExpenses} keyboardType="numeric" />
      <InputField label="Notes" value={notes} onChangeText={setNotes} />

      <Button mode="contained" onPress={onSave} style={{ marginTop: 12 }}>
        Save Entry
      </Button>

      <Text style={{ marginTop: 16, color: '#6B7280' }}>
        Tip: enter kms and optional expenses. App will auto-calculate income, fuel cost and profit.
      </Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16, backgroundColor: '#fff', flex: 1 },
});
