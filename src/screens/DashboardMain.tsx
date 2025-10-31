import React, { useEffect, useState } from 'react';
import { View, ScrollView, StyleSheet } from 'react-native';
import { Text, Title, Button } from 'react-native-paper';
import StatCard from '../components/StatCard';
import ChartView from '../components/ChartView';
import RecentEntries from '../components/RecentEntries';
import { sampleMonthly } from '../utils/constants';
import { formatCurrency } from '../utils/helpers';
import { getAllDailyEntries } from '../services/storageService';

export default function DashboardMain({ navigation }: any) {
  const [entries, setEntries] = useState<any[]>([]);

  async function load() {
    const all = await getAllDailyEntries();
    setEntries(all);
  }

  useEffect(() => {
    load();
    const unsub = (navigation as any).addListener?.('focus', load);
    return () => unsub && unsub();
  }, []);

  const today = entries.length > 0 ? entries[0] : { date: 'No entries', kms: 0, income: 0, fuelCost: 0, profit: 0 };

  // monthly summary (current month)
  const now = new Date();
  const currentMonthEntries = entries.filter((e) => {
    try {
      const d = new Date(e.createdAt || e.date);
      return d.getMonth() === now.getMonth() && d.getFullYear() === now.getFullYear();
    } catch (err) {
      return false;
    }
  });

  const monthlyTotals = currentMonthEntries.reduce(
    (acc, e) => {
      acc.kms += e.kms || 0;
      acc.income += e.income || 0;
      const expenses = (e.fuelCost || 0) + (e.fixedExpensesPerDay || 0) + (e.extraExpenses || 0);
      acc.expenses += expenses;
      acc.profit += e.profit || 0;
      return acc;
    },
    { kms: 0, income: 0, expenses: 0, profit: 0 }
  );

  return (
    <ScrollView contentContainerStyle={styles.container}>
      <Title style={styles.header}>Transport Profit Tracker</Title>

      <View style={styles.row}>
        <StatCard title="KMs (today)" value={`${today.kms} km`} subtitle={today.date} />
        <StatCard title="Income (today)" value={formatCurrency(today.income)} subtitle="Today's income" />
      </View>

      <View style={styles.row}>
        <StatCard title="Fuel (today)" value={formatCurrency(today.fuelCost)} subtitle="Fuel cost" />
        <StatCard title="Profit (today)" value={formatCurrency(today.profit)} subtitle="Net profit" color={today.profit >= 0 ? '#4CAF50' : '#FF5252'} />
      </View>

      <View style={{ marginTop: 8 }}>
        <Text style={{ fontWeight: '700', color: '#001F3F', marginBottom: 8 }}>Monthly Summary</Text>
        <View style={styles.row}>
          <StatCard title="Total KMs" value={`${monthlyTotals.kms} km`} subtitle={`Entries: ${currentMonthEntries.length}`} />
          <StatCard title="Total Income" value={formatCurrency(monthlyTotals.income)} subtitle="This period" />
        </View>
        <View style={styles.row}>
          <StatCard title="Total Expenses" value={formatCurrency(monthlyTotals.expenses)} subtitle="Fuel + fixed + extra" />
          <StatCard title="Profit" value={formatCurrency(monthlyTotals.profit)} subtitle="Net" color={monthlyTotals.profit >= 0 ? '#4CAF50' : '#FF5252'} />
        </View>
      </View>

      <ChartView data={sampleMonthly} />

      <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginTop: 12 }}>
        <Button mode="contained" onPress={() => navigation.navigate('DailyEntry')}>Add Entry</Button>
        <Button mode="outlined" onPress={() => navigation.navigate('VehicleSetup')}>Vehicle Settings</Button>
      </View>

      <RecentEntries entries={entries.slice(0, 8)} />

      <Text style={styles.note}>Monthly summary shown as kms per day (sample chart).</Text>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 16,
    backgroundColor: '#F8FAFC',
  },
  header: {
    marginBottom: 12,
    color: '#001F3F',
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 12,
  },
  note: {
    marginTop: 12,
    color: '#6B7280',
    textAlign: 'center',
  },
});
