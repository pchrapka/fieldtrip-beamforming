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

% Load data
cfgtmp = ftb.get_stage(cfg, 'beamformer');
cfgbf = ftb.load_config(cfgtmp.stage.full);
source = ftb.util.loadvar(cfgbf.files.ft_sourceanalysis.all);

source_inside = source.avg.pow(source.inside);
lfpos_inside = leadfield.pos(leadfield.inside,:);

[source_inside, idx] = sort(source_inside);
lfpos_inside = lfpos_inside(idx,:);
cmp = jet(length(source_inside));

scatter3(...
    lfpos_inside(:,1),...
    lfpos_inside(:,2),...
    lfpos_inside(:,3),...
    30*source_inside/max(source_inside),...
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