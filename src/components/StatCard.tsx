import React from 'react';
import { StyleSheet, View } from 'react-native';
import { Card, Title, Paragraph } from 'react-native-paper';

type Props = {
  title: string;
  value: string;
  subtitle?: string;
  color?: string;
};

export default function StatCard({ title, value, subtitle, color = '#3A6D8C' }: Props) {
  return (
    <Card style={[styles.card, { borderColor: color }]}> 
      <Card.Content>
        <Title style={{ color }}>{title}</Title>
        <Paragraph style={styles.value}>{value}</Paragraph>
        {subtitle ? <Paragraph style={styles.subtitle}>{subtitle}</Paragraph> : null}
      </Card.Content>
    </Card>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    margin: 4,
    borderWidth: 1,
    borderRadius: 10,
    elevation: 2,
  },
  value: {
    fontSize: 18,
    fontWeight: '700',
    marginTop: 6,
  },
  subtitle: {
    fontSize: 12,
    color: '#6B7280',
    marginTop: 4,
  },
});
