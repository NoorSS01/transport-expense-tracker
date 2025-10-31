import React from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { Card, Paragraph, Title } from 'react-native-paper';
import { formatCurrency } from '../utils/helpers';

type Entry = {
  id: string;
  date: string;
  kms: number;
  income: number;
  fuelCost: number;
  fixedExpensesPerDay: number;
  extraExpenses?: number;
  profit: number;
  notes?: string;
};

export default function EntryList({ entries = [] as Entry[] }: { entries?: Entry[] }) {
  return (
    <View style={styles.container}>
      <Title style={styles.title}>Recent Entries</Title>
      <FlatList
        data={entries}
        keyExtractor={(i) => i.id}
        scrollEnabled={false}
        renderItem={({ item }) => (
          <Card style={styles.card}>
            <Card.Content>
              <View style={styles.row}>
                <View style={styles.col}>
                  <Paragraph style={styles.date}>{item.date}</Paragraph>
                  <Paragraph style={styles.kms}>{item.kms} km</Paragraph>
                </View>
                <View style={styles.colRight}>
                  <Paragraph style={styles.income}>{formatCurrency(item.income)}</Paragraph>
                  <Paragraph style={[styles.profit, { color: item.profit >= 0 ? '#166534' : '#b91c1c' }]}>{formatCurrency(item.profit)}</Paragraph>
                </View>
              </View>
              {item.notes ? <Paragraph style={styles.notes}>{item.notes}</Paragraph> : null}
            </Card.Content>
          </Card>
        )}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { marginTop: 12 },
  title: { marginBottom: 8, color: '#001F3F' },
  card: { marginBottom: 8, borderRadius: 8 },
  row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
  col: {},
  colRight: { alignItems: 'flex-end' },
  date: { fontSize: 12, color: '#6B7280' },
  kms: { fontSize: 16, fontWeight: '700', color: '#001F3F' },
  income: { fontSize: 14, fontWeight: '700' },
  profit: { fontSize: 14, fontWeight: '700' },
  notes: { marginTop: 6, color: '#374151' },
});
