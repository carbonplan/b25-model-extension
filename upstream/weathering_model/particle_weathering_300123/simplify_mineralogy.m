function params = simplify_mineralogy(params)

ii = find(params.mf == 0);
params.minerals(ii) = [];
params.mf(ii) = [];

%ii = find(strcmp(params.minerals,'Apatite'));
%params.minerals(ii) = [];
%params.mf(ii) = [];

%params.mf = params.mf/sum(params.mf);
