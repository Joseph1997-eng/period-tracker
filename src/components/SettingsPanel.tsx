/**
 * Settings panel with dark mode, PIN, and preferences
 */

import React, { useReducer, useCallback } from 'react';
import { Settings, Moon, Sun, Lock, X } from 'lucide-react';
import { UserPreferences } from '@/types';

interface SettingsPanelProps {
  isOpen: boolean;
  onClose: () => void;
  preferences: UserPreferences;
  onPreferencesChange: (preferences: Partial<UserPreferences>) => void;
  onSetPin: (pin: string) => boolean;
  onDisablePin: () => void;
  onToggleDarkMode: (enabled: boolean) => void;
  darkMode: boolean;
}

export const SettingsPanel: React.FC<SettingsPanelProps> = React.memo(
  ({
    isOpen,
    onClose,
    preferences,
    onPreferencesChange,
    onSetPin,
    onDisablePin,
    onToggleDarkMode,
    darkMode,
  }) => {
    type PinFormState = {
      newPin: string;
      pinError: string;
    };

    type PinFormAction =
      | { type: 'set_new_pin'; value: string }
      | { type: 'set_pin_error'; value: string }
      | { type: 'reset_form' };

    const pinFormReducer = (state: PinFormState, action: PinFormAction): PinFormState => {
      switch (action.type) {
        case 'set_new_pin':
          return { ...state, newPin: action.value };
        case 'set_pin_error':
          return { ...state, pinError: action.value };
        case 'reset_form':
          return { newPin: '', pinError: '' };
        default:
          return state;
      }
    };

    const [pinForm, dispatch] = useReducer(pinFormReducer, {
      newPin: '',
      pinError: '',
    });

    const handleSetPin = useCallback((): void => {
      if (pinForm.newPin.length !== 4 || !/^\d+$/.test(pinForm.newPin)) {
        dispatch({ type: 'set_pin_error', value: 'PIN must be 4 digits' });
        return;
      }

      if (onSetPin(pinForm.newPin)) {
        dispatch({ type: 'reset_form' });
      } else {
        dispatch({ type: 'set_pin_error', value: 'Failed to set PIN' });
      }
    }, [pinForm.newPin, onSetPin, dispatch]);

    if (!isOpen) {
      return null;
    }

    return (
      <div
        className={`fixed inset-0 z-40 flex justify-end ${
          darkMode ? 'bg-black/50' : 'bg-gray-900/50'
        }`}
        onClick={onClose}
        role="dialog"
        aria-modal="true"
        aria-label="Settings"
      >
        <div
          className={`w-full max-w-md h-full overflow-y-auto shadow-lg ${
            darkMode ? 'bg-gray-800 text-white' : 'bg-white text-gray-900'
          }`}
          onClick={(e) => e.stopPropagation()}
        >
          <div className={`flex items-center justify-between p-6 border-b ${
            darkMode ? 'border-gray-700' : 'border-gray-200'
          }`}>
            <h2 className="text-2xl font-bold flex items-center gap-2">
              <Settings size={28} />
              Settings
            </h2>
            <button
              onClick={onClose}
              aria-label="Close settings"
              className={`p-2 rounded-lg transition ${
                darkMode ? 'hover:bg-gray-700' : 'hover:bg-gray-100'
              }`}
            >
              <X size={24} />
            </button>
          </div>

          <div className="p-6 space-y-6">
            <div className={`border-b pb-6 ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
              <h3 className="font-semibold mb-4 flex items-center gap-2">
                {darkMode ? <Moon size={20} /> : <Sun size={20} />}
                Appearance
              </h3>
              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={darkMode}
                  onChange={(e) => onToggleDarkMode(e.target.checked)}
                  className="w-4 h-4 rounded"
                  aria-label="Dark mode"
                />
                <span>Dark Mode</span>
              </label>
            </div>

            <div className={`border-b pb-6 ${darkMode ? 'border-gray-700' : 'border-gray-200'}`}>
              <h3 className="font-semibold mb-4">Cycle Settings</h3>
              <div className="space-y-3">
                <label className="block">
                  <span className="text-sm font-medium mb-2 block">Default Cycle Length</span>
                  <input
                    type="number"
                    min="21"
                    max="35"
                    value={preferences.cycleLengthDefault}
                    onChange={(e) =>
                      onPreferencesChange({ cycleLengthDefault: parseInt(e.target.value) })
                    }
                    className={`w-full px-3 py-2 rounded-lg border transition ${
                      darkMode
                        ? 'bg-gray-700 border-gray-600 text-white'
                        : 'bg-gray-50 border-gray-300'
                    }`}
                  />
                </label>

                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={preferences.notificationsEnabled}
                    onChange={(e) =>
                      onPreferencesChange({ notificationsEnabled: e.target.checked })
                    }
                    className="w-4 h-4 rounded"
                  />
                  <span>Enable Notifications</span>
                </label>
              </div>
            </div>

            <div>
              <h3 className="font-semibold mb-4 flex items-center gap-2">
                <Lock size={20} />
                Privacy PIN
              </h3>

              {!preferences.pinLockEnabled ? (
                <div className="space-y-3">
                  <p className="text-sm opacity-75">
                    Set a 4-digit PIN to lock your data
                  </p>
                  <input
                    type="password"
                    placeholder="Enter 4-digit PIN"
                    maxLength={4}
                    value={pinForm.newPin}
                    onChange={(e) => {
                      dispatch({
                        type: 'set_new_pin',
                        value: e.target.value.replace(/\D/g, ''),
                      });
                      dispatch({ type: 'set_pin_error', value: '' });
                    }}
                    className={`w-full px-3 py-2 rounded-lg border transition ${
                      darkMode
                        ? 'bg-gray-700 border-gray-600 text-white'
                        : 'bg-gray-50 border-gray-300'
                    }`}
                  />
                  {pinForm.pinError && (
                    <p className="text-sm text-red-500" role="alert">
                      {pinForm.pinError}
                    </p>
                  )}
                  <button
                    onClick={handleSetPin}
                    disabled={pinForm.newPin.length !== 4}
                    className={`w-full py-2 rounded-lg font-medium transition ${
                      pinForm.newPin.length === 4
                        ? 'bg-pink-500 text-white hover:bg-pink-600'
                        : 'bg-gray-300 text-gray-500 cursor-not-allowed'
                    }`}
                  >
                    Set PIN
                  </button>
                </div>
              ) : (
                <div>
                  <p className="text-sm text-green-600 dark:text-green-400 font-medium mb-3">
                    ✓ Privacy PIN is enabled
                  </p>
                  <button
                    onClick={onDisablePin}
                    className="w-full py-2 rounded-lg font-medium transition text-red-600 hover:bg-red-50 dark:hover:bg-red-900 dark:text-red-400"
                  >
                    Disable PIN
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    );
  }
);

SettingsPanel.displayName = 'SettingsPanel';
