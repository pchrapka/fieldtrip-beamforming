function pipeline = ft_psom_add_job(pipeline, cfg)

% Create the brick
brick = ft_psom_make_brick(cfg);
% Add the job to the pipeline
pipeline = psom_add_job(pipeline,...
    name, brick, cfg.inputfile, cfg.outputfile, cfg);

end