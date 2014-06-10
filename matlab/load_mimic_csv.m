function [ids,data] = load_mimic_csv(fin)


% Open file
fid = fopen(fin);

nLines = 0;

% Read headline to get column names
header = fgets(fid)

% get number of lines
while (fgets(fid) ~= -1),
  nLines = nLines+1;
end
fclose(fid);
fid = fopen(fin);

% Tokenize column names    
cols = regexp(header,',','split')

% Init
cardiac_output = [];
lactate = [];
urine_output = [];

for n = 0:nLines
    
    idx = find(id==ids(n));
    if length(cols) > 3
        data(n) = struct('id',ids(n),'t',charttime(idx),...
            'x1',val1(idx),'x2',val2(idx),'category',category(idx));
    else
        data(n) = struct('id',ids(n),'t',charttime(idx),'x',val1(idx));
    end
end


for n = 1:length(cols)
    switch upper(cols{n})
        case {'ICUSTAY_ID','SUBJECT_ID','HADM_ID','ICUSTAY_ADMIT_AGE','DAYS_IN_ICU'} % number
        case {'HOSPITAL_ADMIT_DT','ICUSTAY_INTIME'} % datetime
        case {'GENDER','EXPIRE_FLG','ICUSTAY_EXPIRE_FLG','VASSOPRESSORS_PRESENT'} % boolean
        case {'CHARTTIME'} % datetime
        case {'LVEF_LOWER','LVEF_UPPER','VAL1','VAL2',,'URINE_OUTPUT_VAL'} % numeric
    end
end