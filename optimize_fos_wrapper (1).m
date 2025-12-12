function [geom_opt, result_opt] = optimize_fos_wrapper(geom_init, materials, DeltaT, Pmax_MPa, cfg, FOS_req)

fprintf("\n=== OPTIMIZATION WRAPPER STARTED ===\n");

%% -------------------------------------------------------
% 1) RUN BASELINE
% -------------------------------------------------------
result0 = run_solver(geom_init, materials, DeltaT, Pmax_MPa, cfg);
[Fmin0, fos_list0] = extract_min_fos(result0);

fprintf("\nBaseline min FoS = %.3f (User requirement = %.3f)\n", Fmin0, FOS_req);

if Fmin0 >= FOS_req
    fprintf("FoS requirement already satisfied. No optimization needed.\n");
    geom_opt   = geom_init;
    result_opt = result0;
    return;
end


%% -------------------------------------------------------
% 2) DEFINE DESIGN VARIABLES FOR OPTIMIZATION
% -------------------------------------------------------
% Decision vars: 
%   x(1) = nut OD
%   x(2) = nut length L
%   x(3) = connector wall thickness t_km

x0 = [geom_init.OD, geom_init.L, geom_init.t_km];

% Lower bounds (physically realistic)
LB = [
    geom_init.d_nom * 1.05          % OD must be > nominal dia
    0.5 * geom_init.L               % L must be positive
    0.5 * geom_init.t_km            % connector wall ≥ 50% current
];

% Upper bounds
UB = [
    geom_init.d_nom * 2.0           % OD up to 2× nominal
    3.0 * geom_init.L               % L up to triple
    3.0 * geom_init.t_km            % connector wall up to triple
];

opts = optimset('Display','iter','TolX',1e-3,'TolFun',1e-3);


%% -------------------------------------------------------
% 3) RUN FMINSEARCH-LIKE BRUTE SEARCH
% -------------------------------------------------------
x_opt = fminsearch(@(x) objective_fos(...
        x, geom_init, materials, DeltaT, Pmax_MPa, cfg, FOS_req, LB, UB), ...
        x0, opts);


%% -------------------------------------------------------
% 4) REBUILD GEOMETRY FROM OPTIMAL PARAMETERS
% -------------------------------------------------------
geom_opt = geom_init;

geom_opt.OD    = x_opt(1);
geom_opt.L     = x_opt(2);
geom_opt.t_km  = x_opt(3);

% Derived geometry (DO NOT optimize directly)
geom_opt.l_eff = geom_opt.L - 2 * geom_init.pitch;

% Recalculate nut wall thickness
geom_opt.t_nut = geom_opt.OD - geom_opt.ID;

% Recalculate connector ID using new thickness
geom_opt.connector_ID = geom_opt.connector_OD - 2 * geom_opt.t_km;


%% -------------------------------------------------------
% 5) FINAL RUN
% -------------------------------------------------------
result_opt = run_solver(geom_opt, materials, DeltaT, Pmax_MPa, cfg);

[Fmin_final, fos_list_final] = extract_min_fos(result_opt);

fprintf("\n=== OPTIMIZATION COMPLETE ===\n");
fprintf("Final minimum FoS = %.3f (≥ required %.3f)\n", Fmin_final, FOS_req);
fprintf("Updated geometry returned.\n");

end
