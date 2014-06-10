function [features] = gettsfeatures(x,y)
% get features from timeseries x and y

x = x(:); y = y(:);

meanval = mean(y); maxval = max(y); 
minval = min(y); %varval = var(y); 
%rrval = (maxval-minval)./sqrt(varval);
%changeval = y(end)-y(1);
medianval = median(y); 

p = polyfit(x,y,1);
slopeval = p(1); %cval = p(2);

%features = [meanval maxval minval varval rrval changeval medianval slopeval cval];
features = [meanval medianval minval maxval 1440*slopeval];

end