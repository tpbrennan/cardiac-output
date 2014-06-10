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

function [Data] = load_cardiac_output_csv(fin)

% get number of lines
[w,c] = system(['wc -l ' fin ' | awk ''{print $1}''']);
nLines = str2num(c)-1;

try 
    fid = fopen(fin);
catch err
    fprintf('Problem reading file: %s\n',err.identifier);
    return;
end

% Read data
[id,icu_id,hadm_id,dt,mins,x,units,type] = ...
    textread(fin,'%d%d%d%s%d%n%s%d\n','headerlines',1,'delimiter',',');

% unique id's
[D,IA,IC] = unique([id,icu_id,hadm_id],'rows');
C = unique(icu_id);
N = length(C);

% number of datatypes
K = max(type);

% Initialise cell array
Data = cell(N,K+1);

% Extract data per unique ID
for n = 1:N
    
    %fprintf('%d) %d',n,C(n));
    
    % get indices for unique ID
    idx = find(C(n) == icu_id);
    
    % get data for patient
    xp = [mins(idx), x(idx), type(idx)];
    
    % ID
    i = idx(1);
    Data{n,1} = [id(i), icu_id(i), hadm_id(i)];
    %ids = [id(i), icu_id(i), hadm_id(i)]:
    
    for k = 1:K
        idc = find(xp(:,3) == k);
        Data{n,k+1} = xp(idc,1:2);
        %fprintf('%d %d, ',k, length(idc));
    end
    %fprintf('\n');
    
    %pause;
end

disp(['Saving data to ',fin(1:end-3),'mat']);
save([fin(1:end-3),'mat'],'Data');