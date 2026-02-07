/**
 * Unit tests for the prediction algorithm
 */

import { describe, it, expect } from 'vitest';
import {
  calculateWeightedAverageCycleLength,
  calculateCycleVariance,
  calculateConfidence,
  calculatePrediction,
  getMostCommonCycleLength,
  calculateHistoricalAccuracy,
  getFertilityStatus,
} from '@utils/prediction';
import { CycleHistory } from '@/types';
import { addDays, subDays } from 'date-fns';

describe('Prediction Algorithm', () => {
  describe('calculateWeightedAverageCycleLength', () => {
    it('should return default cycle length for empty input', () => {
      const result = calculateWeightedAverageCycleLength([]);
      expect(result).toBe(28);
    });

    it('should return a single cycle length as-is', () => {
      const result = calculateWeightedAverageCycleLength([28]);
      expect(result).toBe(28);
    });

    it('should weight recent cycles higher', () => {
      const cycles = [25, 30, 28];
      const result = calculateWeightedAverageCycleLength(cycles);
      expect(result).toBeGreaterThan(27);
    });

    it('should clamp values to min/max range', () => {
      const cycles = [15, 40, 28];
      const result = calculateWeightedAverageCycleLength(cycles);
      expect(result).toBeGreaterThanOrEqual(21);
      expect(result).toBeLessThanOrEqual(35);
    });
  });

  describe('calculateCycleVariance', () => {
    it('should return defaults for empty input', () => {
      const result = calculateCycleVariance([]);
      expect(result.average).toBe(28);
      expect(result.variance).toBe(0);
      expect(result.stdDev).toBe(0);
    });

    it('should calculate variance correctly', () => {
      const cycles = [26, 28, 30];
      const result = calculateCycleVariance(cycles);
      expect(result.average).toBe(28);
    });

    it('should identify stable cycles', () => {
      const stableCycles = [28, 28, 28];
      const result = calculateCycleVariance(stableCycles);
      expect(result.variance).toBe(0);
      expect(result.stdDev).toBe(0);
    });

    it('should identify variable cycles', () => {
      const variableCycles = [21, 28, 35];
      const result = calculateCycleVariance(variableCycles);
      expect(result.variance).toBeGreaterThan(0);
      expect(result.stdDev).toBeGreaterThan(0);
    });
  });

  describe('calculateConfidence', () => {
    it('should return minimum confidence for few entries', () => {
      const history: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [],
      };
      const confidence = calculateConfidence(history);
      expect(confidence).toBeGreaterThanOrEqual(0.3);
      expect(confidence).toBeLessThanOrEqual(1);
    });

    it('should have higher confidence for stable cycles', () => {
      const stableHistory: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [28, 28, 28, 28, 28],
      };
      const variableHistory: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [21, 24, 28, 32, 35],
      };
      const stableConfidence = calculateConfidence(stableHistory);
      const variableConfidence = calculateConfidence(variableHistory);
      expect(stableConfidence).toBeGreaterThan(variableConfidence);
    });
  });

  describe('calculatePrediction', () => {
    it('should calculate correct next period date', () => {
      const today = new Date(2024, 0, 1);
      const history: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [28],
      };
      const prediction = calculatePrediction(today, history);
      expect(prediction.nextPeriodStart).toEqual(addDays(today, 28));
    });

    it('should calculate ovulation 14 days before next period', () => {
      const today = new Date(2024, 0, 1);
      const history: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [28],
      };
      const prediction = calculatePrediction(today, history);
      const expectedOvulation = subDays(addDays(today, 28), 14);
      expect(prediction.ovulationDate).toEqual(expectedOvulation);
    });

    it('should calculate fertile window correctly', () => {
      const today = new Date(2024, 0, 1);
      const history: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [28],
      };
      const prediction = calculatePrediction(today, history);
      const ovulation = prediction.ovulationDate;
      expect(prediction.fertileWindowStart).toEqual(subDays(ovulation, 5));
      expect(prediction.fertileWindowEnd).toEqual(addDays(ovulation, 1));
    });

    it('should include confidence score', () => {
      const today = new Date(2024, 0, 1);
      const history: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [28, 28, 28],
      };
      const prediction = calculatePrediction(today, history);
      expect(prediction.confidence).toBeGreaterThan(0);
      expect(prediction.confidence).toBeLessThanOrEqual(1);
    });
  });

  describe('getMostCommonCycleLength', () => {
    it('should return default for empty array', () => {
      const result = getMostCommonCycleLength([]);
      expect(result).toBe(28);
    });

    it('should identify most common length', () => {
      const cycles = [28, 28, 28, 30, 26];
      const result = getMostCommonCycleLength(cycles);
      expect(result).toBe(28);
    });
  });

  describe('calculateHistoricalAccuracy', () => {
    it('should return 0 for insufficient entries', () => {
      const history: CycleHistory = {
        entries: [],
        averageCycleLength: 28,
        cycleLengths: [],
      };
      const accuracy = calculateHistoricalAccuracy(history);
      expect(accuracy).toBe(0);
    });

    it('should calculate accuracy correctly', () => {
      const date1 = new Date(2024, 0, 1);
      const date2 = addDays(date1, 28);
      const history: CycleHistory = {
        entries: [
          {
            id: '1',
            lastPeriodStart: date1,
            cycleLength: 28,
            createdAt: new Date(),
          },
          {
            id: '2',
            lastPeriodStart: date2,
            cycleLength: 28,
            createdAt: new Date(),
          },
        ],
        averageCycleLength: 28,
        cycleLengths: [28],
      };
      const accuracy = calculateHistoricalAccuracy(history);
      expect(accuracy).toBeGreaterThan(50);
    });
  });

  describe('getFertilityStatus', () => {
    it('should identify menstrual days', () => {
      const today = new Date(2024, 0, 15);
      const prediction = {
        nextPeriodStart: today,
        nextPeriodEnd: addDays(today, 5),
        ovulationDate: addDays(today, 9),
        fertileWindowStart: addDays(today, 4),
        fertileWindowEnd: addDays(today, 10),
        confidence: 0.9,
      };
      const status = getFertilityStatus(today, prediction);
      expect(status).toBe('menstrual');
    });

    it('should identify ovulation day', () => {
      const periodStart = new Date(2024, 0, 1);
      const prediction = {
        nextPeriodStart: addDays(periodStart, 28),
        nextPeriodEnd: addDays(periodStart, 33),
        ovulationDate: addDays(periodStart, 14),
        fertileWindowStart: addDays(periodStart, 9),
        fertileWindowEnd: addDays(periodStart, 15),
        confidence: 0.9,
      };
      const status = getFertilityStatus(prediction.ovulationDate, prediction);
      expect(status).toBe('ovulation');
    });

    it('should identify fertile window days', () => {
      const periodStart = new Date(2024, 0, 1);
      const fertileDay = addDays(periodStart, 11);
      const prediction = {
        nextPeriodStart: addDays(periodStart, 28),
        nextPeriodEnd: addDays(periodStart, 33),
        ovulationDate: addDays(periodStart, 14),
        fertileWindowStart: addDays(periodStart, 9),
        fertileWindowEnd: addDays(periodStart, 15),
        confidence: 0.9,
      };
      const status = getFertilityStatus(fertileDay, prediction);
      expect(status).toBe('fertile');
    });

    it('should identify other days', () => {
      const periodStart = new Date(2024, 0, 1);
      const otherDay = addDays(periodStart, 20);
      const prediction = {
        nextPeriodStart: addDays(periodStart, 28),
        nextPeriodEnd: addDays(periodStart, 33),
        ovulationDate: addDays(periodStart, 14),
        fertileWindowStart: addDays(periodStart, 9),
        fertileWindowEnd: addDays(periodStart, 15),
        confidence: 0.9,
      };
      const status = getFertilityStatus(otherDay, prediction);
      expect(status).toBe('other');
    });
  });
});
