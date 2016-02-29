classdef TestHeadmodel < matlab.unittest.TestCase
    
    properties
        params;
        name;
        prev;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            % set up config
            cfg = [];
            cfg.ft_prepare_headmodel.method = 'bemcp';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'bemcp';
            testCase.prev = ftb.tests.create_test_mri();
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testdir,'HMbemcp-test.mat');
            
            % create test config file
            save(testCase.paramfile,'cfg');
            
            % create output folder
            if ~exist(testCase.out_folder,'dir')
                mkdir(testCase.out_folder)
            end
        end
    end
    
    methods(TestClassTeardown)
        function delete_files(testCase)
            rmdir(testCase.out_folder,'s');
        end
    end
    
    methods (Test)
        function test_constructor1(testCase)
           a = ftb.Headmodel(testCase.params, testCase.name, testCase.prev);
           testCase.verifyEqual(a.prefix,'HM');
           testCase.verifyEqual(a.name,'bemcp');
           testCase.verifyEqual(a.rank,0);
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_headmodel'));
           testCase.verifyTrue(isa(a.prev,'ftb.MRI'));
           testCase.verifyTrue(isfield(a.prev.config, 'ft_prepare_mesh'));
        end
        
        function test_constructor2(testCase)
           a = ftb.Headmodel(testCase.paramfile, testCase.name, testCase.prev);
           testCase.verifyEqual(a.prefix,'HM');
           testCase.verifyEqual(a.name,'bemcp');
           testCase.verifyEqual(a.rank,0);
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_headmodel'));
           testCase.verifyTrue(isa(a.prev,'ftb.MRI'));
           testCase.verifyTrue(isfield(a.prev.config, 'ft_prepare_mesh'));
        end
        
        function test_init1(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name, testCase.prev);
            testCase.verifyError(@()a.init(''),'ftb:Headmodel');
        end
        
        function test_init2(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name, testCase.prev);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.state.init,true);
        end
        
        function test_process1(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name, testCase.prev);
            testCase.verifyError(@()a.process(),'ftb:Headmodel');
        end
        
        function test_process2(testCase)
            a = ftb.Headmodel(testCase.params, testCase.name, testCase.prev);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end