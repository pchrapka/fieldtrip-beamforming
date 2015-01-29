function check_sourceanalysis(cfg)

debug = true;
if debug
    % Load source analysis
    cfgtmp = ftb.get_stage(cfg);
    cfgsource = ftb.load_config(cfgtmp.stage.full);
    source = ftb.util.loadvar(cfgsource.files.ft_sourceanalysis.all);
    % Load the head model
    cfgtmp = ftb.get_stage(cfg, 'headmodel');
    cfghm = ftb.load_config(cfgtmp.stage.full);
    volume = ftb.util.loadvar(cfghm.files.mri_headmodel);
    
    cfgin = [];
    mri = ftb.util.loadvar(cfghm.files.mri_mat);
    resliced = ft_volumereslice(cfgin, mri);
    
    % Take neural activity index
    % NOTE doesn't seem to help
    sourcenai = source;
    %sourcenai.avg.pow = source.avg.pow ./ source.avg.noise;
    
    cfgin = [];
    cfgin.parameter = 'avg.pow';
    interp = ft_sourceinterpolate(cfgin, sourcenai, resliced);
    
    cfgin = [];
%     cfgin.method = 'slice';
    cfgin.method = 'ortho';
    cfgin.funparameter = 'avg.pow';
    ft_sourceplot(cfgin, interp);
end

if debug
    figure;
    
    cfgin = [];
    cfgin.stage = cfg.stage;
    cfgin.elements = {'brain', 'dipole', 'leadfield'};
    ftb.vis_headmodel_elements(cfgin);
end

if debug
    figure;
    cfgin = [];
    cfgin.stage = cfg.stage;
    ftb.vis_sourceanalysis(cfgin);
end

end