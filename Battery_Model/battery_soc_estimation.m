%% SOC Estimation using Coulomb Counting Method
% This script simulates State of Charge (SOC) based on discharge current.

clc;
clear;

%%  Load Battery Parameters

battery_parameters;  % Call the parameter file to load variables

%%  Simulation Setup

dt = 1;                             % Time step in seconds
time = 0:dt:t_sim;                  % Time vector
num_steps = length(time);

I_discharge = I_load * ones(1, num_steps);  % Constant load current (can be replaced with real data)

%%  Initialize SOC

SOC = zeros(1, num_steps);
SOC(1) = initial_SOC;              % Start from 100% or defined value

%%  Coulomb Counting Loop

for t = 2:num_steps
    delta_SOC = -(I_discharge(t) * dt) / Q_capacity;  % Discharged fraction
    SOC(t) = SOC(t-1) + delta_SOC;
    
    % Limit SOC between 0 and 1
    if SOC(t) < 0
        SOC(t) = 0;
    elseif SOC(t) > 1
        SOC(t) = 1;
    end
end

%%  Plot SOC over Time

figure;
plot(time, SOC * 100, 'LineWidth', 2);
xlabel('Time (s)');
ylabel('State of Charge (%)');
title('SOC Estimation using Coulomb Counting');
grid on;
saveas(gcf, 'Results/soc_plot.png');

disp(" SOC estimation completed and graph saved.");
