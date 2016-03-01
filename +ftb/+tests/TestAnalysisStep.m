classdef TestAnalysisStep < matlab.unittest.TestCase
    
    properties (TestParameter)
        prefix = {'E','HM'};
    end
    
    methods (Test)
        function test_constructor(testCase)
           a = ftb.AnalysisStep();
           testCase.verifyEqual(a.prefix,'');
           testCase.verifyEqual(a.name,'');
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyEqual(a.init_called,false);
        end
        
        function test_constructor1(testCase,prefix)
           a = ftb.AnalysisStep(prefix);
           testCase.verifyEqual(a.prefix,prefix);
           testCase.verifyEqual(a.name,'');
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyEqual(a.init_called,false);
        end
        
        function test_init(testCase)
            a = ftb.AnalysisStep();
            params = [];
            testCase.verifyError(@()a.init(params),'ftb:AnalysisStep');
        end
        
        function test_process(testCase)
            a = ftb.AnalysisStep();
            testCase.verifyError(@()a.process(),'ftb:AnalysisStep');
        end
        
        function test_add_prev(testCase)
            a = ftb.AnalysisStep();
            testCase.verifyError(@()a.add_prev(),'ftb:AnalysisStep');
        end
        
        function test_get_name1(testCase)
            a = ftb.AnalysisStep();
            name = a.get_name();
            testCase.verifyEqual(name, '');
        end
        
        function test_get_name2(testCase,prefix)
            a = ftb.AnalysisStep(prefix);
            name = a.get_name();
            testCase.verifyEqual(name, prefix);
        end
    end
    
end

