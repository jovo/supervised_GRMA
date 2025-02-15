% mu = [1 -1]; Sigma = [.9 .4; .4 .3];
% r = mvnrnd(mu, Sigma, 500);
% figure;
% plot(r(:,1),r(:,2),'.');


% plot(normpdf(-4:0.01:4, 0, 1), 'x-') 



% A = rand(3,3);
% B = A'*A
% eig(B)


% A = normrnd(0,1,10000, 1);
% plot(A, 'x')
% B = normrnd(0,1,10000,1);
% plot(A,B, 'x')
% 
% close all;
% mu1 = [ 0 0];
% Sigma1 = [ 1 0; 0 1]
% C = mvnrnd(mu1, Sigma1, 50000);
% figure;
% plot(C(:,1), C(:,2), 'x')
% hold on;
% 
% mu1 = [ 0 0];
% Sigma1 = [ 1 1; 1 1]
% C = mvnrnd(mu1, Sigma1, 50000);
% hold on;
% plot(C(:,1), C(:,2), 'rx')
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% %% Test Mean Probability of MVN with different dimensions
% 
% Comment: This test of mean probability does not work
% It does go to zero
% First, if you sum normpdf from -1 to 1 with very short steps, you will ge
% t a very large number >>1
% Second, by equal weight, there are too many f(x) = 0 as we increase the domain 

% % Dim = 1
% 
% N1 = 1000;
% A1 = normpdf(linspace(-4,4,N1), 0, 1);
% % figure;
% % plot(A, 'x-')
% mean(A1)
% 
% N2 = 10000;
% A2 = normpdf(linspace(-4,4,N2), 0, 1);
% mean(A2)
% 
% 
% N3 = 10000;
% A3 = normpdf(linspace(-4,4,N3), 0, 1);
% mean(A3)
% 
% 
% N4 = 100000;
% A4 = normpdf(linspace(-4,4,N4), 0, 1);
% mean(A4)
% 
% 
% % Dim = 2
% clear all;
% N1 = 1000; % 200 400 800 1600
% grid = linspace(-4,4, N1);
% [x,y] =meshgrid(grid,grid);
% X = reshape(x, numel(x), 1);
% Y = reshape(y, numel(y), 1);
% Z = [X Y];
% mu0 = [ 0 0];
% Sigma0 = [ 1 0; 0 1]
% B1 =mvnpdf(Z, mu0, Sigma0);
% whos B1
% mean(B1)
% 
% % Different Sigma for Dim = 2
% clear all;
% N1 = 1000; % 200 400 800 1600
% grid = linspace(-4,4, N1);
% [x,y] =meshgrid(grid,grid);
% X = reshape(x, numel(x), 1);
% Y = reshape(y, numel(y), 1);
% Z = [X Y];
% mu0 = [ 0 0];
% Sigma0 = [ 1 0.8; 0.8 1]
% B1 =mvnpdf(Z, mu0, Sigma0);
% whos B1
% mean(B1)
% 
% 
% % Dim = 2
% clear all;
% N1 = 1000; % 200 400 800 1600
% grid = linspace(-4,4, N1);
% [x,y] =meshgrid(grid,grid);
% X = reshape(x, numel(x), 1);
% Y = reshape(y, numel(y), 1);
% Z = [X Y];
% mu0 = [ 0 0];
% Sigma0 = [ 1 0; 0 1]
% B2 =mvnpdf(Z, mu0, Sigma0);
% whos B2
% mean(B2)
% 
% % Different Sigma for Dim = 2
% clear all;
% N1 = 1000; % 200 400 800 1600
% grid = linspace(-4,4, N1);
% [x,y] =meshgrid(grid,grid);
% X = reshape(x, numel(x), 1);
% Y = reshape(y, numel(y), 1);
% Z = [X Y];
% mu0 = [ 0 0];
% Sigma0 = [ 1 0.5; 0.5 1]
% B3 =mvnpdf(Z, mu0, Sigma0);
% whos B3
% mean(B3)
% 
% % Dim=1: 0.125
% % Dim=2: 0.0156
% % Dim=3: 0.0019
% Test = mvnpdf(mu0, mu0, Sigma0)
% 
% % What happens if we put in the mean vector, I expect the probability to be
% % the same as above:
% % No it's not. Always don't confuse with mean vector does not lead to mean
% % probability of the distribution
% 
% 
% % Dim = 3
% 
% 
% % Different Sigma for Dim = 3
% clear all;
% 
% Sigma{1} = [ 1 0 0 ; 0 1 0; 0 0 1]
% Sigma{2} = [ 1 0.5 0.5; 0.5 1 0.5; 0.5 0.5 1];
% Sigma{3} = [ 1 0.1 0.1; 0.1 1 0.1; 0.1 0.1 1];
% Sigma{4} = [ 1 0.1 0.4; 0.1 1 0.8; 0.4 0.8 1];
% 
% 
% for i = 1:4
%     N1 = 100; % 200 400 800 1600
%     grid = linspace(-4,4, N1);
%     [x,y,z] =meshgrid(grid,grid,grid);
%     X = reshape(x, numel(x), 1);
%     Y = reshape(y, numel(y), 1);
%     Z = reshape(z, numel(z), 1);
%     clear x y z
%     W = [X Y Z];
%     mu0 = [ 0 0 0];
%     B3 =mvnpdf(W, mu0, Sigma{i});
%     whos B3
%     mean(B3)
% end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



clear all
%% Testing for unbiased probability estimation for normal distribution
N1 = 10^8
mu1 = -1;
std1 = 3;
A1 = mean(normpdf(normrnd(mu1,std1, N1, 1), mu1, std1))
% S1 = sum(normpdf(normrnd(0,1, N1, 1), 0, 1))
% This converges to 1/(2*sqrt(pi))
dx = 0.01;
domain = [mu1-std1*8 mu1+std1*8];
% Nsample = (domain(2) - domain(1))./dx;
% sample_domain = linspace(domain(1), domain(2), Nsample);
sample = domain(1): dx: domain(2);
% B2 = sum(dx.*normpdf(sample, 0, 1));  % YES!!! it gets to 1.

B3 = sum(dx.*normpdf(sample, mu1, std1).^2)    % YES!!!!!!!! it gets to 0.2821
% where 0.2821 is 1/(2*sqrt(pi)) and value of the following:
% mean(normpdf(normrnd(0,1,N1, 1), 0, 1))
EasyWay = 1/(std1*2*sqrt(pi))
% RESULT: mean of the distribution does not change the mean probability
% standard deviation of the distribution changes it.
% Let's test whether covariance affects it with Dim = 2


%% Testing estimation of variance from PDF and
%% whether scaling a PDF changes the the variance

clear all; close all

dx = 0.0001;
mu1 = 13;
var1 = 18;
std1 = sqrt(var1);
X = mu1 - 10*std1: dx :mu1 + 10*std1;
Y = normpdf(X, mu1, std1);
% Y = 0.01.*Y; % This DOES NOT work
% sum(dx*Y) 
% % results in 0.9999999999999999999
EXP_X = sum(X.*(dx.*Y));
% % results in 12.999999999999947
EXP_X2 = sum(X.^2.*(dx.*Y));
VAR_X2 = EXP_X2 - EXP_X.^2

%% Rescaling the conditional distribution with P(X1 = x1)

clear all; close all;
mu1 = 1;
mu2 = -1;
covX1 = 1; covX1X2 = 0.9; covX2 = 4;
mu = [1 -1]; Sigma = [covX1 covX1X2; covX1X2 covX2];
% figure; 
for x1 = -3:1:3
    dx = 0.001;
    x2 = mu2 - covX2*10: dx: mu2 + covX2*10;
    [X1,X2] = meshgrid(x1,x2);
    X = [X1(:) X2(:)];
    p = mvnpdf(X, mu, Sigma);
    p = p./sum(dx*p);
%     plot(p, 'x'); hold on;
%     sum(dx*p)
%     mvnpdf(x1, mu1, covX1)
%     % ok first the above two are the same.
    EXP_X = sum(x2'.*(dx.*p));
    EXP_X2 = sum(x2'.^2.*(dx.*p));
    VAR_X2 = EXP_X2 - EXP_X.^2
end

VarX2givenX1_condCov = condCov(Sigma, 1)
% Result: 
% The conditional variance of X2 rescaled by dividing by the P(X1 = x1) is same and
% independent on the x1 value.
% Furthermore, it's same with the block matrix conditional variance value.

close all;
clear all;
% Dim = 2, slightly different: X1 known, X2 unknown
N1 = 10^9;
muX1 = 0;
muX2 = 100;
VarX1 = 1;
CovX1X2 = 0.5;
VarX2 = 1;
mu1 = [muX1 muX2]; 
Sigma1 = [VarX1 CovX1X2; CovX1X2 VarX2]; 
X = mvnrnd(mu1, Sigma1, N1);
% figure;
% plot(X(:,1), X(:,2), 'rx')
domain = [-7 7]
% figure; 
% hist(X(:,1), 100)
% figure; 
% hist(X(:,2), 100)
%% Fix X1
X1 = 5; X1_nghbr = 0.01;
X_X1equal3 = X(X(:,1) < X1+ X1_nghbr & X(:,1) > X1 - X1_nghbr, :);
figure;
hist(X_X1equal3(:,2), 30)
MeanX2givenX1_obs = mean(X_X1equal3(:,2))
VarX2givenX1_obs = var(X_X1equal3(:,2))

% VarX2givenX1 = mvnpdf(

MeanX2givenX1_est = muX2 + CovX1X2*inv(VarX1)*(X1 - muX1)
VarX2givenX1_est = VarX2 - CovX1X2*inv(VarX1)*CovX1X2
VarX2givenX1_condCov = condCov(Sigma1, 1)
%RESULTS: YESSSSSS! This works...!!!!! I can estimate the conditional expected value 
%and the conditional variance with this formula.
% I should test this formula on conditional "mean probability" too.

MeanProb_obs = mean(mvnpdf(X_X1equal3, mu1, Sigma1))
MeanProb_est = mvnpdf(X1, muX1, VarX1)*1/(sqrt(VarX2givenX1_est)*2*sqrt(pi))
%RESULTS: The mean probability given X1 value is NOT affected by:
% mean of X2
% but IS affected by the covariance of X1 and X2.
% And YES!! We can estimate the conditional mean probability.


%% Test: Mean probability of X1 and X2 (both unknown)
clear all
N = 10^8;
mu1 = 0;
mu2 = 0;
mu = [ mu1 mu2 ];
var1 = 0.5; var2 = 2; cov = 0.9;
Sigma = [var1 cov; cov var2];

MeanProb_obs = mean(mvnpdf(mvnrnd(mu,Sigma, N), mu, Sigma)) 

dx = 0.001;
domX1 = [mu1-var1*8 mu1+var1*8];
domX2 = [mu2-var2*8 mu2+var2*8];
sampX1 = domX1(1): dx: domX1(2);
sampX2 = domX2(1): dx: domX2(2);
[sampX1, sampX2] = meshgrid(sampX1, sampX2);
sampX = [sampX1(:) sampX2(:)];
MeanProb_est = sum(dx.^2*mvnpdf(sampX, mu, Sigma).^2)   


MeanProb_drv = (1/(sqrt(var1)*2*sqrt(pi)))*(1/(sqrt(var2)*2*sqrt(pi)))*(1/sqrt(det(Sigma)))

    
%% Test: Mean probability of X1, X2, and X3 (all unknown)
clear all
N = 10^8;
mu1 = 0;
mu2 = 0;
mu3 = 0;
mu = [ mu1 mu2 mu3 ];
var1 = 1; var2 = 1; var3 = 1; cov12 = 0.9; cov13 = 0.8; cov23 = 0.5;
Sigma = [var1 cov12 cov13; cov12 var2 cov23; cov13 cov23 var3];

MeanProb_obs = mean(mvnpdf(mvnrnd(mu,Sigma, N), mu, Sigma)) 

dx = 0.05;
domX1 = [mu1-var1*8 mu1+var1*8];
domX2 = [mu2-var2*8 mu2+var2*8];
domX3 = [mu3-var3*8 mu3+var3*8];
sampX1 = domX1(1): dx: domX1(2);
sampX2 = domX2(1): dx: domX2(2);
sampX3 = domX3(1): dx: domX3(2);
[sampX1, sampX2, sampX3] = meshgrid(sampX1, sampX2, sampX3);
sampX = [sampX1(:) sampX2(:) sampX3(:)];

MeanProb_est = sum(dx.^3*mvnpdf(sampX, mu, Sigma).^2)   

MeanProb_drv = (1/(sqrt(var1)*2*sqrt(pi)))*(1/(sqrt(var2)*2*sqrt(pi)))...
    *(1/(sqrt(var3)*2*sqrt(pi)))*(1/sqrt(det(Sigma)))

logMeanProb = meanProb(Sigma);
MeanProb  = exp(logMeanProb)


clear all
%% Test: Mean probability of X2 with fixed X1 = 1 (DIM=2)
N1 = 10^8;
mu1 = [0 0]; 
Sigma1 = [1 0.8; 0.8 2]; 
dx = 0.01;
x1 = 2;
[X1, X2 ] = meshgrid(x1, -10:dx:10);
X = [X1(:) X2(:)];
whos X
Y = mvnpdf(X, mu1, Sigma1);
whos Y
p_X2sumX1equals1 = sum(dx.*mvnpdf(X, mu1, Sigma1))
p_X1equals1 = mvnpdf(x1, mu1(1), Sigma1(1))
%RESULTS: As expected, the value of the covariance does not affect the
%results.


clear all
%% Test: Sum of probability of X2 with fixed X1 = 1 
% EQUALS probability of X1 = 1
N1 = 10^8;
mu1 = [0 0]; 
Sigma1 = [1 0.8; 0.8 2]; 
dx = 0.01;
x1 = 2;
[X1, X2 ] = meshgrid(x1, -10:dx:10);
X = [X1(:) X2(:)];
whos X
Y = mvnpdf(X, mu1, Sigma1);
whos Y
p_X2sumX1equals1 = sum(dx.*mvnpdf(X, mu1, Sigma1))
p_X1equals1 = mvnpdf(x1, mu1(1), Sigma1(1))
%RESULTS: As expected, the value of the covariance does not affect the
%results.
% The sum of sum(Pr(X2, X1=x1)) = Pr(X1 = x1), which is only affected by
% var(X1).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Testing the surface


% %% Testing the distribution of x2 with fixed x1
% X = [ 0 0]
% mu = [ 0 1];
% Sigma = [ 1 0 ; 0 1];
% Prob1 = mvnpdf(X, mu, Sigma)
% X1 = 0; X2 = 0;
% mu1 = 0; mu2 = 1;
% Prob2 = mvnpdf(X1, mu1, 1) * mvnpdf(X2, mu2, 1)
% 
% 
% X = [ 0 0]
% mu = [ 2 1];
% Sigma = [ 1 0.5 ; 0.5 1];
% Prob1 = mvnpdf(X, mu, Sigma)
% X1 = 0; X2 = 0;
% mu1 = 2; mu2 = 1;
% K = 0.5/(X1 - mu1) ;
% condmu = K + mu2
% Prob2 = mvnpdf(X1, mu1, 1) * mvnpdf(X2, condmu, K)
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% 
% 
% 
% 
% clear all;
% grid = -4:0.01:4;
% [x,y] =meshgrid(grid,grid);
% X = reshape(x, numel(x), 1);
% Y = reshape(y, numel(y), 1);
% Z = [X Y];
% mu0 = [ 0 0];
% Sigma0 = [ 1 0; 0 1]
% B1 =mvnpdf(Z, mu0, Sigma0);
% whos B1
% mean(B1)
% 
% 
% 
% 
% mu1 = [ 0 0];
% Sigma1 = [ 1 1; 1 1]
% C =normpdf(-4:0.01:4, mu1, Sigma1);
% whos C
% mean(C)
% 
% 
% 
% 
