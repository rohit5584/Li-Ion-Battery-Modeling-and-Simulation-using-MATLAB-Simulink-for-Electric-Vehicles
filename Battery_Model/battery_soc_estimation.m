%% battery_soc_estimation.m
% Script to simulate SOC estimation of a 48V / 35Ah Li-Ion NMC Battery Pack
% Author: Rohit Kumar Rai

clc; clear; close all;

%% Load Battery Parameters
battery_parameters;  % Load all battery and model parameters

%% Simulation Time Settings
t_end = 600;                          % Total simulation time (10 minutes)
time = 0:sample_time:t_end;           % Time vector
n_steps = length(time);

%% Define Load Current Profile
% Example: Step + Pulsed load pattern in Amperes (positive for discharge)
i_load = zeros(1, n_steps);
i_load(time >= 100 & time < 600)   = 10;   % 10 A discharge
i_load(time >= 600 & time < 1200)  = 20;   % 20 A discharge
i_load(time >= 1200 & time < 1800) = 15;   % 15 A discharge
i_load(time >= 1800 & time < 2400) = 5;    % 5 A discharge
i_load(time >= 3000 & time < 3300) = -10;  % 10 A charging pulse

%% Initialize SOC Array
SOC = zeros(1, n_steps);
SOC(1) = SOC_initial;

%% SOC Estimation Using Coulomb Counting
for k = 2:n_steps
    % Delta time
    dt = time(k) - time(k-1);
    
    % Coulomb counting: SOC(t) = SOC(t-1) - (i/Q) * dt
    SOC(k) = SOC(k-1) - (i_load(k) * dt) / Q_pack_coulombs;

    % Limit SOC between 0 and 1 (as per Saturation block)
    SOC(k) = max(0, min(1, SOC(k)));
end

%% Calculate Terminal Voltage (optional – simplified estimate)
Voc_interp = interp1(SOC_lookup, OCV_pack, SOC, 'linear', 'extrap');
V_terminal = Voc_interp - Rs_pack * i_load;

%% Plot Results

figure;
subplot(3,1,1);
plot(time, i_load, 'LineWidth', 1.5); grid on;
xlabel('Time (s)');
ylabel('Current (A)');
title('Load Current Profile');

subplot(3,1,2);
plot(time, SOC * 100, 'b', 'LineWidth', 1.5); grid on;
xlabel('Time (s)');
ylabel('SOC (%)');
title('State of Charge (SOC)');

subplot(3,1,3);
plot(time, V_terminal, 'r', 'LineWidth', 1.5); grid on;
xlabel('Time (s)');
ylabel('Terminal Voltage (V)');
title('Estimated Terminal Voltage');

sgtitle('Battery SOC Estimation using Coulomb Counting');

