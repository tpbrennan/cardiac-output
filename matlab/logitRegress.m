function res=logitRegress(X,Y,nFolds)

%
% This function fits a logistic regression model to the given model.
%
% Inputs:
% X - input data matrix, rows are subjects and columns are covariates.
% Y - outcome variable, each element matching each row in X, can be binary
% or categorial
% nFolds - number of folds in cross-validation
%
% Outputs:
% res - structure containing logistic regression results.
%

res.N=size(X,1);

if ~isempty(find(Y>1))
    
    res.N_Y = zeros(1,max(Y));
    for i = 1:max(Y)
        res.N_Y(i) = sum(Y==i);
    end
    
    [res.b,res.dev,res.stats] = mnrfit(X,Y);
    
    res.yfit = mnrval(res.b,X);
else
    res.N_true=sum(Y==1);
    res.N_false=sum(Y==0);
    
    [res.b,res.dev,res.stats]=glmfit(X,Y,'binomial','link','logit');
    
    res.yfit=glmval(res.b,X,'logit');

end

% Compute Recive Operating Curve & AUC
res.ytarget=Y;
[tpr fpr]=roc(res.ytarget',res.yfit');
res.auc=computeAUC(tpr,fpr);

% Assess goodness-of-fit
res.HLtestp=HosmerLemeshowTest(res.yfit,Y);

% cross-validation
randidx=randperm(res.N);
Xrand=X(randidx,:);
Yrand=Y(randidx);
temp=[];
yfit_xval=[];
ytarget_xval=[];

for k=0:nFolds-1
    testIdx=mod(1:res.N,nFolds)==k;
    trainIdx=~testIdx;
    
    if ~isempty(find(Y>1))
        b = mnrfit(Xrand(trainIdx,:),Yrand(trainIdx));
        prob = mnrval(b,Xrand(testIdx,:));
    else
        b=glmfit(Xrand(trainIdx,:),Yrand(trainIdx),'binomial','link','logit');
        prob=glmval(b,Xrand(testIdx,:),'logit');
    end
    
    yfit_xval=[yfit_xval; prob];
    ytarget_xval=[ytarget_xval; Yrand(testIdx)];
    [tpr,fpr]=roc(Yrand(testIdx)',prob');
    temp=[temp computeAUC(tpr,fpr)];
end

res.xvalvec=temp;
res.xval=[mean(temp) std(temp)];
res.yfit_xval=yfit_xval;
res.ytarget_xval=ytarget_xval;

