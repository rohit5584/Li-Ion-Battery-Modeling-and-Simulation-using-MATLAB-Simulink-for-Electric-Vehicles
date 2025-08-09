%% Battery Model Script - battery_model.m
% Author: Rohit Kumar Rai
% Description: Runs the simulation of a 48V 35Ah NMC battery pack using 1RC model

clc;
clear;
close all;

disp(' Running Li-Ion NMC Battery Model Simulation');

%% Load Parameters
run('battery_parameters.m');

%% Open the Simulink Model
model_name = 'battery_sim';
if ~bdIsLoaded(model_name)
    open_system(model_name);
end

%% Set Simulation Time
sim_time = 600; % in seconds, e.g., 10 Minutes
set_param(model_name, 'StopTime', num2str(sim_time));

%% Run the Simulation
disp(' Starting Simulation...');
simOut = sim(model_name);

disp('Simulation Complete');

%% Extract Output Data
time = simOut.tout;
SOC = simOut.logsout.getElement('SOC').Values.Data;
V_terminal = simOut.logsout.getElement('V_terminal').Values.Data;

%% Plot SOC vs Time
figure;
plot(time/60, SOC, 'LineWidth', 2);
xlabel('Time (minutes)');
ylabel('State of Charge (SOC)');
title('SOC vs Time');
grid on;

%% Plot Terminal Voltage vs Time
figure;
plot(time/60, V_terminal, 'LineWidth', 2);
xlabel('Time (minutes)');
ylabel('Terminal Voltage (V)');
title('Terminal Voltage vs Time');
grid on;

disp('Plots generated successfully.');

