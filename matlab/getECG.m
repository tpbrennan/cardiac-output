%Script for testing the loading of a ECG collected
%close to the chart time of a lactate measurement

%This script get the ECG waveforms closest to the Lactate measurements
%specified by the following format in Lactact_ECG_match.csv
%ID,LACTACTE,ECG
%where LACTACTE is given by datenum(datestr,'mm-dd-yyyy HH.MM.SS');

clear all;close all;clc

dataDir='mimic2wdb/matched/';
%Number corresponding to one second in DATENUM format
DATE_NUM_SEC=  datenum('00:00:01.000 01-01-0000','HH:MM:SS.FFF mm-dd-yyyy')...
    -datenum('00:00:00.000 01-01-0000','HH:MM:SS.FFF mm-dd-yyyy');
%Window to include before and after the measurement (in seconds)
window=DATE_NUM_SEC*3;

fid=fopen('Lactact_ECG_match.csv','r');
recs=textscan(fid,'%s%f%f','Delimiter',',');
fclose(fid)
fname=recs{1};
lact_tm=recs{2};
lactate_values=recs{3};
N=length(fname);
leadName='II';
ann=cell(N,3);

for n=35%1:N
    
    %Get record name
    desc=wfdbdesc([dataDir fname{n}],1);
    sigIndex=[];
    %Select the specific lead if it does not exist, skip
    for s=1:length(desc.groups.signals)
        if(strcmp(desc.groups.signals(s).description,leadName))
            sigIndex=s;
        end
    end
    if(~isempty(sigIndex))
        %Convert start time to same format as  lactate measurement
        ecg_str_start_time=strrep(desc.startingTime(2:end-1),'/','-');
        ecg_start_time=datenum(ecg_str_start_time,'HH:MM:SS.FFF mm-dd-yyyy');
        
        %Calculate offset of the inistial record to the lactacte measurement
        offset=lact_tm(n)-ecg_start_time;
        
        %Read the record +- 5 seconds from the offset mark
        start_str=datestr(offset-window,'HH:MM:SS');
        stop_str=datestr(offset+window,'HH:MM:SS');
        
        try
            data=rdsamp([dataDir fname{n}],'begin',start_str, ...
                'stop',stop_str,'phys',true,'sigs',sigIndex-1);
            plot(data(:,end))
            [x,y,buttons] = ginput;
            ann(n,1)={x};
            ann(n,2)={y};
            ann(n,3)={buttons};
            title(num2str(lactate_values(n)))
            close all
        catch
            warning(['Could not load: '  fname{n} ])
        end
    end
    
end



%Calculate R-T ratio based on annotation of wave segments
%Loop throught annotation and use onlye those that have  pairs
%of P and T wave
predict_lactate=zeros(N,2)+NaN;
for n=1:N
    labels=ann{n,3};
    amps=ann{n,2};
    ints=ann{n,1};
    R=find(labels==1);
    T=find(labels==3);
    if(length(R)==length(T))
        Ramp=mean(amps(R));
        Rint=mean(diff(ints(R)));
        Tamp=mean(amps(T));
        ratio=Ramp/Tamp;
        if(ratio>0 && ratio >1)
            predict_lactate(n,:)=[ratio Rint];
        end
    end
end
[lactate_values predict_lactate]
p1=predict_lactate(:,1);p1=(p1-nanmean(p1))/nanstd(p1);
p2=predict_lactate(:,2);p2=(p2-nanmean(p2))/nanstd(p2);

scatter(lactate_values,p1,'filled','LineWidth',2)
hold on;grid on
scatter(lactate_values,p2,'Marker','x','MarkerEdgeColor','r','LineWidth',2)







