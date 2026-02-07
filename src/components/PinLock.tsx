/**
 * Privacy PIN lock component with secure input handling
 */

import React, { useReducer, useCallback } from 'react';
import { Lock, Eye, EyeOff } from 'lucide-react';

interface PinLockProps {
  onUnlock: (pin: string) => boolean;
  isLocked: boolean;
  darkMode: boolean;
  isLockedOut?: boolean;
  remainingTime?: number;
}

export const PinLock: React.FC<PinLockProps> = React.memo(
  ({ onUnlock, isLocked, darkMode, isLockedOut = false, remainingTime = 0 }) => {
    type PinLockState = {
      pin: string;
      showPin: boolean;
      error: string;
    };

    type PinLockAction =
      | { type: 'set_pin'; value: string }
      | { type: 'toggle_show' }
      | { type: 'set_error'; value: string }
      | { type: 'reset_pin' };

    const pinLockReducer = (state: PinLockState, action: PinLockAction): PinLockState => {
      switch (action.type) {
        case 'set_pin':
          return { ...state, pin: action.value };
        case 'toggle_show':
          return { ...state, showPin: !state.showPin };
        case 'set_error':
          return { ...state, error: action.value };
        case 'reset_pin':
          return { ...state, pin: '', error: '' };
        default:
          return state;
      }
    };

    const [pinLockState, dispatch] = useReducer(pinLockReducer, {
      pin: '',
      showPin: false,
      error: '',
    });

    const handlePinChange = useCallback((e: React.ChangeEvent<HTMLInputElement>): void => {
      const value = e.target.value.replace(/\D/g, '').slice(0, 4);
      dispatch({ type: 'set_pin', value });
      dispatch({ type: 'set_error', value: '' });
    }, [dispatch]);

    const handleSubmit = useCallback(
      (e: React.FormEvent): void => {
        e.preventDefault();

        if (isLockedOut) {
          dispatch({
            type: 'set_error',
            value: `Too many attempts. Try again in ${Math.ceil(remainingTime / 1000)} seconds.`,
          });
          return;
        }

        if (pinLockState.pin.length !== 4) {
          dispatch({ type: 'set_error', value: 'PIN must be 4 digits' });
          return;
        }

        if (onUnlock(pinLockState.pin)) {
          dispatch({ type: 'reset_pin' });
        } else {
          dispatch({ type: 'set_error', value: 'Incorrect PIN' });
          dispatch({ type: 'set_pin', value: '' });
        }
      },
      [pinLockState.pin, onUnlock, isLockedOut, remainingTime, dispatch]
    );

    if (!isLocked) {
      return null;
    }

    return (
      <div
        className={`fixed inset-0 flex items-center justify-center p-4 z-50 ${
          darkMode ? 'bg-black/50' : 'bg-gray-900/50'
        }`}
        role="dialog"
        aria-modal="true"
        aria-label="PIN lock dialog"
      >
        <div
          className={`w-full max-w-sm rounded-lg shadow-2xl p-8 ${
            darkMode ? 'bg-gray-800 text-white' : 'bg-white text-gray-900'
          }`}
        >
          <div className="flex justify-center mb-6">
            <div className={`p-3 rounded-full ${darkMode ? 'bg-pink-600' : 'bg-pink-500'}`}>
              <Lock size={32} className="text-white" />
            </div>
          </div>

          <h2 className="text-2xl font-bold text-center mb-2">Enter PIN</h2>
          <p className={`text-center text-sm mb-6 ${darkMode ? 'text-gray-300' : 'text-gray-600'}`}>
            Your data is protected with a privacy PIN
          </p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="relative">
              <input
                type={pinLockState.showPin ? 'text' : 'password'}
                value={pinLockState.pin}
                onChange={handlePinChange}
                placeholder="••••"
                maxLength={4}
                disabled={isLockedOut}
                autoFocus
                aria-label="PIN input"
                className={`w-full px-4 py-2 text-center text-2xl font-bold tracking-widest rounded-lg border-2 transition ${
                  darkMode
                    ? 'bg-gray-700 border-gray-600 text-white placeholder-gray-500'
                    : 'bg-gray-100 border-gray-300 text-gray-900 placeholder-gray-400'
                } ${pinLockState.error && 'border-red-500'} ${isLockedOut && 'opacity-50 cursor-not-allowed'}`}
              />
              <button
                type="button"
                onClick={() => dispatch({ type: 'toggle_show' })}
                className="absolute right-3 top-1/2 -translate-y-1/2"
                aria-label={pinLockState.showPin ? 'Hide PIN' : 'Show PIN'}
              >
                {pinLockState.showPin ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>

            {pinLockState.error && (
              <p className="text-sm text-red-500 font-medium text-center" role="alert">
                {pinLockState.error}
              </p>
            )}

            <button
              type="submit"
              disabled={pinLockState.pin.length !== 4 || isLockedOut}
              className={`w-full py-2 rounded-lg font-bold transition ${
                pinLockState.pin.length === 4 && !isLockedOut
                  ? 'bg-pink-500 text-white hover:bg-pink-600'
                  : 'bg-gray-300 text-gray-500 cursor-not-allowed'
              }`}
            >
              Unlock
            </button>
          </form>
        </div>
      </div>
    );
  }
);

PinLock.displayName = 'PinLock';
