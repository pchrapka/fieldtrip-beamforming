classdef TestMRI < matlab.unittest.TestCase
    
    properties
        params;
        name;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            cfg = [];
            
            % Processing options
            cfg.ft_volumesegment.output = {'brain','skull','scalp'};
            cfg.ft_prepare_mesh.method = 'projectmesh';
            cfg.ft_prepare_mesh.tissue = {'brain','skull','scalp'};
            cfg.ft_prepare_mesh.numvertices = [2000, 1500, 1000];
            % MRI data
            cfg.mri_data = 'mrifile.mat';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'TestMRI';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testdir,'MRI-test.mat');
            
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
           a = ftb.MRI(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'MRI');
           testCase.verifyEqual(a.name,'TestMRI');
           testCase.verifyEqual(a.rank,0);
           testCase.verifyEqual(a.config.mri_data,'mrifile.mat');
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_mesh'));
        end
        
        function test_constructor2(testCase)
           a = ftb.MRI(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'MRI');
           testCase.verifyEqual(a.name,'TestMRI');
           testCase.verifyEqual(a.rank,0);
           testCase.verifyEqual(a.config.mri_data,'mrifile.mat');
           testCase.verifyTrue(isfield(a.config, 'ft_prepare_mesh'));
        end
        
        function test_init1(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),'ftb:MRI');
        end
        
        function test_init2(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.state.init,true);
        end
        
        function test_process1(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:MRI');
        end
        
        function test_process2(testCase)
            a = ftb.MRI(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end