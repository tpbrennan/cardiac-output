function convert_sql_csv(data,fout)

fid = fopen(fout,'w');

[A,ia,ic] = unique(data(:,1:2),'rows');

data = data(ia,:);

for n = 1:length(data)
    dstr = upper(datestr(data(n,2),'dd-mmm-yy HH.MM.SS'));
    fprintf(fid,'%d,%s,%d,%d\n',data(n,1),dstr,data(n,3),data(n,4));
end

