package com.example.periodtracker;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.TextView;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

/**
 * MainActivity handles the UI and user interactions for the Period Tracker app.
 * Integrates PeriodCalculator for cycle predictions and DataStorage for data persistence.
 */
public class MainActivity extends AppCompatActivity {

    // UI Components
    private DatePicker periodStartPicker;
    private DatePicker periodEndPicker;
    private Button logPeriodButton;
    private Button predictButton;
    private Button viewHistoryButton;
    private CardView resultCard;
    private CardView statisticsCard;
    private TextView nextPeriodText;
    private TextView fertileDaysText;
    private TextView daysUntilText;
    private TextView statisticsText;
    private TextView periodDurationText;

    // Business Logic Components
    private DataStorage dataStorage;
    private PeriodCalculator calculator;
    private SimpleDateFormat dateFormat;
    private DateTimeFormatter localDateFormatter;
    
    // Constants
    private static final int DEFAULT_CYCLE_LENGTH = 28;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Initialize formatters
        dateFormat = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
        localDateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");

        // Initialize data storage and calculator
        dataStorage = new DataStorage(this);
        initializeCalculator();

        // Initialize UI views
        initializeViews();

        // Set up click listeners
        setupClickListeners();

        // Load and display existing data
        loadAndDisplayData();
    }

    /**
     * Initialize the PeriodCalculator with stored or default data
     */
    private void initializeCalculator() {
        LocalDate lastPeriodStart = dataStorage.getLastPeriodStart();
        int cycleLength = dataStorage.getCycleLength();
        
        if (lastPeriodStart == null) {
            lastPeriodStart = LocalDate.now();
        }
        
        calculator = new PeriodCalculator(lastPeriodStart, cycleLength);
    }

    /**
     * Initialize all UI components
     */
    private void initializeViews() {
        periodStartPicker = findViewById(R.id.periodStartPicker);
        periodEndPicker = findViewById(R.id.periodEndPicker);
        logPeriodButton = findViewById(R.id.logPeriodButton);
        predictButton = findViewById(R.id.predictButton);
        viewHistoryButton = findViewById(R.id.viewHistoryButton);
        resultCard = findViewById(R.id.resultCard);
        statisticsCard = findViewById(R.id.statisticsCard);
        nextPeriodText = findViewById(R.id.nextPeriodText);
        fertileDaysText = findViewById(R.id.fertileDaysText);
        daysUntilText = findViewById(R.id.daysUntilText);
        statisticsText = findViewById(R.id.statisticsText);
        periodDurationText = findViewById(R.id.periodDurationText);

        // Set today's date as default in pickers
        Calendar today = Calendar.getInstance();
        periodStartPicker.updateDate(today.get(Calendar.YEAR), 
                                     today.get(Calendar.MONTH), 
                                     today.get(Calendar.DAY_OF_MONTH));
        periodEndPicker.updateDate(today.get(Calendar.YEAR), 
                                   today.get(Calendar.MONTH), 
                                   today.get(Calendar.DAY_OF_MONTH));

        // Initially hide result and statistics cards
        resultCard.setVisibility(View.GONE);
        statisticsCard.setVisibility(View.GONE);
    }

    /**
     * Set up all button click listeners
     */
    private void setupClickListeners() {
        logPeriodButton.setOnClickListener(v -> handleLogPeriod());
        
        predictButton.setOnClickListener(v -> handlePrediction());
        
        viewHistoryButton.setOnClickListener(v -> displayPeriodHistory());
    }

    /**
     * Handle logging a new period entry
     */
    private void handleLogPeriod() {
        LocalDate startDate = getDateFromPicker(periodStartPicker);
        LocalDate endDate = getDateFromPicker(periodEndPicker);

        if (startDate == null) {
            Toast.makeText(this, "Please select a valid start date", Toast.LENGTH_SHORT).show();
            return;
        }

        if (endDate != null && endDate.isBefore(startDate)) {
            Toast.makeText(this, "End date cannot be before start date", Toast.LENGTH_SHORT).show();
            return;
        }

        // Save period entry
        dataStorage.savePeriodEntry(startDate, endDate);
        
        // Update calculator with new data
        calculator.setLastPeriodStart(startDate);
        calculator.setCycleLength(dataStorage.getAverageCycleLength());

        // Provide feedback
        String periodInfo = "Period logged: " + startDate.format(localDateFormatter);
        if (endDate != null) {
            int duration = PeriodCalculator.calculatePeriodLength(startDate, endDate);
            periodInfo += " (" + duration + " days)";
        }
        Toast.makeText(this, periodInfo, Toast.LENGTH_LONG).show();

        // Reset pickers and display data
        loadAndDisplayData();
    }

    /**
     * Handle prediction calculation when button is clicked
     */
    private void handlePrediction() {
        LocalDate startDate = getDateFromPicker(periodStartPicker);

        if (startDate == null) {
            Toast.makeText(this, "Please select a start date", Toast.LENGTH_SHORT).show();
            return;
        }

        calculator.setLastPeriodStart(startDate);
        displayPredictions();
    }

    /**
     * Display all prediction results
     */
    private void displayPredictions() {
        LocalDate nextPeriod = calculator.getNextPeriodDate();
        PeriodCalculator.DateRange fertileWindow = calculator.getFertileWindow();
        int daysUntil = calculator.getDaysUntilNextPeriod();
        boolean inFertileWindow = calculator.isTodayInFertileWindow();

        if (nextPeriod != null) {
            String nextPeriodStr = nextPeriod.format(localDateFormatter);
            String daysStr = daysUntil >= 0 ? String.valueOf(daysUntil) : "Unknown";
            nextPeriodText.setText("Next Period: " + nextPeriodStr + "\nDays away: " + daysStr);
        }

        if (fertileWindow != null) {
            String fertileStr = fertileWindow.getStartDate().format(localDateFormatter) + 
                               " to " + 
                               fertileWindow.getEndDate().format(localDateFormatter);
            String status = inFertileWindow ? " (TODAY IS IN FERTILE WINDOW!)" : "";
            fertileDaysText.setText("Fertile Window: " + fertileStr + status);
        }

        daysUntilText.setText("Days until fertile window: " + calculator.getDaysUntilFertileWindow());

        resultCard.setVisibility(View.VISIBLE);
    }

    /**
     * Display cycle statistics from period history
     */
    private void displayStatistics() {
        List<LocalDate> periodHistory = dataStorage.getPeriodHistory();

        if (periodHistory.size() < 2) {
            statisticsText.setText("Need at least 2 periods for statistics");
            statisticsCard.setVisibility(View.VISIBLE);
            return;
        }

        PeriodCalculator.CycleStatistics stats = 
            PeriodCalculator.calculateCycleStatistics(periodHistory);

        String statsInfo = "Cycle Statistics:\n" +
                          "Average: " + stats.getAverageCycleLength() + " days\n" +
                          "Min: " + stats.getMinCycleLength() + " days\n" +
                          "Max: " + stats.getMaxCycleLength() + " days\n" +
                          "Tracked Cycles: " + (periodHistory.size() - 1);

        statisticsText.setText(statsInfo);
        statisticsCard.setVisibility(View.VISIBLE);
    }

    /**
     * Display period history and statistics
     */
    private void displayPeriodHistory() {
        List<LocalDate> periodHistory = dataStorage.getPeriodHistory();

        if (periodHistory.isEmpty()) {
            Toast.makeText(this, "No period data recorded yet", Toast.LENGTH_SHORT).show();
            return;
        }

        StringBuilder historyText = new StringBuilder("Period History (Last 12):\n\n");
        
        int count = 0;
        for (LocalDate date : periodHistory) {
            if (count >= 12) break;
            historyText.append(date.format(localDateFormatter)).append("\n");
            count++;
        }

        // Display history and statistics
        displayStatistics();
        
        Toast.makeText(this, historyText.toString(), Toast.LENGTH_LONG).show();
    }

    /**
     * Load data from storage and display current predictions
     */
    private void loadAndDisplayData() {
        LocalDate lastPeriod = dataStorage.getLastPeriodStart();

        if (lastPeriod != null) {
            calculator.setLastPeriodStart(lastPeriod);
            calculator.setCycleLength(dataStorage.getAverageCycleLength());
            displayPredictions();
        }
    }

    /**
     * Convert DatePicker selection to LocalDate
     */
    private LocalDate getDateFromPicker(DatePicker picker) {
        try {
            return LocalDate.of(picker.getYear(), 
                              picker.getMonth() + 1,  // DatePicker months are 0-indexed
                              picker.getDayOfMonth());
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
