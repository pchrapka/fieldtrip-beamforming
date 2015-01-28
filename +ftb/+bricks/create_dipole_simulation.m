function [in, out, opt] = create_dipole_simulation(in, out, opt)
% Computes the forward model for dipole locations for a concenctric sphere
% volume conductor model using the fieldtrip toolbox.
%
% SYNTAX:
% [IN,OUT,OPT] = CREATE_DIPOLE_SIMULATION(IN,OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% in        
%   (structure) with the following fields:
%
%   elec
%   (string) file name of electrode array
%
%   vol
%   (string) file name of the volume conductor model
%
% out
%   (structure) with the following fields:
%
%   data
%   (string, default 'data.mat')
%   file name for the EEG data
%
% opt           
%   (structure) with the following fields.  
%
%   dipole_simulation
%       (struct, default: empty struct), specifies options for
%       ft_dipolesimulation. The entire struct is passed through except
%       for the fields elec and vol, which are set to the data specified in
%       the input files
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
fields   = {'dipole_simulation','flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {struct(),           true           , false       , ''           };
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
    out.vol = cat(2, opt.folder_out, filesep, 'data.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the electrode array
elec = ft_read_sens(in.elec);
elec = ft_convert_units(elec, 'mm');

% Load the volume conductor model
data_in = load(in.vol);
vol = data_in.vol;
clear data_in;

% Copy the parameters for the dipole simulation
cfg = opt.dipole_simulation;
cfg.elec = elec;
cfg.vol = vol;

data = ft_dipolesimulation(cfg);

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.data, 'gb_psom_omitted');
    save(out.data, 'data');
end

end
