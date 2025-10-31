import React from 'react';
import { View, StyleSheet, FlatList } from 'react-native';
import { Card, Paragraph, Text } from 'react-native-paper';
import { formatCurrency } from '../utils/helpers';
import { DailyEntry } from '../services/storageService';

export default function RecentEntries({ entries = [] as DailyEntry[] }: { entries?: DailyEntry[] }) {
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Recent Entries</Text>
      {entries.length === 0 ? (
        <Paragraph style={styles.empty}>No entries yet. Add your first daily entry.</Paragraph>
      ) : (
        <FlatList
          data={entries}
          keyExtractor={(item) => item.id}
          scrollEnabled={false}
          renderItem={({ item }) => (
            <Card style={styles.card}>
              <Card.Content>
                <Text style={styles.date}>{item.date}</Text>
                <View style={styles.row}>
                  <Paragraph style={styles.km}>{item.kms} km</Paragraph>
                  <Paragraph style={styles.income}>{formatCurrency(item.income)}</Paragraph>
                  <Paragraph style={[styles.profit, { color: item.profit >= 0 ? '#4CAF50' : '#FF5252' }]}>{formatCurrency(item.profit)}</Paragraph>
                </View>
                {item.notes ? <Paragraph style={styles.notes}>{item.notes}</Paragraph> : null}
              </Card.Content>
            </Card>
          )}
        />
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: { marginTop: 12 },
  title: { fontWeight: '700', color: '#001F3F', marginBottom: 8 },
  empty: { color: '#6B7280' },
  card: { marginBottom: 8, borderRadius: 8 },
  date: { fontWeight: '700', marginBottom: 6 },
  row: { flexDirection: 'row', justifyContent: 'space-between' },
  km: { fontWeight: '600' },
  income: { fontWeight: '700' },
  profit: { fontWeight: '700' },
  notes: { marginTop: 6, color: '#6B7280' },
});
