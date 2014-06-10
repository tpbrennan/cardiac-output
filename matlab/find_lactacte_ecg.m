% USAGE function [subject_id,nlact] = find_lactate_ecg(flactates,fecg,delta);
%
% INPUT:
%   flactactes - filename of lactacte measurements
%   fecg       - filename of ecg measurements
%   delta      - time (in hours) to add to start and end times of ECG
%
% OUTPUT:
%   subject_id - matched subject ID
%   nlact      - number of matched lactates and ECG records
%
% Copyright (c) Thomas Brennan, 15 March 2013

function [subject_id,nlact] = find_lactate_ecg(flactates,fecg,delta);

format long

fout = fopen('Results/Lactact_ECG_match.csv','w');
fprintf(fout,'ID,LACTACTE,ECG\n');

fidl = fopen(flactates);
L = textscan(fidl,'%d %s %s %s %s\n','HeaderLines',1,'Delimiter',',');
fclose(fidl);

fide = fopen(fecg);
E = textscan(fide,'%s %s\n','Delimiter','/');
fclose(fide);

% get unique subject ids
sids = unique(E{1,1});

% init
N = length(sids);
id = zeros(N,1);
lactates = struct('val',{},'dt',{});

% for every subject with ECGs
for n = 1:N
    
    % extract ID
    sid = sids{n};
    id(n) = str2double(sid(2:end));
    
    
    % Get lactacte variables
    [s,w] = system(sprintf('grep -w %d,LACTATE %s | awk -F, ''{print $3 " " $4}''', id(n),flactates));
    if (isempty(w)) 
        fprintf('Skipping %s - no lactacte measurements\n',sids{n});
        continue; 
    end
    
    % Get lactacte date tokens
    ldtoks = regexp(w,'\s','split');
    nl = (length(ldtoks)-1)/5;
    
    % Extract vector of lactate values & timestamps (AM/PM corrected)
    for m = 1:nl
        
        % Extract lactate values
        lactates(m).val = ldtoks{5*(m-1)+1};
        
        % Extract lactate timestamps
        datestr = sprintf('%s %s\n',ldtoks{5*(m-1)+2},ldtoks{5*(m-1)+3});
        if (strcmp(ldtoks{5*(m-1)+4},'PM'))
            tstoks = regexp(ldtoks{5*(m-1)+3},'\.','split');
            if (str2double(tstoks{1})<12)
                datestr = sprintf('%s %d.%s.%s\n',ldtoks{5*(m-1)+2},str2double(tstoks{1})+12,tstoks{2},tstoks{3});
            end
        end
        try 
            lactates(m).dt = datenum(datestr,'mm-dd-yyyy HH.MM.SS');
        catch e
            fprintf('Error datestr: %s\n',sprintf('%s %s',dtoks{2},dtoks{1}));
            continue;
        end
        
    end
    
    % Get ECG files & tokens
    [s,w] = system(sprintf('grep -w %s %s | awk -F/ ''{print $2}''', sids{n},fecg));
    if (isempty(w)) 
        fprintf('Skipping %s - no ECG records\n',sids{n});
        continue; 
    end

    % Extract tokens
    toks = regexp(w,'\s+','split');
    nle = length(toks)-1;

    % Extract matrix of ECG start and end times
    for m = 1:nle
        
        % start times
        % fprintf('wfdbdesc mimic2wdb/matched/%s/%s | grep Starting\n',sids{n},toks{m});
        [s,w] = system(sprintf('wfdbdesc mimic2wdb/matched/%s/%s | grep Starting',sids{n},toks{m}));
        if (isempty(w)) 
            fprintf('Error ''wfdbdesc'': No ECG record data\n'); 
            continue;
        end
        dtoks = regexp(w(strfind(w,'[')+1:strfind(w,']')-1),'\s+','split');
        try
            starttime = datenum(sprintf('%s %s',dtoks{2},dtoks{1}),'dd/mm/yyyy HH:MM:SS');
        catch e
            fprintf('Error datestr: %s\n',sprintf('%s %s',dtoks{2},dtoks{1}));
            continue;
        end
        
        % duration
        [s,ecgd] = system(sprintf('wfdbdesc mimic2wdb/matched/%s/%s | grep Length | awk ''{print $2}''',sids{n},toks{m}));
        tt = regexp(ecgd,':','split');
        switch length(tt)
            case 1
                endtime = addtodate(starttime,round(str2num(tt{1})),'second');
            case 2
                endtime = addtodate(starttime,round(str2num(tt{2})),'second');
                endtime = addtodate(starttime,round(str2num(tt{1})),'minute');
            case 3
                endtime = addtodate(starttime,round(str2num(tt{3})),'second');
                endtime = addtodate(starttime,round(str2num(tt{2})),'minute');
                endtime = addtodate(starttime,round(str2num(tt{2})),'hour');
        end
        
        % check to see if lactate time within ecg record
        for k = 1:nl
            if (lactates(k).dt > starttime) && (lactates(k).dt < endtime)
                % Write output to file
                %fprintf('%s/%s,%d,%s\n',sids{n},toks{m},lactates(k).dt,lactates(k).val);
                fprintf(fout,'%s/%s,%10.10f,%s\n',sids{n},toks{m},lactates(k).dt,lactates(k).val);
                fprintf('%s/%s,%10.10f,%s\n',sids{n},toks{m},lactates(k).dt,lactates(k).val);
            end
        end
        

    end

end

fclose(fout);

subject_id = sids;
nlact = n;