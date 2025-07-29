%% Create Battery Discharge Model using Simulink (no Simscape)

clc;
bdclose all;
clear;

% Model name
modelName = 'simple_battery_model';
new_system(modelName);
open_system(modelName);

% Model settings
set_param(modelName, 'Solver', 'ode45', 'StopTime', '1000');

%%  Block Positions
x = 30; y = 30; dx = 120; dy = 80;

%% 1. Battery Voltage Source (Voc)
add_block('simulink/Sources/Constant', [modelName '/Voc'], ...
    'Value', '3.7', ...
    'Position', [x y x+50 y+30]);

%% 2. Internal Resistance (Rs)
add_block('simulink/Commonly Used Blocks/Gain', [modelName '/Rs'], ...
    'Gain', '0.01', ...
    'Position', [x+dx y x+dx+50 y+30]);

%%  3. Current Source (Load Current)
add_block('simulink/Sources/Constant', [modelName '/I_load'], ...
    'Value', '1.5', ...
    'Position', [x y+dy x+50 y+dy+30]);

%%  4. MATLAB Function Block (SOC Estimation)
add_block('simulink/User-Defined Functions/MATLAB Function', [modelName '/SOC_Estimator'], ...
    'Position', [x+2*dx y+dy x+2*dx+100 y+dy+80]);

set_param([modelName '/SOC_Estimator'], 'FunctionName', 'estimate_soc');
set_param([modelName '/SOC_Estimator'], 'MaskDisplay', 'disp(''SOC'')');

matlabFunctionCode = [
    'function soc = estimate_soc(current)\n' ...
    'persistent soc_val\n' ...
    'if isempty(soc_val)\n' ...
    '    soc_val = 1.0;\n' ...
    'end\n' ...
    'Q = 2.3 * 3600; % Capacity in Coulombs\n' ...
    'dt = 1;         % Time step in sec\n' ...
    'soc_val = soc_val - (current * dt) / Q;\n' ...
    'soc_val = min(max(soc_val, 0), 1);\n' ...
    'soc = soc_val;\n' ...
];
set_param([modelName '/SOC_Estimator'], 'MATLABFunction', matlabFunctionCode);

%%  5. Scope
add_block('simulink/Sinks/Scope', [modelName '/Scope'], ...
    'Position', [x+3*dx y+dy x+3*dx+80 y+dy+50]);

%%  Connections
add_line(modelName, 'I_load/1', 'SOC_Estimator/1');
add_line(modelName, 'SOC_Estimator/1', 'Scope/1');

%%  Save and run
save_system(modelName);
disp(" Model created: simple_battery_model.slx");