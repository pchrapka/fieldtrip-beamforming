classdef AnalysisStep < handle
    %AnalysisStep Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
        prefix;
        name;
        
        % state
        init_called;
        
        % linked prev object
        prev;
    end
    
    properties(SetAccess = public)
        force;
    end
    
    methods
        function obj = AnalysisStep(varargin)
            
            p = inputParser;
            addOptional(p,'prefix','',@ischar);
            parse(p,varargin{:});
            
            obj.prefix = p.Results.prefix;
            obj.name = '';
            obj.prev = [];
            obj.init_called = false;
            obj.force = false;
        end
        
        function name = get_name(obj)
            %GET_NAME returns name of analysis step based on dependency
            %structure
            %   GET_NAME returns name of analysis step based on dependency
            %   structure
            %   
            %   Output
            %   ------
            %   name (string)
            %       name of analysis step with dependency names prefixed to
            %       it
            
            % create current object name
            name = [obj.prefix obj.name];
            
            % prefix with name of previous step
            if ~isempty(obj.prev)
                prev_name = obj.prev.get_name();
                name = [prev_name '-' name];
            end
        end
        
        function restart = check_deps(obj)
            %CHECK_DEPS checks if any dependencies have been recomputed
            %   CHECK_DEPS checks if any dependencies have been recomputed
            %   
            %   Output
            %   ------
            %   restart (boolean)
            %       true if any previous step has its restart flag set to
            %       true, false otherwise
            
            restart = false;
            while ~isempty(obj.prev)
                if obj.prev.force
                    restart = true;
                    break;
                end
            end
            
        end
        
    end
    
    methods (Abstract)
        init(obj, params)
        process(obj)
        plot(obj, elements)
        add_prev(obj, prev)
    end
    
end

