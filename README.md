# 🔋 Li-Ion Battery Pack Modeling and Simulation using MATLAB/Simulink for Electric Vehicles


This project models a **48V / 35Ah Lithium-Ion NMC battery pack** using MATLAB/Simulink. The model is based on a **1RC equivalent circuit** and estimates the **State of Charge (SOC)** using the **Coulomb Counting method**, with optional **OCV vs SOC correction** logic. It simulates terminal voltage, transient behavior, and SOC dynamics under various load profiles, making it suitable for electric vehicle (EV) applications.

---

## 🔢 SOC Estimation – Coulomb Counting

This model estimates the **State of Charge (SOC)** of the battery using the **Coulomb Counting method**, which integrates the battery current over time:

**SOC(t) = SOC_initial − (1 / Q_pack) * ∫ i(t) dt**


- `SOC_initial` = Initial state of charge  
- `Q_pack` = Battery pack capacity in Ah  
- `i(t)` = Battery current (positive for discharge) <br>

**Note:** To avoid unrealistic values, SOC is limited between 0 and 1 using a saturation block.

---

## 🔌 NMC Cell Voltage Specifications

| Parameter                   | Typical Value                    |
|----------------------------|----------------------------------|
| Nominal Voltage            | 3.7 V                      |
| Fully Charged Voltage (100% SOC) |4.20 V              |
| Minimum Voltage (0% SOC)   | 3.0 V                      |
| Safe Operating Range       | 3.0V – 4.2 V                      |

> ℹ️ Most BMS systems restrict max voltage to 4.15V and min to 3.0V to extend battery life.

---

## ⚙️ Battery Pack Configuration

- **Chemistry**: Li-ion NMC  
- **Cell Specs**: 3.7V / 3.2Ah  
- **Configuration**: 13S11P (13 cells in series, 11 in parallel)  
- **Total Voltage**: ~48.1V  
- **Total Capacity**: ~35.2Ah  
- **Total Cells**: 143

---

## 📌 Project Objectives

- 🧩 Model a Li-ion cell using a 1RC electrical equivalent circuit  
- ⚡ Simulate battery voltage response under dynamic load conditions  
- 🔋 Estimate SOC using Coulomb Counting  
- 📉 Integrate OCV vs SOC curve for realistic voltage behavior and SOC correction  
- 🔁 Scale the model to represent a full 48V / 35Ah battery pack  
- 🚗 Simulate EV drive cycles and explore BMS algorithms

---

## 🛠️ Tools & Technologies

- MATLAB R2021b or newer  
- Simulink  
- Simscape  
- Simscape Electrical

---

## 🔍 Model Overview

The simulation includes:

- Open Circuit Voltage Source (**Voc_pack**)  
- Internal Resistance (**Rs_pack**)  
- RC Network (**R1_pack–C1_pack**)  
- Load current source  
- SOC estimation block (Coulomb Counting)  
- Optional **OCV vs SOC Lookup Table** for voltage correction and health estimation  
- Scopes for monitoring voltage and SOC

**Model Topology:**

Voc_pack → Rs_pack → [R1_pack || C1_pack] → Load

---

## 📊 OCV vs SOC Implementation

A 1-D lookup table is included to map SOC to Open Circuit Voltage based on typical NMC chemistry. This helps improve accuracy during idle/rest periods or in hybrid estimation models.

**Sample Lookup Table:**

`SOC_lookup = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];` <br>
`OCV_lookup = [3.0 3.3 3.5 3.6 3.65 3.7 3.75 3.8 3.85 3.9 4.2]; % in Volts` <br>
`OCV_pack = OCV_lookup * 13; % Scaled for 13 series cells`

Used a **Lookup Table block** in Simulink to map SOC to OCV dynamically.

---

## 📈 Output Samples

- **SOC vs Time**  
  ![SOC vs Time](Results/soc_plot.png)

- **Terminal Voltage vs Time**  
  _(Plot/image will be added Soon)_

- **OCV vs SOC**  
   _(Plot/image will be added Soon)_

- **Transient Voltage Response under Pulsed Load**  
   _(Plot/image will be added Soon)_

- **Estimated vs Actual Voltage**  
  _(Plot/image will be added Soon)_

---

## ▶️ How to Run the Project

1. Open MATLAB  
2. Run the parameter script:  
   ```matlab
   battery_parameters

3.Open the Simulink model:
  open_system('battery_sim.slx')

4.Click Run

5.View results on Scope blocks or export data using To Workspace blocks

---

 ## 🚀 Future Enhancements

🔁 Implement Kalman Filter for robust SOC estimation

🌡️ Add thermal model and temperature effects

📉 Add real EV drive cycles (WLTP, FTP, UDDS) as input

🧠 Simulate fault conditions for BMS development

📊 Parameterize for other chemistries (LFP, LCO, etc.)

---

## 💬 Contributionst 
Have ideas or improvements? Feel free to fork, raise issues, or submit pull requests.

---

## 📄 Licenset 
This project is open-source under the MIT License.


---

## 👨‍💻 Author

**Rohit Kumar Rai**  
**Software Test Analyst**  <br>
*EV Tech & Model-Based Design Enthusiast*  <br>
🌐 [Portfolio Website](https://rohit-rai-auto-test-twz4lnq.gamma.site/) | 🔗 [LinkedIn](https://www.linkedin.com/in/rohitrai5584/)
