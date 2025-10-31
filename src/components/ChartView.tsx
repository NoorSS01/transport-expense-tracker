import React from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import { BarChart } from 'react-native-chart-kit';
import { Text } from 'react-native-paper';

type DataPoint = { day: string; kms: number };

export default function ChartView({ data = [] as DataPoint[] }: { data?: DataPoint[] }) {
  const labels = data.map((d) => d.day);
  const values = data.map((d) => d.kms);
  const screenWidth = Math.min(Dimensions.get('window').width - 48, 800);

  const chartData = {
    labels,
    datasets: [{ data: values }],
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Monthly KMs (sample)</Text>
      <BarChart
        data={chartData}
        width={screenWidth}
        height={220}
        yAxisLabel={""}
        yAxisSuffix={""}
        fromZero
        chartConfig={{
          backgroundGradientFrom: '#fff',
          backgroundGradientTo: '#fff',
          decimalPlaces: 0,
          color: () => '#3A6D8C',
          labelColor: () => '#001F3F',
          style: { borderRadius: 8 },
        }}
        style={{ borderRadius: 8 }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { backgroundColor: '#fff', padding: 12, borderRadius: 10, marginTop: 12 },
  title: { marginBottom: 8, color: '#001F3F', fontWeight: '700' },
});
