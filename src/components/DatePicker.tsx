/**
 * Accessible DatePicker component with keyboard navigation
 */

import React, { useState, useCallback, useMemo } from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import {
  format,
  startOfMonth,
  endOfMonth,
  eachDayOfInterval,
  isSameMonth,
  isSameDay,
  addMonths,
  subMonths,
} from 'date-fns';

interface DatePickerProps {
  selectedDate: Date | null;
  onDateSelect: (date: Date) => void;
  maxDate?: Date;
  label?: string;
}

export const DatePicker: React.FC<DatePickerProps> = React.memo(
  ({ selectedDate, onDateSelect, maxDate = new Date(), label = 'Select Date' }) => {
    const [currentMonth, setCurrentMonth] = useState(new Date());

    const monthDays = useMemo(() => {
      const start = startOfMonth(currentMonth);
      const end = endOfMonth(currentMonth);
      return eachDayOfInterval({ start, end });
    }, [currentMonth]);

    const firstDayOfWeek = useMemo(() => {
      return startOfMonth(currentMonth).getDay();
    }, [currentMonth]);

    const handlePrevMonth = useCallback((): void => {
      setCurrentMonth((prev) => subMonths(prev, 1));
    }, []);

    const handleNextMonth = useCallback((): void => {
      setCurrentMonth((prev) => addMonths(prev, 1));
    }, []);

    const handleDateClick = useCallback(
      (date: Date): void => {
        if (date <= maxDate) {
          onDateSelect(date);
        }
      },
      [maxDate, onDateSelect]
    );

    const handleKeyDown = useCallback(
      (e: React.KeyboardEvent<HTMLButtonElement>, date: Date): void => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          handleDateClick(date);
        }
      },
      [handleDateClick]
    );

    const paddingDays = Array.from({ length: firstDayOfWeek });

    return (
      <div className="w-full max-w-sm mx-auto p-4 rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900">
        <label className="block text-sm font-semibold text-gray-900 dark:text-white mb-4">
          {label}
        </label>

        <div className="flex items-center justify-between mb-4">
          <button
            onClick={handlePrevMonth}
            aria-label="Previous month"
            className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition"
          >
            <ChevronLeft size={20} />
          </button>

          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
            {format(currentMonth, 'MMMM yyyy')}
          </h2>

          <button
            onClick={handleNextMonth}
            aria-label="Next month"
            className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition"
          >
            <ChevronRight size={20} />
          </button>
        </div>

        <div className="grid grid-cols-7 gap-1 mb-4">
          {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((day) => (
            <div
              key={day}
              className="text-center text-xs font-semibold text-gray-600 dark:text-gray-400 py-2"
            >
              {day}
            </div>
          ))}

          {paddingDays.map((_, index) => (
            <div key={`padding-${index}`} />
          ))}

          {monthDays.map((date) => {
            const isSelected = selectedDate ? isSameDay(date, selectedDate) : false;
            const isDisabled = date > maxDate;
            const isCurrentMonth = isSameMonth(date, currentMonth);

            return (
              <button
                key={date.toISOString()}
                onClick={() => handleDateClick(date)}
                onKeyDown={(e) => handleKeyDown(e, date)}
                disabled={isDisabled}
                aria-pressed={isSelected}
                aria-label={format(date, 'EEEE, MMMM d, yyyy')}
                className={`
                  p-2 rounded-lg text-sm font-medium transition
                  ${!isCurrentMonth && 'opacity-30'}
                  ${isDisabled && 'opacity-40 cursor-not-allowed'}
                  ${
                    isSelected
                      ? 'bg-pink-600 text-white dark:bg-pink-500'
                      : 'hover:bg-gray-100 dark:hover:bg-gray-800 text-gray-900 dark:text-gray-100'
                  }
                `}
              >
                {format(date, 'd')}
              </button>
            );
          })}
        </div>

        {selectedDate && (
          <div className="text-center text-sm text-gray-600 dark:text-gray-400">
            Selected: {format(selectedDate, 'MMMM d, yyyy')}
          </div>
        )}
      </div>
    );
  }
);

DatePicker.displayName = 'DatePicker';
