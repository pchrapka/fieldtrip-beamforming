function cfg = load_config(name)

outfile = fullfile('.ftb', 'config', [name '.mat']);
if exist(outfile, 'file')
    cfg = ftb.util.loadvar(outfile);
end

end