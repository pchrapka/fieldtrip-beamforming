function [in, out, opt] = prepare_concentricsphere_vol(in, out, opt)
% Creates a concentric sphere volume conductor model using the fieldtrip
% toolbox
%
% SYNTAX:
% [IN,OUT,OPT] = PREPARE_CONCENTRICSPHERE_VOL(IN,OUT,OPT)
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
% out
%   (structure) with the following fields:
%       
%   vol
%   (string, default 'concspheres_vol.mat')
%   file name for the volume conductor model
%
% opt           
%   (structure) with the following fields.  
% 
%   conductivity
%       (array, default: []) conductivity for each sphere
%       ex. [1 1/80 1]; % skin skull brain
%
%   r
%       (array, default: []) percent scaling of electrode positions, the
%       number of elements defines the number of spheres
%       ex. [1 0.92 0.88];
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
% FT_READ_SENS, FT_HEADMODEL_CONCENTRICSPHERES
%
% _________________________________________________________________________
% COMMENTS:
%
% That code is just to demonstrate the guidelines for PSOM bricks. It is
% also a good idea to start a new command project by editing this file and
% saving it under the new brick name.
%
% This code is just to demonstrate the principles of a brick. It will crash
% if attempted to run (it has dependencies on the NIAK toolbox).
%
% _________________________________________________________________________
% Copyright (c) Phil Chrapka, , 2014
% Maintainer : pchrapka@gmail.com
% See licensing information in the code.

% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
%
% The above copyright notice and this permission notice shall be included in
% all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
% THE SOFTWARE.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialization and syntax checks %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Syntax
if ~exist('in','var')||~exist('out','var')||~exist('opt','var')
    error('fbt:brick',...
        'Bad syntax, type ''help %s'' for more info.', mfilename)
end
    
%% Options
fields   = {'conductivity', 'r', 'flag_verbose' , 'flag_test' , 'folder_out' };
defaults = {[],             [],  true           , false       , ''           };
if nargin < 3
    opt = psom_struct_defaults(struct(), fields, defaults);
else
    opt = psom_struct_defaults(opt, fields, defaults);
end

%% Check the output files structure
fields    = {'vol'};
defaults  = {'gb_psom_omitted'};
out = psom_struct_defaults(out, fields, defaults);

%% Building default output names

if strcmp(opt.folder_out,'') % if the output folder is left empty, use the same folder as the input
    opt.folder_out = 'head-model';    
end

if isempty(out.vol)
    out.vol = cat(2, opt.folder_out, filesep, 'concspheres_vol.mat');
end

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The core of the brick starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if opt.flag_verbose
    fprintf('Creating concentric sphere ');
    fprintf('volume conductor model for %s\n', in.elec);
end

% Load the electrode array
elec = ft_read_sens(in.elec);
elec = ft_convert_units(elec, 'mm');

% Volume conductor model
fitind = [];
n_spheres = numel(opt.r);
for i=1:n_spheres
    geometry(i).pnt = opt.r(i)*elec.chanpos;
    geometry(i).unit = elec.unit;
end
% NOTE if you get an error dealing with unit, another version of fieldtrip
% is probably in your path, run restoredefaultpath and the startup again
vol = ft_headmodel_concentricspheres(geometry,...
    'conductivity', opt.conductivity, 'fitind', fitind);
vol = ft_convert_units(vol, 'mm');

%% Save outputs
if opt.flag_verbose
    fprintf('Save outputs ...\n');
end

if ~strcmp(out.vol, 'gb_psom_omitted');
    save(out.vol, 'vol');
end

end
