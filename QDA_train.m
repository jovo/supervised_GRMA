function [classifier_trained] = QDA_train(Input,Target,Priors)

% LDA - MATLAB subroutine to perform linear discriminant analysis
% by Will Dwinnell and Deniz Sevis - modified by Mauro Maggioni
%
% Use:
% W = LDA(Input,Target,Priors)
%
% W       = discovered linear coefficients (first column is the constants)
% Input   = predictor data (variables in columns, observations in rows)
% Target  = target variable (class labels)
% Priors  = vector of prior probabilities (optional)
%
% Note: discriminant coefficients are stored in W in the order of unique(Target)
%
% Example:
%
% % Generate example data: 2 groups, of 10 and 15, respectively
% X = [randn(10,2); randn(15,2) + 1.5];  Y = [zeros(10,1); ones(15,1)];
%
% % Calculate linear discriminant coefficients
% W = LDA(X,Y);
%
% % Calulcate linear scores for training data
% L = [ones(25,1) X] * W';
%
% % Calculate class probabilities
% P = exp(L) ./ repmat(sum(exp(L),2),[1 2]);
%
%

% Determine size of input data
[n,m] = size(Input);

if (n<=1) || (m==0),
    classifier_trained.W = [];
    classifier_trained.ClassLabel = unique(Target);
    return;
end;

% Discover and count unique class labels
ClassLabel  = unique(Target);
k           = length(ClassLabel);

% Initialize
nGroup                          = NaN(k,1);     % Group counts
classifier_trained.GroupMean    = NaN(k,m);     % Group sample means
classifier_trained.Covs         = cell(1,k);   % Pooled covariance
W                               = NaN(k,m+1);   % model coefficients

% Loop over classes to perform intermediate calculations
if n>=k,
    for i = 1:k,
        % Establish location and size of each class
        Group      = (Target == ClassLabel(i));
        nGroup(i)  = sum(double(Group));
        
        % Calculate group mean vectors
        classifier_trained.GroupMean(i,:) = mean(Input(Group,:));
        
        % Accumulate pooled covariance information
        classifier_trained.Covs{i} = cov(Input(Group,:));
    end
end;

% Assign prior probabilities
if  (nargin >= 3) && ~isempty(Priors),
    % Use the user-supplied priors
    PriorProb = Priors;
else
    % Use the sample probabilities
    PriorProb = nGroup / n;
end

% Loop over classes to calculate linear discriminant coefficients
try    
    for i = 1:k,
        % Intermediate calculation for efficiency
        % This replaces:  GroupMean(g,:) * inv(PooledCov)
        % Temp = GroupMean(i,:) / PooledCov;
        invCov = pinv(classifier_trained.Covs{i});
        Temp = classifier_trained.GroupMean(i,:)*invCov;
        
        % Constant
        W(i,1) = -0.5 * Temp * classifier_trained.GroupMean(i,:)'+ log(PriorProb(i));
        
        % Linear
        W(i,2:end) = Temp;
    end
    
    classifier_trained.W = W;
    classifier_trained.ClassLabel = ClassLabel;
    
    if isempty(W) || any(any(isnan(W))),
        dbstop,                     % DBG
    end;
catch
    classifier_trained.W = W;
    classifier_trained.ClassLabel = ClassLabel;
end;

return


