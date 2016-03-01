classdef Headmodel < ftb.AnalysisStep
    %Headmodel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        mri_headmodel;
    end
    
    methods
        function obj = Headmodel(params,name)
            %   params (struct or string)
            %       struct or file name
            %
            %   name (string)
            %       object name
            %   prev (Object)
            %       previous analysis step
            
            % parse inputs
            p = inputParser;
            p.StructExpand = false;
            addRequired(p,'params');
            addRequired(p,'name',@ischar);
            parse(p,params,name);
            
            % set vars
            obj@ftb.AnalysisStep('HM');
            obj.name = p.Results.name;
            
            if isstruct(p.Results.params)
                % Copy config
                obj.config = p.Results.params;
            else
                % Load config from file
                din = load(p.Results.params);
                obj.config = din.cfg;
            end
            
            obj.mri_headmodel = '';
        end
        
        function obj = add_prev(obj,prev)
            
            % parse inputs
            p = inputParser;
            addRequired(p,'prev',@(x)isa(x,'ftb.MRI'));
            parse(p,prev);
            
            % set the previous step, aka MRI
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
            
            % create folder for analysis step, name accounts for dependencies
            out_folder2 = fullfile(out_folder, obj.get_name());
            if ~exist(out_folder2,'dir')
                mkdir(out_folder2)
            end            
            
            % set up file names
            obj.mri_headmodel = fullfile(...
                out_folder2, ['mri_vol_' obj.config.ft_prepare_headmodel.method '.mat']);
            
            obj.init_called = true;
        end
        
        function obj = process(obj)
            if ~obj.init_called
                error(['ftb:' mfilename],...
                    'not initialized');
            end
            
            % Create the head model from the segmented data
            cfgin = obj.config.ft_prepare_headmodel;
            inputfile = obj.prev.mri_mesh;
            outputfile = obj.prev.mri_headmodel;
            if ~exist(outputfile, 'file')
                data = ftb.util.loadvar(inputfile);
                vol = ft_prepare_headmodel(cfgin, data);
                save(outputfile, 'vol');
            else
                fprintf('%s: skipping ft_prepare_headmodel, already exists\n',mfilename);
            end
        end
        
        function plot(obj, elements)
            %   elements
            %       cell array of head model elements to be plotted:
            %       'scalp'
            %       'brain'
            %       can also include elements from previous stages
            
            unit = 'mm';
            
            % Load data
            vol = ftb.util.loadvar(obj.mri_headmodel);
            % Convert to mm
            vol = ft_convert_units(vol, unit);
            
            for i=1:length(elements)
                switch elements{i}
                    case 'scalp'
                        hold on;
                        
                        % Plot the scalp
                        if isfield(vol, 'bnd')
                            switch vol.type
                                case 'bemcp'
                                    ft_plot_mesh(vol.bnd(3),...
                                        'edgecolor','none',...
                                        'facealpha',0.8,...
                                        'facecolor',[0.6 0.6 0.8]);
                                case 'dipoli'
                                    ft_plot_mesh(vol.bnd(1),...
                                        'edgecolor','none',...
                                        'facealpha',0.8,...
                                        'facecolor',[0.6 0.6 0.8]);
                                case 'openmeeg'
                                    idx = vol.skin_surface;
                                    ft_plot_mesh(vol.bnd(idx),...
                                        'edgecolor','none',...
                                        'facealpha',0.8,...
                                        'facecolor',[0.6 0.6 0.8]);
                                otherwise
                                    error(['ftb:' mfilename],...
                                        'Which one is the scalp?');
                            end
                        elseif isfield(vol, 'r')
                            ft_plot_vol(vol,...
                                'facecolor', 'none',...
                                'faceindex', false,...
                                'vertexindex', false);
                        end
                        
                    case 'brain'
                        hold on;
                        
                        % Plot the scalp
                        if isfield(vol, 'bnd')
                            switch vol.type
                                case 'bemcp'
                                    ft_plot_mesh(vol.bnd(1),...
                                        'edgecolor','none',...
                                        'facealpha',0.8,...
                                        'facecolor',[0.6 0.6 0.8]);
                                case 'dipoli'
                                    ft_plot_mesh(vol.bnd(3),...
                                        'edgecolor','none',...
                                        'facealpha',0.8,...
                                        'facecolor',[0.6 0.6 0.8]);
                                case 'openmeeg'
                                    idx = vol.source;
                                    ft_plot_mesh(vol.bnd(idx),...
                                        'edgecolor','none',...
                                        'facealpha',0.8,...
                                        'facecolor',[0.6 0.6 0.8]);
                                otherwise
                                    error(['ftb:' mfilename],...
                                        'Which one is the brain?');
                            end
                        else
                            error(['ftb:' mfilename],...
                                'Which one is the brain?');
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

