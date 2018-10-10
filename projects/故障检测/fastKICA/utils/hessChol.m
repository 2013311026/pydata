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

function [HS] = hessChol(WS,X,ks, varargin)
% function [HS] = hessChol(WS,X,ks, [sigma])
%
% Hessian 
% WS:       whitened signal
% X :       current point (demixing matrix)
% HS:       approximate Hessian (with Cholesky)
% sigma:    width of Gaussian kernel (here we assume that all kernels are
%           of the same width), default: sigma = 1;


[m n] = size(WS);
n2 = n^2;
if nargin < 4
    sigma = 1;
else
    sigma = varargin{1};
end
eta = 1e-8 * n;
Y = X' * WS;
mt = zeros(3,m); % three "magic terms"

% Magic Terms, see AISTATS paper
for nos = 1:m

    G = ks{nos};

    % M1
    v = ones(1,n)*G;   % 1 x d
    mt(1,nos) = v*v'/n2;

    % M3
    v2 = (Y(nos,:).^2 * G) * (G' * ones(n,1)); % 1 x d
    mt(3,nos) = v2/n2;

    % M2
    v = Y(nos,:)*G; % d x 1
    mt(2,nos) = (v*v')/n2;
end

% Hessian
HS = zeros(m);
t2 = 2/(sigma^2);
t4 = 4/(sigma^4);
for row = 1 : m
    for col = (row+1) : m
        HS(row,col) = 1 / (t2* mt(1,row)*mt(2,col) + t2*mt(2,row)*mt(1,col) + ...
            t4 * mt(2,row) * mt(2, col) - t4*mt(3,row)*mt(3,col));
    end
end
HS = HS + HS';
