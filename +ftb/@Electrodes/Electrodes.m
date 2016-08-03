classdef Electrodes < ftb.AnalysisStep
    %Electrodes Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        elec;
        elec_aligned;
        
        % fiducial channel labels
        fid_nas;
        fid_lpa;
        fid_rpa;
        
        process_mode;
    end
    
    methods(Access = private)
        obj = process_default(obj)
        obj = process_auto(obj)
    end
    
    methods
        function obj = Electrodes(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Headmodel Object)
            %       previous analysis step - Headmodel Object
            %
            %   Config
            %   ------
            %   fiducials (cell array, optional)
            %       name value pairs for set_fiducial_channels
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
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
            
            obj.elec = '';
            obj.elec_aligned = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.Headmodel'));
            parse(p,prev);
            
            % set the previous step, aka Headmodel
            obj.prev = p.Results.prev;
        end
        
        function obj = init(obj,analysis_folder)
            %INIT initializes the output files
            %   INIT(analysis_folder)
            %
            %   Input
            %   -----
            %   analysis_folder (string)
            %       root folder for the analysis output
            
            % init output folder and files
            [obj.elec,obj.elec_aligned] = ...
                obj.init_output(analysis_folder,...
                'properties',{'elec','elec_aligned'});
            
            if isfield(obj.config,'fiducials')
                obj.set_fiducial_channels(obj.config.fiducials{:});
            end
            
            if isempty(obj.fid_nas)
                fprintf('%s: using defaults for fiducial channels\n',...
                    strrep(class(obj),'ftb.',''));
                obj.set_fiducial_channels();
            end
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            debug = false;
            
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % Check if we're setting up a head model from scratch
            if ~obj.check_file(obj.elec_aligned)
                % Return if it already exists
                fprintf('%s: skipping %s, already exists\n',...
                    strrep(class(obj),'ftb.',''), obj.elec_aligned);
                return
            end
            
            % Load electrode data
            if obj.check_file(obj.elec)
                data = ft_read_sens(obj.config.elec_orig,'senstype','eeg');
                % Ensure electrode coordinates are in mm
                data = ft_convert_units(data, 'mm'); % should be the same unit as MRI
                % Save
                save(obj.elec, 'data');
            else
                fprintf('%s: skipping ft_read_sens, already exists\n',...
                    strrep(class(obj),'ftb.',''));
            end
            
            if debug
                % plot pre-alignment
                elements = {'electrodes', 'scalp'};
                obj.plot(elements);
            end
            
            % determine process mode
            if ~isfield(obj.config, 'ft_electroderealign')
                obj.process_mode = 'auto';
            else
                obj.process_mode = 'default';
            end
            
            switch obj.process_mode
                case 'auto'
                    obj.process_auto();
                case 'default'
                    obj.process_default();
                otherwise
                    error(['ftb:' mfilename], 'unknown mode %s', obj.process_mode)
            end
        end
        
                
        function obj = set_fiducial_channels(obj, varargin)
            % sets fiducial channel names
            
            % parse inputs
            p = inputParser;
            addParameter(p,'NAS','NAS',@ischar);
            addParameter(p,'LPA','LPA',@ischar);
            addParameter(p,'RPA','RPA',@ischar);
            parse(p,varargin{:});
            
            obj.fid_nas = p.Results.NAS;
            obj.fid_lpa = p.Results.LPA;
            obj.fid_rpa = p.Results.RPA;
            
        end
        
        function align_electrodes(obj, type, varargin)
            % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
            
            % parse inputs
            p = inputParser;
            addRequired(p,'type',@ischar);
            addParameter(p,'Input',obj.elec,@ischar);
            addParameter(p,'Output',obj.elec_aligned,@ischar);
            parse(p,type,varargin{:});
            type = p.Results.type;
            in_file = p.Results.Input;
            out_file = p.Results.Output;
            
            % Load electrodes
            elecdata = ftb.util.loadvar(in_file);
            % load head model obj
            hmObj = obj.get_dep('ftb.Headmodel');
            % load mri obj
            mriObj = obj.get_dep('ftb.MRI');
            
            switch type
                
                case 'fiducial'
                    % Fiducial alignment
                    
                    [pos,names] = mriObj.get_mri_fiducials();
                    
                    % create a structure similar to a template set of electrodes
                    fid.chanpos = pos;       % ctf-coordinates of fiducials
                    % same labels as in elec, same order as in
                    % get_mri_fiducials
                    names = lower(names);
                    for i=1:length(names)
                        fid.label{i} = obj.(['fid_' names{i}]);
                    end
                    fid.unit = 'mm'; % same units as mri
                    
                    % Alignment
                    cfgin               = [];
                    cfgin.method        = 'fiducial';
                    cfgin.target        = fid; % see above
                    cfgin.elec          = elecdata;
                    % labels of fiducials in fid and in elec
                    cfgin.fiducial      = {obj.fid_nas, obj.fid_lpa, obj.fid_rpa};
                    elec      = ft_electroderealign(cfgin);
                    
                case 'interactive'
                    % Interactive alignment
                    
                    vol = ftb.util.loadvar(hmObj.mri_headmodel);
                    
                    cfgin           = [];
                    cfgin.method    = 'interactive';
                    cfgin.elec      = elecdata;
                    if isfield(vol, 'skin_surface')
                        cfgin.headshape = vol.bnd(vol.skin_surface);
                    else
                        cfgin.headshape = vol.bnd(1);
                    end
                    elec  = ft_electroderealign(cfgin);
                    
                otherwise
                    error(['ftb:' mfilename],...
                        'unknown type %s', cfg.type);
                    
            end
            
            % Save
            save(out_file, 'elec');
            
        end
        
        function channels = remove_fiducials(obj)
            % removes fiducial channels
            % returns list of channels without fiducials
            
            % load electrodes
            sens = ftb.util.loadvar(obj.elec_aligned);
            % remove fid channels
            fidch = {'all', ['-' obj.fid_nas],['-' obj.fid_lpa],['-' obj.fid_rpa]};
            channels = ft_channelselection(fidch, sens.label);
            
        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'electrodes'
            %       'electrodes-aligned'
            %       'electrodes-labels'
            %
            %       can also include elements from previous stages
            %       'scalp'
            %       'skull'
            %       'brain'
            %       'fiducials'
            
            unit = 'mm';
            
            % check if we should plot labels
            plot_labels = any(cellfun(@(x) isequal(x,'electrodes-labels'),elements));
            
            for i=1:length(elements)
                switch elements{i}
                    
                    case 'electrodes'
                        hold on;
                        
                        % Load data
                        sens = ftb.util.loadvar(obj.elec);
                        
                        % Convert to mm
                        sens = ft_convert_units(sens, unit);
                        
                        % Plot electrodes
                        if plot_labels
                            ft_plot_sens(sens,'style','ok','label','label');
                        else
                            ft_plot_sens(sens,'style','ok');
                        end
                    
                    case 'electrodes-aligned'
                        hold on;
                        
                        % Load data
                        sens = ftb.util.loadvar(obj.elec_aligned);
                        
                        % Convert to mm
                        sens = ft_convert_units(sens, unit);
                        
                        % Plot electrodes
                        if plot_labels
                            ft_plot_sens(sens,'style','ok','label','label');
                        else
                            ft_plot_sens(sens,'style','ok');
                        end
                end
            end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
    end
    
end

