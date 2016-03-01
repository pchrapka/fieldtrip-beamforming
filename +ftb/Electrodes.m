classdef Electrodes < ftb.AnalysisStep
    %Electrodes Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        elec;
        elec_aligned;
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
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % Check if we're setting up a head model from scratch
            if exist(obj.elec_aligned, 'file') && ~obj.force
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
%             cfgin = [];
%             cfgin.type = 'fiducial';
%             cfgin.files = cfg.files;
%             cfgin.stage = cfg.stage;
%             cfgin.outputfile = cfg.files.elec_aligned;
%             ftb.align_electrodes(cfgin);
            obj.align_electrodes('fiducial');
            obj.align_electrodes('fiducial',...
                    'Output',obj.elec_aligned);
            
            %% Visualization - check alignment
            h = figure;
%             cfgin = [];
%             cfgin.stage = cfg.stage;
%             cfgin.elements = {'electrodes', 'scalp'};
%             ftb.vis_headmodel_elements(cfgin);
            
            elements = {'electrodes', 'scalp'};
            obj.plot(elements);
            
            %% Interactive alignment
            prompt = 'How''s it looking? Need manual alignment? (Y/n)';
            response = input(prompt, 's');
            if isequal(response, 'Y')
                close(h);
                % Refer to http://fieldtrip.fcdonders.nl/tutorial/headmodel_eeg
%                 cfgin = [];
%                 cfgin.type = 'interactive';
%                 cfgin.files = cfg.files;
%                 cfgin.stage = cfg.stage;
%                 % Use the automatically aligned file
%                 cfgin.files.elec = obj.elec_aligned;
%                 cfgin.outputfile = obj.elec_aligned;
%                 ftb.align_electrodes(cfgin);
                obj.align_electrodes('interactive',...
                    'Input',obj.elec_aligned,...
                    'Output',obj.elec_aligned);
            end
            
            %% Visualization - check alignment
            h = figure;
%             cfgin = [];
%             cfgin.stage = cfg.stage;
%             cfgin.elements = {'electrodes', 'scalp'};
%             ftb.vis_headmodel_elements(cfgin);
            
            elements = {'electrodes', 'scalp'};
            obj.plot(elements);
        end
        
        function align_electrodes(type, varargin)
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
            elec = ftb.util.loadvar(in_file);
            % Load head model data
            hm = obj.prev.prev;
            
            switch type
                
                case 'fiducial'
                    %% Fiducial alignment
                    
                    % Load MRI data
                    if isprop(hm, 'mri_mat')
                        mri = ftb.util.loadvar(hm.mri_mat);
                    else
                        mri = ft_read_mri(hm.mri_data);
                    end
                    
                    % Get landmark coordinates
                    nas=mri.hdr.fiducial.mri.nas;
                    lpa=mri.hdr.fiducial.mri.lpa;
                    rpa=mri.hdr.fiducial.mri.rpa;
                    
                    transm=mri.transform;
                    
                    nas=ft_warp_apply(transm,nas, 'homogenous');
                    lpa=ft_warp_apply(transm,lpa, 'homogenous');
                    rpa=ft_warp_apply(transm,rpa, 'homogenous');
                    
                    % create a structure similar to a template set of electrodes
                    fid.chanpos       = [nas; lpa; rpa];       % ctf-coordinates of fiducials
                    fid.label         = {'FidNz','FidT9','FidT10'};    % same labels as in elec
                    fid.unit          = 'mm';                  % same units as mri
                    
                    % Alignment
                    cfgin               = [];
                    cfgin.method        = 'fiducial';
                    cfgin.template      = fid;                   % see above
                    cfgin.elec          = elec;
                    cfgin.fiducial      = {'FidNz','FidT9','FidT10'};  % labels of fiducials in fid and in elec
                    elec      = ft_electroderealign(cfgin);
                    
                    % Remove the fiducial labels
                    %         temp = ft_channelselection({'all','-FidNz','-FidT9','-FidT10'}, elec.label);
                    
                case 'interactive'
                    %% Interactive alignment
                    
                    vol = ftb.util.loadvar(hm.mri_headmodel);
                    
                    cfgin           = [];
                    cfgin.method    = 'interactive';
                    cfgin.elec      = elec;
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
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'electrodes'
            %
            %       can also include elements from previous stages
            %       'scalp'
            %       'brain'
            
            unit = 'mm';
            
            % Load data
            elec = ftb.util.loadvar(obj.elec_aligned);
            
            for i=1:length(elements)
                switch elements{i}
                    
                    case 'electrodes'
                        hold on;
                        
                        % Convert to mm
                        elec = ft_convert_units(elec, unit);
                        
                        % Plot electrodes
                        ft_plot_sens(elec,...
                            'style', 'sk',...
                            'coil', true);
                        %'coil', false,...
                        %'label', 'label');
                end
            end
            
            % plot previous steps
            if ~isempty(obj.prev)
                obj.prev.plot(elements);
            end
        end
    end
    
end

