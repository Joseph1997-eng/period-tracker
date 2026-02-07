/**
 * Main App Component with full feature integration
 */

import React, { useReducer, useCallback, useEffect } from 'react';
import { useAppStore } from '@store/appStore';
import { usePin } from '@hooks/usePin';
import { usePrediction, useConfidenceLevel } from '@hooks/usePrediction';
import { PinLock } from '@components/PinLock';
import { SettingsPanel } from '@components/SettingsPanel';
import { DatePicker } from '@components/DatePicker';
import { PredictionCard } from '@components/PredictionCard';
import { AnalyticsDashboard } from '@components/AnalyticsDashboard';
import { CycleHistory } from '@components/CycleHistory';
import { Settings } from 'lucide-react';

export const App: React.FC = () => {
  type UiState = {
    selectedDate: Date | null;
    settingsOpen: boolean;
  };

  type UiAction =
    | { type: 'set_selected_date'; value: Date | null }
    | { type: 'set_settings_open'; value: boolean };

  const uiReducer = (state: UiState, action: UiAction): UiState => {
    switch (action.type) {
      case 'set_selected_date':
        return { ...state, selectedDate: action.value };
      case 'set_settings_open':
        return { ...state, settingsOpen: action.value };
      default:
        return state;
    }
  };

  const [uiState, dispatch] = useReducer(uiReducer, {
    selectedDate: null,
    settingsOpen: false,
  });

  const {
    cycleHistory,
    preferences,
    darkMode,
    addCycleEntry,
    updatePreferences,
    setDarkMode,
    getAnalytics,
    deleteCycleEntry,
  } = useAppStore();

  const { isPinLocked, pinLockEnabled, setPin, verifyPin, disablePin, isLockedOut, remainingLockoutTime } =
    usePin();
  const { prediction } = usePrediction(uiState.selectedDate, cycleHistory);
  const confidenceLevel = useConfidenceLevel(cycleHistory);
  const analytics = getAnalytics();

  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
  }, [darkMode]);

  const handleAddCycleEntry = useCallback((): void => {
    if (!uiState.selectedDate) {
      alert('Please select a date first');
      return;
    }

    let cycleLength = preferences.cycleLengthDefault;
    if (cycleHistory.entries.length > 0) {
      const lastEntry = cycleHistory.entries[cycleHistory.entries.length - 1];
      const lastDate = new Date(lastEntry.lastPeriodStart);
      const daysDiff = Math.round(
        (uiState.selectedDate.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24)
      );
      if (daysDiff >= 21 && daysDiff <= 35) {
        cycleLength = daysDiff;
      }
    }

    const newEntry = {
      id: Math.random().toString(36).substring(2, 9),
      lastPeriodStart: uiState.selectedDate,
      cycleLength,
      createdAt: new Date(),
    };

    addCycleEntry(newEntry);
    dispatch({ type: 'set_selected_date', value: null });
  }, [uiState.selectedDate, cycleHistory.entries, preferences.cycleLengthDefault, addCycleEntry, dispatch]);

  const handlePinUnlock = useCallback(
    (pin: string): boolean => {
      return verifyPin(pin);
    },
    [verifyPin]
  );

  return (
    <div
      className={`min-h-screen transition-colors ${
        darkMode ? 'bg-gray-900' : 'bg-gray-50'
      }`}
    >
      <header
        className={`border-b sticky top-0 z-30 ${
          darkMode ? 'border-gray-700 bg-gray-800' : 'border-gray-200 bg-white'
        }`}
      >
        <div className="max-w-6xl mx-auto px-4 py-4 flex items-center justify-between">
          <h1 className={`text-3xl font-bold ${darkMode ? 'text-white' : 'text-gray-900'}`}>
            Period Tracker
          </h1>
          <button
            onClick={() => dispatch({ type: 'set_settings_open', value: true })}
            className={`p-2 rounded-lg transition ${
              darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'
            }`}
            aria-label="Open settings"
          >
            <Settings size={24} />
          </button>
        </div>
      </header>

      {pinLockEnabled && (
        <PinLock
          isLocked={isPinLocked}
          onUnlock={handlePinUnlock}
          darkMode={darkMode}
          isLockedOut={isLockedOut}
          remainingTime={remainingLockoutTime}
        />
      )}

      <SettingsPanel
        isOpen={uiState.settingsOpen}
        onClose={() => dispatch({ type: 'set_settings_open', value: false })}
        preferences={preferences}
        onPreferencesChange={updatePreferences}
        onSetPin={setPin}
        onDisablePin={disablePin}
        onToggleDarkMode={setDarkMode}
        darkMode={darkMode}
      />

      {!isPinLocked && (
        <main className="max-w-6xl mx-auto px-4 py-8">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
            <div className="lg:col-span-1">
              <DatePicker
                selectedDate={uiState.selectedDate}
                onDateSelect={(date) => dispatch({ type: 'set_selected_date', value: date })}
                label="Last Period Start Date"
              />

              <button
                onClick={handleAddCycleEntry}
                disabled={!uiState.selectedDate}
                className={`w-full mt-4 py-3 rounded-lg font-bold transition ${
                  uiState.selectedDate
                    ? 'bg-pink-500 text-white hover:bg-pink-600'
                    : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                }`}
              >
                Add Cycle Entry
              </button>
            </div>

            <div className="lg:col-span-2 space-y-6">
              {prediction && (
                <PredictionCard
                  prediction={prediction}
                  confidenceLevel={confidenceLevel}
                  darkMode={darkMode}
                />
              )}

              {cycleHistory.entries.length > 0 && (
                <AnalyticsDashboard analytics={analytics} darkMode={darkMode} />
              )}

              <CycleHistory
                entries={cycleHistory.entries}
                onDelete={deleteCycleEntry}
                onAddNew={() => {
                  document.querySelector<HTMLInputElement>('input[type="date"]')?.focus();
                }}
                darkMode={darkMode}
              />
            </div>
          </div>
        </main>
      )}
    </div>
  );
};

export default App;
