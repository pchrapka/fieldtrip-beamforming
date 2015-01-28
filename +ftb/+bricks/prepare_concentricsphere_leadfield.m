function [in, out, opt] = prepare_concentricsphere_leadfield(in, out, opt)
% Computes the forward model for dipole locations for a concenctric sphere
% volume conductor model using the fieldtrip toolbox.
%
% SYNTAX:
% [IN,OUT,OPT] = PREPARE_CONCENTRICSPHERE_LEADFIELD(IN,OUT,OPT)
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
%   leadfield
%   (string, default 'concspheres_leadfield.mat')
%   file name for the leadfield data
%
% opt           
%   (structure) with the following fields.  
%
%   prepare_leadfield
%       (struct, default: empty struct), specifies options for
%       ft_prepare_leadfield. The entire struct is passed through except
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
% BRICK_PREPARE_CONCENTRICSPHERE_VOL, FT_PREPARE_LEADFIELD
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
fields   = {'prepare_leadfield', 'flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {struct(),            true           , false       , ''           };
if nargin < 3
    opt = psom_struct_defaults(struct(), fields, defaults);
else
    opt = psom_struct_defaults(opt, fields, defaults);
end

%% Check the output files structure
fields    = {'leadfield'};
defaults  = {'gb_psom_omitted'};
out = psom_struct_defaults(out, fields, defaults);

%% Building default output names

if strcmp(opt.folder_out,'') % if the output folder is left empty, use the same folder as the input
    opt.folder_out = 'head-model';    
end

if isempty(out.leadfield)
    out.vol = cat(2, opt.folder_out, filesep, 'concspheres_leadfield.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

cfg = opt.prepare_leadfield;
cfg.elec = elec;
cfg.vol = vol;
leadfield = ft_prepare_leadfield(cfg);

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.leadfield, 'gb_psom_omitted');
    save(out.leadfield, 'leadfield');
end

end
