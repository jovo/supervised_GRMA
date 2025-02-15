ACC_GMRALOL_GW =[0.96665 0.96651 0.97051 0.96806 0.95932 0.94529 0.91850 0.90954]
k = [3 5 10 20 40 100 200 400];
figure;
plot(k, ACC_GMRALOL_GW, 'o-')
title('Accuracy over 20 trials: MNIST012Triple Training:0.3k/Test:10k', 'FontSize', 22)
xlabel('k')
ylabel('Accuracy')

ACC_GMRALOL_X = [0.9657 0.9658 0.9579 0.9440 0.9157]
k = [10 20 40 100 200]
hold on; plot(k, ACC_GMRALOL_X, 'ro-')

ks = [  1     2     3     4     5     6     7     8     9    10    11    12    13    14    15    17    18    20    22    24    26    29    31    34    37    41, ... 
    45    49    53    58    63    69    75    82    90    98   107   116   127   138   151   165   180   196   214   233   254   277   302   329   359   392, ...
   427   466   508   554   604   659   718   784];

ACC_GMRALOL_X_TrainK = 0.9617;
hold on; plot(ks, repmat(ACC_GMRALOL_X_TrainK, size(ks)), 'k-')

ACC_GMRALDA_GW = [ 0.9590 0.9661 0.9626 0.9511 0.8993];
k = [ 10 20 40 100 200]
hold on; plot(k, ACC_GMRALDA_GW, 'mx-')
ACC_GMRALDA_X = 0.9557;
hold on; plot(ks, repmat(ACC_GMRALDA_X, size(ks)), 'k--')

ACC_LOL = [0.8774
    0.9353
    0.9404
    0.9431
    0.9505
    0.9535
    0.9560
    0.9573
    0.9585
    0.9595
    0.9605
    0.9608
    0.9613
    0.9618
    0.9619
    0.9611
    0.9609
    0.9604
    0.9604
    0.9602
    0.9600
    0.9589
    0.9580
    0.9569
    0.9565
    0.9554
    0.9546
    0.9531
    0.9527
    0.9512
    0.9497
    0.9474
    0.9466
    0.9440
    0.9423
    0.9397
    0.9378
    0.9359
    0.9334
    0.9316
    0.9284
    0.9249
    0.9213
    0.9154
    0.9102
    0.9018
    0.8907
    0.8764
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017
    0.8017]

hold on; plot(ks, ACC_LOL, 'go-')


legend('GMRALOL:GW (FixedK)', 'GMRALOL:X (FixedK)', 'GMRALOL:X (TrainedK[CV])','GMRALDA:GW (FixedK)','GMRALDA:X (No K)', 'LOL (FixedK)')


% 1. GMRALOL:GW (FixedK)	LDA_traintest, local_LOL_analysis, ~UseLOL, ~UseX
%                             1,                 1,           0,     0, 
% 2. GMRALOL: X (FixedK)	local_SVD_analysis, UseLOL, UseX, LDA_traintest
% 3. GMRALOL: X (TrainedK)	local_SVD_analysis, ~UseLOL, UseX, LOL_traintest
% 4. GMRALDA:GW (FixedK)	LDA_traintest,  local_SVD_analysis, ~UseLOL, ~UseX
%                                1,                 0,              0,     0 
% 5. GMRALDA: X (No K)		local_SVD_analysis, ~UseLOL, UseX, LDA_traintest
% 6. LOL



% 2nd TRY: N = 40;
% GMRALOL_GW: LDA_test 1, local_LOL_analysis 1, UseLOL 0, UseX 0
ACC_GMRALOL_GW_2 =   [0.9679 0.9689 0.9703  0.9675 0.9582  0.9445   0.9170 0.9110];
STD_ACC_GMRALOL_GW = [0.0064 0.0049 0.0066  0.0048 0.0071  0.0059   0.0075 0.0407];
k = [3 5 10 20 40 100 200 400];
Timing_GMRALOL_GW = [14.3562 13.6465  14.2837   15.6790 14.0767 14.6649  7.0487 11.9562];
Timing_GMRA_GMRALOL_GW = [9.0197 8.4523 8.9723 8.2803 7.0418   6.3813  1.9865 2.3363];


% GMRALDA_GW: LDA_test 1, local_LOL_analysis 0, UseLOL 0, UseX 0
% N = 40;
ACC_GMRALDA_GW_2 = [ 0.9568 0.9582 0.9637  0.9618 0.9536 0.9070];
STD_ACC_GMRALOL_GW = [ 0.0138 0.0133 0.0083 0.0062 0.0050 0.0406];
k = [5 10 20 40 100 200];
Timing_GMRALDA_GW = [ 6.8490 6.5993 8.7088 8.3792 9.9812  5.9775];
Timing_GMRA_GMRALDA_GW = [ 1.3380 1.3887 1.4785 1.6105 2.0650  1.1835];


% GMRALOL_X (FixedK): LDA_test 1, local_LOL_analysis 0, UseLOL 1, UseX 1
ACC_GMRALOL_X_2 =   [0.9496 0.9645 0.9680 0.9633 0.9579 0.9438 ];
STD_ACC_GMRALOL_X = [0.0097 0.0082 0.0056  0.0066 0.0080 0.0058 ];
k = [3 5 10 20 40 100 ];
Timing_GMRALOL_X = [7.4155 7.2812 7.1120  9.9882 9.4085 10.2040];
Timing_GMRA_GMRALOL_X = [1.3008 1.3228 1.3470 1.5395 1.6702 2.0055];
Timing_LOL_GMRALOL_X = [0.4212 0.3920 0.3918 0.4185 0.3977 0.3860];

% GMRALOL_X (TrainK): LOL_test 5, local_LOL_analysis 0, UseLOL 0, UseX 1
ACC_GMRALOL_X_TrainK_2 =   [0.9525 ];
STD_ACC_GMRALOL_X_TrainK = [0.0143 ];
Timing_GMRALOL_X_TrainK = [88.1878 ];
Timing_GMRA_GMRALOL_X_TrainK = [1.2650 ];
% The accuracy value is less than the previous trial N = 20. Check why
% => ok, if I run N= 20 again, I get a higher value, its just N not big
% enough. N=40 again, I get the same 0.9525 accuracy.

% Is this CV the best method to do this? It takes so much time.
% Also, the flexibility of k enlarges the tree and mess the choice of picking the right active nodes up.

% Does the Accuracy get influenced by ManifoldDimension? It shouldn't..
%

% GMRALDA_X (No K): LDA_test 1, local_LOL_analysis 0, UseLOL 0, UseX 1
ACC_GMRALDA_X =   [ 0.9533 0.9571 0.9534 0.9251 ];
STD_ACC_GMRALDA_X = [ 0.0133 0.0080 0.0119 0.0133];
k = [ 5 10 20 200 ];
Timing_GMRALDA_X = [ 114.0545 114.4820 107.1535 24.6430];
Timing_GMRA_GMRALDA_X = [ 1.2730 1.3360 1.4005 1.1500 ];

% I ran k = 200 for N = 20 just to be sure that changing k would not
% affect this algorithm, but it does.
% The ManifoldDimension influence in the FGWT may not be reflected
% because we are using the original X. Then, what is changing it?
%


%CV Takes a aweful lot amount of time here as well.
%                     GW: 2
%                  graph: 0.7400
%                 nesdis: 0.0100
%                     CV: 116.5800
%                  Train: 1.9400
%         GMRAClassifier: 121.5800
%     GMRAClassifierTest: 4.2600

% GMRA:LDA:GW (ManifoldDimension = 0)
ACC_GMRALDA_GW_MD0 =   [ 0.9678 ];
STD_ACC_GMRALDA_GW_MD0 = [ 0.0076 ];
Timing_GMRALDA_GW_MD0 = [ 9.9523];
Timing_GMRA_GMRALDA_GW_MD0 = [ 1.9595 ];



