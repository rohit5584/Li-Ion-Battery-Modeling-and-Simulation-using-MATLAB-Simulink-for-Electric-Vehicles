# 🔋  Li-Ion Battery Pack Modeling and Simulation using MATLAB/Simulink for Electric Vehicles

This project models a **48V / 35Ah Lithium-Ion NMC battery pack** using MATLAB/Simulink. The model is based on a **1RC equivalent circuit** and estimates the **State of Charge (SOC)** using the **Coulomb Counting method**, with optional **OCV vs SOC correction** logic. It simulates terminal voltage, transient behavior, and SOC dynamics under various load profiles, making it suitable for electric vehicle (EV) applications.

---

## SOC Estimation – Coulomb Counting

This model estimates the **State of Charge (SOC)** using the **Coulomb Counting method**, which integrates the battery current over time:

**SOC(t) = SOC_initial − (1 / (Q_pack × 3600)) × ∫ i(t) dt**

Where:
- `SOC_initial` = Initial state of charge (0 to 1)
- `Q_pack` = Battery pack capacity (35.2 Ah)
- `i(t)` = Battery current in Amperes (positive for discharge)
- `3600` = Conversion factor (Ah to As - Coulombs)

**Implementation:** The integration is performed using a Simulink Integrator block with saturation limits (0 to 1).

> **Note:** To avoid unrealistic values, SOC is clamped between 0 and 1 using a saturation block in Simulink.

---

##  NMC Cell Voltage Specifications

| Parameter                   | Typical Value                    |
|----------------------------|----------------------------------|
| Nominal Voltage            | 3.7 V                      |
| Fully Charged Voltage (100% SOC) |4.20 V              |
| Minimum Voltage (0% SOC)   | 3.0 V                      |
| Safe Operating Range       | 3.0V – 4.2 V                      |

>  Most BMS systems restrict max voltage to 4.15V and min to 3.0V to extend battery life.

---

##  Battery Pack Configuration

- **Chemistry**: Li-ion NMC  
- **Cell Specs**: 3.7V / 3.2Ah  
- **Configuration**: 13S11P (13 cells in series, 11 in parallel)  
- **Nominal Voltage**: ~48.1V 
- **Max Voltage (100% SOC)**: 54.6V  
- **Min Voltage (0% SOC)**: 39.0V
- **Total Capacity**: ~35.2Ah  
- **Total Cells**: 143

###  Electrical Parameters (1RC Equivalent Circuit Model)

| Parameter | Cell Value | Pack Value | Description |
|-----------|-----------|------------|-------------|
| **Rs** (Series Resistance) | 0.015 Ω | **0.0177 Ω** | Internal ohmic resistance |
| **R1** (RC Resistance) | 0.005 Ω | **0.0059 Ω** | Polarization resistance |
| **C1** (RC Capacitance) | 1000 F | **846.15 F** | Polarization capacitance |
| **τ (Time Constant)** | R1×C1 = 5s | R1×C1 = 5s | RC transient response time |

**Pack Parameter Calculation:**
- **Series Resistance**: Rs_pack = (Rs_cell / N_parallel) × N_series = (0.015/11) × 13 = **0.0177 Ω**
- **RC Resistance**: R1_pack = (R1_cell / N_parallel) × N_series = (0.005/11) × 13 = **0.0059 Ω**
- **RC Capacitance**: C1_pack = (C1_cell × N_parallel) / N_series = (1000×11) / 13 = **846.15 F**

###  Voltage Drop Analysis

**Terminal Voltage Calculation:**
```
V_terminal = V_oc - V_Rs - V_RC
```

**Example: 10A Discharge**
- **OCV** (at 100% SOC): 54.6V
- **Resistive Drop** (Rs): 0.0177Ω × 10A = **0.177V**
- **RC Drop** (transient): ~0.059V (R1 × I)
- **Total Drop**: ~0.24V
- **Terminal Voltage**: 54.6V - 0.24V ≈ **54.36V**

> **Note:** The voltage drop in this model is minimal (~0.24V) because the internal resistance is very low (0.0177Ω). In real-world batteries with higher degradation or at higher discharge rates (>1C), voltage drops would be significantly larger (5-10V).

---

##  Project Objectives

-  Model a Li-ion cell using a 1RC electrical equivalent circuit  
-  Simulate battery voltage response under dynamic load conditions  
-  Estimate SOC using Coulomb Counting  
-  Integrate OCV vs SOC curve for realistic voltage behavior and SOC correction  
-  Scale the model to represent a full 48V / 35Ah battery pack  
-  Simulate EV drive cycles and explore BMS algorithms

---

##  Tools & Technologies

- **MATLAB** R2021b or newer  
- **Simulink**  
- **Simscape** (optional for advanced models)
- **Simscape Electrical** (optional)

---

##  Model Overview

### Simulink Model Structure

The `battery_sim.slx` model contains the following blocks:

1. **Input Block**: Constant current source (`load_current = 10A`)
2. **SOC Calculation**: 
   - Gain block: `-1/(Q_pack × 3600)`
   - Integrator with initial condition (`SOC_initial = 1.0`)
   - Saturation block (limits: 0 to 1)
3. **OCV Lookup**: 1-D lookup table mapping SOC → Open Circuit Voltage
4. **Voltage Drop Calculation**:
   - Series resistance drop: `V_Rs = Rs_pack × I`
   - RC network: Transfer function `R1/(R1×C1×s + 1)`
5. **Terminal Voltage**: `V_terminal = V_oc - V_Rs - V_RC`
6. **Output Ports**: SOC and V_terminal (with signal logging enabled)

**Signal Flow Diagram:**
```
Load_Current (10A)
      ↓
      ├──→ [Gain: -1/(Q×3600)] → [Integrator] → [Saturation 0-1] → SOC
      │                                                   ↓
      │                                          [1-D OCV Lookup] → V_oc
      │                                                   ↓
      ├──→ [Gain: Rs_pack] ────────────────────→ [Sum Block (+--)] → V_terminal
      │                                                   ↑
      └──→ [Transfer Fcn: R1/(R1×C1×s+1)] ──────────────┘
                  (RC Network)
```

**Model Topology (Electrical Circuit):**
```
    +─────Rs_pack─────┬─────R1_pack─────┬─────+
    │                 │                 │     │
V_oc               Load              C1_pack  V_terminal
    │                 │                 │     │
    +─────────────────┴─────────────────┴─────+
```

###  MATLAB Scripts Included

| File Name | Description |
|-----------|-------------|
| `battery_parameters.m` | Defines all battery parameters (capacity, resistance, OCV table) |
| `battery_model.m` | Runs Simulink simulation and generates SOC/Voltage plots |
| `battery_soc_estimation.m` | Pure MATLAB implementation of Coulomb Counting for comparison |
| `create_battery_sim.m` | Auto-generates the Simulink model programmatically |
| `battery_sim.slx` | Simulink model (generated by create_battery_sim.m) |

---

## 📊 OCV vs SOC Implementation

A 1-D lookup table is included to map SOC to Open Circuit Voltage based on typical NMC chemistry. This helps improve accuracy during idle/rest periods or in hybrid estimation models.

**Lookup Table (from battery_parameters.m):**

| SOC (%) | Cell OCV (V) | Pack OCV (V) |
|---------|--------------|--------------|
| 0%      | 3.00         | 39.0         |
| 10%     | 3.30         | 42.9         |
| 20%     | 3.50         | 45.5         |
| 30%     | 3.60         | 46.8         |
| 40%     | 3.65         | 47.5         |
| 50%     | 3.70         | 48.1         |
| 60%     | 3.75         | 48.8         |
| 70%     | 3.80         | 49.4         |
| 80%     | 3.85         | 50.1         |
| 90%     | 3.90         | 50.7         |
| 100%    | 4.20         | 54.6         |

**Code Implementation:**
```matlab
SOC_lookup = [0.0  0.1  0.2  0.3  0.4  0.5  0.6  0.7  0.8  0.9  1.0];
OCV_cell   = [3.0  3.3  3.5  3.6  3.65  3.7  3.75  3.8  3.85  3.9  4.2];
OCV_pack   = OCV_cell * N_series;  % Scaled for 13 series cells
```

> **Note:** Pack voltage = Cell voltage × 13 (series configuration)

---

##  Simulation Results
![Battery SOC Estimation using Coulomb Counting - 48V 35Ah NMC Pack](Results/Combined%20graph%20of%20Load%20current%2CSOC%2CTerminal%20voltage%20vs%20Time%20graph.png)
### Test Scenario
- **Initial SOC**: 100% (Fully Charged)
- **Load Profile**: 
  - 0-100s: 0A (Idle/Rest)
  - 100-600s: 10A (Constant Discharge)
- **Duration**: 10 minutes (600 seconds)
- **Discharge Period**: 500 seconds at 10A
![Load Current vs Time](Results/Load%20current%20vs%20time%20Plot.png)

### 1. SOC vs Time (Coulomb Counting)
- **Initial SOC**: 100%
- **Load Start**: 10A discharge begins at t=100s
- **Final SOC**: ~96% after 500 seconds of discharge
- **SOC Loss**: 4% (mathematically verified)
- **Behavior**: Smooth linear decline during discharge, flat during idle period ✓

![SOC vs Time](Results/SOC%20vs%20Time%20plot.png)

**Mathematical Verification:**
```
Charge Discharged = 10A × 500s / 3600 = 1.39 Ah
SOC Loss = (1.39 Ah / 35.2 Ah) × 100 = 3.95% ≈ 4%
Final SOC = 100% - 4% = 96% ✓
```

### 2. Terminal Voltage vs Time
- **No-Load Voltage** (0-100s): ~54.6V (OCV at 100% SOC)
- **Load Applied** (100s): Small voltage drop (~0.24V)
- **Under 10A Load** (100-600s): ~54.3V → ~52V
- **Voltage Drop**: Minimal due to low internal resistance (Rs = 0.0177Ω)
- **Behavior**: Gradual decrease following SOC decline ✓

![Terminal Voltage vs Time](Results/Battery%20SOC%20and%20terminal%20Voltage%20during%20discharge%20with%20time.png)

**Voltage Drop Components:**
- **Instant Drop** (Rs): 0.0177Ω × 10A = 0.177V
- **Transient Drop** (RC): ~0.059V (settles in ~5s)
- **Total Instant Drop**: ~0.24V
- **Gradual Drop**: ~2V over 500s due to SOC decrease (OCV curve)

### 3. Combined Plot (SOC + Voltage)
- **Dual Y-axis visualization** showing correlation
- **Left axis**: SOC (%) - Blue curve
- **Right axis**: Terminal Voltage (V) - Red curve
- **Time Range**: 0-10 minutes
- **Observation**: Voltage drop mirrors SOC decline

![Battery SOC and Terminal Voltage](Results/Battery%20SOC%20and%20terminal%20Voltage%20during%20discharge%20with%20time.png)

### 4. Key Performance Metrics

| Metric | Value | Notes |
|--------|-------|-------|
| **Initial SOC** | 100% | Fully charged |
| **Final SOC** | 96% | After 500s at 10A |
| **SOC Loss** | 4% | Matches Coulomb Counting calculation ✓ |
| **Energy Discharged** | 1.39 Ah | ~75 Wh @ 54V average |
| **Discharge Rate** | 0.28C | Slow discharge (10A / 35.2Ah) |
| **Voltage Stability** | Excellent | Only 2.6V drop over 500s |
| **Rs Voltage Drop** | 0.177V | Very low due to parallel cells |
| **RC Time Constant** | 5 seconds | Fast transient response |

> **Important Note:** The minimal voltage drop (~2.6V) is due to the very low pack resistance (0.0177Ω) achieved through 11 parallel cells. In real-world applications with higher discharge rates (1C-3C), aged batteries, or fewer parallel cells, voltage drops can be 5-15V or more.

---

## ▶️ How to Run the Project

###  File Structure
```
📁 Project Root
├── 📄 battery_parameters.m          # Battery specs & electrical parameters
├── 📄 battery_model.m               # Main Simulink simulation script
├── 📄 battery_soc_estimation.m      # MATLAB-only Coulomb Counting implementation
├── 📄 create_battery_sim.m          # Auto-generates Simulink model
├── 📄 battery_sim.slx               # Simulink model (auto-generated)
├── 📄 README.md                     # Project documentation
└── 📁 Results/                      # Output plots and data
```

### Method 1: Auto-Generate Model (Recommended )

1. **Open MATLAB** and navigate to project folder
2. **Create the Simulink model automatically:**
   ```matlab
   create_battery_sim
   ```
   This will generate `battery_sim.slx` with all blocks and connections.

3. **Run the simulation:**
   ```matlab
   battery_model
   ```
   This will:
   - Load parameters
   - Run 600-second simulation
   - Generate SOC and Voltage plots

4. **View generated plots** (SOC and Voltage vs Time)

### Method 2: MATLAB-Only Simulation (Quick Analysis)

Run the pure MATLAB script for fast analysis without Simulink:
```matlab
battery_soc_estimation
```
This generates similar plots using numerical integration in MATLAB.

### Method 3: Manual Simulink Workflow

1. **Load parameters:**
   ```matlab
   battery_parameters
   ```

2. **Open Simulink model:**
   ```matlab
   open_system('battery_sim.slx')
   ```

3. **Click Run ▶️** in Simulink toolbar

4. **View results:**
   - Check Scope blocks in model
   - Or access data from MATLAB workspace: `simOut.logsout`

---

##  Model Validation

### Test Cases

| Test Case | Load Profile | Expected SOC Loss | Actual Result | Status |
|-----------|--------------|-------------------|---------------|--------|
| **Idle Test** | 0A for 600s | 0% | 0% | ✅ Pass |
| **Constant Discharge** | 10A for 500s | ~4% | 3.95% | ✅ Pass |
| **Step Load Response** | 0→10A at 100s | Voltage drop ~0.24V | 0.24V | ✅ Pass |
| **SOC Saturation** | Discharge beyond 0% | Clamp at 0% | Clamped | ✅ Pass |
| **Integration Accuracy** | Coulomb counting | Match analytical | Match | ✅ Pass |

### Verification Checks
- ✅ SOC never exceeds 0-100% range (saturation working)
- ✅ Voltage stays within safe limits (39-54.6V)
- ✅ Coulomb counting math verified analytically
- ✅ No numerical instabilities or simulation crashes
- ✅ RC transient response settles in ~5s (τ = R1×C1)
- ✅ Signal logging works correctly (logsout accessible)

### Known Limitations
- ⚠️ **Single RC pair**: Real batteries may need 2-3 RC pairs for accurate modeling
- ⚠️ **Temperature effects**: Not modeled (resistance and capacity are temperature-dependent)
- ⚠️ **Aging/Degradation**: Not included (capacity fade, resistance increase over cycles)
- ⚠️ **Cell imbalance**: Assumes perfect cell matching (no balancing needed)
- ⚠️ **Self-discharge**: Not modeled (typically 2-3% per month)
- ⚠️ **Hysteresis**: OCV hysteresis during charge/discharge not captured

---

## Future Enhancements

### Advanced SOC Estimation
- Implement **Extended Kalman Filter (EKF)** for robust SOC estimation under sensor noise
- Add **Dual Extended Kalman Filter (DEKF)** for simultaneous SOC and SOH estimation
- Compare **Coulomb Counting vs EKF vs Adaptive algorithms** (accuracy, computational cost)
- Add **OCV-based SOC correction** during rest periods

### Thermal & Health Monitoring
-  Add **thermal model** (heat generation from I²R losses, cooling mechanisms)
-  Implement **State of Health (SOH)** degradation over charge/discharge cycles
-  Add **temperature-dependent** OCV curves and resistance values
-  Model thermal runaway conditions and safety limits

### Realistic Drive Cycles
-  Simulate **EV drive cycles**: WLTP, NEDC, FTP-75, UDDS, US06
-  Add **regenerative braking** (negative current, charging)
-  Test under **pulsed discharge profiles** (acceleration/deceleration patterns)
-  Compare energy consumption across different driving patterns

### Battery Management System (BMS)
-  Implement **active cell balancing** algorithms (top/bottom balancing)
-  Add **fault detection and isolation**: overcurrent, overvoltage, undervoltage, overtemperature
-  Add **safety cutoff logic** (SOC < 10%, T > 60°C, V > 4.2V per cell)
-  Log comprehensive data for **BMS validation** and HIL testing
-  Implement **power limiting** based on SOC, temperature, and C-rate

### Multi-Chemistry Support
-  Parameterize for **LFP (LiFePO4)** chemistry (flatter OCV curve)
-  Add support for **LCO, NCA** chemistries
-  Compare performance metrics across different chemistries
-  Study trade-offs: energy density vs safety vs cost vs cycle life

### Advanced Circuit Models
-  Extend to **2RC or 3RC models** for better transient accuracy
-  Add **transmission line model** for high-frequency effects
-  Include **diffusion effects** and concentration gradients
-  Model **electrode-level electrochemical processes** (optional for research)

---

## 💬 Contributions
Have ideas or improvements? Feel free to:
- Fork the repository
- Raise issues for bugs or feature requests
- Submit pull requests with enhancements
- Share feedback and suggestions

---

##  License
This project is open-source under the **MIT License**.

---

##  Author

**Rohit Kumar Rai**   <br>
**Automotive Software Test Analyst**  <br>
**EV Tech & Model-Based Design Enthusiast**  <br>
LinkedIn: https://www.linkedin.com/in/rohitrai5584/  <br>
Mail: rohitrai5584@gmail.com

### 📊 Project Statistics
- **Development Platform**: MATLAB R2021b+
- **Model Type**: 1RC Equivalent Circuit
- **Total Scripts**: 4 MATLAB files + 1 Simulink model
- **Lines of Code**: ~600+ (including comments)
- **Validation Status**: ✅ Verified with analytical calculations
- **Simulation Speed**: ~1 second for 600s real-time

---

## 📚 References

1. G. L. Plett, "Battery Management Systems, Volume I: Battery Modeling"
2. IEEE Standards for Battery Modeling (IEEE 1725, IEEE 1188)
3. SAE J2464 - Electric Vehicle Battery Abuse Testing
4. NMC Battery Datasheets (Samsung, LG Chem, Panasonic)
5. MATLAB Simscape Electrical Documentation

---

**⭐ If you find this project helpful, please consider giving it a star!**

---

*Last Updated: October 2025*  
*Version: 1.1*
