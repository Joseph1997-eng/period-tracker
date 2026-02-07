/**
 * Memoized prediction display card with accessibility features
 */

import React, { useMemo } from 'react';
import { PredictionResult } from '@/types';
import { format, differenceInDays } from 'date-fns';
import { Calendar, Heart, TrendingUp } from 'lucide-react';

interface PredictionCardProps {
  prediction: PredictionResult;
  confidenceLevel: string;
  darkMode: boolean;
}

export const PredictionCard: React.FC<PredictionCardProps> = React.memo(
  ({ prediction, confidenceLevel, darkMode }) => {
    const daysUntilPeriod = useMemo(() => {
      return Math.ceil(differenceInDays(prediction.nextPeriodStart, new Date()));
    }, [prediction.nextPeriodStart]);

    const daysUntilOvulation = useMemo(() => {
      return Math.ceil(differenceInDays(prediction.ovulationDate, new Date()));
    }, [prediction.ovulationDate]);

    return (
      <div
        className={`w-full max-w-2xl rounded-lg shadow-lg overflow-hidden ${
          darkMode ? 'bg-gray-800 text-white' : 'bg-white text-gray-900'
        }`}
        role="region"
        aria-label="Period prediction results"
      >
        <div className={`px-6 py-4 ${darkMode ? 'bg-pink-600' : 'bg-pink-500'}`}>
          <h2 className="text-xl font-bold flex items-center gap-2">
            <Calendar size={24} />
            Your Cycle Predictions
          </h2>
        </div>

        <div className="p-6 space-y-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium opacity-75">Prediction Confidence</p>
              <p className="text-lg font-semibold">{confidenceLevel}</p>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-12 h-12 rounded-full bg-gradient-to-r from-pink-500 to-rose-500 flex items-center justify-center">
                <span className="text-white font-bold">{Math.round(prediction.confidence * 100)}%</span>
              </div>
            </div>
          </div>

          <div
            className={`p-4 rounded-lg ${
              darkMode ? 'bg-red-900 bg-opacity-30' : 'bg-red-50'
            }`}
          >
            <p className="text-sm font-medium opacity-75 flex items-center gap-2 mb-2">
              <span className="w-3 h-3 rounded-full bg-red-600"></span>
              Next Period
            </p>
            <p className="text-2xl font-bold">
              {format(prediction.nextPeriodStart, 'MMMM d, yyyy')}
            </p>
            <p className="text-sm opacity-75 mt-1">
              {daysUntilPeriod > 0 ? `In ${daysUntilPeriod} days` : 'Today'}
            </p>
            <p className="text-xs opacity-50 mt-2">
              Expected duration: {format(prediction.nextPeriodEnd, 'MMM d')}
            </p>
          </div>

          <div
            className={`p-4 rounded-lg ${
              darkMode ? 'bg-amber-900 bg-opacity-30' : 'bg-amber-50'
            }`}
          >
            <p className="text-sm font-medium opacity-75 flex items-center gap-2 mb-2">
              <Heart size={16} className="text-amber-600" />
              Ovulation Date
            </p>
            <p className="text-2xl font-bold">
              {format(prediction.ovulationDate, 'MMMM d, yyyy')}
            </p>
            <p className="text-sm opacity-75 mt-1">
              {daysUntilOvulation > 0 ? `In ${daysUntilOvulation} days` : 'Today'}
            </p>
          </div>

          <div
            className={`p-4 rounded-lg ${
              darkMode ? 'bg-green-900 bg-opacity-30' : 'bg-green-50'
            }`}
          >
            <p className="text-sm font-medium opacity-75 flex items-center gap-2 mb-2">
              <TrendingUp size={16} className="text-green-600" />
              Fertile Window
            </p>
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm opacity-75">From</p>
                <p className="font-semibold">{format(prediction.fertileWindowStart, 'MMM d')}</p>
              </div>
              <div className="text-center">
                <p className="text-xs opacity-50">to</p>
              </div>
              <div>
                <p className="text-sm opacity-75">To</p>
                <p className="font-semibold">{format(prediction.fertileWindowEnd, 'MMM d')}</p>
              </div>
            </div>
          </div>

          <div
            className={`p-3 rounded text-xs ${
              darkMode ? 'bg-gray-700 text-gray-200' : 'bg-gray-100 text-gray-700'
            }`}
          >
            <p className="font-semibold mb-1">Note:</p>
            <p>
              These predictions are estimates based on your cycle history. For medical concerns,
              please consult with a healthcare provider.
            </p>
          </div>
        </div>
      </div>
    );
  }
);

PredictionCard.displayName = 'PredictionCard';
