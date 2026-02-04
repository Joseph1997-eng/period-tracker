package com.example.periodtracker;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;

/**
 * PeriodCalculator handles all menstrual cycle calculations including
 * prediction logic, fertile window calculation, and cycle statistics.
 * 
 * Uses java.time.LocalDate for precision and accuracy.
 */
public class PeriodCalculator {
    
    private static final int DEFAULT_CYCLE_LENGTH = 28;
    private static final int FERTILE_WINDOW_START = 12;
    private static final int FERTILE_WINDOW_END = 16;
    
    private LocalDate lastPeriodStart;
    private int cycleLength;
    
    /**
     * Constructor initializes calculator with last period start date and cycle length
     */
    public PeriodCalculator(LocalDate lastPeriodStart, int cycleLength) {
        this.lastPeriodStart = lastPeriodStart;
        this.cycleLength = cycleLength > 0 ? cycleLength : DEFAULT_CYCLE_LENGTH;
    }
    
    /**
     * Predicts the next period date based on current cycle length
     * @return LocalDate representing predicted next period start
     */
    public LocalDate getNextPeriodDate() {
        if (lastPeriodStart == null) {
            return null;
        }
        return lastPeriodStart.plusDays(cycleLength);
    }
    
    /**
     * Calculates the fertile window (ovulation period) for current cycle
     * Typically occurs around day 14 of a 28-day cycle
     * 
     * @return DateRange object containing fertile window start and end dates
     */
    public DateRange getFertileWindow() {
        if (lastPeriodStart == null) {
            return null;
        }
        
        LocalDate fertileStart = lastPeriodStart.plusDays(FERTILE_WINDOW_START);
        LocalDate fertileEnd = lastPeriodStart.plusDays(FERTILE_WINDOW_END);
        
        return new DateRange(fertileStart, fertileEnd);
    }
    
    /**
     * Calculates the fertile window for a specific cycle number
     * @param cycleCount number of cycles in the future (0 = current)
     * @return DateRange for the specified cycle
     */
    public DateRange getFertileWindowForCycle(int cycleCount) {
        if (lastPeriodStart == null) {
            return null;
        }
        
        LocalDate cycleStart = lastPeriodStart.plusDays((long) cycleLength * cycleCount);
        LocalDate fertileStart = cycleStart.plusDays(FERTILE_WINDOW_START);
        LocalDate fertileEnd = cycleStart.plusDays(FERTILE_WINDOW_END);
        
        return new DateRange(fertileStart, fertileEnd);
    }
    
    /**
     * Calculates days until next period
     * @return number of days remaining until next period
     */
    public int getDaysUntilNextPeriod() {
        LocalDate nextPeriod = getNextPeriodDate();
        if (nextPeriod == null) {
            return -1;
        }
        
        long daysRemaining = java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), nextPeriod);
        return (int) daysRemaining;
    }
    
    /**
     * Calculates days until fertile window
     * @return number of days until fertile window starts
     */
    public int getDaysUntilFertileWindow() {
        DateRange fertile = getFertileWindow();
        if (fertile == null) {
            return -1;
        }
        
        long daysRemaining = java.time.temporal.ChronoUnit.DAYS.between(LocalDate.now(), fertile.getStartDate());
        return (int) daysRemaining;
    }
    
    /**
     * Checks if today falls within the fertile window
     * @return true if today is in fertile window, false otherwise
     */
    public boolean isTodayInFertileWindow() {
        DateRange fertile = getFertileWindow();
        if (fertile == null) {
            return false;
        }
        
        LocalDate today = LocalDate.now();
        return !today.isBefore(fertile.getStartDate()) && !today.isAfter(fertile.getEndDate());
    }
    
    /**
     * Calculates cycle information from period history
     * @param periodDates list of period start dates
     * @return CycleStatistics object with average, min, and max cycle lengths
     */
    public static CycleStatistics calculateCycleStatistics(List<LocalDate> periodDates) {
        if (periodDates == null || periodDates.size() < 2) {
            return new CycleStatistics(DEFAULT_CYCLE_LENGTH, 0, 0);
        }
        
        List<Integer> cycleLengths = new ArrayList<>();
        
        // Calculate cycle lengths between consecutive periods
        for (int i = 0; i < periodDates.size() - 1; i++) {
            LocalDate current = periodDates.get(i);
            LocalDate next = periodDates.get(i + 1);
            
            long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(current, next);
            cycleLengths.add((int) daysBetween);
        }
        
        // Calculate statistics
        int average = (int) cycleLengths.stream().mapToInt(Integer::intValue).average().orElse(DEFAULT_CYCLE_LENGTH);
        int min = cycleLengths.stream().mapToInt(Integer::intValue).min().orElse(DEFAULT_CYCLE_LENGTH);
        int max = cycleLengths.stream().mapToInt(Integer::intValue).max().orElse(DEFAULT_CYCLE_LENGTH);
        
        return new CycleStatistics(average, min, max);
    }
    
    /**
     * Validates if a year is a leap year
     * @param year the year to check
     * @return true if leap year, false otherwise
     */
    public static boolean isLeapYear(int year) {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
    }
    
    /**
     * Checks if a date is valid for a specific month/year
     * @param day day of month
     * @param month month (1-12)
     * @param year year
     * @return true if date is valid
     */
    public static boolean isValidDate(int day, int month, int year) {
        try {
            LocalDate.of(year, month, day);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    /**
     * Calculates period length (from start to end date)
     * @param startDate period start date
     * @param endDate period end date
     * @return number of days in period
     */
    public static int calculatePeriodLength(LocalDate startDate, LocalDate endDate) {
        if (startDate == null || endDate == null || endDate.isBefore(startDate)) {
            return 0;
        }
        
        long daysBetween = java.time.temporal.ChronoUnit.DAYS.between(startDate, endDate);
        return (int) daysBetween + 1; // Include both start and end days
    }
    
    // Getters and Setters
    
    public LocalDate getLastPeriodStart() {
        return lastPeriodStart;
    }
    
    public void setLastPeriodStart(LocalDate lastPeriodStart) {
        this.lastPeriodStart = lastPeriodStart;
    }
    
    public int getCycleLength() {
        return cycleLength;
    }
    
    public void setCycleLength(int cycleLength) {
        this.cycleLength = cycleLength > 0 ? cycleLength : DEFAULT_CYCLE_LENGTH;
    }
    
    /**
     * Inner class to represent a date range
     */
    public static class DateRange {
        private LocalDate startDate;
        private LocalDate endDate;
        
        public DateRange(LocalDate startDate, LocalDate endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
        
        public LocalDate getStartDate() {
            return startDate;
        }
        
        public LocalDate getEndDate() {
            return endDate;
        }
        
        public boolean containsDate(LocalDate date) {
            return !date.isBefore(startDate) && !date.isAfter(endDate);
        }
        
        @Override
        public String toString() {
            return startDate + " to " + endDate;
        }
    }
    
    /**
     * Inner class for cycle statistics
     */
    public static class CycleStatistics {
        private int averageCycleLength;
        private int minCycleLength;
        private int maxCycleLength;
        
        public CycleStatistics(int average, int min, int max) {
            this.averageCycleLength = average;
            this.minCycleLength = min;
            this.maxCycleLength = max;
        }
        
        public int getAverageCycleLength() {
            return averageCycleLength;
        }
        
        public int getMinCycleLength() {
            return minCycleLength;
        }
        
        public int getMaxCycleLength() {
            return maxCycleLength;
        }
        
        @Override
        public String toString() {
            return "Avg: " + averageCycleLength + " | Min: " + minCycleLength + " | Max: " + maxCycleLength;
        }
    }
}
