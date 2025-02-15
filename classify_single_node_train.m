function [classifier_trained,dataIdxs_train] = classify_single_node_train( Data_train_GWT, Labels_train, min_ks, Opts )
%
% IN:
%   Data_train_GWT  : GWT of training data
%   Labels_train    : labels of training data. Row vector.
%   Opts:
%       Opts            : structure contaning the following fields:
%                           [Classifier]     : function handle to classifier. Default: LDA_traintest.
%                           current_node_idx : index at which to train the classifier
%                           [COMBINED]       : whether to use only scaling function subspace (=0) or also wavelet subspace (=1). Default: 0.
%
% OUT:
%   trained_classifier : classifier
%
bestAllK = 0;
bestTrainK = 1;
if bestAllK
    bestTrainK = 0;
end
if ~isfield(Opts,'Classifier') || isempty(Opts.Classifier),     Opts.Classifier = @LDA_traintest;   end;
if ~isfield(Opts,'COMBINED')   || isempty(Opts.COMBINED),       Opts.COMBINED   = 0;                end;

if ~Opts.COMBINED %|| current_node_idx == length(Data_train.PointsInNet),
    coeffs_train = cat(1, Data_train_GWT.CelScalCoeffs{Data_train_GWT.Cel_cpidx == Opts.current_node_idx});
else
    coeffs_train = cat(2,   cat(1, Data_train_GWT.CelScalCoeffs{Data_train_GWT.Cel_cpidx == Opts.current_node_idx}), ...
        cat(1, Data_train_GWT.CelWavCoeffs{Data_train_GWT.Cel_cpidx == Opts.current_node_idx}));
end

dataIdxs_train      = Data_train_GWT.PointsInNet{Opts.current_node_idx};

% Addition to use X instead of Wavelet Coeffs
%UseX = 0;
if Opts.UseX
    coeffs_train = Opts.X_train(:, dataIdxs_train)';
end

dataLabels_train    = Labels_train(dataIdxs_train);
% disp('checking the size of coeffs and dataLabels with X')
% size(coeffs_train)
% size(dataLabels_train)
if isequal(Opts.Classifier, @LOL_traintest)
    task = {};
    task.LOL_alg = Opts.LOL_alg;
    %         task.ntrain = cp.TrainSize(1);
    task.ntrain = size(coeffs_train, 2);
    ks=unique(floor(logspace(0,log10(task.ntrain),task.ntrain)));
    Opts.task = task;
    if bestTrainK
        ks = min_ks;
    end
    for i = 1:length(ks)
        Opts.task.ks = ks(i);
        [~,~,classifier_trained{i}] = Opts.Classifier( coeffs_train', dataLabels_train,[],[], Opts );
    end
else
    [~,~,classifier_trained] = Opts.Classifier( coeffs_train', dataLabels_train,[],[], Opts );
end

return;
