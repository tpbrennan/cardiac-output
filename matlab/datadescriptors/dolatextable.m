function dolatextable(filename,labelname,groupname,data)
% create Table for chloride variables

FID = fopen(filename, 'w');
%fprintf(FID, '\\caption{%s}\n',labelname);
fprintf(FID, '\\centerline{\\small \n');
fprintf(FID, '\\begin{tabular}{l c c c}\n');
fprintf(FID, '\\toprule\n');
fprintf(FID, '& \\multicolumn{3}{c}{\\textbf{No. (\\%%) of Patients}}  \\\\ \n');
fprintf(FID, '\\cmidrule(l){2-4} \n');
fprintf(FID, '& %s & %s & %s  \\\\ \n',groupname{1},groupname{2},groupname{3});
fprintf(FID, '& %s & %s & %s  \\\\ \n',sprintf('(N = %d)',data{1,2}),sprintf('(N = %d)',data{1,3}),sprintf('(N = %d)',data{1,4}));
fprintf(FID, '\\hline\n');
           
for i = 4
    fprintf(FID, '%s & %s & %s & %s \\\\ \n', data{i,1},data{i,2},data{i,3},data{i,4});
end
fprintf(FID, 'Service type: & & &  \\\\ \n');
for i = 5 : 8
    fprintf(FID, '%s & %s & %s & %s \\\\ \n', data{i,1},data{i,2},data{i,3},data{i,4});
end
fprintf(FID, 'Primary Outcomes: & & &  \\\\ \n');
for i = 9 : 13
    fprintf(FID, '%s & %s & %s & %s \\\\ \n', data{i,1},data{i,2},data{i,3},data{i,4});
end

fprintf(FID, '\\hline\n');
fprintf(FID, '& \\multicolumn{3}{c}{\\textbf{Median (IQR)}}  \\\\ \n');
fprintf(FID, '\\cmidrule(l){2-4} \n');

for i = 3
    fprintf(FID, '%s & %s & %s & %s \\\\ \n', data{i,1},data{i,2},data{i,3},data{i,4});
end

for i = 37:42
    fprintf(FID, '%s & %s & %s & %s \\\\ \n', data{i,1},data{i,2},data{i,3},data{i,4});
end

fprintf(FID, 'Secondary Outcomes: & & &  \\\\ \n');
for i = 14 : 15
    fprintf(FID, '%s & %s & %s & %s \\\\ \n', data{i,1},data{i,2},data{i,3},data{i,4});
end

fprintf(FID, '\\bottomrule\n');
fprintf(FID, '\\end{tabular}\n');
fprintf(FID, '}\n');
fclose(FID);
