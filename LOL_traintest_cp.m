function [labels_pred, n_errors, classifier, labels_prob] = LOL_traintest( data_train, labels_train, data_test, labels_test, Opts )

% LDA train and test

if nargin<5,                    Opts = [];          end;
if ~isfield(Opts,'Priors'),     Opts.Priors = [];   end;

% 
% task = {};
% task.LOL_alg = Opts.LOL_alg;
% task.ntrain = size(data_train',2);
% task.ks=unique(floor(logspace(0,log10(task.ntrain),task.ntrain)));
% Nks=length(task.ks);
task = Opts.task
Nks=length(task.ks);
       
disp('a')
size(data_test)
% Train LOL classifier
[labels_pred, Proj, P, boundary] = LOL_classify(data_test',data_train',labels_train', task);
classifier.W = boundary;
classifier.Proj = Proj;
classifier.ClassLabel = unique(labels_train)';

disp('b')
% Projection of test data
% for i=1:Nks
%     proj = Proj{1}.V(1:task.ks(i),:);
%     data_test_projd{i}= proj*data_test;
% end

disp('c')
% Test LDA classifier
% [n_errors, labels_pred, labels_prob] = LOL_test( classifier, data_test_projd{1}, labels_test );
[n_errors, labels_pred, labels_prob] = LOL_test( classifier, data_test_projd{1}, labels_test );
disp('d')
size(labels_pred)
end
