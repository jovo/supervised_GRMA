function BIC = computeBIC(X_train, Labels_train, paramsBIC, classifier, fullCovMat)
%computeBIC.m computes the BIC value of each LOL model with different k.

%% Parameters for BIC

X_train = X_train'; % Ntrain by k
[Ntrain, Ktrain]  = size(X_train);

%% Compute Maximized value of the likelihood function
disp('logdetcov in computeBIC.m')
logdetcov = -0.5*logdet(paramsBIC.PooledCov); 
% logdetcov = -0.5*logdet(paramsBIC.PooledCov, 'chol'); 
otherConst = -0.5*Ktrain*log(2*pi);
% otherConst = 0;
TotalConst = Ntrain*(logdetcov + otherConst);
PriorTerm = paramsBIC.nGroup' * paramsBIC.PriorProb;
MainTerm = 0;
sumX = zeros(Ktrain, 1);

for i = 1: numel(classifier.ClassLabel)
     Group = (Labels_train == classifier.ClassLabel(i));
%      centeredX = bsxfun(@minus, X_train(Group,:), mean(X_train(Group,:), 1));
     centeredX2 = bsxfun(@minus, X_train(Group,:), paramsBIC.GroupMean(i,:));
     mainterm = centeredX2 * paramsBIC.invCov;
%      max(max(paramsBIC.invCov))
%      find(mean(centeredX,2)>0.01)
    
%     for j = 1:size(centeredX, 1)
%         sumX = sumX - 1/2*centeredX(j, :)*paramsBIC.invCov*centeredX(j, :)';
%     end
     MainTerm = MainTerm -0.5*sum(sum(mainterm.*centeredX2, 2));
end  

% for i = 1: Ntrain
%     Labels_train(i) == classifier.ClassLabel
L = TotalConst + PriorTerm + MainTerm; % Likelihood function: L(Data|Model); the joint probability of data and label 

%% Compute the compensating (conditional) likelihood for (D-k) dimensions
% Ktrain
condcov = condCov(fullCovMat, Ktrain);
% sum(sum(condcov))
logmeanprob = meanProb(condcov);
% logmeanprob
% L
L = L + Ntrain*logmeanprob;

%% Determine the number of free parameters
numMean		= numel(paramsBIC.nGroup)
numPrior	= numel(paramsBIC.nGroup);
size(classifier.W)
numCov 		= Ktrain.^2*numel(paramsBIC.nGroup)
numCov  = Ktrain.^3;
numClassifierCoeff = numel(classifier.W) % (Dtrain+1)* ClassLabel
numProjectionMatrix = Ktrain*784
% numClassifierCoeff = size(classifier.W, 1);
%disp('check whether same')
%(Ktrain + 1)* numel(classifier.ClassLabel)
%numProjectionMatrixCoeff
k = numMean + numPrior + numCov + numClassifierCoeff + numProjectionMatrix;
BIC.BIC = -2*L + k*(log(Ntrain) - log(2*pi)); 
% disp('TotalConst, PriorTerm, MainTerm, L, the other term')
BIC.TotalConst = TotalConst;
BIC.PriorTerm  = PriorTerm;
BIC.MainTerm   = MainTerm;
BIC.Likelihood = L;
BIC.PenalizingTerm   = k*(log(Ntrain) - log(2*pi));
BIC.logdetcov  = logdetcov;
BIC.otherConst = otherConst;
BIC.sumX = sumX;
% normalDist = -0.5*logdet(paramsBIC.PooledCov) - centeredX'*paramsBIC.invCov*centeredX - 
% normalDist = -0.5*logdet(paramsBIC.PooledCov) - (X_train(paramsBIC.Group,:)-paramsBIC.GroupMean)'*paramsBIC.invCov* - D*....
% normalDist = -0.5*(log(det(cov_mat)) - (X-mean)'*inv(cov_mat)*(X-mean) - D*log(2*pi));
% max_L = sum(normalDist*prior)



end

