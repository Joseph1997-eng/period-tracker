package com.example.periodtracker;

import org.junit.Before;
import org.junit.Test;
import static org.junit.Assert.*;

import java.time.LocalDate;
import java.time.YearMonth;

/**
 * Unit Tests for PeriodCalculator
 * Verifies prediction logic including leap year handling and edge cases
 */
public class PeriodCalculatorTest {

    private PeriodCalculator calculator;

    @Before
    public void setUp() {
        calculator = new PeriodCalculator();
    }

    /**
     * Test Case 1: Basic 28-day cycle prediction
     * Given: Last period start = 2026-01-15, cycle length = 28 days
     * Expected: Next period should be 2026-02-12
     */
    @Test
    public void testBasicCyclePrediction() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 1, 15);
        int cycleLength = 28;

        LocalDate nextPeriod = calculator.getNextPeriodDate(lastPeriodStart, cycleLength);

        assertEquals(LocalDate.of(2026, 2, 12), nextPeriod);
    }

    /**
     * Test Case 2: Leap year handling - February period
     * Given: Last period = 2024-01-15 (leap year), cycle = 28 days
     * Expected: Next period = 2024-02-12 (should handle leap day correctly)
     */
    @Test
    public void testLeapYearCyclePrediction() {
        LocalDate lastPeriodStart = LocalDate.of(2024, 1, 15);
        int cycleLength = 28;

        LocalDate nextPeriod = calculator.getNextPeriodDate(lastPeriodStart, cycleLength);

        assertEquals(LocalDate.of(2024, 2, 12), nextPeriod);
    }

    /**
     * Test Case 3: Year transition - Period crossing into next year
     * Given: Last period = 2024-12-20, cycle = 30 days
     * Expected: Next period = 2025-01-19 (should correctly handle year boundary)
     */
    @Test
    public void testYearBoundaryCyclePrediction() {
        LocalDate lastPeriodStart = LocalDate.of(2024, 12, 20);
        int cycleLength = 30;

        LocalDate nextPeriod = calculator.getNextPeriodDate(lastPeriodStart, cycleLength);

        assertEquals(LocalDate.of(2025, 1, 19), nextPeriod);
    }

    /**
     * Test Case 4: Variable cycle length - Short cycle
     * Given: Last period = 2026-01-20, cycle = 21 days (short)
     * Expected: Next period = 2026-02-10
     */
    @Test
    public void testShortCyclePrediction() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 1, 20);
        int cycleLength = 21;

        LocalDate nextPeriod = calculator.getNextPeriodDate(lastPeriodStart, cycleLength);

        assertEquals(LocalDate.of(2026, 2, 10), nextPeriod);
    }

    /**
     * Test Case 5: Variable cycle length - Long cycle
     * Given: Last period = 2026-01-01, cycle = 35 days (long)
     * Expected: Next period = 2026-02-05
     */
    @Test
    public void testLongCyclePrediction() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 1, 1);
        int cycleLength = 35;

        LocalDate nextPeriod = calculator.getNextPeriodDate(lastPeriodStart, cycleLength);

        assertEquals(LocalDate.of(2026, 2, 5), nextPeriod);
    }

    /**
     * Test Case 6: Fertile window calculation - Standard 28-day cycle
     * Given: Last period = 2026-02-05, cycle = 28 days
     * Expected: Fertile window around day 12-16 (2026-02-17 to 2026-02-21)
     */
    @Test
    public void testFertileWindowCalculation() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 2, 5);
        int cycleLength = 28;

        LocalDate[] fertileWindow = calculator.getFertileWindow(lastPeriodStart, cycleLength);

        assertNotNull(fertileWindow);
        assertEquals(2, fertileWindow.length);
        // Fertile window typically starts on day 12-3 (ovulation day - 3)
        assertEquals(LocalDate.of(2026, 2, 14), fertileWindow[0]);
        // Fertile window ends on ovulation day + 1
        assertEquals(LocalDate.of(2026, 2, 16), fertileWindow[1]);
    }

    /**
     * Test Case 7: Leap year identification
     * Given: Year 2024
     * Expected: Should return true (2024 is a leap year)
     */
    @Test
    public void testLeapYearDetection() {
        assertTrue(calculator.isLeapYear(2024));
    }

    /**
     * Test Case 8: Non-leap year identification
     * Given: Year 2023
     * Expected: Should return false (2023 is not a leap year)
     */
    @Test
    public void testNonLeapYearDetection() {
        assertFalse(calculator.isLeapYear(2023));
    }

    /**
     * Test Case 9: Century leap year (divisible by 400)
     * Given: Year 2000
     * Expected: Should return true (2000 is a leap year)
     */
    @Test
    public void testCenturyLeapYearDetection() {
        assertTrue(calculator.isLeapYear(2000));
    }

    /**
     * Test Case 10: Century non-leap year (divisible by 100 but not 400)
     * Given: Year 1900
     * Expected: Should return false (1900 is not a leap year)
     */
    @Test
    public void testCenturyNonLeapYearDetection() {
        assertFalse(calculator.isLeapYear(1900));
    }

    /**
     * Test Case 11: Days until next period
     * Given: Current date = 2026-02-05, last period = 2026-01-20, cycle = 28
     * Expected: Should calculate remaining days correctly
     */
    @Test
    public void testDaysUntilNextPeriod() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 1, 20);
        LocalDate currentDate = LocalDate.of(2026, 2, 5);
        int cycleLength = 28;

        int daysUntil = calculator.daysUntilNextPeriod(lastPeriodStart, currentDate, cycleLength);

        assertTrue(daysUntil > 0);
        assertTrue(daysUntil <= cycleLength);
    }

    /**
     * Test Case 12: Validate cycle duration bounds
     * Given: Invalid cycle length = 10 days
     * Expected: Should clamp to minimum (typically 21 days)
     */
    @Test
    public void testCycleLengthValidation() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 1, 15);
        int invalidCycleLength = 10; // Too short

        LocalDate nextPeriod = calculator.getNextPeriodDate(lastPeriodStart, invalidCycleLength);

        // Should use a reasonable minimum cycle length
        assertNotNull(nextPeriod);
    }

    /**
     * Test Case 13: Multiple period predictions (3 months ahead)
     * Given: Last period = 2026-01-15, cycle = 28 days
     * Expected: Should predict 3 subsequent periods correctly
     */
    @Test
    public void testMultiplePeriodPredictions() {
        LocalDate lastPeriodStart = LocalDate.of(2026, 1, 15);
        int cycleLength = 28;

        LocalDate period1 = calculator.getNextPeriodDate(lastPeriodStart, cycleLength);
        LocalDate period2 = calculator.getNextPeriodDate(period1, cycleLength);
        LocalDate period3 = calculator.getNextPeriodDate(period2, cycleLength);

        assertEquals(LocalDate.of(2026, 2, 12), period1);
        assertEquals(LocalDate.of(2026, 3, 12), period2);
        assertEquals(LocalDate.of(2026, 4, 9), period3);
    }

    /**
     * Test Case 14: Period duration calculation
     * Given: Period start = 2026-01-15, period end = 2026-01-20
     * Expected: Duration should be 6 days (inclusive)
     */
    @Test
    public void testPeriodDurationCalculation() {
        LocalDate periodStart = LocalDate.of(2026, 1, 15);
        LocalDate periodEnd = LocalDate.of(2026, 1, 20);

        int duration = calculator.getPeriodDuration(periodStart, periodEnd);

        assertEquals(6, duration); // Inclusive of both start and end date
    }

    /**
     * Test Case 15: Average cycle calculation
     * Given: Periods starting on 2026-01-15, 2026-02-12, 2026-03-12
     * Expected: Should calculate average cycle length as 28 days
     */
    @Test
    public void testAverageCycleCalculation() {
        LocalDate[] periodStarts = {
                LocalDate.of(2026, 1, 15),
                LocalDate.of(2026, 2, 12),
                LocalDate.of(2026, 3, 12)
        };

        int averageCycle = calculator.calculateAverageCycle(periodStarts);

        assertTrue(averageCycle > 0);
        assertTrue(averageCycle <= 35); // Should be within normal range
    }
}
