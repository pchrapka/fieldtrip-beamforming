function [in, out, opt] = analysis_source_contrast(in, out, opt)
% Contrasts source analysis results with noise
%
% SYNTAX:
% [IN,OUT,OPT] = analysis_source_contrast(IN,OUT,OPT)
%
% _________________________________________________________________________
% INPUTS:
%
% in        
%   (structure) with the following fields:
%
%   data
%   (string) file name of the source analysis
%   
%   data_contrast
%   (string) file name of the source analysis for contrast
%
% out
%   (structure) with the following fields:
%
%   data
%   (string, default 'sourceanalysis_contrast.mat')
%   file name for the contrasted source analysis
%
% opt           
%   (structure) with the following fields. 
%
%   type
%       (string, default: 'noise') specifies type of contrast
%       noise       
%           contrasts with projected noise, requires projectnoise in source
%           analysis stage
%       condition   
%           contrasts with another condition, requires data_contrast in
%           input struct
%   threshold
%       (number) threshold for power levels to be contrasted
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
fields   = {'type', 'threshold','flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {'noise',0          ,true           , false       , ''           };
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
    out.vol = cat(2, opt.folder_out, filesep, 'sourceanalysis_contrast.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the source analysis
data_in = load(in.data);
data = data_in.data;

% % Copy the source analysis for the output
% data = sourceanalysis;

% Only do the contrast on source data exceeding a threshold to avoid
% spurious results
% max_pow = max(data.avg.pow);
% % Get the indices of points that exceed the threshold
% idx = data.avg.pow > max_pow*opt.threshold;
% % Set everything below the threshold to NaNs
% data.avg.pow(not(idx)) = NaN;
cfg = [];
cfg.threshold = opt.threshold;
cfg.field = 'avg.pow';
data = ftb.extra.ft_threshold(cfg, data);


% Contrast the source data with a noise estimate
% According to fieldtrip, the noise estimate is based on the smallest
% eigenvalue
switch opt.type
    case 'noise'
        data.avg.pow = data.avg.pow ./ data.avg.noise - 1;
    case 'contrast'
        % Load the source analysis
        data_contrast_in = load(in.data_contrast);
        data_contrast = data_contrast_in.data;
        % Threshold the contrast data too
        cfg = [];
        cfg.threshold = opt.threshold;
        cfg.field = 'avg.pow';
        data_contrast = ftb.extra.ft_threshold(cfg, data_contrast);
        data.avg.pow = data.avg.pow ./ data_contrast.avg.pow;
    otherwise
        error('ftb:analysis_source_contrast',...
            ['unknown contrast type: ' opt.type]);
end


%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.data, 'gb_psom_omitted');
    save(out.data, 'data');
end

end
