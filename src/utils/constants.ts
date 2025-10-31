export const defaultVehicleSettings = {
  mileage: 15, // km per litre
  ratePerKm: 16, // ₹ per km earned
  fuelPrice: 100, // ₹ per litre (sample)
  emi: 20000, // monthly
  driverSalary: 23000, // monthly
  maintenance: 2000, // monthly
};

export const sampleDaily = [
  {
    date: '31 Oct 2025',
    kms: 120,
    income: 120 * 16,
    fuelCost: (120 / 15) * 100,
    fixedExpensesPerDay: Math.round((20000 + 23000 + 2000) / 30),
    profit: Math.round(120 * 16 - ((120 / 15) * 100 + (20000 + 23000 + 2000) / 30)),
    notes: 'Sample entry',
  },
  {
    date: '30 Oct 2025',
    kms: 150,
    income: 150 * 16,
    fuelCost: (150 / 15) * 100,
    fixedExpensesPerDay: Math.round((20000 + 23000 + 2000) / 30),
    profit: Math.round(150 * 16 - ((150 / 15) * 100 + (20000 + 23000 + 2000) / 30)),
    notes: 'Sample entry',
  },
];

// sampleMonthly used by the chart view (kms per day for a month sample)
export const sampleMonthly = Array.from({ length: 10 }).map((_, i) => ({
  day: `${i + 1}`,
  kms: [80, 100, 120, 140, 160, 90, 110, 130, 150, 100][i % 10],
}));
