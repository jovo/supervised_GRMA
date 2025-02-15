% MNIST_012_T0.3k10k
clear all
close all
clc


%% LDA

ACC_LDA = [ 0.8437    0.8395    0.7990    0.8099    0.7833    0.8453    0.7647    0.8422    0.8288    0.8030    0.8127    0.7650    0.7952, ...
  0.8052    0.8385    0.7986    0.8290    0.8328    0.8296    0.7531];


cputime_LDA =[ 1.0800    0.9300    0.9200    0.9400    0.9400    0.9200    0.9400    0.9300    0.9300    0.9300    0.9300    0.9400    0.9100, ...
    0.9100    0.9400    0.9300    0.9200    0.9400    0.9300    0.9200 ];


tictoc_LDA = [0.2918    0.1536    0.1515    0.1536    0.1548    0.1526    0.1545    0.1525    0.1537    0.1533    0.1531    0.1556    0.1508, ...
    0.1508    0.1537    0.1537    0.1507    0.1544    0.1521    0.1508];

ACC_LDA_Avg20 = mean(ACC_LDA)
std(ACC_LDA);
cputime_LDA_Avg20 = mean(cputime_LDA)
tictoc_LDA_Avg20 = mean(tictoc_LDA)


% Test2 at a different time
cputime_LDA_2 =[0.9800    0.9700    0.8400    1.0700    0.9300    0.9200    0.9900    0.9300    0.9400    0.9300    0.7700    0.9600    0.9400, ...
 0.8800    1.0400    0.9100    0.9300    0.9200    0.7900    1.0000];

tictoc_LDA_2 =[0.1946    0.1827    0.1736    0.1746    0.1748    0.1729    0.1737    0.1741    0.1751    0.1743    0.1745    0.1720    0.1757, ...
    0.1740    0.1722    0.1709    0.1739    0.1724    0.1715    0.1731];

cputime_LDA_2_Avg20 = mean(cputime_LDA_2)
tictoc_LDA_2_Avg20 = mean(tictoc_LDA_2)










%% LOL


cputime_LOL =[ 15.1800   13.9700   14.0900   13.8300   13.9700   13.7900   13.8700   13.9700   13.2500   13.4900   13.1900   13.1200   12.9000, ...
   13.1900   12.9000   13.0400   12.9900   12.8700   13.0600   13.4400];
hold on; plot(ks, repmat(mean(cputime_LOL), size(ks)), 'g')

tictoc_LOL =[ 2.7498    2.2861    2.3054    2.2634    2.2871    2.2511    2.2663    2.2835    2.2517    2.2862    2.2483    2.2770    2.2466, ...
    2.2734    2.2642    2.2726    2.2477    2.2775    2.2537    2.2809];


% ACC_LOL_Avg20 = mean(ACC_LOL)
% std(ACC_LOL);
cputime_LOL_Avg20 = mean(cputime_LOL)
tictoc_LOL_Avg20 = mean(tictoc_LOL)

% Note that LOL computes it for every k and this result is of DENL not of
% DEFL.



%% GMRA:LDA


%% GMRA:LOL








% Plot


figure; 
ydata = [cputime_LDA_Avg20 cputime_LOL_Avg20]
xdata = 1: length(ydata);
xlabels = {'cputime_LDA', 'cputime_LOL'};
plot(ydata, 'x', 'MarkerSize', 22)
set(gca, 'Xtick', xdata, 'XtickLabel', xlabels);
axis([xdata(1)-1 xdata(end)+1 -1 15])
% set(gca,'XTickLabel',{'cputime_LDA' 'cputime_LOL'});
