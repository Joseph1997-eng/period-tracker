# PHASE 2: SYSTEM DESIGN & ARCHITECTURE

## Complete Architecture Documentation

---

## 1. PROJECT OVERVIEW

**Application Name:** Period Tracker  
**Purpose:** Track menstrual cycles, predict next periods, and calculate fertile windows  
**Target Users:** Women seeking cycle tracking and fertility prediction  
**Platform:** Android (API 21+)  
**Architecture Pattern:** MVP (Model-View-Presenter)

---

## 2. CLASS ARCHITECTURE DIAGRAM

```
┌──────────────────────────────────────────────────────────────────┐
│                         UI LAYER                                  │
│                      (MainActivity)                               │
├──────────────────────────────────────────────────────────────────┤
│  - periodStartPicker: DatePicker                                  │
│  - periodEndPicker: DatePicker                                    │
│  - logPeriodButton: Button                                        │
│  - predictButton: Button                                          │
│  - resultCard: CardView (displays predictions)                    │
│  - statisticsCard: CardView (displays statistics)                 │
├──────────────────────────────────────────────────────────────────┤
│  RESPONSIBILITIES:                                                │
│  - Capture user input from DatePicker widgets                     │
│  - Display calculation results to user                            │
│  - Handle button clicks and navigation                            │
│  - Update UI based on business logic results                      │
└──────────┬───────────────────────────────────────────────────────┘
           │ uses
    ┌──────┴──────────────────────────────────────────────────────┐
    │                                                              │
    ▼                                                              ▼
┌─────────────────────────────┐                    ┌────────────────────────────┐
│   BUSINESS LOGIC LAYER      │                    │   DATA PERSISTENCE LAYER   │
│  (PeriodCalculator)         │                    │    (DataStorage)           │
├─────────────────────────────┤                    ├────────────────────────────┤
│ - lastPeriodStart: LocalDate│                    │ - encryptedPrefs:          │
│ - cycleLength: int          │                    │   SharedPreferences        │
│ - cycleLengths[]: int[]     │                    │                            │
│                             │                    ├────────────────────────────┤
├─────────────────────────────┤                    │ PERSISTENCE OPERATIONS:    │
│ CALCULATION METHODS:        │                    │ + savePeriodEntry()        │
│ + getNextPeriodDate()       │                    │ + getPeriodHistory()       │
│ + getFertileWindow()        │                    │ + getLastPeriodStart()     │
│ + getAverageCycle()         │                    │ + getAverageCycleLength()  │
│ + getCycleDuration()        │                    │ + deletePeriodEntry()      │
│ + isLeapYear()              │                    │ + exportAsCSV()            │
│ + daysUntilNextPeriod()     │                    │                            │
│ + calculateAverageCycle()   │                    │ STORAGE FORMAT:            │
│ + getPeriodDuration()       │                    │ Key: "period_YYYY-MM-DD"   │
│                             │                    │ Value: "start_date|end_date"
│ VALIDATION METHODS:         │                    │                            │
│ + validateCycleLength()     │                    │ Encryption: Yes            │
│ + validateDate()            │                    │ (EncryptedSharedPreferences)
└─────────────────────────────┘                    └────────────────────────────┘
           ▲                                                  ▲
           │ calls                                            │ calls
           └────────────────────────────────────────────────┘
```

---

## 3. DETAILED CLASS SPECIFICATIONS

### **3.1 MainActivity Class**

#### **Purpose:**
Primary UI controller that orchestrates user interactions and displays results.

#### **Key Attributes:**
```java
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

// Business Logic
private DataStorage dataStorage;
private PeriodCalculator calculator;
private SimpleDateFormat dateFormat;
private DateTimeFormatter localDateFormatter;
```

#### **Key Methods:**
```java
+ onCreate(Bundle): void
  → Initialize UI components
  → Create DataStorage and PeriodCalculator instances
  → Set up event listeners

+ onLogPeriodClick(): void
  → Extract dates from DatePicker widgets
  → Validate dates
  → Call dataStorage.savePeriodEntry()
  → Update UI with success message

+ onPredictClick(): void
  → Get last period date from DataStorage
  → Calculate next period using PeriodCalculator
  → Calculate fertile window
  → Display results in resultCard

+ onViewHistoryClick(): void
  → Retrieve period history from DataStorage
  → Display list of past cycles with statistics

+ displayResults(LocalDate, LocalDate[], int): void
  → Format dates for display
  → Update resultCard with predictions

+ displayStatistics(): void
  → Calculate average, min, max cycle lengths
  → Display in statisticsCard

+ validateUserInput(): boolean
  → Check date ranges
  → Ensure dates are in past/present
  → Return validation result

+ convertLocalDateToDisplay(LocalDate): String
  → Format LocalDate to user-friendly string
```

#### **Lifecycle Events:**
- **onCreate()** - Initialize components when app starts
- **onResume()** - Refresh data when user returns to app
- **onPause()** - Save state before backgrounding

---

### **3.2 PeriodCalculator Class**

#### **Purpose:**
Pure calculation engine for cycle predictions and fertile window calculations using `java.time.LocalDate`.

#### **Key Attributes:**
```java
private static final int DEFAULT_CYCLE_LENGTH = 28;
private static final int MIN_CYCLE_LENGTH = 21;
private static final int MAX_CYCLE_LENGTH = 35;
private static final int FERTILE_WINDOW_START = 12;  // Day 12 of cycle
private static final int FERTILE_WINDOW_END = 16;    // Day 16 of cycle
private static final int OVULATION_DAY = 14;         // Day 14 (midpoint)
```

#### **Core Calculation Methods:**

```java
/**
 * Calculate next period date based on last period and cycle length
 * Uses LocalDate for precision handling of month/year boundaries
 */
+ getNextPeriodDate(LocalDate lastPeriod, int cycleLength): LocalDate
  Input: 
    - lastPeriod: Start date of last period
    - cycleLength: Days in cycle (default 28)
  Process:
    1. Add cycleLength days to lastPeriod
    2. Handle month/year transitions automatically
    3. Return calculated date
  Output: LocalDate of predicted next period
  Example: 2026-01-15 + 28 days = 2026-02-12

/**
 * Calculate fertile window (typically 5 days around ovulation)
 * For 28-day cycle: Day 12-16 of cycle = most fertile
 */
+ getFertileWindow(LocalDate lastPeriod, int cycleLength): LocalDate[]
  Input: Last period start date, cycle length
  Process:
    1. Calculate ovulation day (typically day 14)
    2. Fertile window = days 12-16 (3 days before to 1 day after ovulation)
    3. Convert cycle days to actual dates
  Output: Array [startDate, endDate] of fertile window
  Example: For cycle starting 2026-02-05:
    - Ovulation: 2026-02-19
    - Fertile Window: 2026-02-17 to 2026-02-21

/**
 * Get average cycle length from historical data
 * Analyzes multiple cycles to compute trend
 */
+ calculateAverageCycle(LocalDate[] periodStarts): int
  Input: Array of period start dates (chronological order)
  Process:
    1. Calculate days between consecutive periods
    2. Sum all cycle lengths
    3. Divide by (number of periods - 1)
  Output: Average cycle length
  Example: [2026-01-15, 2026-02-12, 2026-03-12]
    - Cycle 1: 28 days
    - Cycle 2: 28 days
    - Average: 28 days

/**
 * Leap year detection for February calculations
 */
+ isLeapYear(int year): boolean
  Rules:
    1. If year divisible by 400 → LEAP
    2. If year divisible by 100 → NOT LEAP
    3. If year divisible by 4 → LEAP
    4. Otherwise → NOT LEAP
  Examples:
    - 2024: LEAP ✓
    - 2000: LEAP ✓
    - 1900: NOT LEAP ✗
    - 2023: NOT LEAP ✗

/**
 * Calculate days until next period from current date
 */
+ daysUntilNextPeriod(LocalDate lastPeriod, LocalDate today, int cycle): int
  Input: Last period, current date, cycle length
  Process:
    1. Calculate next period date
    2. Calculate ChronoUnit.DAYS.between(today, nextPeriod)
    3. Return remaining days
  Output: Integer days remaining
```

#### **Validation Methods:**

```java
+ validateCycleLength(int cycleLength): int
  → Clamp to range [21, 35]
  → Return valid cycle length

+ validateDate(LocalDate date): boolean
  → Check date is not in future
  → Return true if valid

+ getPeriodDuration(LocalDate start, LocalDate end): int
  → Calculate days between start and end (inclusive)
  → Handle edge cases
```

---

### **3.3 DataStorage Class**

#### **Purpose:**
Abstraction layer for encrypted local data persistence using SharedPreferences.

#### **Key Attributes:**
```java
private static final String PREFS_NAME = "period_tracker_prefs";
private SharedPreferences encryptedPrefs;
private Context context;

// Key constants
private static final String KEY_PERIOD_ENTRIES = "period_entries";
private static final String KEY_LAST_PERIOD_START = "last_period_start";
private static final String KEY_AVERAGE_CYCLE = "average_cycle";
```

#### **Storage Format:**

```
SharedPreferences Structure:
├── period_2026-01-15 = "2026-01-15|2026-01-20"
├── period_2026-02-12 = "2026-02-12|2026-02-17"
├── period_2026-03-12 = "2026-03-12|2026-03-17"
├── last_period_start = "2026-03-12"
└── average_cycle = 28

Data Format:
- Key: "period_" + ISO_LOCAL_DATE (YYYY-MM-DD)
- Value: "startDate|endDate" (pipe-separated)
- Encryption: EncryptedSharedPreferences
```

#### **CRUD Operations:**

```java
/**
 * SAVE: Persist a new period entry
 */
+ savePeriodEntry(LocalDate start, LocalDate end): void
  Process:
    1. Create entry key: "period_" + start date
    2. Create value: "start|end"
    3. Update last_period_start
    4. Recalculate average_cycle
    5. Commit to encrypted storage

/**
 * READ: Retrieve all period entries
 */
+ getPeriodHistory(): List<String>
  Process:
    1. Iterate all SharedPreferences keys
    2. Filter entries starting with "period_"
    3. Sort reverse chronological order
    4. Return list of "start|end" strings

/**
 * READ: Get last period start date
 */
+ getLastPeriodStart(): LocalDate
  Process:
    1. Retrieve key_last_period_start
    2. Parse as LocalDate
    3. Return LocalDate object

/**
 * READ: Get average cycle length
 */
+ getAverageCycleLength(): int
  Process:
    1. Try to retrieve cached average_cycle
    2. If not found or empty, recalculate
    3. Default to 28 if no history
    4. Return integer days

/**
 * DELETE: Remove specific period entry
 */
+ deletePeriodEntry(LocalDate startDate): void
  Process:
    1. Create key: "period_" + startDate
    2. Remove from storage
    3. Recalculate statistics
    4. Commit changes

/**
 * EXPORT: Generate CSV export of all data
 */
+ exportAsCSV(): String
  Format:
    Start Date,End Date,Duration (Days)
    2026-01-15,2026-01-20,6
    2026-02-12,2026-02-17,6
  Output: CSV string ready for file export
```

#### **Encryption Implementation:**

```java
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
```

---

## 4. DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────┐
│                       USER INPUT FLOW                            │
└─────────────────────────────────────────────────────────────────┘

USER INPUT (DatePicker Widgets)
        │
        ▼
MainActivity.onLogPeriodClick()
        │
        ├─→ Extract dates from UI
        ├─→ Validate date range
        │
        ▼
DataStorage.savePeriodEntry(start, end)
        │
        ├─→ Encrypt and store in SharedPreferences
        ├─→ Update last_period_start
        ├─→ Recalculate average_cycle
        │
        ▼
MainActivity.displayResults()
        │
        └─→ Show success toast to user


┌─────────────────────────────────────────────────────────────────┐
│                      PREDICTION FLOW                             │
└─────────────────────────────────────────────────────────────────┘

USER CLICK: "Predict Next Period"
        │
        ▼
MainActivity.onPredictClick()
        │
        ├─→ Retrieve lastPeriodStart from DataStorage
        ├─→ Retrieve cycleLength from DataStorage
        │
        ▼
PeriodCalculator.getNextPeriodDate(start, length)
        │
        ├─→ LocalDate.plus(cycleLength, ChronoUnit.DAYS)
        │
        ▼
PeriodCalculator.getFertileWindow(start, length)
        │
        ├─→ Calculate ovulation day (day 14)
        ├─→ Calculate window (day 12-16)
        │
        ▼
MainActivity.displayResults(nextDate, fertileWindow, daysUntil)
        │
        └─→ Update resultCard with formatted dates


┌─────────────────────────────────────────────────────────────────┐
│                    STATISTICS FLOW                               │
└─────────────────────────────────────────────────────────────────┘

USER CLICK: "View Statistics"
        │
        ▼
MainActivity.onViewStatisticsClick()
        │
        ├─→ DataStorage.getPeriodHistory()
        │
        ▼
PeriodCalculator.calculateAverageCycle(periodStarts[])
        │
        ├─→ Calculate differences between consecutive periods
        ├─→ Compute average/min/max
        │
        ▼
MainActivity.displayStatistics()
        │
        └─→ Update statisticsCard with metrics
```

---

## 5. STATE MANAGEMENT

### **Application State:**

```java
// MainActivity maintains:
- currentlySelectedStartDate: LocalDate
- currentlySelectedEndDate: LocalDate
- lastStoredPeriod: LocalDate
- cycleLengthCache: int

// PeriodCalculator maintains:
- Stateless (all calculations from input parameters)

// DataStorage maintains:
- Persistent state in EncryptedSharedPreferences
- Cache of average cycle (updated on each save)
```

### **State Transitions:**

```
[INIT] → Load last period from storage
   │
   ├─→ [READY] Display UI, ready for input
   │
   ├─→ USER ENTERS DATES
   │
   ├─→ [VALIDATING] Check date bounds
   │
   ├─→ [SAVING] Persist to storage, recalculate
   │
   └─→ [DISPLAYING] Show results and statistics
```

---

## 6. ERROR HANDLING STRATEGY

### **User Input Validation:**

```java
try {
    // Validate date range
    if (startDate.isAfter(endDate)) {
        throw new IllegalArgumentException("Start date must be before end date");
    }
    
    // Validate not in future
    if (startDate.isAfter(LocalDate.now())) {
        throw new IllegalArgumentException("Period cannot be in future");
    }
    
    // Validate reasonable duration
    long duration = ChronoUnit.DAYS.between(startDate, endDate);
    if (duration > 14) {
        Toast.makeText(this, "Period duration seems long, verify dates", Toast.LENGTH_SHORT).show();
    }
    
    // Proceed with save
    dataStorage.savePeriodEntry(startDate, endDate);
    
} catch (DateTimeParseException e) {
    Toast.makeText(this, "Invalid date format", Toast.LENGTH_SHORT).show();
} catch (IllegalArgumentException e) {
    Toast.makeText(this, e.getMessage(), Toast.LENGTH_SHORT).show();
}
```

---

## 7. THREADING MODEL

- **UI Thread:** All UI updates, user interactions
- **SharedPreferences:** Synchronous operations (fast)
- **Calculations:** Performed on main thread (minimal computation)
- **Future Enhancement:** Use WorkManager for background backup tasks

---

## 8. DEPENDENCY INJECTION

### **Current Implementation (Manual):**
```java
// In MainActivity.onCreate()
dataStorage = new DataStorage(this);
calculator = new PeriodCalculator();
```

### **Future Enhancement (Dagger Hilt):**
```java
@HiltViewModel
class MainActivity extends AppCompatActivity {
    @Inject
    DataStorage dataStorage;
    
    @Inject
    PeriodCalculator calculator;
}
```

---

## 9. TESTING STRATEGY

### **Unit Tests (PeriodCalculatorTest):**
- Basic cycle prediction (28 days)
- Leap year handling
- Year boundary transitions
- Variable cycle lengths (21-35 days)
- Fertile window calculations
- Period duration computation

### **Integration Tests:**
- DataStorage persistence and retrieval
- Encryption/decryption verification
- UI component interactions

---

## 10. SCALABILITY CONSIDERATIONS

### **Current Design Supports:**
- ✅ Unlimited historical period entries
- ✅ Custom cycle length tracking
- ✅ Multiple cycle analysis
- ✅ Data export functionality

### **Future Enhancements:**
- Symptom logging (mood, flow intensity, etc.)
- Medication/supplement tracking
- Cloud sync with Firebase
- Machine learning for prediction accuracy
- Backup/restore functionality

---

## 11. SECURITY ARCHITECTURE

### **Data Protection:**
1. **Encrypted Storage:** EncryptedSharedPreferences with AES-256
2. **No Network Traffic:** All data stored locally
3. **Permission Minimalism:** Only necessary permissions requested
4. **Secure Deletion:** When user clears data

### **Privacy by Design:**
- No user tracking
- No analytics by default
- No third-party SDK dependencies
- Transparent data handling

---

## SUMMARY

The Period Tracker architecture follows:
- ✅ **Separation of Concerns** (UI, Business Logic, Data)
- ✅ **Immutability** (LocalDate objects)
- ✅ **Error Handling** (Comprehensive validation)
- ✅ **Security** (Encrypted storage)
- ✅ **Testability** (Pure calculation functions)
- ✅ **Maintainability** (Clear class responsibilities)

This design allows for easy testing, future enhancements, and confident maintenance! 🎯
