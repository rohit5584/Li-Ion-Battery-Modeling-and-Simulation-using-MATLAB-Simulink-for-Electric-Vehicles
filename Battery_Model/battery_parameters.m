%% battery_parameters.m
% Battery Pack and Cell Parameters for 48V 35Ah Li-Ion NMC Pack
% Author: Rohit Kumar Rai

%% Cell Specifications (NMC Chemistry)
cell_voltage_nominal = 3.7;        % Volts
cell_voltage_max     = 4.2;        % Fully charged voltage
cell_voltage_min     = 3.0;        % Fully discharged voltage
cell_capacity_Ah     = 3.2;        % Ah (cell capacity)

%% Pack Configuration
N_series  = 13;                    % 13 cells in series
N_parallel = 11;                   % 11 cells in parallel
Q_cell    = cell_capacity_Ah;      % Cell capacity (Ah)
Q_pack    = Q_cell * N_parallel;   % Total pack capacity (Ah)
V_pack_nominal = cell_voltage_nominal * N_series;
V_pack_max     = cell_voltage_max * N_series;
V_pack_min     = cell_voltage_min * N_series;

%% Initial Conditions
SOC_initial = 1.0;                 % Fully charged

%% 1RC Equivalent Circuit Parameters (Pack level)
Rs_cell   = 0.015;                 % Internal resistance per cell (Ohm)
R1_cell   = 0.005;                 % RC resistance per cell (Ohm)
C1_cell   = 1000;                  % RC capacitance per cell (Farad)

Rs_pack   = Rs_cell / N_parallel * N_series;    % Effective pack Rs
R1_pack   = R1_cell / N_parallel * N_series;    % Effective R1
C1_pack   = C1_cell * N_parallel / N_series;    % Effective C1

%% OCV vs SOC Lookup Table (for NMC)
SOC_lookup = [0.0  0.1  0.2  0.3  0.4  0.5  0.6  0.7  0.8  0.9  1.0];
OCV_cell   = [3.0  3.3  3.5  3.6  3.65  3.7  3.75  3.8  3.85  3.9  4.2];
OCV_pack   = OCV_cell * N_series;  % Scaled for entire pack

%% Load Profile Input (Optional placeholder)
load_current = 10;  % Constant discharge current in Amps for initial testing


% Simulation Settings
sample_time = 1;        % Sample time for simulation (s)

% Optional: Display values in Command Window
enable_display = true;  % Set to false to suppress output

if enable_display
    disp('Battery Parameters Loaded:');
    disp(['Pack Voltage: ', num2str(V_pack_nominal), ' V']);
    disp(['Pack Capacity: ', num2str(Q_pack), ' Ah']);
    disp(['SOC Initial: ', num2str(SOC_initial * 100), ' %']);
end
