# SARAT Version 3 - Official Implementation Roadmap

**Official Document**: Search and Rescue Aid Tool (SARAT) version 3 - Major model improvements and visualization additions  
**Authors**: P Vijay, TNC Karthik, Arkaprava R, M Pravallika, and D Manasa  
**Organization**: INCOIS (Indian National Centre for Ocean Information Services)

---

## Executive Summary

SARAT V3 represents a **paradigm shift** from static whole-period probability mapping to **dynamic time-evolved probability visualization**. The core innovation is interval-based particle seeding and probability calculation, which dramatically reduces search areas over time and aids operational planning.

**Key Innovation**: From sprinkled particles throughout simulation → Controlled interval-based seeding with evolving probability maps

---

## Part 1: Core Model Improvements (Backend - Leeway Model)

### **1.1 Particle Seeding Control** 🎯
**Current V2**: Particles sprinkled throughout entire simulation period
**V3 Change**: Controlled interval-based seeding

**What to Implement**:
- Modify Leeway model configuration to support seeding duration parameter
- **Seeding duration guidelines**:
  - **12 hours maximum** if simulation period > 1 day
  - **3 hours minimum** otherwise
  - Optimized to account for forecast uncertainty and time-locking
- Update `lwseed*.in` file structure to include seeding duration
- Ensure particles are only seeded within specified interval, not throughout simulation

**Why**: Allows time-evolution of probabilities instead of static maps

---

### **1.2 Probability Calculation by Intervals** 📊
**Current V2**: Single probability map for entire simulation
**V3 Change**: Time-interval-based probability calculation

**What to Implement**:
- Calculate probabilities for selected regular intervals (e.g., 24-hour chunks)
- Process particle positions ONLY within each time interval
- Generate separate probability grid for each interval
- Store interval-specific data for evolution tracking
- Default interval: 24 hours (daily snapshots)

**Result**: Shows where object is MOST likely at each time period

---

### **1.3 Background Current Averaging** 🌊
**Current V2**: No interval-specific current averaging
**V3 Change**: Average currents for respective intervals

**What to Implement**:
- Calculate mean ocean current field for each time interval
- Use interval-averaged currents in visualizations
- Display current vectors overlay for each interval
- Helps explain particle drift in probability maps

---

### **1.4 New Uniform Grid Cells** 📐
**Current V2**: Variable probability resolution
**V3 Change**: Standardized 0.1° × 0.1° grid cells

**What to Implement**:
- Define global uniform grid with 0.1° resolution
- Bin all probability data into these cells
- Calculate probability percentage per cell
- Maintain grid consistency across all intervals
- Grid metadata: cell indices, boundaries, counts

---

### **1.5 Maximum Search Area Bounding Box** 📦
**Current V2**: Large overall search region
**V3 Change**: Interval-specific bounding boxes

**What to Implement**:
- Calculate bounding rectangle for each interval's probability cloud
- Store: bottom-left (lon, lat), top-right (lon, lat)
- Drastically reduces search area over time
- Output to `bounding_rect_and_centroid.txt`

---

### **1.6 Centroid Tracking** 🎯
**What to Implement**:
- Calculate mean position (centroid) for each interval
- Track centroid evolution across intervals
- Plot as line showing object's probable path
- Store interval centroids for search planning

**Benefit**: Guides search assets as area evolves

---

### **1.7 Zero-Leeway Object Category** 🚨
**New Feature**: For small objects (buoys, small containers)

**What to Implement**:
- Add new object classification: "zero-leeway"
- Wind effect on zero-leeway objects = minimal
- Modify leeway parameters for this category
- Only current drift, minimal wind influence

---

### **1.8 Particle Stranding** 🏖️
**What to Implement**:
- Enable particles to strand (stop) when hitting land
- Use existing land/ocean mask (ETOPO database)
- Update particle positions to reflect stranding
- Particles don't continue drifting after grounding

---

## Part 2: Visualization Improvements (Python Frontend)

### **2.1 Last Known Position (LKP) Formatting** 📍
**Current V2**: Minimal formatting
**V3 Change**: Degree Decimal units display

**What to Implement**:
- Display LKP in Degree Decimal format (e.g., 77.5°, 15.3°)
- Support both decimal degrees and DMS (Degrees Minutes Seconds)
- Include in outputs and web interface
- Add to bulletin PDF display

---

### **2.2 Simulation Duration Display** ⏱️
**Current V2**: "Search Time" parameter
**V3 Change**: "Simulation Duration" terminology

**What to Implement**:
- Rename UI label from "Search Time" to "Simulation Duration"
- Display total simulation time period
- Show time evolution clearly in interval labels
- Example: "0-24 hrs", "24-48 hrs" instead of timestamps

---

### **2.3 Seeding Duration Visibility** 🌱
**New Feature**: Display seeding duration in outputs

**What to Implement**:
- Show seeding duration in UI and bulletins
- Example: "Particles seeded for first 12 hours"
- Explain why seeding is limited (forecast uncertainty)
- Context for operational understanding

---

### **2.4 Coastal Map Integration** 🗺️
**What to Implement**:
- Add coastline/land features to all probability maps
- Integrate topographic data (ETOPO)
- Show geography context for search operators
- Apply in:
  - Individual interval maps (PNG)
  - Combined dashboard (PNG)
  - PDF bulletins

---

### **2.5 LKP1 and LKP2 Support** 🚢
**New Feature**: Handle moving vessel scenarios

**What to Implement**:
- Support multiple LKP inputs:
  - LKP1: Position at time of loss
  - LKP2: Position of moving vessel/object
- Display both on map
- Calculate drift from LKP1 to LKP2
- Adjust seeding logic accordingly

---

### **2.6 Web Application UI Improvements** 💻
**What to Implement**:
- **Input Form Updates**:
  - Add "Seeding Duration" parameter
  - Change "Search Time" label to "Simulation Duration"
  - Support LKP1/LKP2 input fields
  - Add LKP format selector (Decimal vs DMS)

- **Output Display**:
  - Show time-evolved probability maps
  - Display interval-specific statistics
  - Interactive slider for time intervals (future enhancement)
  - Centroid evolution visualization
  - Bounding box animation

- **Information Sections**:
  - FAQ page (new)
  - Model version indicator (V2 vs V3)
  - Explanation of time evolution
  - Search area reduction over time

---

### **2.7 PDF Bulletin Enhancements** 📄
**What to Implement**:
- Display time-interval maps (not just final)
- Coastal map background
- Bounding box evolution
- Centroid trajectory
- Seeding information
- Comparison with V2 output (during transition)
- Simulation parameters display

---

## Part 3: Output Data & Storage

### **3.1 Output Files Generated**

| File | Format | Interval-Specific | Purpose |
|------|--------|-------------------|---------|
| `bounding_rect_and_centroid.txt` | CSV | ✅ Yes | Search area box + centroid per interval |
| `seeding_<start>_<end>.png` | Image | ✅ Yes | Individual interval probability map |
| `seeding_duration_<id>_combined.png` | Image | ✅ Yes | All intervals on one dashboard |
| `lkp_<id>.geojson` | GeoJSON | ❌ No | Last Known Position point |
| `trajectories_<id>.geojson` | GeoJSON | ❌ No | All particle paths |
| `meantrajectory_<id>.geojson` | GeoJSON | ❌ No | Mean drift path |

**New in V3**: Interval-specific maps showing time evolution

---

## Part 4: Operational Implementation Steps

### **Step 1: Model Modification & Recompilation** 🔧
**What Needs Changing**:
- Modify Leeway model source code to support seeding duration parameter
- Update `lwseed*.in` format to include seeding duration field
- Recompile Leeway executable with new parameters
- **Seeding Duration Rules**:
  - ✅ Max 12 hours if simulation > 1 day
  - ✅ Min 3 hours otherwise
  - ✅ Optimized for forecast uncertainty & time-locking

**Dependencies**: Access to Leeway model source code (Fortran)

---

### **Step 2: Backend Script Updates** 🐍
**InfilePreparationV2.sh** modifications:
- Add seeding duration calculation
- Update lwseed file generation
- Include seeding duration in configuration
- Validate seeding duration constraints

**leeway_probV2.f** modifications:
- Update probability calculation to be interval-specific
- Store probabilities per interval in separate arrays
- Calculate centroid for each interval
- Generate bounding boxes per interval

---

### **Step 3: Python Visualization Update** 📊
**sarat_visuals.py** modifications:
- Fix `prob_centroid()` to process ALL intervals (not just first)
- Update `plot_individual()` for interval-specific maps
- Complete `plot_combined()` function (add save statement)
- Enhance coastline/land feature display
- Improve current vector overlays

---

### **Step 4: Output & Storage** 💾
**What to Generate**:
- One PNG per interval (individual maps)
- One combined dashboard PNG
- Enhanced GeoJSON outputs
- Interval metadata in CSV
- Bounding box evolution data

---

### **Step 5: Web Application Overhaul** 🌐
**Frontend Changes**:
- Redesign input form for V3 parameters
- Change "Search Time" → "Simulation Duration"
- Add "Seeding Duration" input field
- Support LKP1/LKP2 inputs
- Display format selector (Decimal/DMS)

**Output Display**:
- Show time-interval probability maps
- Display bounding box evolution
- Centroid trajectory visualization
- Interval-specific statistics
- Comparison with V2 (during transition)

**New Pages**:
- FAQ section
- Model explanation
- Time evolution guide

---

### **Step 6: Testing & Validation** ✅
**Test Cases** (3 real maritime incidents from Oct 2024 - Oct 2025):
- **Case 1**: East coast fishing vessel (70% success rate area)
- **Case 2**: West coast human rescue (82% success rate area)
- **Case 3**: Container drift with sighted positions

**Validation Metrics**:
- Probability maps cover actual sighting locations
- Bounding box correctly encloses drift cloud
- Search area reduction over time (40-60% reduction expected)
- Centroid track aligns with most probable path

---

### **Step 7: ICG Feedback & Integration** 🤝
**Stakeholders**:
- Indian Coast Guard (ICG)
- Three Maritime Rescue Coordination Centers (MRCCs)

**Feedback Collection**:
- Online meeting with ICG & MRCCs
- Review proposed V3 improvements
- Gather operational feedback
- Implement suggestions

---

### **Step 8: Best Practices Adoption** 📚
**Reference Systems**:
- **NOAA** (National Oceanic & Atmospheric Admin, USA)
- **OCEAN-SAR** (CMCC, Mediterranean)
- **SARMAP** (RSP Company)

**Best Practices to Adopt**:
- UI/UX design patterns
- Probability visualization standards
- Search area definition methods
- Output format conventions

---

### **Step 9: Demonstration & Training** 🎓
**Pre-Deployment Activities**:
- Demonstration of V3 to stakeholders
- Comparison: V2 vs V3 outputs side-by-side
- Hands-on training for operational team
- SOP (Standard Operating Procedure) documentation

**Training Topics**:
- Understanding time-evolved probabilities
- Interval-based search planning
- New UI navigation
- Output interpretation
- Troubleshooting

---

### **Step 10: Parallel Operation & Transition** 🔄
**Duration**: 2-3 months parallel operation

**Activities**:
- Run V2 and V3 simultaneously
- Compare outputs for quality assurance
- Gather operator feedback
- Fine-tune V3 based on feedback
- Gradually shift to V3 as confidence builds

---

### **Step 11: Publication** 📝
**Final Deliverable**:
- Revise SARAT research article with V3 improvements
- Include validation results
- Document model innovations
- Submit to international peer-reviewed journal

---

## Part 5: Resource Requirements & Timeline

### **Resources Needed**
- ✅ **Dedicated Computer Scientist**: For operationalization period (~3-4 months)
- ✅ **Server Infrastructure**: Existing SARAT server can be utilized
- ✅ **Regular Feedback**: Quarterly meetings with ICG & MRCCs
- ✅ **Testing Environment**: Staging server for parallel V2/V3 testing

---

### **Expected Timeline** (Post-Development)

| Phase | Duration | Activities |
|-------|----------|-----------|
| **Model Compilation** | 1-2 weeks | Modify & recompile Leeway (Fortran) |
| **Backend Updates** | 2-3 weeks | Update bash scripts, Fortran processors |
| **Python Visualization** | 2-3 weeks | Fix bugs, implement visualization improvements |
| **Web App Overhaul** | 3-4 weeks | Frontend redesign, new UI, FAQ pages |
| **Testing & Validation** | 2-3 weeks | Case testing, operator feedback, refinement |
| **Documentation & Training** | 1-2 weeks | SOP creation, team training, demonstrations |
| **Parallel Operation** | 8-12 weeks | Run V2 & V3, gather feedback, smooth transition |
| **Operationalization** | Continuous | Regular feedback cycle (quarterly) |

**Total Estimated Timeline**: 3-4 months for full operational deployment

---

## Part 6: V3 Success Criteria & Validation

### **Model Improvements Validation**
- ✅ Particles seed only during specified interval (not throughout)
- ✅ Probabilities calculated for each interval separately
- ✅ Bounding boxes show shrinking search area over time
- ✅ Centroids track evolving search focus
- ✅ Search area reduced 40-60% compared to V2
- ✅ Zero-leeway objects handled correctly
- ✅ Particles strand on land appropriately

### **Visualization Improvements Validation**
- ✅ LKP displayed in Degree Decimal format
- ✅ Simulation duration clearly labeled
- ✅ Seeding duration visible in outputs
- ✅ Coastal maps integrated in PNG + PDF
- ✅ LKP1/LKP2 inputs supported
- ✅ Web UI intuitive for new parameters
- ✅ FAQ page complete and helpful

### **Operational Readiness**
- ✅ All test cases pass validation
- ✅ ICG feedback incorporated
- ✅ Operational team trained
- ✅ SOP documentation complete
- ✅ Parallel operation successful
- ✅ No critical issues during transition

---

## Part 7: Known Constraints & Considerations

### **Seeding Duration Optimization**
- **Challenge**: Balance seeding length with forecast uncertainty
- **Solution**: Use 12-hour max (>1 day simulation), 3-hour min otherwise
- **Rationale**: Longer seeding = more accurate initial uncertainty; shorter = accounts for forecast drift

### **Backward Compatibility**
- **Decision**: Provide V2 outputs alongside V3 during transition
- **Duration**: 2-3 months parallel operation
- **Benefit**: Stakeholders can compare and gain confidence in V3

### **Regional Customization**
- **Coastal Maps**: Different regions may need custom bathymetry/coastline data
- **Search Area Definition**: Bounding box logic may need regional tuning

### **Real-Time Data Dependency**
- Current/wind data must be available in specified format (NetCDF/GRIB)
- Forecast data quality directly impacts V3 accuracy

---

## Part 8: Real-World Validation Results

**Test Period**: October 2024 - October 2025

**East Coast Performance** (High Success Rate):
- 37/80 cases successful (70% - confirmed locations found)
- 16/80 cases failed predictions
- 43/80 cases not yet tested
- Primary incidents: Fishing vessels, maritime persons in water

**West Coast Performance** (Variable Success):
- 9/33 cases successful (82% - found)
- 24/33 cases not tested
- Primary incidents: Humans in water
- Higher percentage of untraced objects (challenging environment)

**Key Finding**: Coastal concentrations of incidents → Confirm SAR focus area

---

## Summary: What V3 Delivers

### Problem It Solves
**V2 Issue**: One large probability map for entire simulation period → Difficult to plan operations

**V3 Solution**: Time-evolved probability maps by interval → Clear, actionable search areas

### Key Benefits
1. **Drastically Reduced Search Area** → Faster, more efficient operations
2. **Clear Time Evolution** → Operators know where to search at each time step
3. **Operational Planning** → Bounding boxes guide asset deployment
4. **User-Friendly Display** → Interval maps easier to understand than static probability grids
5. **Better Outcomes** → Real-world validation shows 70-82% success rates

### For Operational Teams
- Clearer decision-making on search priority areas
- Time-based planning (search today vs. tomorrow)
- Reduced search time and resources needed
- Better allocation of maritime assets

---

## Next Steps

1. **Leeway Model Modification** - Coordinate with model developers
2. **Backend Script Updates** - Implement seeding duration logic
3. **Python Visualization Fixes** - Complete the pipeline
4. **Web App Redesign** - Update UI for new parameters
5. **Stakeholder Coordination** - Engage ICG for feedback
6. **Testing & Validation** - Use real case data
7. **Training & Documentation** - Prepare operational team
8. **Deployment** - Launch with parallel V2 operation
9. **Continuous Improvement** - Quarterly feedback cycle

---

## References & Credits

**INCOIS SARAT V3 Document**: "Search and Rescue Aid Tool (SARAT) version 3 - Major model improvements and visualization additions"

**Authors**: P Vijay, TNC Karthik, Arkaprava R, M Pravallika, D Manasa

**Organization**: Indian National Centre for Ocean Information Services (INCOIS), Ministry of Earth Sciences, Government of India

---

*Document Updated*: April 2026  
*Status*: Official V3 Implementation Roadmap  
*Based On*: INCOIS SARAT V3 Official Specification Document

