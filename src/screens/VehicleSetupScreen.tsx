import React, { useEffect, useState } from 'react';
import { View, StyleSheet, Alert } from 'react-native';
import { Title, Button } from 'react-native-paper';
import InputField from '../components/InputField';
import { getVehicleSettings, saveVehicleSettings } from '../services/vehicleService';

export default function VehicleSetupScreen() {
  const [mileage, setMileage] = useState('');
  const [fuelPrice, setFuelPrice] = useState('');
  const [ratePerKm, setRatePerKm] = useState('');
  const [emi, setEmi] = useState('');
  const [driverSalary, setDriverSalary] = useState('');
  const [maintenance, setMaintenance] = useState('');

  useEffect(() => {
    (async () => {
      const s = await getVehicleSettings();
      setMileage(String(s.mileage));
      setFuelPrice(String(s.fuelPrice));
      setRatePerKm(String(s.ratePerKm));
      setEmi(String(s.emi));
      setDriverSalary(String(s.driverSalary));
      setMaintenance(String(s.maintenance));
    })();
  }, []);

  const onSave = async () => {
    const payload = {
      mileage: parseFloat(mileage || '0') || undefined,
      fuelPrice: parseFloat(fuelPrice || '0') || undefined,
      ratePerKm: parseFloat(ratePerKm || '0') || undefined,
      emi: parseFloat(emi || '0') || undefined,
      driverSalary: parseFloat(driverSalary || '0') || undefined,
      maintenance: parseFloat(maintenance || '0') || undefined,
    };
    const updated = await saveVehicleSettings(payload as any);
    if (updated) {
      Alert.alert('Saved', 'Vehicle settings saved');
    } else {
      Alert.alert('Error', 'Could not save settings');
    }
  };

  return (
    <View style={styles.container}>
      <Title style={{ marginBottom: 12 }}>Vehicle Setup</Title>
      <InputField label="Mileage (km per litre)" value={mileage} onChangeText={setMileage} keyboardType="numeric" />
      <InputField label="Fuel price (₹ per litre)" value={fuelPrice} onChangeText={setFuelPrice} keyboardType="numeric" />
      <InputField label="Rate per km (₹)" value={ratePerKm} onChangeText={setRatePerKm} keyboardType="numeric" />
      <InputField label="EMI (monthly)" value={emi} onChangeText={setEmi} keyboardType="numeric" />
      <InputField label="Driver salary (monthly)" value={driverSalary} onChangeText={setDriverSalary} keyboardType="numeric" />
      <InputField label="Maintenance (monthly)" value={maintenance} onChangeText={setMaintenance} keyboardType="numeric" />

      <Button mode="contained" onPress={onSave} style={{ marginTop: 12 }}>
        Save Vehicle Settings
      </Button>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { padding: 16, backgroundColor: '#fff', flex: 1 },
});
