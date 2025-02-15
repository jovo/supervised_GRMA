function [x,y,h,s,A] = treelayout(parent,post)
%TREELAYOUT Lay out tree or forest.
%   [x,y,h,s] = treelayout(parent,post)
%       parent is the vector of parent pointers, with 0 for a root.
%       post is a postorder permutation on the tree nodes.
%       (If post is omitted we compute it here.)
%       x and y are vectors of coordinates in the unit square at which 
%       to lay out the nodes of the tree to make a nice picture.
%       Optionally, h is the height of the tree and s is the 
%       number of vertices in the top-level separator.
%
%   See also ETREE, TREEPLOT, ETREEPLOT, SYMBFACT.

%   Copyright 1984-2009 The MathWorks, Inc. 
%   $Revision: 5.13.4.2 $  $Date: 2009/04/21 03:26:21 $

% This is based on the C code in sptrees.c by John Gilbert.
% Leaves are spaced evenly on the x axis, and internal
% nodes are centered over their descendant leaves with
% y coordinate proportional to height in the tree.

n = length(parent);

pv = [];
if (size(parent,1)>1), parent = parent(:)'; end
if (nargin<2) && ~all(parent==0 | parent>(1:n))
    % This does not appear to be in the form generated by ETREE.
    if (any(parent>n | parent<0 | parent~=floor(parent) | parent==1:n))
       error('MATLAB:treelayout:InvalidParentPointers',...
             'Bad vector of parent pointers.');
    end
    [parent,pv] = fixparent(parent);
end

if nargin < 2,

    % Create the adjacency matrix A of the given tree,
    % and get the postorder with another call to etree.

    j = find(parent);
    A = sparse (parent(j), j, 1, n, n);
    A = A + A' + speye(n,n);
    [~, post] = etree(A);

end;

% Add a dummy root node #n+1, and identify the leaves.
parent_orig=parent;
parent = rem (parent+n, n+1) + 1;  % change all 0s to n+1s
isaleaf = ones(1,n+1);
isaleaf(parent) = zeros(n,1);

% In postorder, compute heights and descendant leaf intervals.
% Space leaves evenly in x (in postorder).

xmin = n(1,ones(1,n+1));
xmax = zeros(1,n+1);
height = zeros(1,n+1);
nkids = zeros(1,n+1);
nleaves = 0;

for i = 1:n,
    node = post(i);
    if isaleaf(node),
        nleaves = nleaves+1;
        xmin(node) = nleaves;
        xmax(node) = nleaves;
        height(node) = length(get_ancestors(parent_orig,node));
    end;
    dad = parent(node);
%     height(dad) = max (height(dad), height(node)+1);
%     while height(dad)>height(node)+1,
%         height(node) = height(node)+1;
%         height(dad) = max (height(dad), height(node)+1);
%     end;
    height(dad) = max (height(dad), height(node)+1);
    if dad<=n,
        height(dad) = length(get_ancestors(parent_orig,dad));
    end;
    xmin(dad)   = min (xmin(dad),   xmin(node));
    xmax(dad)   = max (xmax(dad),   xmax(node));
    nkids(dad)  = nkids(dad)+1;
end;

lmaxheight=max(height);
height = lmaxheight-height;
height(n+1)=lmaxheight;

% Compute coordinates, leaving a little space on all sides.

treeht = height(n+1) - 1;
deltax = 1/(nleaves+1);
deltay = 1/(treeht+2);
x = deltax * (xmin+xmax)/2;
y = deltay * (height+1);

% Omit the dummy node.

x = x(1:n);
y = y(1:n);

% Return the height and top separator size.

h = treeht;
s = n+1 - find(nkids~=1,1,'last');

if ~isempty(pv)
   x(pv) = x;
   y(pv) = y;
end

% ----------------------------
function [a,pv] = fixparent(parent)
%FIXPARENT  Fix order of parent vector
%   [A,PV] = FIXPARENT(B) takes a vector of parent nodes for an
%   elimination tree, and re-orders it to produce an equivalent vector
%   A in which parent nodes are always higher-numbered than child
%   nodes.  If B is an elimination tree produced by the TREE
%   functions, this step will not be necessary.  PV is a
%   permutation vector, so that A = B(PV);

n = length(parent);
a = parent;
a(a==0) = n+1;
pv = 1:n;

niter = 0;
while(1)
   k = find(a<(1:n));
   if isempty(k), break; end
   k = k(1);
   j = a(k);
   
   % Put node k before its parent node j
   a  = [ a(1:j-1)  a(k)  a(j:k-1)  a(k+1:end)]; 
   pv = [pv(1:j-1) pv(k) pv(j:k-1) pv(k+1:end)]; 
   t = (a >= j & a < k);
   a(a==k) = j;
   a(t) = a(t) + 1;

   niter = niter+1;
   if (niter>n*(n-1)/2), 
     error('MATLAB:treelayout:InvalidParentPointers','Bad vector of parent pointers.');
   end
end

a(a>n) = 0;