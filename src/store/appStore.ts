/**
 * Central state management using Zustand
 * Handles all app state, persistence, and actions
 */

import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import {
  AppState,
  CycleEntry,
  UserPreferences,
  AnalyticsData,
} from '@/types';
import {
  calculatePrediction,
  calculateCycleVariance,
  getMostCommonCycleLength,
  calculateHistoricalAccuracy,
  calculateConfidence,
} from '@utils/prediction';

const DEFAULT_PREFERENCES: UserPreferences = {
  darkMode: false,
  cycleLengthDefault: 28,
  cycleStartDay: 'sunday',
  notificationsEnabled: true,
  pinLockEnabled: false,
};

const STORAGE_KEY = 'period-tracker-store';

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      cycleHistory: {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [],
      },
      currentPrediction: null,
      preferences: DEFAULT_PREFERENCES,
      isPinLocked: false,
      darkMode: false,

      addCycleEntry: (entry: CycleEntry) => {
        set((state) => {
          const newEntries = [...state.cycleHistory.entries, entry];
          const newCycleLengths = calculateCycleLengths(newEntries);

          return {
            cycleHistory: {
              entries: newEntries,
              averageCycleLength:
                newCycleLengths.length > 0
                  ? Math.round(newCycleLengths.reduce((a, b) => a + b) / newCycleLengths.length)
                  : 28,
              cycleLengths: newCycleLengths,
            },
          };
        });

        get().generatePrediction(entry.lastPeriodStart, entry.cycleLength);
      },

      updatePreferences: (newPreferences: Partial<UserPreferences>) => {
        set((state) => ({
          preferences: { ...state.preferences, ...newPreferences },
        }));
      },

      setPinLocked: (locked: boolean) => {
        set({ isPinLocked: locked });
      },

      setDarkMode: (enabled: boolean) => {
        set({ darkMode: enabled });
        get().updatePreferences({ darkMode: enabled });
      },

      generatePrediction: (lastPeriodStart: Date) => {
        set((state) => {
          const prediction = calculatePrediction(lastPeriodStart, state.cycleHistory);
          return { currentPrediction: prediction };
        });
      },

      getAnalytics: (): AnalyticsData => {
        const state = get();
        const { variance, average, stdDev } = calculateCycleVariance(
          state.cycleHistory.cycleLengths
        );
        const mostCommon = getMostCommonCycleLength(state.cycleHistory.cycleLengths);
        const predictability = calculateConfidence(state.cycleHistory);
        const accuracy = calculateHistoricalAccuracy(state.cycleHistory);

        return {
          averageCycleLength: average,
          cycleLengthVariance: variance,
          mostCommonLength: mostCommon,
          predictablityScore: predictability * 100,
          periodDuration: 5,
          ovulationVariance: stdDev,
          historicalAccuracy: accuracy,
        };
      },

      deleteCycleEntry: (id: string) => {
        set((state) => {
          const newEntries = state.cycleHistory.entries.filter((entry) => entry.id !== id);
          const newCycleLengths = calculateCycleLengths(newEntries);

          return {
            cycleHistory: {
              entries: newEntries,
              averageCycleLength:
                newCycleLengths.length > 0
                  ? Math.round(newCycleLengths.reduce((a, b) => a + b) / newCycleLengths.length)
                  : 28,
              cycleLengths: newCycleLengths,
            },
          };
        });
      },
    }),
    {
      name: STORAGE_KEY,
      version: 1,
      serialize: (state) => JSON.stringify(state),
      deserialize: (stored) => {
        const state = JSON.parse(stored);
        if (state.state.cycleHistory.entries) {
          state.state.cycleHistory.entries = state.state.cycleHistory.entries.map(
            (entry: CycleEntry) => ({
              ...entry,
              lastPeriodStart: new Date(entry.lastPeriodStart),
              createdAt: new Date(entry.createdAt),
            })
          );
        }
        if (state.state.currentPrediction) {
          state.state.currentPrediction = {
            ...state.state.currentPrediction,
            nextPeriodStart: new Date(state.state.currentPrediction.nextPeriodStart),
            nextPeriodEnd: new Date(state.state.currentPrediction.nextPeriodEnd),
            ovulationDate: new Date(state.state.currentPrediction.ovulationDate),
            fertileWindowStart: new Date(state.state.currentPrediction.fertileWindowStart),
            fertileWindowEnd: new Date(state.state.currentPrediction.fertileWindowEnd),
          };
        }
        return state.state;
      },
    }
  )
);

function calculateCycleLengths(entries: CycleEntry[]): number[] {
  if (entries.length < 2) return [];

  const sorted = [...entries].sort(
    (a, b) => new Date(a.lastPeriodStart).getTime() - new Date(b.lastPeriodStart).getTime()
  );

  const lengths: number[] = [];
  for (let i = 0; i < sorted.length - 1; i++) {
    const current = new Date(sorted[i].lastPeriodStart);
    const next = new Date(sorted[i + 1].lastPeriodStart);
    const days = Math.round((next.getTime() - current.getTime()) / (1000 * 60 * 60 * 24));
    if (days >= 21 && days <= 35) {
      lengths.push(days);
    }
  }

  return lengths;
}
