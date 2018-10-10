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

function [derivKL] = dChol(Knd,Kdd,dKnd, Lnd, Ldd, dLnd, indsK, indsL)
%
% Matlab interface for pairwise derivative for kernels K and L
% Knd:          n x d submatrix of K
% Kdd:          inverted d x d submatrix of K
% dKnd:         d(Knd)
% Lnd:          n x d submatrix of K
% Ldd:          inverted d x d submatrix of K
% dLnd:         d(Knd)
% indsK, indsL: indices from incomplete Cholesky decomposition
%


[n,dl] = size(Lnd);
dk = length(indsK);
[ndk,m] = size(dKnd);

derivKL = zeros(2,m);

% column-centered Lnd
HL = Lnd - repmat(mean(Lnd),n,1);

% derivative of d x d submatrix of K and L
indsext = repmat(indsK,1,dk) + kron(0:n:(n*dk-1),ones(1,dk));
dKdd = dKnd(indsext,:);
indsext = repmat(indsL,1,dl) + kron(0:n:(n*dl-1),ones(1,dl));
dLdd = dLnd(indsext,:);
clear indsext;

% derivative wrt row (of X) for K
derivKL(1,:) = dChol2(HL, Ldd, Knd, Kdd, dKnd, dKdd);

% column-centered Knd
HK = Knd - repmat(mean(Knd),n,1);
% derivative wrt row (of X) for L
derivKL(2,:) = dChol2(HK, Kdd, Lnd, Ldd, dLnd, dLdd);
