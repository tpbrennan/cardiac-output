function data = load_lactate_data

%% Pre-processing
% read file
fname = '../data/export_data_lactate_raw.csv';
[icustay_id, lactime, lacval] = textread(fname,'%d%d%f', ...
    'headerlines',1,'delimiter',',');

ids = unique(icustay_id); ids = ids(:)';

% Sort times over indices
for i = ids
    ind = find(icustay_id==i);
    lacval_p = lacval(ind); time_p = lactime(ind);
    [time, itime] = sort(time_p);
    lactime(ind) = time;
    lacval(ind) = lacval_p(itime);
end

% Remove measurements of lactate 30 which are only 30 minutes apart!
INDEX = zeros(size(icustay_id));
for i = ids
    ind = find(icustay_id==i);
    time_p = lactime(ind);
    time_deltas = diff(time_p);
    ind_rm = time_deltas < 30;
    INDEX(ind(ind_rm)) = 1;    
end
icustay_id(INDEX == 1) = [];
lactime(INDEX == 1) = [];
lacval(INDEX == 1) = [];

% Determine number of icustays with more than two measurements of lactate
ids = unique(icustay_id); ids = ids(:)';
N = length(ids);
IDS = [];
% lac = [];
for i = ids
    ind = find(icustay_id==i);
    if length(ind) > 2
        IDS = [IDS, i];
%     else
%         lac = [lac; lacval(ind)];
    end
end

group = zeros(length(IDS),2);
pt = 0;
for i = IDS
    pt = pt + 1;
    ind = find(icustay_id==i);
    if lacval(ind(end)) >= 2
        group(pt,1) = 1;
        group(pt,2) = i;
    else
        group(pt,2) = i;
    end
end

%% Get IBP and NBP info
% read file
% fname = '../data/export_data_lactate_wnbp.csv';
% [icustay_idnbp, lactimenbp, lacvalnbp, sysnbp, dianbp, ppnbp, mapnbp, hrnbp] =  ...
%     textread(fname,'%d%d%f%f%f%f%f%f', 'headerlines',1,'delimiter',',');
% 
% % Sort times over indices
% for i = ids
%     ind = find(icustay_idnbp==i);
%     time_p = lactime(ind);
%     [time, itime] = sort(time_p);
%     lactimenbp(ind) = time;
%     lacvalnbp(ind) = lacvalnbp(ind(itime));
%     sysnbp(ind) = sysnbp(ind(itime));
%     dianbp(ind) = dianbp(ind(itime));
%     ppnbp(ind) = ppnbp(ind(itime));
%     mapnbp(ind) = mapnbp(ind(itime));
%     hrnbp(ind) = hrnbp(ind(itime));
% end 
% 
% % Cleaning
% INDEX = zeros(size(icustay_idnbp));
% for i = ids
%     ind = find(icustay_idnbp==i);
%     time_p = lactimenbp(ind);
%     time_deltas = diff(time_p);
%     ind_rm = time_deltas < 30;
%     INDEX(ind(ind_rm)) = 1;    
% end
% icustay_idnbp(INDEX == 1) = [];
% lactimenbp(INDEX == 1) = [];
% lacvalnbp(INDEX == 1) = [];
% sysnbp(INDEX == 1) = [];
% dianbp(INDEX == 1) = [];
% ppnbp(INDEX == 1) = [];
% mapnbp(INDEX == 1) = [];
% hrnbp(INDEX == 1) = [];

fname = '../data/export_data_lactate_wibp.csv';
[icustay_idibp, lactimeibp, lacvalibp, sysibp, diaibp, ppibp, mapibp, hribp] =  ...
    textread(fname,'%d%d%f%f%f%f%f%f', 'headerlines',1,'delimiter',',');

for i = ids
    ind = find(icustay_idibp==i);
    time_p = lactimeibp(ind);
    [time, itime] = sort(time_p);
    lactimeibp(ind) = time;
    lacvalibp(ind) = lacvalibp(ind(itime));
    sysibp(ind) = sysibp(ind(itime));
    diaibp(ind) = diaibp(ind(itime));
    ppibp(ind) = ppibp(ind(itime));
    mapibp(ind) = mapibp(ind(itime));
    hribp(ind) = hribp(ind(itime));
end

INDEX = zeros(size(icustay_idibp));
for i = ids
    ind = find(icustay_idibp==i);
    time_p = lactimeibp(ind);
    time_deltas = diff(time_p);
    ind_rm = time_deltas < 30;
    INDEX(ind(ind_rm)) = 1;    
end
icustay_idibp(INDEX == 1) = [];
lactimeibp(INDEX == 1) = [];
lacvalibp(INDEX == 1) = [];
sysibp(INDEX == 1) = [];
diaibp(INDEX == 1) = [];
ppibp(INDEX == 1) = [];
mapibp(INDEX == 1) = [];
hribp(INDEX == 1) = [];

% Select matched patients
IDSibp = [];
groupibp = [];
for i = IDS
    L = sum(icustay_id == i);
    ind = find(group(:,2) == i);
    if sum(icustay_idibp == i) > .5*L && sum(icustay_idibp == i) > 2
        IDSibp = [IDSibp, i];
        groupibp = [groupibp; group(ind,1)];
    end
end


%% Perform correlation analysis
% DATAnbp = [];
% for i = IDSnbp
%     DATAnbp = [DATAnbp; lacvalnbp(icustay_idnbp == i), ...
%         sysnbp(icustay_idnbp == i) dianbp(icustay_idnbp == i) ...
%         ppnbp(icustay_idnbp == i) mapnbp(icustay_idnbp == i) hrnbp(icustay_idnbp == i)];
% end

DATAibp = [];
for i = IDSibp
    DATAibp = [DATAibp; i*ones(sum(icustay_idibp == i),1), lactimeibp(icustay_idibp == i), lacvalibp(icustay_idibp == i), ...
        sysibp(icustay_idibp == i) diaibp(icustay_idibp == i) ...
        ppibp(icustay_idibp == i) mapibp(icustay_idibp == i) hribp(icustay_idibp == i)];
end
DATAibp = [DATAibp, DATAibp(:,6).*DATAibp(:,8)*1.7];    % Cardiac Output

FEATURES = {'Lactate, mmol/L','Systolic BP, mmHg','Diastolic BP, mmHg', ...
    'Pulse Pressure, mmHg','Mean Arterial Pressure, mmHg','Heart Rate, bpm', 'CO'};

% corrplot(DATAnbp,'varNames',FEATURES);
% corrplot(DATAibp(:,[3:end]),'varNames',FEATURES);
% figure;
% for i = IDSibp
%     subplot(211); plot(lactimeibp(icustay_idibp == i),lacvalibp(icustay_idibp == i));
%     drawnow; hold on;
%     ylabel('Lactate, mmol/L');
%     subplot(212); plot(lactimeibp(icustay_idibp == i),ppibp(icustay_idibp == i));
%     ylabel('Pulse Pressure, mmHg'), xlabel('Time, min.');
%     drawnow;
%     hold on;
% end

DATA_FINAL = zeros(length(IDSibp),36);
DATA_FINAL(:,1) = IDSibp';

pt = 1;
for i = IDSibp
    for j = 1 : 7
        x = DATAibp(DATAibp(:,1)==i,2); y = DATAibp(DATAibp(:,1)==i,2+j);
        DATA_FINAL(pt,(j-1)*5+2:j*5+1) = gettsfeatures(x,y);
    end
    pt = pt + 1;
end

data = [DATA_FINAL, groupibp];

