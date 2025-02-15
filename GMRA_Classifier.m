function [MRA] = GMRA_Classifier( X, TrainGroup, Labels, Opts )

%
% function [GMRA_Classifier, GMRAs] = GMRA_LDA( X, Labels, Opts )
%
% IN:
%   X           : D by N matrix of N points in D dimensions
%   TrainGroup  : row N vector, with 1's corresponding to columns of X to be used as training set.
%   Labels      : row N vector of labels for the points
%   [Opts]      : structure with options
%                   [GMRAopts] : options for the GMRA. Default: uses GMRA defaults.
%                   [Priors]   : vector of priors on the classes listed as unique(Labels). If not provided, will use empirical estimate.
%                   [Classifier] : function handle for a classifier, see for example LDA_traintest (the default).
%
%
% OUT:
%   MRA         : a GMRA with extra subfields describing a classifier associated with the GMRA of the training portion of X:
%                   Data_train_GWT : FGWT of the training portion of X
%                   Classifier     : structure with the following fields:
%                                       activenode_idxs : indices of the active nodes in the GMRA-classifier construction.
%                                       Classifier      : a classifier for every node of the GMRA tree, nonempty only for selected active nodes
%                   
%
% (c) Copyright Mauro Maggioni, 2013
%
Timing.GMRAClassifier = cputime;

if nargin<4,    Opts = []; end;
if ~isfield(Opts,'GMRAopts'),
    Opts.GMRAopts = struct();
    Opts.GMRAopts.ManifoldDimension = 20;
    Opts.GMRAopts.precision  = 1e-5;
    Opts.GMRAopts.threshold0 = 0.1;
    Opts.GMRAopts.threshold1 = sqrt(2)*(1-cos(pi/24));    % threshold of singular values for determining the rank of each ( I - \Phi_{j,k} * \Phi_{j,k} ) * Phi_{j+1,k'}
    Opts.GMRAopts.threshold2 = sqrt(2)*sin(pi/24);        % threshold for determining the rank of intersection of ( I - \Phi_{j,k} * \Phi_{j,k} ) * Phi_{j+1,k'}
    Opts.GMRAopts.addTangentialCorrections = false;
    Opts.GMRAopts.sparsifying = false;
    Opts.GMRAopts.sparsifying_method = 'ksvd'; % or 'spams'
    Opts.GMRAopts.splitting = false;
    Opts.GMRAopts.knn = 8;
    Opts.GMRAopts.knnAutotune = 3;
    Opts.GMRAopts.smallestMetisNet = 5;
    Opts.GMRAopts.verbose = 0;
    Opts.GMRAopts.shrinkage = 'hard';
    Opts.GMRAopts.avoidLeafnodePhi = false;
    Opts.GMRAopts.mergePsiCapIntoPhi  = false;
end;
if ~isfield(Opts,'Priors'),
    Opts.Priors     = hist(Labels,unique(Labels))/length(Labels);
end;
if ~isfield(Opts,'Classifier'),
    Opts.Classifier = @LDA_traintest;
end;
if ~isfield(Opts,'LOL_alg'), % Added for LOL classifier
    Opts.LOL_alg = {};
end;
if ~isfield(Opts, 'localEmbedding')
    Opts.GMRAopts.localEmbedding = 0 % Default: SVD
else
    Opts.GMRAopts.localEmbedding = Opts.localEmbedding; % Added for choosing local embedding method: SVD (0) vs LOL (1)
end
if ~isfield(Opts, 'LOL_Projection')
    Opts.LOL_Projection = 0;
end
if ~isfield(Opts, 'UseX')
    Opts.UseX = 0;
end

fcn_train_single_node   = @classify_single_node_train;
fcn_traincv_single_node = @classify_single_node_crossvalidation;

% This parameter sets the depth down in the GMRA tree that will be searched
% past the point at which using the children is worse than using the node
% itself. DEPTH = 0 will stop immediately when children don't help.
% DEPTH = 2 will look down 2 levels to see if it can do better. I usually
% set to 6 or 10 to search most of the tree.
ALLOWED_DEPTH = 10;

% Flag for error status on each node
global USE_THIS USE_SELF USE_CHILDREN UNDECIDED COMBINED
USE_THIS        = 10;
USE_SELF        = 1;
USE_CHILDREN    = -1;
UNDECIDED       = -10;
COMBINED        = false;    % Combined uses both scaling functions and wavelets together for all fine scales. Otherwise, only scaling functions are used

X_train      = X(:,TrainGroup == 1);
Labels_train = Labels(TrainGroup == 1);
X_test       = X(:,TrainGroup == 0); % Added to project LOL here.
%% Generate GMRA
fprintf('\n Constructing GMRA...');
% tic;
if ~isfield(Opts,'debugMRA') % If there is not MRA already, do GMRA and output as MRA
    MRA         = GMRA(X_train, Opts.GMRAopts, Labels_train);
%    MRA.debugMRA = MRA;
else                         % If there is MRA given as input, don't do GMRA.
    MRA         = Opts.debugMRA;
end

MRA         = rmfield(MRA, 'X');
MRA.Labels_train = Labels_train;

fprintf('done.');

% Compute all wavelet coefficients
fprintf('\nTransform data via GWT...');
% tic;
MRA.Data_train_GWT = FGWT(MRA, X_train);
% toc;
fprintf('done.');

%% LOL TIME (if LOL is used for embedding, without GWT, with fixedK, without CV)
if Opts.LOL_Projection
    types{1} = 'DENL';
    Kmax = Opts.GMRAopts.ManifoldDimension;
    MRA.Timing.LOL = cputime;
    [Proj, ~] = LOL(X_train, Labels_train,types,Kmax);
    MRA.Timing.LOL = cputime - MRA.Timing.LOL;
    X_train = Proj{1}.V* X_train;
    MRA.X_test  = Proj{1}.V* X_test;    
end


%% Build model with train data split by cross-validation
fprintf(1, '\n GMRA_Classifier...');
MRA.Timing.CV = cputime;

results = struct();
for ii = 1:length(MRA.cp),
    results(ii).self_error = NaN;
    results(ii).self_std = NaN;
    results(ii).best_children_errors = NaN;
    results(ii).direct_children_errors = NaN;
    results(ii).error_value_to_use = NaN;
end

% Version that tests holdout by walking tree only down as far as it needs before it hits single class or too small nodes
tree_parent_idxs = MRA.cp;

% Container for child nodes which need to be freed up if a node eventually switches from USE_SELF to USE_CHILDREN, but some children have stopped
% propagating down the tree because they were past the ALLOWED_DEPTH of the indexed node
children_to_free = cell([length(MRA.cp) 1]);

% Start at root of the tree (cp(root_idx) == 0)
root_idx = find(tree_parent_idxs == 0);

if (length(root_idx) > 1)
    fprintf( 'cp contains too many root nodes (cp == 0)!! \n' );
    return;
end;
               
% This routine calculates errors for the children of the current node so we need to first calculate the root node error
[total_errors, std_errors, min_ks] = fcn_traincv_single_node( MRA.Data_train_GWT, Labels_train, ...
                                    struct('current_node_idx',root_idx, 'COMBINED', COMBINED, 'Priors',Opts.Priors,'Classifier',Opts.Classifier, ...
                                    'LOL_alg', Opts.LOL_alg, 'X_train', X_train, 'UseX',Opts.UseX ) ); % Added Opts.LOLalg for an option for the LOL transformer/decider type
% disp('Lets look at the root node error')
% total_errors
% Record the results for the root node
results(root_idx).self_error = total_errors;
results(root_idx).self_std = std_errors;
results(root_idx).error_value_to_use = UNDECIDED;
results(root_idx).min_ks = min_ks;
% disp('displayed min_ks')
% Initialize the java deque
activenode_idxs = java.util.ArrayDeque();
activenode_idxs.addFirst(root_idx);

%% Main loop to work iteratively down the tree breadth first
while (~activenode_idxs.isEmpty())
    current_node_idx = activenode_idxs.removeLast();
    % Get list of parent node indexes for use in a couple spots later
    current_parents_idxs = fliplr(dpath(MRA.cp, current_node_idx));
    current_parents_idxs = current_parents_idxs(2:end);    
    % Get children of the current node
    current_children_idxs = find(tree_parent_idxs == current_node_idx);    
    % Loop through the children
    for current_child_idx = current_children_idxs,        
        % Calculate the error on the current child
        [total_errors, std_errors, min_ks] = fcn_traincv_single_node( MRA.Data_train_GWT, Labels_train, ...
            struct('current_node_idx',current_child_idx, 'COMBINED', COMBINED, 'Priors',Opts.Priors,'Classifier',Opts.Classifier, ...
             'LOL_alg', Opts.LOL_alg, 'X_train', X_train, 'UseX',Opts.UseX) ); % Added Opts.LOLalg for an option for the LOL transformer/decider type) );                
        results(current_child_idx).self_error           = total_errors;                 % Record the results for the current child
        results(current_child_idx).self_std             = std_errors;
        results(current_child_idx).error_value_to_use   = UNDECIDED;
	results(current_child_idx).min_ks 		= min_ks;
 %  	disp('displayed min_ks')
    end
       
    children_error_sum = Inf;                                                           % If no children, want error to be infinite for any comparisons    
    if ~isempty(current_children_idxs)                                                  % Set children errors to child sum
        children_error_sum = sum( [results(current_children_idxs).self_error] );
        results(current_node_idx).direct_children_errors = children_error_sum;
        results(current_node_idx).best_children_errors = children_error_sum;
    else
        fprintf('\n There is no current children_idxs');
    end
    
    % Compare children results to self error
    self_error = results(current_node_idx).self_error;
	% disp('compare the self_error and the children_error_sum')
	% self_error
	% children_error_sum
    if (self_error < children_error_sum)                                                % NOTE: slop based on std?
        % disp('USE_SELF')
	results(current_node_idx).error_value_to_use = USE_SELF;                        % Set status = USE_SELF        
    else        
	% disp('USE_CHILDREN')
        results(current_node_idx).error_value_to_use = USE_CHILDREN;                    % Set status = USE_CHILDREN                
        error_difference = self_error - children_error_sum;                             % Propagate difference up parent chain        
        for parent_node_idx = current_parents_idxs,                                     % Loop through list of parent nodes            
            % Subtract difference from best_children_errors
            results(parent_node_idx).best_children_errors = results(parent_node_idx).best_children_errors - error_difference;                        
            if (results(parent_node_idx).error_value_to_use == USE_CHILDREN)            % If parent.status = USE_CHILDREN                
                continue;                                                               % Propagate differnce up to parent                
            elseif (results(parent_node_idx).error_value_to_use == USE_SELF)            % else if parent.status = USE_SELF
                % Compare best_children_errors to self_error
                % if still parent.self_error < parent.best_children_errors
                if (results(parent_node_idx).self_error < results(parent_node_idx).best_children_errors),   % NOTE: slop based on std?                    
                    break;                                                              % stop difference propagation
                else                                                                    % else if now parent.best_children_errors < parent.self_error                    
                    results(parent_node_idx).error_value_to_use = USE_CHILDREN;         % parent.status = USE_CHILDREN                    
                    error_difference = results(parent_node_idx).self_error - results(parent_node_idx).best_children_errors; % propagate this NEW difference up to parent
                    % Since some children of this node might have not added their children to the queue because
                    % this node was too far up the tree for ALLOWED_DEPTH, now that this has switched, need
                    % to check those older nodes to see if now their children should be added...
                    for idx = children_to_free{parent_node_idx}
                        activenode_idxs.addFirst(idx);
                    end
                    children_to_free{parent_node_idx} = [];
                    continue;
                end
            else
                fprintf('\nERROR: parent error status flag not set properly on index %d!!\n', parent_node_idx);
            end
        end
    end
    
    % Allowing here to go a certain controlled depth beyond where the children seem to be worse than a parent to see if it
    % eventually reverses. Set threshold to Inf to use whole tree of valid error values. Set threshold to zero to never go beyond
    % a single reversal where children are greater than the parent.
    
    % Figure out how far up tree to highest USE_SELF. If hole_depth < hole_depth_threshold push children on to queue for further processing
    % else stop going any deeper
    self_parent_idx_chain       = [current_node_idx current_parents_idxs];
    self_parent_status_flags    = [results(self_parent_idx_chain).error_value_to_use];
    use_self_depth              = find(self_parent_status_flags == USE_SELF, 1, 'last');
    % Depth set with this test. Root node or not found gives empty find result    
    use_self_depth_low_enough = isempty(use_self_depth) || (use_self_depth <= ALLOWED_DEPTH);    
    % All children must have finite error sums to go lower in any child
    all_children_errors_finite = isfinite(children_error_sum);    
    % If child errors are finite, but the node is too deep, keep track of the child indexes to add to the queue in case the USE_SELF
    % node it's under switches to USE_CHILDREN
    if (~use_self_depth_low_enough && all_children_errors_finite)
        problem_parent_idx = self_parent_idx_chain(use_self_depth);
        children_to_free{problem_parent_idx} = cat(2, children_to_free{problem_parent_idx}, current_children_idxs);
    end
    
    % Only addFirst children on to the stack if this node qualifies
    if (use_self_depth_low_enough && all_children_errors_finite)
        % fprintf('\n debugging: The node qualifies.');
        % Find childrent of current node
        for idx = current_children_idxs
            activenode_idxs.addFirst(idx);
        end
    else
        % DEBUG
        
	% fprintf('\n debugging: No node qualifies.');
        
	% if ~use_self_depth_low_enough
        %    fprintf('\n debugging: The nodes are too low.');
        % end
        
	% if ~all_children_errors_finite
        %    fprintf('\n debugging: Not all the children errors are finite.')
        % end
    end
end

%% Build the classifier
nodeFlags = results;
MRA.Classifier.Classifier     = cell(1,length(results));

%% Only evaluate the held-out points on the training crossvalidation winner model (nodes)
node_idxs = java.util.ArrayDeque();
node_idxs.addFirst(root_idx);

% Main loop to work iteratively down the tree depth first
while (~node_idxs.isEmpty())
    current_node_idx = node_idxs.removeFirst();
    % Set flag if this is the deepest node to use
    if (nodeFlags(current_node_idx).error_value_to_use == USE_SELF)
        nodeFlags(current_node_idx).error_value_to_use = USE_THIS;
    else
        % Get children of the current node
        current_children_idxs = find(tree_parent_idxs == current_node_idx);        
        % and put them in the stack for further traversal
        for idx = current_children_idxs
            node_idxs.addFirst(idx);
        end
    end
end

MRA.Classifier.activenode_idxs = find(cat(1,nodeFlags.error_value_to_use)==USE_THIS);

for i = 1: size(nodeFlags,2)
	if isempty(nodeFlags(i).min_ks)
		nodeFlags(i).min_ks = 0;
	end
	MRA.min_ks(i) = nodeFlags(i).min_ks;
end
% temp2 = reshape([nodeFlags.min_ks], size(nodeFlags))
temp = cat(1, nodeFlags.min_ks);
% whos temp
% disp('checking the nodes that were not empty: either scalar or Inf: ')
% find(temp >0)
% find(temp >0 & temp <inf)
MRA.Timing.CV = cputime - MRA.Timing.CV;
% Save NodeFlags_min_ks to MRA so that we can transfer it to GMRA_Classifier_test.m
% MRA.min_ks = nodeFlags.min_ks;

MRA.Timing.Train = cputime;
% Go through the active nodes in the classifier and classify the test points in there
for k = 1:length(MRA.Classifier.activenode_idxs),
    current_node_idx = MRA.Classifier.activenode_idxs(k);
    min_ks = nodeFlags(current_node_idx).min_ks;
    [MRA.Classifier.Classifier{current_node_idx},dataIdxs_train] = ...
        fcn_train_single_node( MRA.Data_train_GWT, Labels_train, min_ks, ...
          struct('current_node_idx',current_node_idx, 'COMBINED',COMBINED, 'Priors',Opts.Priors,'Classifier',Opts.Classifier, ...
               'LOL_alg',Opts.LOL_alg, 'X_train', X_train, 'UseX',Opts.UseX) );
    MRA.Classifier.ModelTrainLabels{current_node_idx} = Labels_train(dataIdxs_train);
end;
%MRA.results = results;
MRA.Timing.Train = cputime - MRA.Timing.Train;
MRA.Timing.GMRAClassifier = cputime-Timing.GMRAClassifier;

fprintf('\n done.\n');

return;
