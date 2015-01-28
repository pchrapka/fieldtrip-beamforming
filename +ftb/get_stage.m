function cfg = get_stage(cfg, name)
%get_stage returns the stage information based on the cfg.stage struct
%
%   Input
%   -----
%   cfg.stage
%       struct of short names for each pipeline stage
%   Possible fields in cfg.stage
%   cfg.stage.headmodel
%   cfg.stage.electrodes
%   cfg.stage.leadfield
%   cfg.stage.dipolesim
%
%   name
%       (optional) specify stage at which to stop
%
%   Output
%   ------
%   updated cfg struct
%   cfg.stage.full
%       full name of current stage, concatenated short names of previous
%       stage name
%   cfg.stage.folder
%       folder for storing the output files of the current stage

if nargin < 2
    name = '';
end

stages = [];
k = 1;
stages(k).name = 'headmodel';
stages(k).rank = k;

k = k+1;
stages(k).name = 'electrodes';
stages(k).rank = k;

k = k+1;
stages(k).name = 'leadfield';
stages(k).rank = k;

k = k+1;
stages(k).name = 'dipolesim';
stages(k).rank = k;

% Check name
if ~isempty(name)
    nameok = false;
    for i=1:length(stages)
        if isequal(name, stages(i).name)
            nameok = true;
        end
    end
    if ~nameok
        error(['ftb:' mfilename],...
            'unknown stage %s',name);
    end
end

out = [];
for i=1:length(stages)
    if isfield(cfg.stage, stages(i).name)
        % Concat the next short name
        if isempty(out)
            out = cfg.stage.(stages(i).name);
        else
            out = [out '_' cfg.stage.(stages(i).name)];
        end
        cfg.stage.folder = ['stage' num2str(stages(i).rank)...
            '_' stages(i).name];
    end
    
    if isequal(name, stages(i).name)
        % Break, if we've reached the stopping point
        break;
    end
end

cfg.stage.full = out;

end