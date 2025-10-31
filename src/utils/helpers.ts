export function formatCurrency(value: number) {
  if (isNaN(value)) return '₹0';
  return `₹${Math.round(value).toLocaleString('en-IN')}`;
}

export function formatDate(dateStr: string) {
  // very small helper — expects 'DD Mon YYYY' strings used in sample data
  return dateStr;
}
