function [data] = ft_threshold(cfg, data)
%
%   cfg.threshold
%       threshold value in percent
%   cfg.field
%       string, field in data to be thresholded

% Split the field names into subfields
fields = regexp(cfg.field, '\.', 'split');

% Copy the data to be thresholded
data_temp = data;
for i=1:length(fields)
    field = fields{i};
    data_temp = data_temp.(field);
end

% Get the maximum value
max_val = max(data_temp);
% Get the indices of points that exceed the threshold
idx = data_temp > max_val*cfg.threshold;
% Set everything below the threshold to NaNs
data_temp(not(idx)) = NaN;

% Output the thresholded data
switch length(fields)
    case 1
        data.(fields{1}) = data_temp;
    case 2
        data.(fields{1}).(fields{2}) = data_temp;
    case 3
        data.(fields{1}).(fields{2}).(fields{3}) = data_temp;
    otherwise
        error('ftb:ft_threshold',...
            'data is way too deep, fix this somehow');
end

end