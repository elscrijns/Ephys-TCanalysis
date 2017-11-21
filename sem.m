function x = sem(data, dim)
if ~exist('dim','var')
     % third parameter does not exist, so default
     dim = 2 ;
end
l = size(data,dim) - sum(isnan(data)) ;
    % In an array the NaN values should be ignored

x = std(data,0,dim, 'omitnan')./sqrt(l);
