% USAGE: function vargout = load_icustay_timeseries(fname)
%
% Extract timeseries data from SQL csv file (fname).
%
% Output: (data types)
%    1. systolic blood pressure 
%    2. diastolic blood pressure
%    3. mean arterial blood pressure
%    4. heart rate
%    5. lactic acid
%    6. urine output
%
% Copyright (c) Thomas Brennan, 29 April 2013
%     Updated 14 June

function varargout = load_icustay_timeseries(fname)

% read file
[sid, icuid, hid, intime, dt, val, unit, type] = ...
    textread(fname,'%d%d%d%n%d','headerlines',1,'delimiter',',');

% check number of output arguments matches number of timeseries types
if nargout ~= max(type)
    error(sprintf('Number of output arguments must equal %s\n',max(type)));
end

% for each time series
for n = 1:max(type)

    % extract all timeseries for specific timeseries
    idx = find(type==n);
    
    % create temp data structure
    id = [subject_id(idx), icustay_id(idx)];
    t = min_post_adm(idx);
    x = val(idx);
    
    % find unique patients & icustay
    [uid,iid,iuid] = unique(id,'rows');
    
    U = cell(length(uid),2);
    for m = 1:length(uid)
        U{m,1} = uid(m,:);
        U{m,2} = [t(find(iuid==m)) x(find(iuid==m)), ];
    end
    varargout{n} = U;
    
end
    
save('../data/cardiac_output_timeseries.mat','varargout');