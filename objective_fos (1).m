function cost = objective_fos(x, geom_init, materials, DeltaT, Pmax_MPa, cfg, FOS_req, LB, UB)
% OBJECTIVE_FOS
% Return cost = max(0, FOS_req - achieved_min_FOS)
% for fminsearch-based brute optimization.

x  = x(:)';     % force row vector
LB = LB(:)';    % force row vector
UB = UB(:)';    % force row vector

%% ---------------------------------------------------------
% 0) Manual bounds enforcement for fminsearch (OPTION B)
% ---------------------------------------------------------
if any(x < LB) || any(x > UB)
    % Huge penalty → forces fminsearch to stay within bounds
    cost = 1e6 + sum(abs(x));
    return;
end


%% ---------------------------------------------------------
% 1) Extract design variables
% ---------------------------------------------------------
OD    = x(1);
L     = x(2);
t_km  = x(3);   % connector wall thickness


%% ---------------------------------------------------------
% 2) Build geometry from design vars
% ---------------------------------------------------------
geom = geom_init;     % start from baseline

% Updated parameters
geom.OD   = OD;
geom.L    = L;
geom.t_km = t_km;

% Derived thread engagement length
geom.l_eff = geom.L - 2 * geom_init.pitch;
if geom.l_eff <= 0
    cost = 1e9;   % physically impossible → huge penalty
    return;
end

% Update nut thickness
geom.t_nut = geom.OD - geom.ID;
if geom.t_nut <= 0
    cost = 1e9;   % impossible wall thickness
    return;
end

% Update connector ID
if cfg.has_connector
    geom.connector_ID = geom.connector_OD - 2 * geom.t_km;
    if geom.connector_ID <= 0
        cost = 1e9;
        return;
    end
end


%% ---------------------------------------------------------
% 3) Call the solver
% ---------------------------------------------------------
result = run_solver(geom, materials, DeltaT, Pmax_MPa, cfg);

[Fmin, fos_list] = extract_min_fos(result);


%% ---------------------------------------------------------
% 4) Compute cost: how far below requirement?
% ---------------------------------------------------------
if isnan(Fmin)
    cost = 1e6;   % solver failure penalty
else
    cost = max(0, FOS_req - Fmin);
end

end
