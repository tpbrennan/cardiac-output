% USAGE: function [Y,E] = median_timeseries(X,dt,thr)
%
% Return average and std for timeseries X
%
% Input
%    data - Input matrix assuming Nx2 [timestamps,vals]
%    dt   - time resolution (same resolution as timestamps, default minutes)
%
% Output
%    X    - time vector
%    Y    - avegage/mean vector
%    E    - standard deviation vector
%    
% Copyright (c) Thomas Brennan, 16 May 2013

function [X,Y,L,U] = median_timeseries(data,dt,thr)

T = max(data(:,1));

% init
X = [];
Y = [];
L = [];
U = [];

for t = 0:dt:T
    X = [X; t];
    
    idx = find(data(:,1)>t & data(:,1)<t+dt);
    
    d = data(idx,2);
    
    Y = [Y; median(d)];
    L = [L; prctile(d,25)];
    U = [U; prctile(d,75)];
    
    % break out if data level drops below 
    if length(d) < thr, break; end
end

