# Backend Changes & Upgrades Log

**Last Updated:** April 23, 2026

---

## 🔄 Change Log

### ✅ 2026-04-23 | Dynamic Seeding Duration in lwseed Input

#### **Files Modified:**
- `BackendScripts/InfilePreparationV2.sh`

#### **Changes Made:**

##### 1. **Duration Calculation Logic** (lines 25-54)
   - Added `start_sec` — Convert StartDate to Unix timestamp
   - Added `end_sec` — Convert EndDate to Unix timestamp
   - Added `duration_hours` — Calculate simulation duration in hours
   - **Seeding Rule:**
     - If duration > 24 hours → seeding = 12 hours
     - If duration ≤ 24 hours → seeding = 6 hours

##### 2. **Seeding End Date Computation** (lines 37-44)
   - Calculate `seed_end` — StartDate + seeding_duration (in hours)
   - Extract components: `SeedYear`, `SeedMonth`, `SeedDate`, `SeedHour`, `SeedMin`
   - Uses `date` command with arithmetic for accurate datetime handling

##### 3. **Debug Output** (lines 46-48)
   - Prints simulation duration
   - Prints seeding duration
   - Prints calculated seeding end datetime
   - **Note:** Can be commented out for production

##### 4. **lwseed.in Output Modification** (lines 97-100)
   - Added new section after endDate:
     ```
     $SeedYear    # seedingEnd - [year]       (int)
     $SeedMonth   # seedingEnd - [month]      (int)
     $SeedDate    # seedingEnd - [day]        (int)
     $SeedHour $SeedMin   # seedingEnd - [hh mm]           (int)
     ```

#### **Impact:**
- ✅ Seeding duration now dynamic based on simulation period
- ✅ Long simulations (>24h) → shorter seeding (12h)
- ✅ Short simulations (≤24h) → standard seeding (6h)
- ⚠️ Requires `date` command with arithmetic support (GNU coreutils)
- ✅ Backward compatible (adds new output fields)
- 🔄 Debug output can be disabled for production

#### **Logic Flow:**
```
Input: StartDate, EndDate
   ↓
Calculate: duration_hours = (EndDate - StartDate) / 3600
   ↓
If duration > 24h:
   seed_hours = 12
Else:
   seed_hours = 6
   ↓
Calculate: SeedingEndDate = StartDate + seed_hours
   ↓
Extract: Year, Month, Day, Hour, Minute
   ↓
Write to: lwseed<request_id>.in
```

---

## 📋 Documentation Template (for future changes)

### **YYYY-MM-DD | [Feature/Enhancement/Bug Fix]**

#### **Files Modified:**
- `path/to/file.sh`
- `path/to/file.py`

#### **Changes Made:**
- **[Section]** — Description
  - Implementation detail 1
  - Implementation detail 2

#### **Impact:**
- ✅ Benefit 1
- ✅ Benefit 2
- ⚠️ Dependencies
- 🔄 Compatibility notes

---

## 📌 Quick Navigation

| Date | Change | File(s) | Status |
|------|--------|---------|--------|
| 2026-04-23 | Dynamic Seeding Duration | InfilePreparationV2.sh | ✅ Complete |

