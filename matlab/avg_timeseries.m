% USAGE: function [X,Y,E] = avg_timeseries(X,dt)
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

function [X,Y,E,N] = avg_timeseries(data,dt)

T = max(data(:,1));

X = [];
Y = [];
E = [];
N = [];

for t = 0:dt:T
    X = [X; t];
    
    idx = find(data(:,1)>=t & data(:,1)<t+dt);
    
    d = data(idx,2);
    
    Y = [Y; mean(d)];
    E = [E; std(d)];
    N = [N; length(d)];
    
end

    