%% Demo Gaussian Process by MAF Pimentel
% This is a demonstration on how different covariance functions can be
% combined in order to make a proper regression to the data and make
% predictions. In the first GP we use a periodic covariance function and
% try to make predictions. In the second GP, we do not use the periodic cov
% function. The difference is: although we can make a very good regression
% on the training data with both models, only the first one can be used to
% make good predictions.
% 
% This demo uses data downloaded from
%   ftp://ftp.cmdl.noaa.gov/ccg/co2/trends/co2_mm_mlo.txt
% and pre-processed using
%   tail -n 637 co2_mm_mlo.txt | awk '{ print $3, " ", $4 }' > mauna.txt
% It mainly contains two column vectors: time (in years), and CO2
% concentration readings performed in each month/year

% Load the data
load mauna.txt
z = mauna(:,2) ~= -99.99;               % get rid of missing data
year = mauna(z,1); co2 = mauna(z,2);    % extract year and CO2 concentration

% Lets split the data in training and test sets
x = year(year<2006); y = co2(year<2006);            % training data
xx = year(year>2006); yy = co2(year>2006);          % test data

%% First example using a periodic cov function
% Here are the covariance contributions:
k1 = @covSEiso;                                 % long term trend
k2 = {@covProd, {@covPeriodic, @covSEisoU}};    % a quasi-periodic component (the amplitude of the oscillations varies)
k3 = @covRQiso;                                 % fluctations with different length-scales
k4 = @covSEiso;                                 % very short term (month to month) correlations 
covfunc = {@covSum, {k1, k2, k3, k4}};          % sum up the covariance terms

% Select priors for the covariance parameters. To evaluate the number of
% parameters in the covariance function use: feval(covfunc{:})
hyp0.cov = [4.2 4.2 0.26 0 0.88 4.5 0.18 -.4 -.2 -1.7 -1.7];
hyp0.lik = -2;               

% Fit the GP model
[hyp fX i] = minimize(hyp0, @gp, -500, @infExact, [], covfunc, @likGauss, x, y-mean(y));

% Make predictions 10 years into the future
zz = (x(1):1/12:2022)';
[mu s2] = gp(hyp, @infExact, [], covfunc, @likGauss, x, y-mean(y), zz);

% Plot the data and the predictions
figure(1); subplot(121);
f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)] + mean(y);
fill([zz; flipdim(zz,1)], f, [7 7 7]/8); hold on; 
plot(zz, mu + mean(y),'--k'); plot(x,y,'b.'); plot(xx,yy,'r.');                            
xlabel('Year'); ylabel('CO_2 concentration, ppm');
title('GP-1 sexp+periodic+sexp+noise');

%% Second example with additive model
% Here are the covariance contributions for this second GP model:
k11 = @covSEiso;                                % long term trend
k21 = @covSEiso;                                % fluctuations in order to cope with periodic component
k31 = @covSEiso;                                % very short term (noise)
covfunc1 = {@covSum, {k11, k21, k31}};          % sum up the covariance terms

% Select priors for the covariance parameters.
hyp1.cov = [4.2 4.2 1 1 -1.7 -1]; hyp1.lik = -2;

% Fit the GP model
[hyp1 fX i] = ...
    minimize(hyp1, @gp, -500, @infExact, [], covfunc1, @likGauss, x, y-mean(y));
 
% Make predictions 10 years into the future
[mu s2] = gp(hyp1, @infExact, [], covfunc1, @likGauss, x, y-mean(y), zz);

% Plot the data and the predictions
figure(1); subplot(122);
f = [mu+2*sqrt(s2); flipdim(mu-2*sqrt(s2),1)] + mean(y);
fill([zz; flipdim(zz,1)], f, [7 7 7]/8); hold on; 
plot(zz, mu + mean(y),'--k'); plot(x,y,'b.'); plot(xx,yy,'r.');                            
xlabel('Year'); ylabel('CO_2 concentration, ppm');
title('GP-2 sexp+sexp+noise');
