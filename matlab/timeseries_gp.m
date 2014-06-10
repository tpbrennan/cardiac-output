function [nlZ] = timeseries_gp(xtr, ytr);

T = max(xtr);
xte = linspace(0,T,1e4)';                    

% setup the GP
cov1 = {@covProd,{@covPeriodic,@covSEiso}};
cov = {@covSum,{cov1,@covNoise}}; % Spuared-exponential with iotropic distance measure
hyp0.cov  = log([0.4;1;0;0.88;4.5;1]); % init hypoperameters

mean = {@meanSum,{@meanLinear,@meanConst}}; % m(x) = a*x+b
a = 1/5; b = 1;       
hyp0.mean = [a;b]; % initialise the mean function

% likGauss, infExact
lik_list = {'likGauss','likLaplace','likSech2','likT'};   % possible likelihoods
inf_list = {'infExact','infLaplace','infEP','infVB'};     % allowable inference algs

Ncg = 50;                     % number of conjugate gradient steps, to estimate hypers
sdscale = 1;                  % how many sd wide should the error bars become?

col = {'k',[.8,0,0],[0,.5,0],'b',[0,.75,.75],[.7,0,.5]};                % colors

ymu{1} = f(xte); 
ys2{1} = sn^2; 
nlZ(1) = -Inf;
for i=1:size(id,1)
  lik = lik_list{id(i,1)};                                % setup the likelihood
  if strcmp(lik,'likT')
    nu = 4;
    hyp0.lik  = log([nu-1;sqrt((nu-2)/nu)*sn]);
  else
    hyp0.lik  = log(sn);
  end
  inf = inf_list{id(i,2)};
  fprintf('OPT: %s/%s\n',lik_list{id(i,1)},inf_list{id(i,2)})
  if Ncg==0
    hyp = hyp0;
  else
    hyp = minimize(hyp0,'gp', -Ncg, inf, mean, cov, lik, xtr, ytr);    % estimate hypers
  end
  hyp0;
  %hyp.cov = [-1.4615;-0.1578]; %likGauss hypers
  %hyp.cov = [0.5023; -0.1102];
  [ymu{i+1}, ys2{i+1}] = gp(hyp, inf, mean, cov, lik, xtr, ytr, xte);  % predict
  [nlZ(i+1)] = gp(hyp, inf, mean, cov, lik, xtr, ytr);
end

figure, hold on
for i=1:size(id,1)+1
  plot(xte,ymu{i},'Color',col{i},'LineWidth',2)
  if i==1
    leg = {'function'};
  else
    leg{end+1} = sprintf('%s/%s -lZ=%1.2f',...
                                lik_list{id(i-1,1)},inf_list{id(i-1,2)},nlZ(i));
  end
end
for i=1:size(id,1)+1
  ysd = sdscale*sqrt(ys2{i});
  fill([xte;flipud(xte)],[ymu{i}+ysd;flipud(ymu{i}-ysd)],...
       col{i},'EdgeColor',col{i},'FaceAlpha',0.1,'EdgeAlpha',0.3);
end
for i=1:size(id,1)+1, plot(xte,ymu{i},'Color',col{i},'LineWidth',2), end
plot(xtr,ytr,'k+'), plot(xtr,ytr,'ko'), legend(leg)
