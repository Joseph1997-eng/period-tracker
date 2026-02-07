/**
 * Custom hook for prediction calculations and memoization
 */

import { useMemo } from 'react';
import { PredictionResult, CycleHistory } from '@/types';
import { calculatePrediction, calculateConfidence } from '@utils/prediction';

export function usePrediction(
  lastPeriodStart: Date | null,
  cycleHistory: CycleHistory
): { prediction: PredictionResult | null; confidence: number } {
  return useMemo(() => {
    if (!lastPeriodStart) {
      return { prediction: null, confidence: 0 };
    }

    const prediction = calculatePrediction(lastPeriodStart, cycleHistory);
    const confidence = calculateConfidence(cycleHistory);

    return { prediction, confidence };
  }, [lastPeriodStart, cycleHistory]);
}

export function useConfidenceLevel(cycleHistory: CycleHistory): string {
  return useMemo(() => {
    const confidence = calculateConfidence(cycleHistory);

    if (confidence >= 0.8) return 'Very High';
    if (confidence >= 0.6) return 'High';
    if (confidence >= 0.4) return 'Medium';
    return 'Low';
  }, [cycleHistory]);
}
