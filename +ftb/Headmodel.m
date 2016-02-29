classdef Headmodel < ftb.AnalysisStep
    %Headmodel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private);
        config;
        mri_headmodel;
    end
    
    methods
        function obj = Headmodel(params,name,prev)
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
            addRequired(p,'prev',@(x)isa(x,'ftb.MRI'));
            parse(p,params,name,prev);
            
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
            
            % set the previous step, aka MRI
            obj.prev = p.Results.prev;
            
            obj.mri_headmodel = '';
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
            obj.mri_headmodel = fullfile(...
                out_folder, ['mri_vol_' obj.config.ft_prepare_headmodel.method '.mat']);
            
            obj.state.init = true;
        end
        
        function obj = process(obj)
            if ~obj.state.init
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
    end
    
end

