/**
 * Advanced cycle prediction algorithm with weighted average
 * Uses historical data to provide more accurate predictions
 */

import { PredictionResult, CycleHistory } from '@/types';
import {
  addDays,
  differenceInDays,
  subDays,
  startOfDay,
} from 'date-fns';

const OVULATION_DAY_BEFORE_PERIOD = 14;
const FERTILE_WINDOW_BEFORE_OVULATION = 5;
const FERTILE_WINDOW_AFTER_OVULATION = 1;
const PERIOD_DURATION = 5;
const MIN_CYCLE_LENGTH = 21;
const MAX_CYCLE_LENGTH = 35;

/**
 * Calculate weighted average cycle length from historical data
 * Recent cycles have higher weight than older cycles
 */
export function calculateWeightedAverageCycleLength(cycleLengths: number[]): number {
  if (cycleLengths.length === 0) {
    return 28;
  }

  let weightedSum = 0;
  let weightSum = 0;

  cycleLengths.forEach((length, index) => {
    const weight = (index + 1) / cycleLengths.length;
    const validLength = Math.max(MIN_CYCLE_LENGTH, Math.min(MAX_CYCLE_LENGTH, length));
    weightedSum += validLength * weight;
    weightSum += weight;
  });

  return Math.round(weightedSum / weightSum);
}

/**
 * Calculate variance and standard deviation of cycle lengths
 */
export function calculateCycleVariance(cycleLengths: number[]): {
  variance: number;
  stdDev: number;
  average: number;
} {
  if (cycleLengths.length === 0) {
    return { variance: 0, stdDev: 0, average: 28 };
  }

  const average = cycleLengths.reduce((a, b) => a + b, 0) / cycleLengths.length;
  const variance =
    cycleLengths.reduce((sum, length) => sum + Math.pow(length - average, 2), 0) /
    cycleLengths.length;
  const stdDev = Math.sqrt(variance);

  return { variance, stdDev, average };
}

/**
 * Calculate prediction confidence based on cycle stability
 */
export function calculateConfidence(cycleHistory: CycleHistory): number {
  const { stdDev, average } = calculateCycleVariance(cycleHistory.cycleLengths);
  const cv = stdDev / average;
  const confidence = Math.max(0.3, 1 - cv);
  return Math.min(1, Math.max(0.3, confidence));
}

/**
 * Calculate the next period prediction with confidence score
 */
export function calculatePrediction(
  lastPeriodStart: Date,
  cycleHistory: CycleHistory
): PredictionResult {
  const validStart = startOfDay(new Date(lastPeriodStart));

  const effectiveCycleLength =
    cycleHistory.cycleLengths.length > 0
      ? calculateWeightedAverageCycleLength(cycleHistory.cycleLengths)
      : 28;

  const nextPeriodStart = addDays(validStart, effectiveCycleLength);
  const nextPeriodEnd = addDays(nextPeriodStart, PERIOD_DURATION);

  const ovulationDate = subDays(nextPeriodStart, OVULATION_DAY_BEFORE_PERIOD);

  const fertileWindowStart = subDays(ovulationDate, FERTILE_WINDOW_BEFORE_OVULATION);
  const fertileWindowEnd = addDays(ovulationDate, FERTILE_WINDOW_AFTER_OVULATION);

  const confidence = calculateConfidence(cycleHistory);

  return {
    nextPeriodStart,
    nextPeriodEnd,
    ovulationDate,
    fertileWindowStart,
    fertileWindowEnd,
    confidence,
  };
}

/**
 * Get the most common cycle length from history
 */
export function getMostCommonCycleLength(cycleLengths: number[]): number {
  if (cycleLengths.length === 0) return 28;

  const frequency: Record<number, number> = {};
  let maxFreq = 0;
  let mostCommon = 28;

  cycleLengths.forEach((length) => {
    frequency[length] = (frequency[length] || 0) + 1;
    if (frequency[length] > maxFreq) {
      maxFreq = frequency[length];
      mostCommon = length;
    }
  });

  return mostCommon;
}

/**
 * Calculate historical prediction accuracy
 */
export function calculateHistoricalAccuracy(cycleHistory: CycleHistory): number {
  if (cycleHistory.entries.length < 2) {
    return 0;
  }

  const entries = cycleHistory.entries.sort(
    (a, b) => new Date(a.lastPeriodStart).getTime() - new Date(b.lastPeriodStart).getTime()
  );

  let accurateCount = 0;

  for (let i = 0; i < entries.length - 1; i++) {
    const currentEntry = entries[i];
    const nextEntry = entries[i + 1];

    const predictedNext = addDays(
      new Date(currentEntry.lastPeriodStart),
      currentEntry.cycleLength
    );

    const actualNext = new Date(nextEntry.lastPeriodStart);
    const daysDiff = Math.abs(differenceInDays(predictedNext, actualNext));

    if (daysDiff <= 2) {
      accurateCount++;
    }
  }

  return (accurateCount / (entries.length - 1)) * 100;
}

/**
 * Validate cycle entry data
 */
export function validateCycleEntry(_lastPeriodStart: Date, cycleLength: number): boolean {
  return cycleLength >= MIN_CYCLE_LENGTH && cycleLength <= MAX_CYCLE_LENGTH;
}

/**
 * Get fertility status for a given date
 */
export function getFertilityStatus(
  date: Date,
  prediction: PredictionResult
): 'fertile' | 'ovulation' | 'menstrual' | 'other' {
  const checkDate = startOfDay(date);

  if (
    checkDate >= startOfDay(prediction.nextPeriodStart) &&
    checkDate <= startOfDay(prediction.nextPeriodEnd)
  ) {
    return 'menstrual';
  }

  if (checkDate.getTime() === startOfDay(prediction.ovulationDate).getTime()) {
    return 'ovulation';
  }

  if (
    checkDate >= startOfDay(prediction.fertileWindowStart) &&
    checkDate <= startOfDay(prediction.fertileWindowEnd)
  ) {
    return 'fertile';
  }

  return 'other';
}
