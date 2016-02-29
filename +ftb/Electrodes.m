classdef Electrodes < ftb.AnalysisStep
    %Electrodes Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        elec;
        elec_aligned;
    end
    
    methods
        function obj = Electrodes(params,name,prev)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Headmodel Object)
            %       previous analysis step - Headmodel Object
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            addRequired(p,'prev',@(x)isa(x,'ftb.Headmodel'));
            parse(p,params,name,prev);
            
            % set vars
            obj@ftb.AnalysisStep('E');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            % set the previous step, aka headmodel
            obj.prev = p.Results.prev;
            
            obj.elec = '';
            obj.elec_aligned = '';
        end
        
        function obj = init(obj,out_folder)
            
            % parse inputs
            p = inputParser;
            addOptional(p,'out_folder','',@ischar);
            parse(p,out_folder);
            
            % check inputs
            if isempty(out_folder)
                error(['ftb:' mfilename],...
                    'please specify an output folder');
            end
            
            % Set up file names
            obj.elec = fullfile(out_folder, 'elec.mat');
            obj.elec_aligned = fullfile(out_folder, 'elec_aligned.mat');
            
            obj.state.init = true;
        end
        
        function obj = process(obj)
            if ~obj.state.init
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % Check if we're setting up a head model from scratch
            if exist(obj.elec_aligned, 'file') && ~obj.state.force
                % Return if it already exists
                fprintf('%s: skipping %s, already exists\n', mfilename, obj.elec_aligned);
                return
            end
            
            % Load electrode data
            if ~exist(obj.elec, 'file')
                data = ft_read_sens(obj.config.elec_orig);
                % Ensure electrode coordinates are in mm
                data = ft_convert_units(data, 'mm'); % should be the same unit as MRI
                % Save
                save(obj.elec, 'data');
            else
                fprintf('%s: skipping ft_read_sens, already exists\n',mfilename);
            end
            
            %% Automatic alignment
            % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
            cfgin = [];
            cfgin.type = 'fiducial';
            cfgin.files = cfg.files;
            cfgin.stage = cfg.stage;
            cfgin.outputfile = cfg.files.elec_aligned;
            ftb.align_electrodes(cfgin);
            
            %% Visualization - check alignment
            h = figure;
            cfgin = [];
            cfgin.stage = cfg.stage;
            cfgin.elements = {'electrodes', 'scalp'};
            ftb.vis_headmodel_elements(cfgin);
            
            %% Interactive alignment
            prompt = 'How''s it looking? Need manual alignment? (Y/n)';
            response = input(prompt, 's');
            if isequal(response, 'Y')
                close(h);
                % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
                cfgin = [];
                cfgin.type = 'interactive';
                cfgin.files = cfg.files;
                cfgin.stage = cfg.stage;
                % Use the automatically aligned file
                cfgin.files.elec = obj.elec_aligned;
                cfgin.outputfile = obj.elec_aligned;
                ftb.align_electrodes(cfgin);
            end
            
            %% Visualization - check alignment
            h = figure;
            cfgin = [];
            cfgin.stage = cfg.stage;
            cfgin.elements = {'electrodes', 'scalp'};
            ftb.vis_headmodel_elements(cfgin);
        end
    end
    
end

