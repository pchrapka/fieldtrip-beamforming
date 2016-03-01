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
        
%         function obj = add_prev(obj,prev)
%             error(['ftb:' mfilename],...
%                 'Not Implemented');
%         end
        
        function name = get_name(obj)
            
            % create current object name
            name = [obj.prefix obj.name];
            
            % prefix with name of previous step
            if ~isempty(obj.prev)
                prev_name = obj.prev.get_name();
                name = [prev_name '-' name];
            end
        end
        
%         function obj = init(obj, params)
%             error(['ftb:' mfilename],...
%                 'Not Implemented');
%         end
%         
%         function obj = process(obj)
%             error(['ftb:' mfilename],...
%                 'Not Implemented');
%         end
%         
%         function plot(obj, elements)
%             error(['ftb:' mfilename],...
%                 'Not Implemented');
%         end
    end
    
    methods (Abstract)
        init(obj, params)
        process(obj)
        plot(obj, elements)
        add_prev(obj, prev)
    end
    
end

