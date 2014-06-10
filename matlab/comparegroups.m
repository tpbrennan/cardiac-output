function [cell_name] = comparegroups(data,group,params,paramLabels,whichtest)

data0 = data(group==0,:); N0 = size(data0,1);
data1 = data(group==1,:);  N1 = size(data1,1);

D = length(params);

fprintf('\nN1 = %d, N2 = %d\n\n',N0,N1);
for i = 1 : D
    switch whichtest{i}
        case 'prop'
            n0 = sum(data0(:,params(i)));
            n1 = sum(data1(:,params(i)));
            [pval, CI0, CI1] = testProportions(n0,N0,n1,N1);
            fprintf('%s: \nGroup 0: %d, (%.1f) [%.1f-%.1f]\nGroup 1: %d, (%.1f) [%.1f-%.1f]\np-val = %.5f\n\n', ...
                paramLabels{i},CI0(1),CI0(2),CI0(3),CI0(4),CI1(1),CI1(2),CI1(3),CI1(4),pval);
            cell_name{i,1} = paramLabels{i};
            cell_name{i,2} = CI0;
            cell_name{i,3} = CI1;
            cell_name{i,4} = pval;
        case 'median'
            [pval, CI0, CI1] = testMedians(data0(:,params(i)),data1(:,params(i)));
            fprintf('%s: \nGroup 0: %.1f (%.1f-%.1f)\nGroup 1: %.1f (%.1f-%.1f)\np-val = %.5f\n\n', ...
                paramLabels{i},CI0(1),CI0(2),CI0(3),CI1(1),CI1(2),CI1(3),pval);
            cell_name{i,1} = paramLabels{i};
            cell_name{i,2} = CI0;
            cell_name{i,3} = CI1;
            cell_name{i,4} = pval;
            
        case 'mean'
            [pval, CI0, CI1] = testMeans(data0(:,params(i)),data1(:,params(i)));
            fprintf('%s: \nGroup 0: %.1f (%.1f-%.1f)\nGroup 1: %.1f (%.1f-%.1f)\np-val = %.5f\n\n', ...
                paramLabels{i},CI0(1),CI0(2),CI0(3),CI1(1),CI1(2),CI1(3),pval);
            cell_name{i,1} = paramLabels{i};
            cell_name{i,2} = CI0;
            cell_name{i,3} = CI1;
            cell_name{i,4} = pval;
    end
end
