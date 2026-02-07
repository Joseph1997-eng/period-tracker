/**
 * Smart analytics dashboard with performance optimizations
 */

import React, { useMemo } from 'react';
import { AnalyticsData } from '@/types';
import { BarChart3, LineChart as LineChartIcon, Activity } from 'lucide-react';

interface AnalyticsDashboardProps {
  analytics: AnalyticsData;
  darkMode: boolean;
}

export const AnalyticsDashboard: React.FC<AnalyticsDashboardProps> = React.memo(
  ({ analytics, darkMode }) => {
    const metrics = useMemo(
      () => [
        {
          label: 'Average Cycle',
          value: `${analytics.averageCycleLength} days`,
          icon: LineChartIcon,
          color: 'pink',
        },
        {
          label: 'Predictability',
          value: `${analytics.predictablityScore.toFixed(0)}%`,
          icon: BarChart3,
          color: 'purple',
        },
        {
          label: 'Accuracy',
          value: `${analytics.historicalAccuracy.toFixed(0)}%`,
          icon: Activity,
          color: 'green',
        },
        {
          label: 'Variance',
          value: `±${analytics.ovulationVariance.toFixed(1)} days`,
          icon: LineChartIcon,
          color: 'blue',
        },
      ],
      [analytics]
    );

    const colorClasses: Record<string, string> = {
      pink: 'bg-pink-100 text-pink-700 dark:bg-pink-900 dark:text-pink-200',
      purple: 'bg-purple-100 text-purple-700 dark:bg-purple-900 dark:text-purple-200',
      green: 'bg-green-100 text-green-700 dark:bg-green-900 dark:text-green-200',
      blue: 'bg-blue-100 text-blue-700 dark:bg-blue-900 dark:text-blue-200',
    };

    return (
      <div
        className={`w-full rounded-lg shadow-lg p-6 ${
          darkMode ? 'bg-gray-800 text-white' : 'bg-white text-gray-900'
        }`}
        role="region"
        aria-label="Cycle Analytics Dashboard"
      >
        <h2 className="text-2xl font-bold mb-6 flex items-center gap-2">
          <BarChart3 size={28} />
          Your Analytics
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
          {metrics.map((metric) => {
            const Icon = metric.icon;
            const colorClass = colorClasses[metric.color];

            return (
              <div
                key={metric.label}
                className={`p-4 rounded-lg flex items-start gap-3 ${
                  darkMode ? 'bg-gray-700' : 'bg-gray-50'
                }`}
              >
                <div className={`p-3 rounded-lg ${colorClass}`}>
                  <Icon size={20} />
                </div>
                <div className="flex-1">
                  <p className={`text-sm font-medium ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
                    {metric.label}
                  </p>
                  <p className="text-xl font-bold mt-1">{metric.value}</p>
                </div>
              </div>
            );
          })}
        </div>

        <div
          className={`p-4 rounded-lg ${
            darkMode ? 'bg-blue-900 bg-opacity-30' : 'bg-blue-50'
          }`}
        >
          <h3 className="font-semibold mb-2 flex items-center gap-2">
            <Activity size={18} />
            Insights
          </h3>
          <ul className="space-y-1 text-sm">
            <li>
              • Your cycle length is{' '}
              <strong>
                {analytics.averageCycleLength >= 28 && analytics.averageCycleLength <= 32
                  ? 'consistent and normal'
                  : 'variable'}
              </strong>
            </li>
            <li>
              • Prediction confidence is{' '}
              <strong>
                {analytics.predictablityScore >= 80
                  ? 'very high'
                  : analytics.predictablityScore >= 60
                    ? 'good'
                    : 'moderate'}
              </strong>
            </li>
            <li>
              • Historical accuracy: {analytics.historicalAccuracy.toFixed(0)}% of predictions
              were within 2 days
            </li>
          </ul>
        </div>
      </div>
    );
  }
);

AnalyticsDashboard.displayName = 'AnalyticsDashboard';
