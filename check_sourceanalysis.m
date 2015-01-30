function check_sourceanalysis(cfg)
%
%   cfg.contrast
%       (optional) name of dipolesim to contrast

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
    
    if isfield(cfg, 'contrast')
        % Load noise source
        cfgcopy = cfg;
        cfgcopy.stage.dipolesim = cfg.contrast;
        cfgtmp = ftb.get_stage(cfgcopy);
        cfgnoise = ftb.load_config(cfgtmp.stage.full);
        source_noise = ftb.util.loadvar(cfgnoise.files.ft_sourceanalysis.all);
    end
    
    cfgin = [];
    mri = ftb.util.loadvar(cfghm.files.mri_mat);
    resliced = ft_volumereslice(cfgin, mri);
    
    % Take neural activity index
    % NOTE doesn't seem to help
    sourcenai = source;
    if exist('source_noise', 'var')
        sourcenai.avg.pow = source.avg.pow ./ source_noise.avg.pow;
    end
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
    if isfield(cfg, 'contrast')
        cfgin.contrast = cfg.contrast;
    end
    ftb.vis_sourceanalysis(cfgin);
end

end