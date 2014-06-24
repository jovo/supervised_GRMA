disp('testing the time of GMRA...');

% Test_GMRAClassifier.m is a matlab script that runs/compares GMRA_Classifier on
% sample data sets with different classifiers for testing/debugging purpose.

clear all
close all
clc

dir = fileparts(mfilename('fullpath'));
cd(dir); 
pwd
addpath(genpath(pwd));

%% Pick a data set

pDataSetNames  = {'MNIST_HardBinary_T60K_t10K', 'MNIST_HardBinary_T5.0K_t5.0K',  'MNIST_HardBinary_T2.5K_t2.5K', 'MNIST_EasyBinary_T2.5K_t2.5K', 'MNIST_EasyBinary_T0.8K_t0.8K', 'MNIST_EasyBinary_T0.7K_t0.7K', 'MNIST_EasyBinary_T0.6K_t0.6K', 'MNIST_EasyBinary_T0.5K_t0.5K', 'MNIST_EasyBinary_T0.4K_t0.4K', 'MNIST_EasyBinary_T0.3K_t0.3K', 'MNIST_EasyBinary_T0.2K_t0.2K', 'MNIST_EasyTriple_T0.6K_t0.6K', 'MNIST_EasyTriple_T0.3K_t0.3K', 'MNIST_EasyBinary_T10_t10', 'Gaussian_2', 'FisherIris' };
    
fprintf('\n Data Sets:\n');
for k = 1:length(pDataSetNames),
    fprintf('\n [%d] %s',k,pDataSetNames{k});
end;
fprintf('\n\n  ');

pDataSetIdx = input('Pick a data set to test: \n');

%% Load the data set

[X, TrainGroup, Labels] = LoadData(pDataSetNames{pDataSetIdx});

%
whos
X = X.*255;
X(:,1)
Labels(1:20)
max(max(X))
min(min(X))
whos
