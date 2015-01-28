function [in, out, opt] = analysis_frequency(in, out, opt)
% Frequency analysis
%
% SYNTAX:
% [IN,OUT,OPT] = ANALYSIS_FREQUENCY(IN,OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
% 
% in        
%   (structure) with the following fields:
%
%   data
%   (string) file name of raw EEG data
%
% out
%   (structure) with the following fields:
%
%   freqanalysis
%   (string, default 'freqanalysis.mat')
%   file name for the frequency analysis
%
% opt           
%   (structure) with the following fields. 
%
%   freqanalysis
%       (struct, default: empty struct), specifies options for
%       ft_freqanalysis. The entire struct is passed through.
%
%   folder_out 
%      (string, default: 'head-models') If present, all default outputs 
%      will be created in the folder FOLDER_OUT. The folder needs to be 
%      created beforehand.
%
%   flag_verbose 
%      (boolean, default 1) if the flag is 1, then the function prints 
%      some infos during the processing.
%
%   flag_test 
%      (boolean, default 0) if FLAG_TEST equals 1, the brick does not do 
%      anything but update the default values in IN, OUT and OPT.
%           
% _________________________________________________________________________
% OUTPUTS:
%
% IN, OUT, OPT: same as inputs but updated with default values.
%              
% _________________________________________________________________________
% SEE ALSO:
% FT_DIPOLESIMULATION
%
% _________________________________________________________________________
% COMMENTS:
%
% _________________________________________________________________________
% Copyright (c) Phil Chrapka, , 2014
% Maintainer : Phil Chrapka, pchrapka@gmail.com
% See licensing information in the code.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('in','var')||~exist('out','var')||~exist('opt','var')
    error('fbt:brick',...
        'Bad syntax, type ''help %s'' for more info.', mfilename)
end
    
%% Options
fields   = {'freqanalysis','flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {struct()      ,true           , false       , ''           };
if nargin < 3
    opt = psom_struct_defaults(struct(), fields, defaults);
else
    opt = psom_struct_defaults(opt, fields, defaults);
end

%% Check the output files structure
fields    = {'freqanalysis'};
defaults  = {'gb_psom_omitted'};
out = psom_struct_defaults(out, fields, defaults);

%% Building default output names

if strcmp(opt.folder_out,'') % if the output folder is left empty, use the same folder as the input
    opt.folder_out = 'head-model';    
end

if isempty(out.freqanalysis)
    out.vol = cat(2, opt.folder_out, filesep, 'freqanalysis.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the EEG data
data_in = load(in.data);
if isfield(data_in,'data')
    data = data_in.data;
else
    data = data_in.selected;
end

% Copy parameters
cfg = opt.freqanalysis;
[freqanalysis] = ft_freqanalysis(cfg, data);

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.freqanalysis, 'gb_psom_omitted');
    save(out.freqanalysis, 'freqanalysis');
end

end
