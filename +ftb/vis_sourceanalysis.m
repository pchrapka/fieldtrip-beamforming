function vis_sourceanalysis(cfg)
%   cfg.stage
%       struct of short names for each pipeline stage
%
%   See also ftb.get_stage

% Plot the brain and dipole
cfgin = [];
cfgin.stage = cfg.stage;
% cfgin.elements = {'brain', 'dipole'};
cfgin.elements = {'dipole'};
ftb.vis_headmodel_elements(cfgin);

% Plot the leadfield with source analysis results
hold on;
% Load data
cfgtmp = ftb.get_stage(cfg, 'leadfield');
cfghm = ftb.load_config(cfgtmp.stage.full);
leadfield = ftb.util.loadvar(cfghm.files.leadfield);
% dipole is in mm
% Convert leadfield to mm
leadfield = ft_convert_units(leadfield, 'mm');

% Load data
cfgtmp = ftb.get_stage(cfg, 'beamformer');
cfgbf = ftb.load_config(cfgtmp.stage.full);
source = ftb.util.loadvar(cfgbf.files.ft_sourceanalysis.all);

if isfield(cfg, 'contrast')
    % Load noise source
    cfgcopy = cfg;
    cfgcopy.stage.dipolesim = cfg.contrast;
    cfgtmp = ftb.get_stage(cfgcopy);
    cfgnoise = ftb.load_config(cfgtmp.stage.full);
    source_noise = ftb.util.loadvar(cfgnoise.files.ft_sourceanalysis.all);
    
    % Contrast
    source.avg.pow = source.avg.pow ./ source_noise.avg.pow;
end

% Get data for inside the head
source_inside = source.avg.pow(source.inside);
lfpos_inside = leadfield.pos(leadfield.inside,:);

% % Sort according to
% [source_inside, idx] = sort(source_inside);
% lfpos_inside = lfpos_inside(idx,:);

markersize = 100;
scatter3(...
    lfpos_inside(:,1),...
    lfpos_inside(:,2),...
    lfpos_inside(:,3),...
    markersize*source_inside/max(source_inside),...
    source_inside,...
    'filled');
colormap(jet);
colorbar;
    

% Plot inside points
% scatter3(...
%     leadfield.pos(leadfield.inside,1),...
%     leadfield.pos(leadfield.inside,2),...
%     leadfield.pos(leadfield.inside,3), 'k.');
end