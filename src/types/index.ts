/**
 * Core types and interfaces for the Period Tracker application
 */

export interface CycleEntry {
  id: string;
  lastPeriodStart: Date;
  cycleLength: number;
  notes?: string;
  createdAt: Date;
}

export interface PredictionResult {
  nextPeriodStart: Date;
  nextPeriodEnd: Date;
  ovulationDate: Date;
  fertileWindowStart: Date;
  fertileWindowEnd: Date;
  confidence: number;
}

export interface CycleHistory {
  entries: CycleEntry[];
  averageCycleLength: number;
  cycleLengths: number[];
}

export interface UserPreferences {
  darkMode: boolean;
  cycleLengthDefault: number;
  cycleStartDay: 'sunday' | 'monday';
  notificationsEnabled: boolean;
  privacyPin?: string;
  pinLockEnabled: boolean;
}

export interface AnalyticsData {
  averageCycleLength: number;
  cycleLengthVariance: number;
  mostCommonLength: number;
  predictablityScore: number;
  periodDuration: number;
  ovulationVariance: number;
  historicalAccuracy: number;
}

export interface AppState {
  cycleHistory: CycleHistory;
  currentPrediction: PredictionResult | null;
  preferences: UserPreferences;
  isPinLocked: boolean;
  darkMode: boolean;
  addCycleEntry: (entry: CycleEntry) => void;
  updatePreferences: (preferences: Partial<UserPreferences>) => void;
  setPinLocked: (locked: boolean) => void;
  setDarkMode: (enabled: boolean) => void;
  generatePrediction: (lastPeriodStart: Date, cycleLength?: number) => void;
  getAnalytics: () => AnalyticsData;
  deleteCycleEntry: (id: string) => void;
}
