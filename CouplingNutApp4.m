classdef CouplingNutApp4 < matlab.apps.AppBase

    % Properties that correspond to app components
        properties (Access = public)
        UIFigure                   matlab.ui.Figure
        TabGroup                   matlab.ui.container.TabGroup
    
        % ---- TAB 1: INTRO ----------------------------------------------
        IntroTab                   matlab.ui.container.Tab
        IntroLeftPanel             matlab.ui.container.Panel
        AppTitle                   matlab.ui.control.Label
        DescriptionTextArea        matlab.ui.control.TextArea
        IntroRightPanel            matlab.ui.container.Panel
    
        % --- Config & Materials ---
        ConfigDropDownLabel        matlab.ui.control.Label
        ConfigDropDown             matlab.ui.control.DropDown
    
        MaterialsPanel             matlab.ui.container.Panel
        MaterialsGrid              matlab.ui.container.GridLayout
        GasketLabel                matlab.ui.control.Label
        GasketDropDown             matlab.ui.control.DropDown
        NutLabel                   matlab.ui.control.Label
        NutDropDown                matlab.ui.control.DropDown
        ConnectorLabel             matlab.ui.control.Label
        ConnectorDropDown          matlab.ui.control.DropDown
        AdaptorLabel               matlab.ui.control.Label
        AdaptorDropDown            matlab.ui.control.DropDown
        LockRingLabel              matlab.ui.control.Label
        LockRingDropDown           matlab.ui.control.DropDown
    
        % ---- Temp & Pressure ----
        TemperatureLabel           matlab.ui.control.Label
        TemperatureDropDown        matlab.ui.control.DropDown
        PressureLabel              matlab.ui.control.Label
        PressureField              matlab.ui.control.NumericEditField
    
        % ---- Geometry Panel ----
        GeometryPanel              matlab.ui.container.Panel
        GeometryGrid               matlab.ui.container.GridLayout
    
        % Geometry Inputs (required by build_geom_from_ui)
        PipelineDiameterLabel      matlab.ui.control.Label
        PipelineDiameterEditField  matlab.ui.control.NumericEditField
    
        NominalLabel               matlab.ui.control.Label
        NominalEditField           matlab.ui.control.NumericEditField
        PitchLabel                 matlab.ui.control.Label
        PitchEditField             matlab.ui.control.NumericEditField
    
        ODLabel                    matlab.ui.control.Label
        ODEditField                matlab.ui.control.NumericEditField
    
        NutLengthLabel             matlab.ui.control.Label
        NutLengthEditField         matlab.ui.control.NumericEditField
    
        GasketIDLabel              matlab.ui.control.Label
        GasketIDEditField          matlab.ui.control.NumericEditField
        GasketODLabel              matlab.ui.control.Label
        GasketODEditField          matlab.ui.control.NumericEditField
        GasketLengthLabel          matlab.ui.control.Label
        GasketLengthEditField      matlab.ui.control.NumericEditField
    
        % Connector fields
        ConnectorMeanDiaLabel          matlab.ui.control.Label
        ConnectorMeanDiaEditField      matlab.ui.control.NumericEditField
        ConnectorThicknessLabel        matlab.ui.control.Label
        ConnectorThicknessEditField    matlab.ui.control.NumericEditField
        ConnectorLengthLabel           matlab.ui.control.Label
        ConnectorLengthEditField       matlab.ui.control.NumericEditField
    
        % Adaptor fields
        AdaptorLengthLabel         matlab.ui.control.Label
        AdaptorLengthEditField     matlab.ui.control.NumericEditField
        AdaptorODLabel             matlab.ui.control.Label
        AdaptorODEditField         matlab.ui.control.NumericEditField
    
        % Lock ring fields
        LockRingMeanDiaLabel       matlab.ui.control.Label
        LockRingMeanDiaEditField   matlab.ui.control.NumericEditField
        LockRingThicknessLabel     matlab.ui.control.Label
        LockRingThicknessEditField matlab.ui.control.NumericEditField
    
        % --- Auto Fill Button ----
        AutoFillButton  matlab.ui.control.Button

        % ---- Run button ----
        RunSolverButton            matlab.ui.control.Button
    
        % ---- TAB 2: Results ----
        ResultsTab                 matlab.ui.container.Tab
        ResultsLeftPanel           matlab.ui.container.Panel
        BaselineFOSTable           matlab.ui.control.Table
        ResultsRightPanel          matlab.ui.container.Panel
        BaselineGeomTable          matlab.ui.control.Table
        ResultsBottomPanel         matlab.ui.container.Panel
        RequiredFOSLabel           matlab.ui.control.Label
        RequiredFOSEditField       matlab.ui.control.NumericEditField
        OptimizeButton             matlab.ui.control.Button
        OptimizeStatusLabel        matlab.ui.control.Label
    
        % ---- TAB 3: Optimized ----
        OptimizedTab               matlab.ui.container.Tab
        OptLeftPanel               matlab.ui.container.Panel
        OptimizedFOSTable          matlab.ui.control.Table
        OptPlotAxes                matlab.ui.control.UIAxes
        OptRightPanel              matlab.ui.container.Panel
        GeometryComparisonTable    matlab.ui.control.Table
    end

    
    properties (Access = private)
        cfg
        geom
        materials
        DeltaT
        Pmax_MPa
        lastBaselineResult
        geom_baseline
        geom_optimized
        % Optimization
        FOS_history     % vector of Fmin values
        iterCount       % iteration count
        LB              % lower bounds
        UB              % upper bounds
    end


     methods (Access = private)


        function ConfigDropDownValueChanged(app, event)
            app.cfg = app.build_cfg_from_ui();
        
            %========== Reset ALL fields to enabled first ==========
            % Nut OD/ID
            app.ODEditField.Enable = 'on';
        
            % Gasket ID normally enabled
            app.GasketIDEditField.Enable = 'on';
        
            % Connector fields
            app.ConnectorMeanDiaEditField.Enable = 'on';
            app.ConnectorThicknessEditField.Enable = 'on';
            app.ConnectorLengthEditField.Enable = 'on';
            app.ConnectorDropDown.Enable = 'on';
        
            % Adaptor OD normally disabled except config 8 (thermal case only)
            app.AdaptorODEditField.Enable = 'off';
        
            % Lock ring fields default disabled
            app.LockRingMeanDiaEditField.Enable = 'off';
            app.LockRingThicknessEditField.Enable = 'off';
            app.LockRingDropDown.Enable = 'off';
        
            %========== CASE: CONFIG 8 (external thread coupling nut) ==========
            if app.cfg.id == 8
                % Rules:
                %   ID = 0 (locked)
                %   OD = nominal (locked)
                %   Gasket ID = nominal (locked)
                %   No connector
        
      
        
                app.ODEditField.Value = app.NominalEditField.Value;
                app.ODEditField.Enable = 'off';
        
                app.GasketIDEditField.Value = app.NominalEditField.Value;
                app.GasketIDEditField.Enable = 'off';
        
                % Disable connector (8 has NONE)
                app.ConnectorMeanDiaEditField.Enable = 'off';
                app.ConnectorThicknessEditField.Enable = 'off';
                app.ConnectorLengthEditField.Enable = 'off';
                app.ConnectorDropDown.Enable = 'off';
        
                % Adaptor OD must be allowed to be custom ONLY in config 8
                app.AdaptorODEditField.Enable = 'on';
        
            end
        
            %========== CASE: CONFIG 11 (no connector) ==========
            if app.cfg.id == 11
                app.ConnectorMeanDiaEditField.Enable = 'off';
                app.ConnectorThicknessEditField.Enable = 'off';
                app.ConnectorLengthEditField.Enable = 'off';
                app.ConnectorDropDown.Enable = 'off';
            end
        
            %========== CASE: CONFIG 9 (lock ring present) ==========
            if app.cfg.id == 9
                app.LockRingMeanDiaEditField.Enable = 'on';
                app.LockRingThicknessEditField.Enable = 'on';
                app.LockRingDropDown.Enable = 'on';
            end
        
            %========== CASE: CONFIG 10 (double nut) ==========
            if app.cfg.id == 10
                % Important: Double nut requires different UI layout normally.
                % Here we only disable connector length (single connector logic).
                app.ConnectorLengthEditField.Enable = 'off';
            end
        
            % Apply temperature logic again (because config affects connector)
            TemperatureDropDownValueChanged(app, []);
        end


        function TemperatureDropDownValueChanged(app, event)
            app.cfg = app.build_cfg_from_ui();
            is_thermal = ~strcmp(app.TemperatureDropDown.Value, 'ambient');

            %=========== DEFAULT DISABLED ====================
            app.GasketLengthEditField.Enable  = 'off';
            app.AdaptorLengthEditField.Enable = 'off';
            app.AdaptorODEditField.Enable     = 'off';
            app.ConnectorLengthEditField.Enable = 'off';

            %=========== ONLY IF THERMAL CASE ================
            if is_thermal
                % Enable gasket & adaptor length for all configs
                app.GasketLengthEditField.Enable  = 'on';
                app.AdaptorLengthEditField.Enable = 'on';

                % Adaptor OD is special:
                %  - Config 8 → user custom
                %  - All else → fixed to nut ID
                if app.cfg.id == 8
                    app.AdaptorODEditField.Enable = 'on';
                else
                    app.AdaptorODEditField.Enable = 'off';
                end

                % Connector length only if configuration has a connector
                if app.cfg.has_connector
                    app.ConnectorLengthEditField.Enable = 'on';
                else
                    app.ConnectorLengthEditField.Enable = 'off';
                end
            end
        end


        function startupFcn(app)
        
            %% ============================
            %  DROPDOWNS: CONFIG + MATERIALS
            %% ============================
            app.ConfigDropDown.Items = arrayfun(@num2str,1:11,'UniformOutput',false);
            app.ConfigDropDown.Value = '1';
        
            gasketList = {'cu','al','rubber'};
            app.GasketDropDown.Items = gasketList;
        
            matList = {'x12x','x06x','x03x','x15x','bt3_1','x15x18h'};
            app.NutDropDown.Items       = matList;
            app.ConnectorDropDown.Items = [{'none'}, matList];
            app.ConnectorDropDown.Value  = 'none';
            app.AdaptorDropDown.Items   = matList;
        
            app.LockRingDropDown.Items  = [{'none'}, matList];
            app.LockRingDropDown.Value  = 'none';
        
            %% ============================
            %  TEMPERATURE + PRESSURE
            %% ============================
            app.TemperatureDropDown.Items = {'ambient','low','high'};
            app.TemperatureDropDown.Value = 'ambient';
        
            app.PressureField.AllowEmpty = 'on';
            app.PressureField.Value = [];
            app.PressureField.Placeholder = 'Enter in MPa';
        
            %% ============================
            %  GEOMETRY FIELDS: ALL EMPTY
            %% ============================
            % Helper for shorter code
            fields = {
                app.PipelineDiameterEditField,     'Pipeline diameter';
                app.NominalEditField,              'Nominal diameter (d_nom)';
                app.PitchEditField,                'Thread pitch';
                app.ODEditField,                   'Outer diameter (OD)';
                app.NutLengthEditField,            'Nut length';
                app.GasketIDEditField,             'Gasket ID';
                app.GasketODEditField,             'Gasket OD';
                app.GasketLengthEditField,         'Gasket length';
                app.ConnectorMeanDiaEditField,     'Connector mean dia';
                app.ConnectorThicknessEditField,   'Connector thickness';
                app.ConnectorLengthEditField,      'Connector length';
                app.AdaptorLengthEditField,        'Adaptor length';
                app.AdaptorODEditField,            'Adaptor OD';
                app.LockRingMeanDiaEditField,      'Lock ring mean dia';
                app.LockRingThicknessEditField,    'Lock ring thickness';
            };
        
            for i = 1:size(fields,1)
                ef = fields{i,1};
                text = fields{i,2};
        
                ef.AllowEmpty = 'on';
                ef.Value = [];
                ef.Placeholder = 'value in mm';
            end

            app.PipelineDiameterEditField.Placeholder= '3 to 30mm' ;
                app.NominalEditField.Placeholder= 'auto-recommended' ;
                app.PitchEditField.Placeholder= 'rec: 1, 1.25, 1.5' ;
                %app.ODEditField.Placeholder= 'nut outer dia' ;
                % app.NutLengthEditField.Placeholder= 'Nut length';
                % app.GasketIDEditField.Placeholder= 'Gasket ID';
                % app.GasketODEditField.Placeholder= 'Gasket OD';
                % app.GasketLengthEditField.Placeholder= 'Gasket length';
                % app.ConnectorMeanDiaEditField.Placeholder= 'Connector mean dia';
                % app.ConnectorThicknessEditField.Placeholder= 'Connector thickness';
                % app.ConnectorLengthEditField.Placeholder= 'Connector length';
                % app.AdaptorLengthEditField.Placeholder= 'Adaptor length';
                % app.AdaptorODEditField.Placeholder= 'Adaptor OD';
                % app.LockRingMeanDiaEditField.Placeholder= 'Lock ring mean dia';
                % app.LockRingThicknessEditField.Placeholder= 'Lock ring thickness';
        
            %% ============================
            %  RESULTS TAB DEFAULTS
            %% ============================
            app.RequiredFOSEditField.AllowEmpty = 'on';
            app.RequiredFOSEditField.Value = [];
            app.RequiredFOSEditField.Placeholder = 'Enter required FoS';
        
            app.OptimizeStatusLabel.Text = '';
        
            %% ============================
            %  APP DESCRIPTION
            %% ============================
            app.DescriptionTextArea.Value = {
                'Coupling Nut Joint Design Tool'
                ''
                '1. Select configuration, materials and temperature.'
                '2. Enter geometry values in the right panel.'
                '3. Press "Run Solver" to compute baseline FoS.'
                '4. If needed, set Required FoS and click "Optimize Geometry".'
            };
        
            %% ============================
            %  APPLY INITIAL UI LOCKING
            %% ============================
            ConfigDropDownValueChanged(app,[]);
            TemperatureDropDownValueChanged(app,[]);
        
        end


        function cfg = build_cfg_from_ui(app)
            id = str2double(app.ConfigDropDown.Value);
            cfg = struct();
            cfg.has_connector = true;
            cfg.has_lock_ring = false;
            cfg.double_nut = false;
            switch id
                case {1,2,3,4,5,6,7}
                    cfg.has_connector = true;
                case 8
                    cfg.has_connector = false;
                case 9
                    cfg.has_lock_ring = true; cfg.has_connector = true;
                case 10
                    cfg.double_nut = true; cfg.has_connector = true;
                case 11
                    cfg.has_connector = false;
                otherwise
                    error('Invalid config id');
            end
            cfg.id = id;
        end


        function geom = build_geom_from_ui(app)
        
            %% ============================================================
            % 1. PIPELINE DIAMETER (always required)
            %% ============================================================
            geom.pipeline_D = app.PipelineDiameterEditField.Value;
        
            %% ============================================================
            % 2. CONFIG STRUCT
            %% ============================================================
            app.cfg = app.build_cfg_from_ui();   % must return cfg.id, cfg.has_connector, cfg.has_lock_ring, cfg.double_nut
        
            %% ============================================================
            % 3. NOMINAL DIA + PITCH
            %% ============================================================
            geom.d_nom = app.NominalEditField.Value;
            geom.pitch = app.PitchEditField.Value;
        
            %% ============================================================
            % 4. NUT INNER & OUTER DIAMETER (config 8 rule)
            %% ============================================================
            if app.cfg.id == 8
                % External thread – no internal diameter
                geom.ID = 0;
                geom.OD = geom.d_nom;         % outer fixed = nominal
            else
                
                geom.ID = geom.d_nom;            
                geom.OD = app.ODEditField.Value;
                if geom.OD <= geom.d_nom
                    geom.OD = geom.d_nom + 1;   % safety fallback
                end
            end
        
            %% ============================================================
            % 5. NUT THICKNESS (auto except configs 3,8,11)
            %% ============================================================
            if app.cfg.id == 3 || app.cfg.id == 8 || app.cfg.id == 11
                geom.t_nut = NaN;
                geom.has_bearing = false;
            else
                geom.t_nut = geom.OD - geom.ID;
                geom.has_bearing = true;
            end
        
            %% ============================================================
            % 6. LENGTH + EFFECTIVE THREAD
            %% ============================================================
            geom.L     = app.NutLengthEditField.Value;
            geom.l_eff = geom.L - 2*geom.pitch;
        
            %% ============================================================
            % 7. GASKET GEOMETRY (config 8 rule)
            %% ============================================================
            if app.cfg.id == 8
                geom.gasket_ID = geom.d_nom;     % forced
                geom.gasket_OD = app.GasketODEditField.Value; 
            else
                geom.gasket_ID = app.GasketIDEditField.Value;
                geom.gasket_OD = app.GasketODEditField.Value;
            end
        
            %% ============================================================
            % 8. THERMAL CASE?
            %% ============================================================
            is_thermal = ~strcmp(app.TemperatureDropDown.Value, "ambient");
        
            %% ============================================================
            % 9. CONNECTOR GEOMETRY (config 8 & 11 have NO connector)
            %% ============================================================
            if app.cfg.has_connector
                geom.Dkm = app.ConnectorMeanDiaEditField.Value;
                geom.t_km = app.ConnectorThicknessEditField.Value;
        
                if is_thermal
                    geom.connector_length = app.ConnectorLengthEditField.Value;
                    geom.connector_OD = geom.gasket_OD;   % rule
                    geom.connector_ID = geom.pipeline_D;  % rule
                else
                    geom.connector_length = NaN;
                    geom.connector_OD = NaN;
                    geom.connector_ID = NaN;
                end
            else
                geom.Dkm = NaN; geom.t_km = NaN;
                geom.connector_length = NaN;
                geom.connector_OD = NaN;
                geom.connector_ID = NaN;
            end
        
            %% ============================================================
            % 10. ADAPTOR (only in thermal case)
            %% ============================================================
            if is_thermal
                geom.gasket_length  = app.GasketLengthEditField.Value;
                geom.adaptor_length = app.AdaptorLengthEditField.Value;
        
                if app.cfg.id == 8
                    % config 8 allows custom adaptor OD
                    geom.adaptor_OD = app.AdaptorODEditField.Value;
                else
                    geom.adaptor_OD = geom.ID;    % forced = nut ID
                end
        
                geom.adaptor_ID = geom.gasket_ID; % rule
            else
                geom.gasket_length  = NaN;
                geom.adaptor_length = NaN;
                geom.adaptor_OD     = NaN;
                geom.adaptor_ID     = NaN;
            end
        
            %% ============================================================
            % 11. LOCK RING (only config 9)
            %% ============================================================
            if app.cfg.has_lock_ring
                geom.lock_D = app.LockRingMeanDiaEditField.Value;
                geom.lock_t = app.LockRingThicknessEditField.Value;
            else
                geom.lock_D = NaN;
                geom.lock_t = NaN;
            end
        
        end

        function AutoFillButtonPushed(app, event)
            % Read pipeline diameter (user input)
            pd = app.PipelineDiameterEditField.Value;
        
            % Determine recommended nominal dia
            if pd < 6
                rec_nom = 'M14';
            elseif pd < 8
                rec_nom = 'M18';
            elseif pd < 10
                rec_nom = 'M22';
            elseif pd < 12
                rec_nom = 'M24';
            elseif pd < 16
                rec_nom = 'M30';
            elseif pd < 20
                rec_nom = 'M33';
            elseif pd < 30
                rec_nom = 'M48';
            else
                rec_nom = 'M64';
            end
        
            % Strip 'M' and update nominal field numerically
            nominal_value = str2double(rec_nom(2:end));
        
            % Populate UI
            app.NominalEditField.Value = nominal_value;
        
            % Notify user in message log or console
            disp("Recommended nominal nut diameter based on pipeline = " + rec_nom);
        end


        function materials = build_materials_from_ui(app)
            materials = struct();
            materials.gasket = app.GasketDropDown.Value;
            materials.nut = app.NutDropDown.Value;
            materials.connector = app.ConnectorDropDown.Value;
            materials.adaptor = app.AdaptorDropDown.Value;
            lr = app.LockRingDropDown.Value;
            if strcmp(lr,'none'), lrval = 'none'; else lrval = lr; end
            materials.lockring = lrval;
        end


        function [DeltaT, pressure_factor] = parse_temperature(app)
            tsel = app.TemperatureDropDown.Value;
            switch tsel
                case 'ambient'
                    DeltaT = 0; pressure_factor = 1.5;
                case 'low'
                    DeltaT = -203; pressure_factor = 1.1;
                case 'high'
                    DeltaT = -101; pressure_factor = 1.5;
                otherwise
                    DeltaT = 0; pressure_factor = 1.5;
            end
        end


        function prettyDisplayBaseline(app, result, geom)
            % pretty-print result table of FOS into the BaselineFOSTable
            % We'll collect relevant FoS fields if they exist
            keys = {
                'FOS_int_thread_YS', 'FOS_int_thread_UTS', ...
                'FOS_ext_thread_YS','FOS_ext_thread_UTS', ...
                'FOS_bearing_YS','FOS_bearing_UTS', ...
                'FOS_nut_tearing_YS','FOS_nut_tearing_UTS', ...
                'FOS_connector_YS','FOS_connector_UTS', ...
                'FOS_lockring_YS','FOS_lockring_UTS' };
            names = {};
            values = [];
            for k = 1:numel(keys)
                key = keys{k};
                if isfield(result, key)
                    names{end+1,1} = key; %#ok<AGROW>
                    val = result.(key);
                    if isempty(val), val = NaN; end
                    values(end+1,1) = double(val); %#ok<AGROW>
                end
            end
            if isempty(names)
                names = {'No FOS outputs found'}; values = NaN;
            end
            T = table(names, values, 'VariableNames', {'Metric','Value'});
            app.BaselineFOSTable.Data = T;

           % convert struct → table format
            fields = fieldnames(geom);
            vals   = struct2cell(geom);
            data   = [fields, vals];
            
            app.BaselineGeomTable.Data = data;

        end


        function prettyDisplayOptimized(app, result, geom)
            % same for optimized results
            keys = {
                'FOS_int_thread_YS', 'FOS_int_thread_UTS', ...
                'FOS_ext_thread_YS','FOS_ext_thread_UTS', ...
                'FOS_bearing_YS','FOS_bearing_UTS', ...
                'FOS_nut_tearing_YS','FOS_nut_tearing_UTS', ...
                'FOS_connector_YS','FOS_connector_UTS', ...
                'FOS_lockring_YS','FOS_lockring_UTS' };
            names = {};
            values = [];
            for k = 1:numel(keys)
                key = keys{k};
                if isfield(result, key)
                    names{end+1,1} = key; %#ok<AGROW>
                    val = result.(key);
                    if isempty(val), val = NaN; end
                    values(end+1,1) = double(val); %#ok<AGROW>
                end
            end
            if isempty(names)
                names = {'No FOS outputs found'}; values = NaN;
            end
            T = table(names, values, 'VariableNames', {'Metric','Value'});
            app.OptimizedFOSTable.Data = T;

            % display geometry as multiline text
            init = app.geom_baseline;      % you already store this somewhere
            opt  = app.geom_optimized;     % result from optimizer
            
            f_init = fieldnames(init);
            f_opt  = fieldnames(opt);
            
            % merge names (required)
            all_fields = unique([f_init; f_opt], 'stable');
            
            rows = cell(length(all_fields),3);
            
            for i = 1:length(all_fields)
                name = all_fields{i};
                rows{i,1} = name;
            
                % initial
                if isfield(init,name)
                    rows{i,2} = init.(name);
                else
                    rows{i,2} = '';
                end
            
                % optimized
                if isfield(opt,name)
                    rows{i,3} = opt.(name);
                else
                    rows{i,3} = '';
                end
            end
            
            app.GeometryComparisonTable.Data = rows;

        end


        function handleRunSolver(app, ~)
            % Called when user presses Run Solver
            try
                app.OptimizeStatusLabel.Text = '';
                app.cfg = app.build_cfg_from_ui();
                app.geom = app.build_geom_from_ui();
                app.materials = app.build_materials_from_ui();
                [app.DeltaT, pf] = app.parse_temperature();
                app.Pmax_MPa = app.PressureField.Value * pf;

                % call user's run_solver; expect struct result
                result = run_solver(app.geom, app.materials, app.DeltaT, app.Pmax_MPa, app.cfg);

                app.lastBaselineResult = result;
                app.FOS_history = []; app.iterCount = 0;

                % store baseline geom
                app.geom_baseline = app.geom;
                app.lastBaselineResult = result;

                % pretty display baseline
                app.prettyDisplayBaseline(result, app.geom);

                % move to Results tab
                app.TabGroup.SelectedTab = app.ResultsTab;
            catch ME
                uialert(app.UIFigure, sprintf('Error running solver:\n%s', ME.message), 'Solver error');
            end
        end


        function [Fmin, fos_list] = call_extract_min_fos_single(~, result)
            % wrapper for extract_min_fos if present; otherwise try to get min from table fields
            if exist('extract_min_fos','file') == 2
                [Fmin, fos_list] = extract_min_fos(result);
            else
                % fallback - find numeric fields named FOS_* and take min
                fn = fieldnames(result);
                vals = [];
                for i=1:numel(fn)
                    if startsWith(fn{i}, 'FOS_') && isnumeric(result.(fn{i}))
                        vals(end+1) = double(result.(fn{i})); %#ok<AGROW>
                    end
                end
                if isempty(vals)
                    Fmin = NaN; fos_list = [];
                else
                    Fmin = min(vals);
                    fos_list = vals;
                end
            end
        end


        function cost = objective_wrapper(app, x, geom_init, materials, DeltaT, Pmax_MPa, cfg, FOS_req)
            % objective used by fminsearch. This is an app method so it can update
            % FOS_history and iterCount for plotting

            % Evaluate bounds
            if any(x < app.LB) || any(x > app.UB)
                cost = 1e6 + sum(abs(x));
                % still record a large value to history
                app.iterCount = app.iterCount + 1;
                app.FOS_history(end+1) = NaN;
                return;
            end

            % rebuild geom
            app.geom = geom_init;
            app.geom.OD = x(1);
            app.geom.L = x(2);
            app.geom.t_km = x(3);

            app.geom.l_eff = app.geom.L - 2 * geom_init.pitch;
            if app.geom.l_eff <= 0
                cost = 1e9; app.iterCount = app.iterCount + 1; app.FOS_history(end+1) = NaN; return;
            end
            app.geom.t_nut = app.geom.OD - app.geom.ID;
            if app.geom.t_nut <= 0
                cost = 1e9; app.iterCount = app.iterCount + 1; app.FOS_history(end+1) = NaN; return;
            end
            if cfg.has_connector
                % update connector ID by thickness
                if isfield(app.geom,'connector_OD') && ~isnan(app.geom.connector_OD)
                    app.geom.connector_ID = app.geom.connector_OD - 2*app.geom.t_km;
                    if app.geom.connector_ID <= 0
                        cost = 1e9; app.iterCount = app.iterCount + 1; app.FOS_history(end+1) = NaN; return;
                    end
                end
            end

            % call solver
            try
                result = run_solver(app.geom, materials, DeltaT, Pmax_MPa, cfg);
            catch
                cost = 1e6; app.iterCount = app.iterCount + 1; app.FOS_history(end+1) = NaN; return;
            end

            [Fmin, ~] = app.call_extract_min_fos_single(result);

            if isnan(Fmin)
                cost = 1e6;
            else
                cost = max(0, FOS_req - Fmin);
            end

            % record history (store Fmin achieved this call)
            app.iterCount = app.iterCount + 1;
            app.FOS_history(end+1) = Fmin;
            % live update plot
            cla(app.OptPlotAxes);
            plot(app.OptPlotAxes, 1:numel(app.FOS_history), app.FOS_history, '-o');
            xlabel(app.OptPlotAxes, 'Optimization Call');
            ylabel(app.OptPlotAxes, 'achieved min FoS');
            grid(app.OptPlotAxes, 'on');
            drawnow;
        end


        function handleOptimize(app, ~)
            % Called when user presses Optimize Geometry button
            try
                if isempty(app.lastBaselineResult)
                    uialert(app.UIFigure, 'Run solver baseline first.', 'No baseline');
                    return;
                end

                FOS_req = app.RequiredFOSEditField.Value;
                if isempty(FOS_req) || ~isnumeric(FOS_req)
                    uialert(app.UIFigure,'Enter a valid FoS requirement','Invalid Input'); return;
                end

                % prepare baseline objects
                geom_init = app.geom;
                materials = app.materials;
                DeltaT = app.DeltaT;
                Pmax_MPa = app.Pmax_MPa;
                cfg = app.cfg;

                % define decision variables (OD, L, t_km)
                x0 = [geom_init.OD, geom_init.L, nan];
                if cfg.has_connector
                    x0(3) = geom_init.t_km;
                else
                    x0(3) = 1.0; % dummy value (not used when connector absent)
                end

                % set bounds (store in app)
                app.LB = [geom_init.d_nom*1.05, 0.5*geom_init.L, 0.5*max(1,geom_init.t_km)];
                app.UB = [geom_init.d_nom*2.0, 3.0*geom_init.L, 3.0*max(1,geom_init.t_km)];

                % reset history
                app.FOS_history = [];
                app.iterCount = 0;

                % baseline check
                [Fmin0, ~] = app.call_extract_min_fos_single(app.lastBaselineResult);
                if ~isnan(Fmin0) && (Fmin0 >= FOS_req)
                    app.OptimizeStatusLabel.Text = 'No change required (baseline meets FoS)';
                    % copy baseline into optimized tab (no change)
                    app.prettyDisplayOptimized(app.lastBaselineResult, app.geom);
                    app.TabGroup.SelectedTab = app.OptimizedTab;
                    return;
                end

                % Run fminsearch with objective that calls app.objective_wrapper
                opts = optimset('Display','iter','TolX',1e-3,'TolFun',1e-3,'MaxFunEvals',200);
                objfun = @(x) app.objective_wrapper(x, geom_init, materials, DeltaT, Pmax_MPa, cfg, FOS_req);

                % fminsearch expects finite initial x; ensure x0 in bounds
                for i=1:3
                    if x0(i) < app.LB(i), x0(i) = app.LB(i); end
                    if x0(i) > app.UB(i), x0(i) = app.UB(i); end
                end

                % call optimizer
                x_opt = fminsearch(objfun, x0, opts);

                % Rebuild geometry from x_opt
                geom_opt = geom_init;
                geom_opt.OD = x_opt(1);
                geom_opt.L = x_opt(2);
                if cfg.has_connector
                    geom_opt.t_km = x_opt(3);
                    geom_opt.connector_ID = geom_opt.connector_OD - 2*geom_opt.t_km;
                end
                geom_opt.l_eff = geom_opt.L - 2*geom_init.pitch;
                geom_opt.t_nut = geom_opt.OD - geom_opt.ID;

                % final run
                result_opt = run_solver(geom_opt, materials, DeltaT, Pmax_MPa, cfg);
                [Fmin_final, ~] = app.call_extract_min_fos_single(result_opt);
    
                % store opt geom
                app.geom_optimized = geom_opt;

                % populate optimized tab
                app.prettyDisplayOptimized(result_opt, geom_opt);

                % status message
                if ~isnan(Fmin_final) && Fmin_final >= FOS_req
                    app.OptimizeStatusLabel.Text = 'User geometry optimized — view results tab';
                else
                    app.OptimizeStatusLabel.Text = 'Optimization completed but FoS target not reached';
                end

                % switch to Optimized tab automatically
                app.TabGroup.SelectedTab = app.OptimizedTab;

            catch ME
                uialert(app.UIFigure, sprintf('Optimization error:\n%s', ME.message), 'Optimization error');
            end
        end

    end


    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)


            
            % Create UIFigure and hide until ready
            app.UIFigure = uifigure('Visible','off');
            app.UIFigure.Position = [100 100 1100 700];
            app.UIFigure.Name = 'Coupling Nut Design Tool';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [10 10 1080 680];

            % Intro Tab
            app.IntroTab = uitab(app.TabGroup, 'Title', 'Home');

            % Left panel
            app.IntroLeftPanel = uipanel(app.IntroTab);
            app.IntroLeftPanel.Position = [10 90 520 560];

            app.AppTitle = uilabel(app.IntroLeftPanel);
            app.AppTitle.FontSize = 18;
            app.AppTitle.FontWeight = 'bold';
            app.AppTitle.Position = [10 510 500 30];
            app.AppTitle.Text = 'Coupling Nut Joint Design Tool (GUI)';

            app.DescriptionTextArea = uitextarea(app.IntroLeftPanel);
            app.DescriptionTextArea.Position = [10 320 500 150];
            app.DescriptionTextArea.Editable = 'off';


            % Config dropdown
            app.ConfigDropDownLabel = uilabel(app.IntroLeftPanel);
            app.ConfigDropDownLabel.Position = [10 280 120 20];
            app.ConfigDropDownLabel.Text = 'Configuration ID';

            app.ConfigDropDown = uidropdown(app.IntroLeftPanel);
            app.ConfigDropDown.Position = [140 280 120 22];

            % ================================================================
            % MATERIALS PANEL (controls size & position)
            % ================================================================
            app.MaterialsPanel = uipanel(app.IntroLeftPanel);
            app.MaterialsPanel.Title = 'Materials';
            app.MaterialsPanel.Position = [10 90 500 170];   % <-- Width & placement controlled HERE
            
            % ===============================
            % Materials Grid *inside* panel
            % ===============================
            app.MaterialsGrid = uigridlayout(app.MaterialsPanel, [6 2]);
            app.MaterialsGrid.RowHeight = repmat({'1x'},1,6);
            app.MaterialsGrid.ColumnWidth = {'fit','1x'};
            app.MaterialsGrid.Padding = [5 5 5 5];
            % (NO .Position HERE — grid auto-fills the panel)
            
            % -------------------------------
            % Row 1: Gasket
            % -------------------------------
            app.GasketLabel = uilabel(app.MaterialsGrid);
            app.GasketLabel.Layout.Row = 1; 
            app.GasketLabel.Layout.Column = 1;
            app.GasketLabel.Text = 'Gasket';
            
            app.GasketDropDown = uidropdown(app.MaterialsGrid);
            app.GasketDropDown.Layout.Row = 1; 
            app.GasketDropDown.Layout.Column = 2;
            
            % -------------------------------
            % Row 2: Nut
            % -------------------------------
            app.NutLabel = uilabel(app.MaterialsGrid);
            app.NutLabel.Layout.Row = 2; 
            app.NutLabel.Layout.Column = 1;
            app.NutLabel.Text = 'Nut';
            
            app.NutDropDown = uidropdown(app.MaterialsGrid);
            app.NutDropDown.Layout.Row = 2; 
            app.NutDropDown.Layout.Column = 2;
            
            % -------------------------------
            % Row 3: Connector
            % -------------------------------
            app.ConnectorLabel = uilabel(app.MaterialsGrid);
            app.ConnectorLabel.Layout.Row = 3; 
            app.ConnectorLabel.Layout.Column = 1;
            app.ConnectorLabel.Text = 'Connector';
            
            app.ConnectorDropDown = uidropdown(app.MaterialsGrid);
            app.ConnectorDropDown.Layout.Row = 3; 
            app.ConnectorDropDown.Layout.Column = 2;
            
            % -------------------------------
            % Row 4: Adaptor
            % -------------------------------
            app.AdaptorLabel = uilabel(app.MaterialsGrid);
            app.AdaptorLabel.Layout.Row = 4; 
            app.AdaptorLabel.Layout.Column = 1;
            app.AdaptorLabel.Text = 'Adaptor';
            
            app.AdaptorDropDown = uidropdown(app.MaterialsGrid);
            app.AdaptorDropDown.Layout.Row = 4; 
            app.AdaptorDropDown.Layout.Column = 2;
            
            % -------------------------------
            % Row 5: Lock Ring
            % -------------------------------
            app.LockRingLabel = uilabel(app.MaterialsGrid);
            app.LockRingLabel.Layout.Row = 5; 
            app.LockRingLabel.Layout.Column = 1;
            app.LockRingLabel.Text = 'Lock ring';
            
            app.LockRingDropDown = uidropdown(app.MaterialsGrid);
            app.LockRingDropDown.Layout.Row = 5; 
            app.LockRingDropDown.Layout.Column = 2;


            % Temp & Pressure
            app.TemperatureLabel = uilabel(app.IntroLeftPanel);
            app.TemperatureLabel.Position = [10 50 80 20];
            app.TemperatureLabel.Text = 'Temperature';

            app.TemperatureDropDown = uidropdown(app.IntroLeftPanel);
            app.TemperatureDropDown.Position = [100 50 120 22];

            app.PressureLabel = uilabel(app.IntroLeftPanel);
            app.PressureLabel.Position = [260 50 60 20];
            app.PressureLabel.Text = 'MEOP';

            app.PressureField = uieditfield(app.IntroLeftPanel,'numeric');
            app.PressureField.Position = [310 50 80 22];

    
            % after creating ConfigDropDown
            app.ConfigDropDown.ValueChangedFcn = createCallbackFcn(app, @ConfigDropDownValueChanged, true);

            % after creating TemperatureDropDown
            app.TemperatureDropDown.ValueChangedFcn = createCallbackFcn(app, @TemperatureDropDownValueChanged, true);


            % Right panel
            app.IntroRightPanel = uipanel(app.IntroTab);
            app.IntroRightPanel.Position = [540 90 520 560];
                       
            % ================================================================
            % GEOMETRY PANEL
            % ================================================================
            app.GeometryPanel = uipanel(app.IntroRightPanel);
            app.GeometryPanel.Title = 'Geometry';
            app.GeometryPanel.Position = [10 10 500 525];
            
            % ------------------------------
            % Create a Grid for all geometry
            % ------------------------------
            app.GeometryGrid = uigridlayout(app.GeometryPanel, [12 2]);
            app.GeometryGrid.RowHeight = repmat({'fit'}, 1, 16);
            app.GeometryGrid.ColumnWidth = {200,260};
            app.GeometryGrid.Padding = [7 7 7 7];
            
            % -------- Row 1: Pipeline Diameter --------
            app.PipelineDiameterLabel = uilabel(app.GeometryGrid);
            app.PipelineDiameterLabel.Text = 'Pipeline Diameter';
            app.PipelineDiameterLabel.Layout.Row = 1; app.PipelineDiameterLabel.Layout.Column = 1;
            
            app.PipelineDiameterEditField = uieditfield(app.GeometryGrid,'numeric');
            app.PipelineDiameterEditField.Layout.Row = 1; app.PipelineDiameterEditField.Layout.Column = 2;
            
            % -------- Row 2: Nominal Dia --------
            app.NominalLabel = uilabel(app.GeometryGrid);
            app.NominalLabel.Text = 'Nominal Dia';
            app.NominalLabel.Layout.Row = 2; app.NominalLabel.Layout.Column = 1;
            
            app.NominalEditField = uieditfield(app.GeometryGrid,'numeric');
            app.NominalEditField.Layout.Row = 2; app.NominalEditField.Layout.Column = 2;
            
            % -------- Row 3: Pitch --------
            app.PitchLabel = uilabel(app.GeometryGrid);
            app.PitchLabel.Text = 'Thread Pitch';
            app.PitchLabel.Layout.Row = 3; app.PitchLabel.Layout.Column = 1;
            
            app.PitchEditField = uieditfield(app.GeometryGrid,'numeric');
            app.PitchEditField.Layout.Row = 3; app.PitchEditField.Layout.Column = 2;
            
            % % -------- Row 4: Custom ID --------
            % app.CustomIDLabel = uilabel(app.GeometryGrid);
            % app.CustomIDLabel.Text = 'Custom ID';
            % app.CustomIDLabel.Layout.Row = 4; app.CustomIDLabel.Layout.Column = 1;
            % 
            % app.CustomIDEditField = uieditfield(app.GeometryGrid,'numeric');
            % app.CustomIDEditField.Layout.Row = 4; app.CustomIDEditField.Layout.Column = 2;
            % 
            % -------- Row 5: Nut OD --------
            app.ODLabel = uilabel(app.GeometryGrid);
            app.ODLabel.Text = 'Nut OD';
            app.ODLabel.Layout.Row = 5; app.ODLabel.Layout.Column = 1;
            
            app.ODEditField = uieditfield(app.GeometryGrid,'numeric');
            app.ODEditField.Layout.Row = 5; app.ODEditField.Layout.Column = 2;
            
            % -------- Row 6: Nut Length --------
            app.NutLengthLabel = uilabel(app.GeometryGrid);
            app.NutLengthLabel.Text = 'Nut Length';
            app.NutLengthLabel.Layout.Row = 6; app.NutLengthLabel.Layout.Column = 1;
            
            app.NutLengthEditField = uieditfield(app.GeometryGrid,'numeric');
            app.NutLengthEditField.Layout.Row = 6; app.NutLengthEditField.Layout.Column = 2;
            
            % -------- Row 7: Gasket ID --------
            app.GasketIDLabel = uilabel(app.GeometryGrid);
            app.GasketIDLabel.Text = 'Gasket ID';
            app.GasketIDLabel.Layout.Row = 7; app.GasketIDLabel.Layout.Column = 1;
            
            app.GasketIDEditField = uieditfield(app.GeometryGrid,'numeric');
            app.GasketIDEditField.Layout.Row = 7; app.GasketIDEditField.Layout.Column = 2;
            
            % -------- Row 8: Gasket OD --------
            app.GasketODLabel = uilabel(app.GeometryGrid);
            app.GasketODLabel.Text = 'Gasket OD';
            app.GasketODLabel.Layout.Row = 8; app.GasketODLabel.Layout.Column = 1;
            
            app.GasketODEditField = uieditfield(app.GeometryGrid,'numeric');
            app.GasketODEditField.Layout.Row = 8; app.GasketODEditField.Layout.Column = 2;
            
            % -------- Row 9: Gasket Length --------
            app.GasketLengthLabel = uilabel(app.GeometryGrid);
            app.GasketLengthLabel.Text = 'Gasket Length';
            app.GasketLengthLabel.Layout.Row = 9; app.GasketLengthLabel.Layout.Column = 1;
            
            app.GasketLengthEditField = uieditfield(app.GeometryGrid,'numeric');
            app.GasketLengthEditField.Layout.Row = 9; app.GasketLengthEditField.Layout.Column = 2;
            
            % -------- Row 10: Connector Fields --------
            app.ConnectorMeanDiaLabel = uilabel(app.GeometryGrid);
            app.ConnectorMeanDiaLabel.Text = 'Connector Mean Dia';
            app.ConnectorMeanDiaLabel.Layout.Row = 10; app.ConnectorMeanDiaLabel.Layout.Column = 1;
            
            app.ConnectorMeanDiaEditField = uieditfield(app.GeometryGrid,'numeric');
            app.ConnectorMeanDiaEditField.Layout.Row = 10; app.ConnectorMeanDiaEditField.Layout.Column = 2;
            
            app.ConnectorThicknessLabel = uilabel(app.GeometryGrid);
            app.ConnectorThicknessLabel.Text = 'Connector Thickness';
            app.ConnectorThicknessLabel.Layout.Row = 11; app.ConnectorThicknessLabel.Layout.Column = 1;
            
            app.ConnectorThicknessEditField = uieditfield(app.GeometryGrid,'numeric');
            app.ConnectorThicknessEditField.Layout.Row = 11; app.ConnectorThicknessEditField.Layout.Column = 2;
            
            app.ConnectorLengthLabel = uilabel(app.GeometryGrid);
            app.ConnectorLengthLabel.Text = 'Connector Length';
            app.ConnectorLengthLabel.Layout.Row = 12; app.ConnectorLengthLabel.Layout.Column = 1;
            
            app.ConnectorLengthEditField = uieditfield(app.GeometryGrid,'numeric');
            app.ConnectorLengthEditField.Layout.Row = 12; app.ConnectorLengthEditField.Layout.Column = 2;
            
            % -------- Row 13 (new): Adaptor --------
            app.AdaptorLengthLabel = uilabel(app.GeometryGrid);
            app.AdaptorLengthLabel.Text = 'Adaptor Length';
            app.AdaptorLengthLabel.Layout.Row = 13; app.AdaptorLengthLabel.Layout.Column = 1;
            
            app.AdaptorLengthEditField = uieditfield(app.GeometryGrid,'numeric');
            app.AdaptorLengthEditField.Layout.Row = 13; app.AdaptorLengthEditField.Layout.Column = 2;
            
            app.AdaptorODLabel = uilabel(app.GeometryGrid);
            app.AdaptorODLabel.Text = 'Adaptor OD';
            app.AdaptorODLabel.Layout.Row = 14; app.AdaptorODLabel.Layout.Column = 1;
            
            app.AdaptorODEditField = uieditfield(app.GeometryGrid,'numeric');
            app.AdaptorODEditField.Layout.Row = 14; app.AdaptorODEditField.Layout.Column = 2;
            
            % -------- Row 15: Lock Ring --------
            app.LockRingMeanDiaLabel = uilabel(app.GeometryGrid);
            app.LockRingMeanDiaLabel.Text = 'Lock Ring Mean Dia';
            app.LockRingMeanDiaLabel.Layout.Row = 15; app.LockRingMeanDiaLabel.Layout.Column = 1;
            
            app.LockRingMeanDiaEditField = uieditfield(app.GeometryGrid,'numeric');
            app.LockRingMeanDiaEditField.Layout.Row = 15; app.LockRingMeanDiaEditField.Layout.Column = 2;
            
            app.LockRingThicknessLabel = uilabel(app.GeometryGrid);
            app.LockRingThicknessLabel.Text = 'Lock Ring Thickness';
            app.LockRingThicknessLabel.Layout.Row = 16; app.LockRingThicknessLabel.Layout.Column = 1;
            
            app.LockRingThicknessEditField = uieditfield(app.GeometryGrid,'numeric');
            app.LockRingThicknessEditField.Layout.Row = 16; app.LockRingThicknessEditField.Layout.Column = 2;
            
            % -------- Auto-Fill Button at bottom --------
            app.AutoFillButton = uibutton(app.GeometryPanel,'push');
            app.AutoFillButton.Text = 'Auto-Fill';
            app.AutoFillButton.Position = [140 440 60 25];
            app.AutoFillButton.ButtonPushedFcn = createCallbackFcn(app, @AutoFillButtonPushed, true);

            % Run button at bottom
            app.RunSolverButton = uibutton(app.IntroTab,'push');
            app.RunSolverButton.Position = [450 20 180 40];
            app.RunSolverButton.Text = 'Run Solver';
            app.RunSolverButton.ButtonPushedFcn = createCallbackFcn(app, @handleRunSolver, true);

            % Results tab
            app.ResultsTab = uitab(app.TabGroup, 'Title', 'Results');

            % Left panel: baseline FOS table
            app.ResultsLeftPanel = uipanel(app.ResultsTab);
            app.ResultsLeftPanel.Position = [10 10 520 640];

            app.BaselineFOSTable = uitable(app.ResultsLeftPanel);
            app.BaselineFOSTable.Position = [10 10 500 620];

            % Right panel: baseline geometry
            app.ResultsRightPanel = uipanel(app.ResultsTab);
            app.ResultsRightPanel.Position = [540 260 520 390];

            app.BaselineGeomTable = uitable(app.ResultsRightPanel);
            app.BaselineGeomTable.Position = [10 10 500 360];
            app.BaselineGeomTable.ColumnName = {'Parameter', 'Initial Value'};
            app.BaselineGeomTable.RowName = {};
            app.BaselineGeomTable.ColumnEditable = [false false];

            % Bottom panel in Results tab
            app.ResultsBottomPanel = uipanel(app.ResultsTab);
            app.ResultsBottomPanel.Position = [540 10 520 240];

            app.RequiredFOSLabel = uilabel(app.ResultsBottomPanel);
            app.RequiredFOSLabel.Position = [10 180 120 20];
            app.RequiredFOSLabel.Text = 'Required FoS';

            app.RequiredFOSEditField = uieditfield(app.ResultsBottomPanel,'numeric');
            app.RequiredFOSEditField.Position = [130 180 80 22];

            app.OptimizeButton = uibutton(app.ResultsBottomPanel,'push');
            app.OptimizeButton.Position = [350 170 150 40];
            app.OptimizeButton.Text = 'Optimize Geometry';
            app.OptimizeButton.ButtonPushedFcn = createCallbackFcn(app, @handleOptimize, true);

            app.OptimizeStatusLabel = uilabel(app.ResultsBottomPanel);
            app.OptimizeStatusLabel.Position = [10 120 480 40];
            app.OptimizeStatusLabel.Text = '';

            % Optimized tab
            app.OptimizedTab = uitab(app.TabGroup, 'Title', 'Optimized Results');

            app.OptLeftPanel = uipanel(app.OptimizedTab);
            app.OptLeftPanel.Position = [10 10 520 640];

            app.OptimizedFOSTable = uitable(app.OptLeftPanel);
            app.OptimizedFOSTable.Position = [10 250 500 380];

            app.OptPlotAxes = uiaxes(app.OptLeftPanel);
            app.OptPlotAxes.Position = [10 10 500 220];
            title(app.OptPlotAxes, 'FoS vs Optimization Iteration');

            app.OptRightPanel = uipanel(app.OptimizedTab);
            app.OptRightPanel.Position = [540 10 520 640];

            app.GeometryComparisonTable = uitable(app.OptRightPanel);
            app.GeometryComparisonTable.Position = [10 10 500 620];
            app.GeometryComparisonTable.ColumnName = {'Parameter','Initial','Optimized'};
            app.GeometryComparisonTable.RowName = {};
            app.GeometryComparisonTable.ColumnEditable = [false false false];

            % Show UIFigure
            app.UIFigure.Visible = 'on';

            % Run startup
            startupFcn(app);
        end
    end

    methods (Access = public)

        % Construct app
        function app = CouplingNutApp4

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
