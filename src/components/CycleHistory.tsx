/**
 * Memoized cycle history list with delete functionality
 */

import React, { useCallback } from 'react';
import { CycleEntry } from '@/types';
import { Trash2, Plus } from 'lucide-react';
import { format } from 'date-fns';

interface CycleHistoryProps {
  entries: CycleEntry[];
  onDelete: (id: string) => void;
  onAddNew: () => void;
  darkMode: boolean;
}

export const CycleHistory: React.FC<CycleHistoryProps> = React.memo(
  ({ entries, onDelete, onAddNew, darkMode }) => {
    const handleDelete = useCallback(
      (id: string): void => {
        if (confirm('Are you sure you want to delete this entry?')) {
          onDelete(id);
        }
      },
      [onDelete]
    );

    const sortedEntries = React.useMemo(() => {
      return [...entries].sort(
        (a, b) => new Date(b.lastPeriodStart).getTime() - new Date(a.lastPeriodStart).getTime()
      );
    }, [entries]);

    return (
      <div
        className={`w-full max-w-2xl rounded-lg shadow-lg overflow-hidden ${
          darkMode ? 'bg-gray-800 text-white' : 'bg-white text-gray-900'
        }`}
        role="region"
        aria-label="Cycle history"
      >
        <div className={`flex items-center justify-between px-6 py-4 border-b ${
          darkMode ? 'border-gray-700' : 'border-gray-200'
        }`}>
          <h2 className="text-xl font-bold">Cycle History</h2>
          <button
            onClick={onAddNew}
            className={`flex items-center gap-2 px-3 py-2 rounded-lg font-medium transition ${
              darkMode
                ? 'bg-pink-600 hover:bg-pink-700 text-white'
                : 'bg-pink-500 hover:bg-pink-600 text-white'
            }`}
            aria-label="Add new cycle entry"
          >
            <Plus size={18} />
            Add Entry
          </button>
        </div>

        <div className={darkMode ? 'divide-gray-700' : 'divide-gray-200'}>
          {sortedEntries.length === 0 ? (
            <div className="p-6 text-center opacity-50">
              <p>No cycle entries yet. Add your first entry to get started!</p>
            </div>
          ) : (
            sortedEntries.map((entry) => (
              <div
                key={entry.id}
                className={`p-4 transition border-b ${
                  darkMode
                    ? 'hover:bg-gray-700 border-gray-700'
                    : 'hover:bg-gray-50 border-gray-200'
                }`}
              >
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <p className="font-semibold">
                      {format(new Date(entry.lastPeriodStart), 'MMMM d, yyyy')}
                    </p>
                    <div className="flex items-center gap-4 mt-1 text-sm opacity-75">
                      <span>Cycle: {entry.cycleLength} days</span>
                      {entry.notes && <span>Note: {entry.notes}</span>}
                    </div>
                  </div>
                  <button
                    onClick={() => handleDelete(entry.id)}
                    className={`p-2 text-red-500 rounded-lg transition ${
                      darkMode ? 'hover:bg-red-900' : 'hover:bg-red-50'
                    }`}
                    aria-label={`Delete entry from ${format(new Date(entry.lastPeriodStart), 'MMMM d, yyyy')}`}
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    );
  }
);

CycleHistory.displayName = 'CycleHistory';
