function dolatextable(filename,labelname,Ni,cell_data,cell_demog)
% create Table for chloride variables

FID = fopen(filename, 'w');
fprintf(FID, '\\caption{%s}\n',labelname);
fprintf(FID, '\\centerline{\\small \n');
fprintf(FID, '\\begin{tabular}{l r l c r l c}\n');
fprintf(FID, '\\toprule\n');
fprintf(FID, '& \\multicolumn{5}{c}{\\textbf{No. (\\%%) [95\\%% CI] of Patients}} & \\\\ \n');
fprintf(FID, '\\cmidrule(l){2-6} \n');
fprintf(FID, '& \\multicolumn{2}{c}{Lactate $<2$} & ~~~ & \\multicolumn{2}{c}{Lactate $>2$} & P \\\\ \n');
fprintf(FID, '& \\multicolumn{2}{c}{(n=%d , %d\\%%)} & & \\multicolumn{2}{c}{(n=%d, %d\\%%)} & value \\\\ \n',Ni(1),round(Ni(1)/sum(Ni)*100),Ni(2),round(Ni(2)/sum(Ni)*100));
fprintf(FID, '\\hline\n');

vec = [1 5 6 7 8 11 12 13 14 15 16 17];
for j = vec
    if j == 5
        fprintf(FID, 'Service type: & & & & & & \\\\ \n');
    elseif j == 15
        fprintf(FID, 'Primary Outcome: & & & & & & \\\\ \n');
    end
    if cell_demog{j,4} < 0.001
        fprintf(FID, '%s & %d & (%d) [%d-%d] & & %d & (%d) [%d-%d] & $\\mathbf{<0.001}$ \\\\ \n',cell_demog{j,1}, ...
            cell_demog{j,2}(1), round(cell_demog{j,2}(2)), round(cell_demog{j,2}(3)), round(cell_demog{j,2}(4)), ...
            cell_demog{j,3}(1), round(cell_demog{j,3}(2)), round(cell_demog{j,3}(3)), round(cell_demog{j,3}(4)));
    elseif cell_demog{j,4} <= 0.01
        fprintf(FID, '%s & %d & (%d) [%d-%d] & & %d & (%d) [%d-%d] & \\textbf{%.3f} \\\\ \n',cell_demog{j,1}, ...
            cell_demog{j,2}(1), round(cell_demog{j,2}(2)), round(cell_demog{j,2}(3)), round(cell_demog{j,2}(4)), ...
            cell_demog{j,3}(1), round(cell_demog{j,3}(2)), round(cell_demog{j,3}(3)), round(cell_demog{j,3}(4)), ...
            cell_demog{j,4});
    else
        fprintf(FID, '%s & %d & (%d) [%d-%d] & & %d & (%d) [%d-%d] & %.3f \\\\ \n',cell_demog{j,1}, ...
            cell_demog{j,2}(1), round(cell_demog{j,2}(2)), round(cell_demog{j,2}(3)), round(cell_demog{j,2}(4)), ...
            cell_demog{j,3}(1), round(cell_demog{j,3}(2)), round(cell_demog{j,3}(3)), round(cell_demog{j,3}(4)), ...
            cell_demog{j,4});
    end
end

fprintf(FID, '& \\multicolumn{5}{c}{\\textbf{Median (Interquartile Range)}} & \\\\ \n');
fprintf(FID, '\\hline\n');

vec = [2 4 9 10];
for j = vec
if cell_demog{j,4} < 0.001
    fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & $\\mathbf{<0.001}$ \\\\ \n',cell_demog{j,1}, ...
        cell_demog{j,2}(1), cell_demog{j,2}(2), cell_demog{j,2}(3), ...
        cell_demog{j,3}(1), cell_demog{j,3}(2), cell_demog{j,3}(3));
elseif cell_demog{j,4} <= 0.01
    fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & \\textbf{%.3f} \\\\ \n',cell_demog{j,1}, ...
        cell_demog{j,2}(1), cell_demog{j,2}(2), cell_demog{j,2}(3), ...
        cell_demog{j,3}(1), cell_demog{j,3}(2), cell_demog{j,3}(3), ...
        cell_demog{j,4});
else
    fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & %.3f \\\\ \n',cell_demog{j,1}, ...
        cell_demog{j,2}(1), cell_demog{j,2}(2), cell_demog{j,2}(3), ...
        cell_demog{j,3}(1), cell_demog{j,3}(2), cell_demog{j,3}(3), ...
        cell_demog{j,4});
end
end

fprintf(FID, 'Lactate, mmol/L: & & & & & & \\\\ \n');
vec = 1 : 5;
for j = vec
    if cell_data{j,4} < 0.001
        fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & $\\mathbf{<0.001}$ \\\\ \n',cell_data{j,1}, ...
            cell_data{j,2}(1), cell_data{j,2}(2), cell_data{j,2}(3), ...
            cell_data{j,3}(1), cell_data{j,3}(2), cell_data{j,3}(3));
    elseif cell_data{j,4} <= 0.01
        fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & \\textbf{%.3f} \\\\ \n',cell_data{j,1}, ...
            cell_data{j,2}(1), cell_data{j,2}(2), cell_data{j,2}(3), ...
            cell_data{j,3}(1), cell_data{j,3}(2), cell_data{j,3}(3), ...
            cell_data{j,4});
    else
        fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & %.3f \\\\ \n',cell_data{j,1}, ...
            cell_data{j,2}(1), cell_data{j,2}(2), cell_data{j,2}(3), ...
            cell_data{j,3}(1), cell_data{j,3}(2), cell_data{j,3}(3), ...
            cell_data{j,4});
    end
end

fprintf(FID, '\\bottomrule\n');
fprintf(FID, '\\end{tabular}\n');
fprintf(FID, '}\n');
fclose(FID);

%% File 2

FID = fopen(strcat(filename(1:end-4),'_data.tex'), 'w');
fprintf(FID, '\\caption{%s}\n',sprintf('Data analysis of study patients with no vasopressors (n = %d).',sum(Ni)));
fprintf(FID, '\\centerline{\\small \n');
fprintf(FID, '\\begin{tabular}{l r l c r l c}\n');
fprintf(FID, '\\toprule\n');
fprintf(FID, '& \\multicolumn{5}{c}{\\textbf{No. (\\%%) [95\\%% CI] of Patients}} & \\\\ \n');
fprintf(FID, '& \\multicolumn{5}{c}{\\textbf{Median (Interquartile Range)}} & \\\\ \n');
fprintf(FID, '\\cmidrule(l){2-6} \n');
fprintf(FID, '& \\multicolumn{2}{c}{Lactate $<2$} & ~~~ & \\multicolumn{2}{c}{Lactate $>2$} & P \\\\ \n');
fprintf(FID, '& \\multicolumn{2}{c}{(n=%d , %d\\%%)} & & \\multicolumn{2}{c}{(n=%d, %d\\%%)} & value \\\\ \n',Ni(1),round(Ni(1)/sum(Ni)*100),Ni(2),round(Ni(2)/sum(Ni)*100));
fprintf(FID, '\\hline\n');

vec = 6 : 35;
for j = vec
    if j == 6
        fprintf(FID, 'Systolic BP, mmHg: & & & & & & \\\\ \n');
    elseif j == 11
        fprintf(FID, 'Diastolic BP, mmHg: & & & & & & \\\\ \n');
    elseif j == 16
        fprintf(FID, 'Pulse Pressure, mmHg: & & & & & & \\\\ \n');
    elseif j == 21
        fprintf(FID, 'Mean Arterial Pressure, mmHg: & & & & & & \\\\ \n');
    elseif j == 26
        fprintf(FID, 'Heart Rate, bpm: & & & & & & \\\\ \n');
    elseif j == 31
        fprintf(FID, 'Cardiac Output: & & & & & & \\\\ \n');
    end
    if cell_data{j,4} < 0.001
        fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & $\\mathbf{<0.001}$ \\\\ \n',cell_data{j,1}, ...
            cell_data{j,2}(1), cell_data{j,2}(2), cell_data{j,2}(3), ...
            cell_data{j,3}(1), cell_data{j,3}(2), cell_data{j,3}(3));
    elseif cell_data{j,4} <= 0.01
        fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & \\textbf{%.3f} \\\\ \n',cell_data{j,1}, ...
            cell_data{j,2}(1), cell_data{j,2}(2), cell_data{j,2}(3), ...
            cell_data{j,3}(1), cell_data{j,3}(2), cell_data{j,3}(3), ...
            cell_data{j,4});
    else
        fprintf(FID, '%s & %.1f & (%.1f-%.1f) & & %.1f & (%.1f-%.1f) & %.3f \\\\ \n',cell_data{j,1}, ...
            cell_data{j,2}(1), cell_data{j,2}(2), cell_data{j,2}(3), ...
            cell_data{j,3}(1), cell_data{j,3}(2), cell_data{j,3}(3), ...
            cell_data{j,4});
    end
end

fprintf(FID, '\\bottomrule\n');
fprintf(FID, '\\end{tabular}\n');
fprintf(FID, '}\n');
fclose(FID);

%% File 3

% FID = fopen(strcat(filename(1:end-4),'_elix.tex'), 'w');
% fprintf(FID, '\\caption{%s}\n',sprintf('Elixhauser components of study patients (n = %d).',sum(Ni)));
% fprintf(FID, '\\centerline{\\small \n');
% fprintf(FID, '\\begin{tabular}{l r l c r l c}\n');
% fprintf(FID, '\\toprule\n');
% fprintf(FID, '& \\multicolumn{5}{c}{No. (\\%%) [95\\%% CI] of Patients} & \\\\ \n');
% fprintf(FID, '\\cmidrule(l){2-6} \n');
% fprintf(FID, '& \\multicolumn{2}{c}{Survivors} & ~~~ & \\multicolumn{2}{c}{Nonsurvivors} & P \\\\ \n');
% fprintf(FID, '& \\multicolumn{2}{c}{(n=%d , %d\\%%)} & & \\multicolumn{2}{c}{(n=%d, %d\\%%)} & value \\\\ \n',Ni(1),round(Ni(1)/sum(Ni)*100),Ni(2),round(Ni(2)/sum(Ni)*100));
% fprintf(FID, '\\hline\n');
% 
% fprintf(FID, 'Elixhauser components: & & & & & & \\\\ \n');
% for i = 1 : length(cell_elix)
%     if cell_elix{i,2}(1) == 0 && cell_elix{i,3}(1) == 0
%         fprintf(FID, '%s & 0 & (0) [0-0] & & 0 & (0) [0] & NA \\\\ \n',cell_elix{i,1});
%     elseif cell_elix{i,4} < 0.001
%         fprintf(FID, '%s & %d & (%d) [%d-%d] & & %d & (%d) [%d-%d] & $\\mathbf{<0.001}$ \\\\ \n',cell_elix{i,1}, ...
%             cell_elix{i,2}(1), round(cell_elix{i,2}(2)), round(cell_elix{i,2}(3)), round(cell_elix{i,2}(4)), ...
%             cell_elix{i,3}(1), round(cell_elix{i,3}(2)), round(cell_elix{i,3}(3)), round(cell_elix{i,3}(4)));
%     elseif cell_elix{i,4} <= 0.01
%         fprintf(FID, '%s & %d & (%d) [%d-%d] & & %d & (%d) [%d-%d] & \\textbf{%.3f} \\\\ \n',cell_elix{i,1}, ...
%             cell_elix{i,2}(1), round(cell_elix{i,2}(2)), round(cell_elix{i,2}(3)), round(cell_elix{i,2}(4)), ...
%             cell_elix{i,3}(1), round(cell_elix{i,3}(2)), round(cell_elix{i,3}(3)), round(cell_elix{i,3}(4)), ...
%             cell_elix{i,4});
%     else
%         fprintf(FID, '%s & %d & (%d) [%d-%d] & & %d & (%d) [%d-%d] & %.3f \\\\ \n',cell_elix{i,1}, ...
%             cell_elix{i,2}(1), round(cell_elix{i,2}(2)), round(cell_elix{i,2}(3)), round(cell_elix{i,2}(4)), ...
%             cell_elix{i,3}(1), round(cell_elix{i,3}(2)), round(cell_elix{i,3}(3)), round(cell_elix{i,3}(4)), ...
%             cell_elix{i,4});
%     end
% end
% fprintf(FID, '\\bottomrule\n');
% fprintf(FID, '\\end{tabular}\n');
% fprintf(FID, '}\n');
% fclose(FID);
