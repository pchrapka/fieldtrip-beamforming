classdef AnalysisStep < handle
    %AnalysisStep Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = protected)
        prefix;
        name;
        rank; %?
        
        % state
        state;
        
        % analysis steps
        prev;
    end
    
    methods
        function obj = AnalysisStep(varargin)
            p = inputParser;
            addOptional(p,'prefix','',@ischar);
            parse(p,varargin{:});
            
            obj.prefix = p.Results.prefix;
            obj.name = '';
            obj.rank = 0;
            obj.prev = [];
            obj.state.init = false;
            obj.state.force = false;
        end
        
        function obj = init(obj, params)
            error(['fb:' mfilename],...
                'Not Implemented');
        end
        
        function obj = process(obj)
            error(['fb:' mfilename],...
                'Not Implemented');
        end
    end
    
end

