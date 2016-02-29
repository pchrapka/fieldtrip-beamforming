classdef TestAnalysisStep < matlab.unittest.TestCase
    
    properties (TestParameter)
        prefix = {'E','HM'};
    end
    
    methods (Test)
        function test_constructor(testCase)
           a = ftb.AnalysisStep();
           testCase.verifyEqual(a.prefix,'');
           testCase.verifyEqual(a.name,'');
           testCase.verifyEqual(a.rank,0);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyEqual(a.state.init,false);
        end
        
        function test_constructor1(testCase,prefix)
           a = ftb.AnalysisStep(prefix);
           testCase.verifyEqual(a.prefix,prefix);
           testCase.verifyEqual(a.name,'');
           testCase.verifyEqual(a.rank,0);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyEqual(a.state.init,false);
        end
        
        function test_init(testCase)
            a = ftb.AnalysisStep();
            params = [];
            testCase.verifyError(@()a.init(params),'fb:AnalysisStep');
        end
        
        function test_process(testCase)
            a = ftb.AnalysisStep();
            testCase.verifyError(@()a.process(),'fb:AnalysisStep');
        end
    end
    
end

