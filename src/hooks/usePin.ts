/**
 * Custom hook for PIN lock functionality
 */

import { useReducer, useCallback } from 'react';
import { useAppStore } from '@store/appStore';

const PIN_HASH_KEY = 'pt-pin-hash';
const MAX_ATTEMPTS = 3;
const LOCKOUT_DURATION = 5 * 60 * 1000;

export function usePin() {
  const { preferences, isPinLocked, setPinLocked, updatePreferences } = useAppStore();
  type PinState = {
    pinAttempts: number;
    lockoutTime: number | null;
  };

  type PinAction =
    | { type: 'set_attempts'; value: number }
    | { type: 'set_lockout_time'; value: number | null }
    | { type: 'reset_security' };

  const pinReducer = (state: PinState, action: PinAction): PinState => {
    switch (action.type) {
      case 'set_attempts':
        return { ...state, pinAttempts: action.value };
      case 'set_lockout_time':
        return { ...state, lockoutTime: action.value };
      case 'reset_security':
        return { pinAttempts: 0, lockoutTime: null };
      default:
        return state;
    }
  };

  const [pinState, dispatch] = useReducer(pinReducer, {
    pinAttempts: 0,
    lockoutTime: null,
  });

  const hashPin = useCallback((pin: string): string => {
    return Buffer.from(pin).toString('base64');
  }, []);

  const setPin = useCallback(
    (pin: string): boolean => {
      if (pin.length !== 4 || !/^\d+$/.test(pin)) {
        return false;
      }

      const hashedPin = hashPin(pin);
      localStorage.setItem(PIN_HASH_KEY, hashedPin);
      updatePreferences({ pinLockEnabled: true, privacyPin: pin });
      return true;
    },
    [hashPin, updatePreferences]
  );

  const verifyPin = useCallback(
    (pin: string): boolean => {
      if (pinState.lockoutTime && Date.now() < pinState.lockoutTime) {
        return false;
      }

      const storedHash = localStorage.getItem(PIN_HASH_KEY);
      if (!storedHash) return false;

      const inputHash = hashPin(pin);

      if (inputHash === storedHash) {
        dispatch({ type: 'reset_security' });
        setPinLocked(false);
        return true;
      }

      const newAttempts = pinState.pinAttempts + 1;
      dispatch({ type: 'set_attempts', value: newAttempts });

      if (newAttempts >= MAX_ATTEMPTS) {
        dispatch({ type: 'set_lockout_time', value: Date.now() + LOCKOUT_DURATION });
      }

      return false;
    },
    [hashPin, pinState.lockoutTime, pinState.pinAttempts, setPinLocked, dispatch]
  );

  const disablePin = useCallback((): void => {
    localStorage.removeItem(PIN_HASH_KEY);
    updatePreferences({ pinLockEnabled: false, privacyPin: undefined });
    setPinLocked(false);
  }, [updatePreferences, setPinLocked]);

  const getRemainingLockoutTime = useCallback((): number => {
    if (!pinState.lockoutTime) return 0;
    const remaining = Math.max(0, pinState.lockoutTime - Date.now());
    return remaining;
  }, [pinState.lockoutTime]);

  return {
    isPinLocked,
    pinLockEnabled: preferences.pinLockEnabled,
    setPin,
    verifyPin,
    disablePin,
    pinAttempts: pinState.pinAttempts,
    isLockedOut: pinState.lockoutTime !== null && Date.now() < pinState.lockoutTime,
    remainingLockoutTime: getRemainingLockoutTime(),
  };
}
