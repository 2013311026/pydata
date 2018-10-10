% ***** BEGIN LICENSE BLOCK *****
% Version: MPL 1.1/GPL 2.0/LGPL 2.1
% 
% The contents of this file are subject to the Mozilla Public License Version
% 1.1 (the "License"); you may not use this file except in compliance with
% the License. You may obtain a copy of the License at
% http://www.mozilla.org/MPL/
% 
% Software distributed under the License is distributed on an "AS IS" basis,
% WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
% for the specific language governing rights and limitations under the
% License.
% 
% The Original Code is Fast Kernel Independent Component Analysis using
% an Approximate Newton Method.
% 
% The Initial Developers of the Original Code are
% Stefanie Jegelka, Hao Shen,  Arthur Gretton, and Francis Bach.
% Portions created by the Initial Developers are Copyright (C) 2007
% the Initial Developers. All Rights Reserved.
% 
% Contributors:
% Stefanie Jegelka,
% Hao Shen,
% Arthur Gretton,
% Francis Bach
% 
% Alternatively, the contents of this file may be used under the terms of
% either the GNU General Public License Version 2 or later (the "GPL"), or
% the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
% in which case the provisions of the GPL or the LGPL are applicable instead
% of those above. If you wish to allow use of your version of this file only
% under the terms of either the GPL or the LGPL, and not to allow others to
% use your version of this file under the terms of the MPL, indicate your
% decision by deleting the provisions above and replace them with the notice
% and other provisions required by the GPL or the LGPL. If you do not delete
% the provisions above, a recipient may use your version of this file under
% the terms of any one of the MPL, the GPL or the LGPL.
% 
% ***** END LICENSE BLOCK *****

function [gradJ] = compDerivChol(WS, X, inds, sigmas)
% function [gradJ] = compDerivChol(WS, X, inds, sigmas)
% 
% gradient (including Cholesky factorization, see the Book Chapter in "Large Scale Kernel Machines")
%
% WS:       whitened signals
% X:        demixing matrix
% inds:     array of cholesky indices: inds{i} is index vector for kernel i
% sigmas:   m x 1 vector: kernel width for each component

% First the necessary submatrices are constructed. The function dChol
% performs the multiplication to get the gradient

N=size(WS,2);       % number of data points
m=size(WS,1);       % number of components

ridge = 1e-6;

if ispc
    Y = X'*WS;
    X = X';

    % parts of Cholesky gradient
    kern_nd = {};   % n x d submatrices
    kern_dd = {};   % d x d submatrices for inversion
    dkern_nd = {};  % derivative of n x d submatrix

    for i=1:m
        kern_nd{i} = getKern(Y(i,:), Y(i,inds{i}), sigmas(i));
        kern_dd{i} = kern_nd{i}(inds{i},:);
        kern_dd{i} = inv(kern_dd{i} + ridge * eye(length(inds{i})));
        dkern_nd{i} = dKmn(kern_nd{i}, inds{i}, X(i,:), WS, sigmas(i));
    end
    gradJ = zeros(m,m);

    % sum up pairwise gradients
    for i=1:(m-1)
        for j=(i+1):m
            g = dChol(kern_nd{i},kern_dd{i},dkern_nd{i}, kern_nd{j}, kern_dd{j}, dkern_nd{j}, inds{i}, inds{j});
            gradJ([i,j],:) = gradJ([i,j],:) + g;
        end
    end
    clear kern_nd;
    clear kern_dd;
    clear dkern_nd;
else
    Y = X'*WS;
    X = X';

    % parts of Cholesky gradient
    kern_nd = {};
    kern_dd = {};
    dkern_nd = {};

    for i=1:m
        kern_nd{i} = getKern(Y(i,:), Y(i,inds{i}), sigmas(i));
        kern_dd{i} = kern_nd{i}(inds{i},:);
        kern_dd{i} = inv(kern_dd{i} + ridge * eye(length(inds{i})));
        dkern_nd{i} = dKmnLin(kern_nd{i}, inds{i}, X(i,:), WS, sigmas(i));
    end
    gradJ = zeros(m,m);

    % sum up pairwise gradients
    for i=1:(m-1)
        for j=(i+1):m
            g = dCholLin(kern_nd{i},kern_dd{i},dkern_nd{i}, kern_nd{j}, kern_dd{j}, dkern_nd{j}, inds{i}, inds{j});
            gradJ([i,j],:) = gradJ([i,j],:) + g;
        end
    end
    clear kern_nd;
    clear kern_dd;
    clear dkern_nd;
end
