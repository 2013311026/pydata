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


function [X, XS, hsics] = fastkica(MS, Xin, maxiter, sigma, thresh)
%
% INPUT:
% MS:       mixed signals, m x n (m sources, n samples)
% Xin:      initial demixing matrix: Xin' * MS are estimated sources
%           (initial guess)
% maxiter:  maximum number of iterations
% sigma:    width of Gaussian kernel
% thresh:   convergence threshold: stops if difference in subsequent values
%           of HSIC is less than thresh
%
% OUTPUT:
% X:        demixing matrix: X' * MX are estimated sources
% XS:       sequence of X for each iteration
% hsics:    HSIC at each iteration
%
% The algorithm terminates if either the difference in hsic values is less
% than 'thresh' or the maximum number of iterations (maxiter) is reached.
%
% Copyright 2007 Stefanie Jegelka, Hao Shen, Arthur Gretton
%

if ~exist('hessChol.m','file')
    addpath('utils');
end

[m n] = size(MS);         % m signals, n samples

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PREPROCESSING: whitening
%   multiply mixed signal MS by a whitening matrix WW such that WW*MM has
%   an identity covariance matrix

% center signal
shift = mean(MS, 2);                 
MS = MS - shift * ones (1, n);

% whiten signal, WS is whitened signal
[Q R] = qr(MS',0);
[theta lamda v] = svd(R');
WW = sqrt(n)*diag(diag(lamda).^(-1))*theta';
WS = WW * MS;

% correct Xin for whitening and make orthogonal
% then X' * WS = Xin' * MS
[U,S,V] = svd(Xin'*inv(WW));
X = U*V';
X = X';  % we use the transpose

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

XS = zeros(m,m,maxiter);  % stores X at each iteration
hsics = zeros(1,maxiter); % stores HSIC after each iteration

n2 = n*n;

sigmas = ones(1,m)*sigma; % kernel width
etas = ones(1,m) * 1e-6;  % Cholesky precision
maxdim = 60;              % maximum number of columns for the Cholesky factors

for iter = 1 : maxiter

    % Cholesky
    ks = {}; %kernel halves
    inds = {};
    Y = X' * WS; % estimated sources
    for iS=1:m
        [G,Pvec] =chol_gauss(Y(iS,:), sigmas(iS), etas(iS)*n);
        ddim = size(G,2);
        inds{iS} = Pvec(1:ddim)+1;
        % This is a restriction to save memory, remove/adapt as you wish.
        % ddim is the d dimension of the decomposition matrices (they are n
        % x d, from incomplete Cholesky). It is here restricted to be at
        % most maxdim=60. 
        if ddim>maxdim
            inds{iS} = Pvec(1:maxdim)+1;
            fprintf('%d: ddim too large ', iS);
        end            
        [a,Pvec]=sort(Pvec); %new pvec contains indices of old pvec
        ks{iS} = G(Pvec,:);
    end

    % HSIC of current estimate
    hsics(iter) = hsicChol(ks,n,m);
    
    % Euclidean gradient: entry-wisely computed
    [G] = compDerivChol(WS, X, inds, sigmas);
    G = G/n2;

    %     compute approximate Hessian
    HS = hessChol(WS,X,ks, sigma);
    
    EG = G * X; % same as (-X'*EG)'
    RG = (EG - EG') / 2;                            % Gradient in parameter space
    X = X * expm( RG.* HS );                        % map Newton direction onto SO(m)
    XS(:,:,iter) = WW'*X;                           
    % unmixed data is X' * WW * MS = XS(:,:,iter)' * MS

    % check for convergence
    if iter>1 && (abs(hsics(iter)-hsics(iter-1))<thresh)
        X = XS(:,:,iter);
        return;
    end
end
X = XS(:,:,maxiter);
