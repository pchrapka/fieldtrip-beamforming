classdef TestAnalysisBeamformer < matlab.unittest.TestCase
    
    properties
    end
    
    methods (Test)
        function test_constructor(testCase)
           a = ftb.AnalysisBeamformer();
           testCase.verifyEqual(a.headmodel,[]);
           testCase.verifyEqual(a.electrodes,[]);
           testCase.verifyEqual(a.leadfield,[]);
           testCase.verifyEqual(a.data,[]);
           testCase.verifyEqual(a.beamformer,[]);
        end
        
%         function test_init(testCase)
%             a = ftb.AnalysisBeamformer();
%             params = [];
%             testCase.verifyError(@()a.init(params),'fb:AnalysisStep');
%         end
%         
%         function test_process(testCase)
%             a = ftb.AnalysisBeamformer();
%             testCase.verifyError(@()a.process(),'fb:AnalysisStep');
%         end
    end
    
end