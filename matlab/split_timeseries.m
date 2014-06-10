% USAGE function [X,Xall,p,f] = split_timeseries(data,idx,dt)
%
% Split data into X and Y along ICUSTAY_ID
%
% Input:
%   data      - cell array, {subject_id, icustay_id} {timeseries}
%   idx       - cell array of icustay_ids for cohort of patients
%   dt        - time resolution on plots
%
% Output:
%   X         - split of data defined by ids
%   Y         - remainder of data
%
% Copyright (c) Thomas Brennan, May 2013

function [X,Xall] = split_timeseries(data,idx,dt)

% init
N = length(idx);
M = length(data);

% output
X = cell(M,N);
Xall = cell(1,N);

for n = 1:N
    
    ids = idx{n};
    
    for i = 1:M
        id = data{i,1};
        
        % check to see if ICUSTAY_ID is in cohort
        if ~isempty(find(ids==id(2))),
            X{i,n} = [X{i,n}, data{i,2}];
            
            % determine timely averages
            Xpt = data{i,2};
            T = max(Xpt(:,1));
            
            for t = 0:dt:T
                
                idc = find(Xpt(:,1)>t & Xpt(:,1)<t+dt);
            
                if ~isempty(idc)
                    Xall{n} = [Xall{n}; t,mean(Xpt(idc,2))];
                end
            end
            
        end
    end
    
    % Sort all data for population
    Xall{n} = sortrows(Xall{n},1);

end



