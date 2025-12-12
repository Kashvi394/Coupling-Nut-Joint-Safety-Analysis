%% ============================================================
%  COUPLING NUT SAFETY & SIZING TOOL (Main Script)
% =============================================================
% 
clear; clc; close all;

fprintf("\n--- Coupling Nut Joint Design Tool ---\n");

%% ------------------------------------------------------------
% 1) SELECT CONFIGURATION
% -------------------------------------------------------------
config_id = input('Select configuration (1–11): ');
cfg = load_config_rules(config_id);


%% ------------------------------------------------------------
% 2) USER INPUT: MATERIALS
% -------------------------------------------------------------
fprintf("\n--- Material Selection ---\n");

%% ----------------- Gasket ------------------
gmat = lower(input('Gasket material (cu/al/rubber): ','s'));
valid_g = ["cu","al","rubber"];
while ~any(strcmp(gmat, valid_g))
    gmat = lower(input('Invalid! Choose cu/al/rubber: ','s'));
end


%% ----------------- Nut Material -----------------
valid_m = ["x12x","x06x","x03x","x15x","bt3_1","x15x18h"];

nmat = lower(input('Coupling nut material (12x/06x/03x/15x/bt3-1/15x18h): ','s'));
while ~any(strcmp(nmat, valid_m))
    nmat = lower(input('Invalid! Choose valid material: ','s'));
end


%% ----------------- Connector Material -----------------
if cfg.has_connector
    cmat = lower(input('Connector material (12x/06x/03x/15x/bt3-1/15x18h): ','s'));
    while ~any(strcmp(cmat, valid_m))
        cmat = lower(input('Invalid! Choose valid material: ','s'));
    end
else
    cmat = "none";
end


%% ----------------- Adaptor Material -----------------
amat = lower(input('Adaptor material (12x/06x/03x/15x/bt3-1/15x18h): ','s'));
while ~any(strcmp(amat, valid_m))
    amat = lower(input('Invalid! Choose valid material: ','s'));
end

%% ----------------- Lock Ring Material -----------------
if cfg.has_lock_ring
    lmat = lower(input('Lock Ring material (12x/06x/03x/15x/bt3-1/15x18h): ','s'));
    while ~any(strcmp(lmat, valid_m))
        lmat = lower(input('Invalid! Choose valid material: ','s'));
    end
else
    lmat = "none";
end

materials = struct( ...
    'gasket', gmat, ...
    'nut', nmat, ...
    'connector', cmat, ...
    'adaptor', amat, ...
    'lockring', lmat ...
);


%% ------------------------------------------------------------
% 3) USER INPUT: TEMPERATURE
% -------------------------------------------------------------
fprintf("\n--- Temperature Selection ---\n");
is_thermal_case = false;
valid = false;
while ~valid
    tsel = lower(input('Select temperature (ambient/low/high): ','s'));
    if any(strcmp(tsel, ["ambient","low","high"]))
        valid = true;
    else
        disp('Invalid — choose ambient, low or high.');
    end
end

switch tsel
    case "ambient"
        DeltaT = 0;
        pressure_factor = 1.5;
        is_thermal_case = false;    % <<<<<< HERE
    case "low"
        DeltaT = -203;
        pressure_factor = 1.1;
        is_thermal_case = true;    % <<<<<< HERE
    case "high"
        DeltaT = -101;
        pressure_factor = 1.5;
        is_thermal_case = true;    % <<<<<< HERE
end


%% ------------------------------------------------------------
% 4) USER INPUT: PRESSURE (MEOP)
% -------------------------------------------------------------
MEOP = input("\nEnter MEOP pressure [MPa]: ");
Pmax_MPa = MEOP * pressure_factor;

fprintf("Using pressure factor %.2f → Pmax = %.2f MPa\n", ...
        pressure_factor, Pmax_MPa);


%% ------------------------------------------------------------
% 5) USER INPUT: GEOMETRY (modifiable design variables)
% -------------------------------------------------------------
geom = get_user_initial_geometry2(cfg, is_thermal_case);


%% ------------------------------------------------------------
% 6) RUN SOLVER
% -------------------------------------------------------------
result = run_solver(geom, materials, DeltaT, Pmax_MPa, cfg);

FOS_req = input("Enter required factor of safety: ");

% Compute baseline minimum FoS
[Fmin0, ~] = extract_min_fos(result);


%% ------------------------------------------------------------
% 6b) RUN OPTIMIZATION ONLY IF NEEDED
% -------------------------------------------------------------
if Fmin0 >= FOS_req
    
    fprintf("\nCurrent geometry already meets safety requirements.\n");
    geom_new   = geom;     % no change
    result_new = result;   % no change

else
    
    fprintf("\nFoS requirement NOT met. Running optimization...\n");
    [geom_new, result_new] = optimize_fos_wrapper(geom, materials, DeltaT, Pmax_MPa, cfg, FOS_req);

end


%% ------------------------------------------------------------
% 7) DISPLAY RESULTS
% -------------------------------------------------------------
fprintf("\n============= RESULTS =============\n");

fprintf("Baseline FoS = %.3f (Required = %.3f)\n", Fmin0, FOS_req);

disp("BASELINE RESULTS:");
disp(result);

if Fmin0 < FOS_req
    disp("UPDATED GEOMETRY:");
    disp(geom_new);

    disp("UPDATED RESULTS:");
    disp(result_new);
else
    fprintf("Optimization skipped — baseline geometry is already safe.\n");
end

fprintf("===================================\n");

