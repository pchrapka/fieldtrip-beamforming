function [in, out, opt] = analysis_source(in, out, opt)
% Performs source analysis
%
% SYNTAX:
% [IN,OUT,OPT] = ANALYSIS_SOURCE(IN,OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% in        
%   (structure) with the following fields:
%
%   timelock
%   (string) file name of the timelocked analysis
%
%   elec
%   (string) file name of electrode array
%
%   vol
%   (string) file name of the volume conductor model
%
%   leadfield
%   (string) file name of the leadfield grid
%
% out
%   (structure) with the following fields:
%
%   data
%   (string, default 'sourceanalysis.mat')
%   file name for the source analysis
%
% opt           
%   (structure) with the following fields. 
%
%   source_analysis
%       (struct, default: empty struct), specifies options for
%       ft_sourceanalysis. The entire struct is passed through except for
%       the fields elec, vol and grid, which are set to the data specified
%       in the input files
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
fields   = {'source_analysis','flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {struct(),         true           , false       , ''           };
if nargin < 3
    opt = psom_struct_defaults(struct(), fields, defaults);
else
    opt = psom_struct_defaults(opt, fields, defaults);
end

%% Check the output files structure
fields    = {'data'};
defaults  = {'gb_psom_omitted'};
out = psom_struct_defaults(out, fields, defaults);

%% Building default output names

if strcmp(opt.folder_out,'') % if the output folder is left empty, use the same folder as the input
    opt.folder_out = 'head-model';    
end

if isempty(out.data)
    out.vol = cat(2, opt.folder_out, filesep, 'sourceanalysis.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the timelocked analysis
data_in = load(in.timelock);
timelock = data_in.data;
clear data_in;

% Load the electrode array
if isstruct(in.elec)
    elec = in.elec;
else
    elec = ft_read_sens(in.elec);
end
elec = ft_convert_units(elec, 'mm');

% Load the volume conductor model
data_in = load(in.vol);
vol = data_in.vol;
clear data_in;

% Load the leadfield
data_in = load(in.leadfield);
leadfield = data_in.leadfield;
clear data_in;

cfg = opt.source_analysis;
cfg.grid = leadfield;
cfg.vol = vol;
cfg.elec = elec;

data = ft_sourceanalysis(cfg, timelock);


%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.data, 'gb_psom_omitted');
    save(out.data, 'data');
end

end
