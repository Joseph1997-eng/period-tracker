package com.example.periodtracker;

import android.content.Context;
import android.content.SharedPreferences;
import androidx.security.crypto.EncryptedSharedPreferences;
import androidx.security.crypto.MasterKey;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * DataStorage handles all data persistence using encrypted SharedPreferences.
 * Stores period entries, cycle statistics, and user preferences locally with encryption.
 * 
 * Features:
 * - End-to-end encryption using EncryptedSharedPreferences
 * - Period entry management (save, retrieve, delete)
 * - Cycle history tracking
 * - Statistics caching
 */
public class DataStorage {
    
    private static final String PREFS_NAME = "period_tracker_prefs";
    private static final String KEY_PERIOD_ENTRIES = "period_entries";
    private static final String KEY_LAST_PERIOD_START = "last_period_start";
    private static final String KEY_CYCLE_LENGTH = "cycle_length";
    private static final String KEY_AVERAGE_CYCLE = "average_cycle";
    private static final String ENTRY_SEPARATOR = "|";
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE;
    private static final int DEFAULT_CYCLE_LENGTH = 28;
    
    private SharedPreferences encryptedPrefs;
    private Context context;
    
    /**
     * Constructor initializes encrypted SharedPreferences
     * @param context Application context
     */
    public DataStorage(Context context) {
        this.context = context;
        try {
            initializeEncryptedPreferences();
        } catch (GeneralSecurityException | IOException e) {
            e.printStackTrace();
            // Fallback to unencrypted if encryption fails
            encryptedPrefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        }
    }
    
    /**
     * Initialize encrypted SharedPreferences with MasterKey
     */
    private void initializeEncryptedPreferences() throws GeneralSecurityException, IOException {
        MasterKey masterKey = new MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build();
        
        encryptedPrefs = EncryptedSharedPreferences.create(
                context,
                PREFS_NAME,
                masterKey,
                EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
                EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        );
    }
    
    /**
     * Save a new period entry (start and optionally end date)
     * @param startDate Period start date
     * @param endDate Period end date (nullable)
     */
    public void savePeriodEntry(LocalDate startDate, LocalDate endDate) {
        if (startDate == null) {
            return;
        }
        
        String entries = encryptedPrefs.getString(KEY_PERIOD_ENTRIES, "");
        String newEntry = startDate.format(DATE_FORMATTER) + 
                         (endDate != null ? "-" + endDate.format(DATE_FORMATTER) : "");
        
        String updatedEntries = entries.isEmpty() ? newEntry : entries + ENTRY_SEPARATOR + newEntry;
        
        SharedPreferences.Editor editor = encryptedPrefs.edit();
        editor.putString(KEY_PERIOD_ENTRIES, updatedEntries);
        editor.putString(KEY_LAST_PERIOD_START, startDate.format(DATE_FORMATTER));
        editor.apply();
        
        // Update cycle statistics
        updateCycleStatistics();
    }
    
    /**
     * Retrieve all period start dates from history
     * @return List of LocalDate objects representing period starts
     */
    public List<LocalDate> getPeriodHistory() {
        String entries = encryptedPrefs.getString(KEY_PERIOD_ENTRIES, "");
        List<LocalDate> periodDates = new ArrayList<>();
        
        if (entries.isEmpty()) {
            return periodDates;
        }
        
        String[] entryArray = entries.split("\\" + ENTRY_SEPARATOR);
        
        for (String entry : entryArray) {
            try {
                String[] dates = entry.split("-");
                LocalDate startDate = LocalDate.parse(dates[0], DATE_FORMATTER);
                periodDates.add(startDate);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        // Sort in descending order (most recent first)
        Collections.sort(periodDates, Collections.reverseOrder());
        return periodDates;
    }
    
    /**
     * Get the last recorded period start date
     * @return LocalDate of last period start, or null if none recorded
     */
    public LocalDate getLastPeriodStart() {
        String dateStr = encryptedPrefs.getString(KEY_LAST_PERIOD_START, "");
        
        if (dateStr.isEmpty()) {
            return null;
        }
        
        try {
            return LocalDate.parse(dateStr, DATE_FORMATTER);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Delete a period entry by start date
     * @param startDate The start date of the period to delete
     */
    public void deletePeriodEntry(LocalDate startDate) {
        if (startDate == null) {
            return;
        }
        
        String entries = encryptedPrefs.getString(KEY_PERIOD_ENTRIES, "");
        if (entries.isEmpty()) {
            return;
        }
        
        String dateToRemove = startDate.format(DATE_FORMATTER);
        String[] entryArray = entries.split("\\" + ENTRY_SEPARATOR);
        StringBuilder updatedEntries = new StringBuilder();
        
        for (String entry : entryArray) {
            if (!entry.startsWith(dateToRemove)) {
                if (updatedEntries.length() > 0) {
                    updatedEntries.append(ENTRY_SEPARATOR);
                }
                updatedEntries.append(entry);
            }
        }
        
        SharedPreferences.Editor editor = encryptedPrefs.edit();
        editor.putString(KEY_PERIOD_ENTRIES, updatedEntries.toString());
        editor.apply();
        
        // Update statistics
        updateCycleStatistics();
    }
    
    /**
     * Get average cycle length from history
     * @return Average cycle length in days, or DEFAULT_CYCLE_LENGTH if insufficient data
     */
    public int getAverageCycleLength() {
        return encryptedPrefs.getInt(KEY_AVERAGE_CYCLE, DEFAULT_CYCLE_LENGTH);
    }
    
    /**
     * Set custom cycle length preference
     * @param cycleLength Cycle length in days
     */
    public void setCycleLength(int cycleLength) {
        if (cycleLength > 0) {
            SharedPreferences.Editor editor = encryptedPrefs.edit();
            editor.putInt(KEY_CYCLE_LENGTH, cycleLength);
            editor.apply();
        }
    }
    
    /**
     * Get stored cycle length preference
     * @return Stored cycle length, or DEFAULT_CYCLE_LENGTH if not set
     */
    public int getCycleLength() {
        return encryptedPrefs.getInt(KEY_CYCLE_LENGTH, DEFAULT_CYCLE_LENGTH);
    }
    
    /**
     * Update cycle statistics based on period history
     */
    private void updateCycleStatistics() {
        List<LocalDate> periodDates = getPeriodHistory();
        if (periodDates.size() < 2) {
            return;
        }
        
        PeriodCalculator.CycleStatistics stats = 
            PeriodCalculator.calculateCycleStatistics(periodDates);
        
        SharedPreferences.Editor editor = encryptedPrefs.edit();
        editor.putInt(KEY_AVERAGE_CYCLE, stats.getAverageCycleLength());
        editor.apply();
    }
    
    /**
     * Clear all stored data (for testing or user reset)
     */
    public void clearAllData() {
        SharedPreferences.Editor editor = encryptedPrefs.edit();
        editor.clear();
        editor.apply();
    }
    
    /**
     * Export period data as CSV format string
     * @return CSV formatted string of all period entries
     */
    public String exportDataAsCSV() {
        StringBuilder csv = new StringBuilder("Period Start,Period End,Duration (days)\n");
        
        List<LocalDate> periodDates = getPeriodHistory();
        String entries = encryptedPrefs.getString(KEY_PERIOD_ENTRIES, "");
        
        if (entries.isEmpty()) {
            return csv.toString();
        }
        
        String[] entryArray = entries.split("\\" + ENTRY_SEPARATOR);
        
        for (String entry : entryArray) {
            try {
                String[] dates = entry.split("-");
                LocalDate startDate = LocalDate.parse(dates[0], DATE_FORMATTER);
                LocalDate endDate = dates.length > 1 ? 
                    LocalDate.parse(dates[1], DATE_FORMATTER) : startDate;
                
                int duration = PeriodCalculator.calculatePeriodLength(startDate, endDate);
                csv.append(startDate).append(",").append(endDate).append(",").append(duration).append("\n");
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        
        return csv.toString();
    }
}
