classdef AnalysisBeamformer < handle
    %AnalysisBeamformer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(SetAccess = private)
        headmodel;
        electrodes;
        leadfield;
        data;
        beamformer;
    end
    
    methods
        function obj = AnalysisBeamformer()
            obj.headmodel = [];
            obj.electrodes = [];
            obj.leadfield = [];
            obj.data = [];
            obj.beamformer = [];
        end
    end
    
end

