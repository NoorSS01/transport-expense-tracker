import React from 'react';
import { TextInput } from 'react-native-paper';

type Props = {
  label: string;
  value: string;
  onChangeText: (t: string) => void;
  keyboardType?: 'default' | 'numeric';
};

export default function InputField({ label, value, onChangeText, keyboardType = 'default' }: Props) {
  return <TextInput label={label} value={value} onChangeText={onChangeText} mode="outlined" keyboardType={keyboardType} style={{ marginBottom: 8 }} />;
}
