package com.example.periodtracker;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;
import androidx.cardview.widget.CardView;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private DatePicker datePicker;
    private Button predictButton;
    private CardView resultCard;
    private TextView nextPeriodText;
    private TextView fertileDaysText;

    // Constants for cycle calculations
    private static final int CYCLE_LENGTH = 28; // Average cycle length in days
    private static final int OVULATION_DAY = 14; // Days before next period
    private static final int FERTILE_WINDOW_START = 5; // Days before ovulation
    private static final int FERTILE_WINDOW_END = 1; // Days after ovulation

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Initialize views
        initializeViews();

        // Set up button click listener
        predictButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                calculatePredictions();
            }
        });
    }

    /**
     * Initialize all UI components
     */
    private void initializeViews() {
        datePicker = findViewById(R.id.datePicker);
        predictButton = findViewById(R.id.predictButton);
        resultCard = findViewById(R.id.resultCard);
        nextPeriodText = findViewById(R.id.nextPeriodText);
        fertileDaysText = findViewById(R.id.fertileDaysText);

        // Initially hide the result card
        resultCard.setVisibility(View.GONE);
    }

    /**
     * Calculate and display period predictions based on selected date
     */
    private void calculatePredictions() {
        // Get selected date from DatePicker
        int day = datePicker.getDayOfMonth();
        int month = datePicker.getMonth();
        int year = datePicker.getYear();

        // Create Calendar instance with selected date
        Calendar selectedDate = Calendar.getInstance();
        selectedDate.set(year, month, day);

        // Calculate next period date (add 28 days to selected date)
        Calendar nextPeriodDate = (Calendar) selectedDate.clone();
        nextPeriodDate.add(Calendar.DAY_OF_MONTH, CYCLE_LENGTH);

        // Calculate ovulation date (14 days before next period)
        Calendar ovulationDate = (Calendar) nextPeriodDate.clone();
        ovulationDate.add(Calendar.DAY_OF_MONTH, -OVULATION_DAY);

        // Calculate fertile window start (5 days before ovulation)
        Calendar fertileWindowStart = (Calendar) ovulationDate.clone();
        fertileWindowStart.add(Calendar.DAY_OF_MONTH, -FERTILE_WINDOW_START);

        // Calculate fertile window end (1 day after ovulation)
        Calendar fertileWindowEnd = (Calendar) ovulationDate.clone();
        fertileWindowEnd.add(Calendar.DAY_OF_MONTH, FERTILE_WINDOW_END);

        // Format dates for display
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
        String nextPeriodDateStr = dateFormat.format(nextPeriodDate.getTime());
        String fertileStartStr = dateFormat.format(fertileWindowStart.getTime());
        String fertileEndStr = dateFormat.format(fertileWindowEnd.getTime());

        // Update UI with results
        nextPeriodText.setText("Next Period Date: " + nextPeriodDateStr);
        fertileDaysText.setText("Fertile Window: " + fertileStartStr + " - " + fertileEndStr);

        // Show the result card
        resultCard.setVisibility(View.VISIBLE);
    }
}
