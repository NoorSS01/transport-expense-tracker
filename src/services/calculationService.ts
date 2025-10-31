import { defaultVehicleSettings } from '../utils/constants';

export type VehicleSettings = typeof defaultVehicleSettings;

export function calculateDailyFromInputs(kms: number, settings: VehicleSettings = defaultVehicleSettings) {
  const dailyIncome = kms * settings.ratePerKm;
  const fuelCost = (kms / settings.mileage) * settings.fuelPrice;
  const fixedExpensesPerDay = (settings.emi + settings.driverSalary + settings.maintenance) / 30;
  const profit = dailyIncome - (fuelCost + fixedExpensesPerDay);

  return {
    kms,
    income: Math.round(dailyIncome),
    fuelCost: Math.round(fuelCost),
    fixedExpensesPerDay: Math.round(fixedExpensesPerDay),
    profit: Math.round(profit),
  };
}
