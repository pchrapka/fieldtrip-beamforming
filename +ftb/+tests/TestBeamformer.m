classdef TestBeamformer < matlab.unittest.TestCase
    
    properties
        params;
        name;
        paramfile;
        out_folder;
    end
    
    methods (TestClassSetup)
        function create_config(testCase)
            % set up config
            cfg = [];
            cfg.ft_sourceanalysis.method = 'lcmv';
            cfg.ft_sourceanalysis.lcmv.keepmom = 'no';
            
            [testdir,~,~] = fileparts(mfilename('fullpath'));
            
            testCase.params = cfg;
            testCase.name = 'Testlcmv';
            testCase.out_folder = fullfile(testdir,'output');
            testCase.paramfile = fullfile(testCase.out_folder,'BFlcmv-test.mat');
            
            % create output folder
            if ~exist(testCase.out_folder,'dir')
                mkdir(testCase.out_folder)
            end
            
            % create test config file
            save(testCase.paramfile,'cfg');
        end
    end
    
    methods(TestClassTeardown)
        function delete_files(testCase)
            rmdir(testCase.out_folder,'s');
        end
    end
    
    methods (Test)
        function test_constructor1(testCase)
           a = ftb.Beamformer(testCase.params, testCase.name);
           testCase.verifyEqual(a.prefix,'BF');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_sourceanalysis'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.sourceanalysis));
        end
        
        function test_constructor2(testCase)
           a = ftb.Beamformer(testCase.paramfile, testCase.name);
           testCase.verifyEqual(a.prefix,'BF');
           testCase.verifyEqual(a.name,testCase.name);
           testCase.verifyEqual(a.prev,[]);
           testCase.verifyTrue(isfield(a.config, 'ft_sourceanalysis'));
           testCase.verifyEqual(a.init_called,false);
           testCase.verifyTrue(isempty(a.sourceanalysis));
        end
        
        function test_init1(testCase)
            % check init throws error
            a = ftb.Beamformer(testCase.params, testCase.name);
            testCase.verifyError(@()a.init(''),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_init2(testCase)
            % check init works
            a = ftb.Beamformer(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            testCase.verifyEqual(a.init_called,true);
            testCase.verifyTrue(~isempty(a.sourceanalysis));
        end
        
        function test_init3(testCase)
            % check that get_name is used inside init
            a = ftb.Beamformer(testCase.params, testCase.name);
            a.add_prev(ftb.tests.create_test_dipolesim());
            n = a.get_name();
            a.init(testCase.out_folder);
            
            [pathstr,~,~] = fileparts(a.sourceanalysis);
            testCase.verifyEqual(pathstr, fullfile(testCase.out_folder,n));
        end
        
        function test_add_prev(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(ftb.tests.create_test_dipolesim());
            testCase.verifyTrue(isa(a.prev,'ftb.DipoleSim'));
            testCase.verifyTrue(isfield(a.prev.config, 'ft_dipolesimulation'));
        end
        
        function test_add_prev2(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            
            a.add_prev(ftb.tests.create_test_eeg());
            testCase.verifyTrue(isa(a.prev,'ftb.EEG'));
            testCase.verifyTrue(isfield(a.prev.config, 'ft_definetrial'));
        end
        
        function test_add_prev_error(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            testCase.verifyEqual(a.prev,[]);
            testCase.verifyError(@()a.add_prev(ftb.tests.create_test_leadfield()),...
                'MATLAB:InputParser:ArgumentFailedValidation');
        end
        
        function test_get_name1(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            n = a.get_name();
            testCase.verifyEqual(n, ['BF' testCase.name]);
        end
        
        function test_get_name2(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            e = ftb.tests.create_test_dipolesim();
            a.add_prev(e);
            n = a.get_name();
            testCase.verifyEqual(n, ['DS' e.name '-BF' testCase.name]);
        end
        
        function test_process1(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            testCase.verifyError(@()a.process(),'ftb:Beamformer');
        end
        
        function test_process2(testCase)
            a = ftb.Beamformer(testCase.params, testCase.name);
            a.init(testCase.out_folder);
            %a.process();
        end
    end
    
end