%% battery_soc_estimation.m (FIXED)
% Script to simulate SOC estimation of a 48V / 35Ah Li-Ion NMC Battery Pack
% Author: Rohit Kumar Rai

clc; clear; close all;

%% Load Battery Parameters
battery_parameters;  % Load all battery and model parameters

%% Simulation Time Settings
t_end = 600;                          % Total simulation time (10 minutes)
time = 0:sample_time:t_end;           % Time vector
n_steps = length(time);

disp('========================================');
disp('Battery SOC Estimation - Coulomb Counting Method');
disp('========================================');
disp(['Simulation Time: ' num2str(t_end) ' seconds']);
disp(['Time Steps: ' num2str(n_steps)]);
disp(['Pack Capacity: ' num2str(Q_pack) ' Ah']);
disp('========================================');

%% Define Load Current Profile (FIXED - matching 600s time range)
% Example: Step load pattern in Amperes (positive for discharge)
i_load = zeros(1, n_steps);

% Simple profile matching the 600 second simulation
i_load(time >= 0 & time < 100)    = 0;     % 0 A (no load, idle)
i_load(time >= 100 & time <= 600) = 10;    % 10 A discharge (main load)

% Alternative: You can create different profiles like:
% i_load(time >= 100 & time < 300) = 10;   % 10 A
% i_load(time >= 300 & time < 500) = 15;   % 15 A
% i_load(time >= 500 & time <= 600) = 5;   % 5 A

%% Initialize SOC Array
SOC = zeros(1, n_steps);
SOC(1) = SOC_initial;

%% Capacity in Coulombs
Q_pack_coulombs = Q_pack * 3600;  % Convert Ah to Coulombs (As)

disp(['Starting SOC: ' num2str(SOC(1)*100) '%']);

%% SOC Estimation Using Coulomb Counting
for k = 2:n_steps
    % Delta time
    dt = time(k) - time(k-1);
    
    % Coulomb counting: SOC(t) = SOC(t-1) - (i/Q) * dt
    % Negative because discharge reduces SOC
    SOC(k) = SOC(k-1) - (i_load(k) * dt) / Q_pack_coulombs;

    % Limit SOC between 0 and 1 (as per Saturation block)
    SOC(k) = max(0, min(1, SOC(k)));
end

disp(['Final SOC: ' num2str(SOC(end)*100) '%']);
disp(['SOC Change: ' num2str((SOC(1)-SOC(end))*100) '%']);

%% Calculate Terminal Voltage (simplified 1RC estimate)
% Interpolate OCV from lookup table
Voc_interp = interp1(SOC_lookup, OCV_pack, SOC, 'linear', 'extrap');

% Terminal voltage with resistive drop only (simplified)
% V_terminal = V_oc - Rs*I (ignoring RC dynamics for simplicity)
V_terminal = Voc_interp - Rs_pack * i_load;

disp(['Initial Voltage: ' num2str(V_terminal(1)) ' V']);
disp(['Final Voltage: ' num2str(V_terminal(end)) ' V']);
disp('========================================');

%% Calculate Energy Discharged
total_charge_discharged_As = sum(i_load .* sample_time);  % Ampere-seconds
total_charge_discharged_Ah = total_charge_discharged_As / 3600;  % Ampere-hours
energy_discharged_Wh = mean(V_terminal(i_load > 0)) * total_charge_discharged_Ah;

disp(' ');
disp('Discharge Statistics:');
disp(['Total Charge Discharged: ' num2str(total_charge_discharged_Ah) ' Ah']);
disp(['Energy Discharged: ' num2str(energy_discharged_Wh) ' Wh']);
disp(['Average Discharge Voltage: ' num2str(mean(V_terminal(i_load > 0))) ' V']);
disp('========================================');

%% Plot Results

figure('Name', 'Battery SOC Estimation', 'NumberTitle', 'off', 'Position', [100 100 900 700]);

% Subplot 1: Load Current Profile
subplot(3,1,1);
plot(time, i_load, 'b-', 'LineWidth', 2); 
grid on;
xlabel('Time (s)', 'FontSize', 11);
ylabel('Current (A)', 'FontSize', 11);
title('Load Current Profile', 'FontSize', 12, 'FontWeight', 'bold');
ylim([-2 22]);
xlim([0 t_end]);

% Subplot 2: State of Charge
subplot(3,1,2);
plot(time, SOC * 100, 'r-', 'LineWidth', 2.5); 
grid on;
xlabel('Time (s)', 'FontSize', 11);
ylabel('SOC (%)', 'FontSize', 11);
title('State of Charge (SOC)', 'FontSize', 12, 'FontWeight', 'bold');
ylim([0 105]);
xlim([0 t_end]);

% Add annotations
hold on;
plot(0, SOC(1)*100, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(time(end), SOC(end)*100, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
text(50, 95, sprintf('Start: %.1f%%', SOC(1)*100), 'FontSize', 10, 'Color', 'g', 'FontWeight', 'bold');
text(time(end)-100, SOC(end)*100+5, sprintf('End: %.1f%%', SOC(end)*100), 'FontSize', 10, 'Color', 'r', 'FontWeight', 'bold');
hold off;

% Subplot 3: Terminal Voltage
subplot(3,1,3);
plot(time, V_terminal, 'k-', 'LineWidth', 2); 
grid on;
xlabel('Time (s)', 'FontSize', 11);
ylabel('Terminal Voltage (V)', 'FontSize', 11);
title('Estimated Terminal Voltage', 'FontSize', 12, 'FontWeight', 'bold');
ylim([30 60]);
xlim([0 t_end]);

% Add voltage level lines
hold on;
yline(V_pack_max, '--g', 'Max', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'bottom');
yline(V_pack_min, '--r', 'Min', 'LineWidth', 1.5, 'LabelVerticalAlignment', 'top');
hold off;

sgtitle('Battery SOC Estimation using Coulomb Counting - 48V 35Ah NMC Pack', ...
    'FontSize', 14, 'FontWeight', 'bold');

%% Additional Combined Plot
figure('Name', 'SOC and Voltage', 'NumberTitle', 'off', 'Position', [150 150 800 500]);

yyaxis left
plot(time/60, SOC * 100, 'b-', 'LineWidth', 2.5);
ylabel('SOC (%)', 'FontSize', 12, 'Color', 'b');
ylim([0 105]);

yyaxis right
plot(time/60, V_terminal, 'r-', 'LineWidth', 2);
ylabel('Terminal Voltage (V)', 'FontSize', 12, 'Color', 'r');
ylim([30 60]);

xlabel('Time (minutes)', 'FontSize', 12);
title('Battery SOC and Voltage during Discharge', 'FontSize', 14, 'FontWeight', 'bold');
grid on;
xlim([0 t_end/60]);

legend('SOC', 'Terminal Voltage', 'Location', 'best');

disp(' ');
disp('✓ Plots generated successfully');
disp('========================================');