function [in, out, opt] = extract_leadfield(in, out, opt)
% Extracts only certain channels from an existing leadfield struct
%
% SYNTAX:
% [IN,OUT,OPT] = EXTRACT_LEADFIELD(IN,OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% in        
%   (structure) with the following fields:
%
%   leadfield
%   (string) file name of the leadfield data
%
% out
%   (structure) with the following fields:
%
%   leadfield
%   (string, default 'extracted_leadfield.mat')
%   file name for the leadfield data
%
% opt           
%   (structure) with the following fields.  
%
%   channel
%      (cell array) cell array of channel names to extract
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
fields   = {'channel', 'flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {{},        true           , false       , ''           };
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

% Load the leadfield
data_in = load(in.leadfield);
leadfield_full = data_in.leadfield;
clear data_in;

% Get selected channels
chansel = match_str(leadfield_full.cfg.channel, opt.channel);

% Copy the old leadfield
leadfield_new = leadfield_full;

% Loop through all valid leadfields
for i=1:length(leadfield_full.inside)
    idx = leadfield_full.inside(i);
    % Clear the previous leadfield
    leadfield_new.leadfield{idx} = [];
    % Get the current leadfield
    leadfield_single = leadfield_full.leadfield{idx};
    % Extract certain channels from the leadfield
    leadfield_new.leadfield{idx} = leadfield_single(chansel,:);
end

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.leadfield, 'gb_psom_omitted');
    leadfield = leadfield_new;
    save(out.leadfield, 'leadfield');
end

end
