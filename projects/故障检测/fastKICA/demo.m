% demo file of how to use fastkica

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




% parameters for fastkica
maxiter = 20;   % maximum number of iterations
sigma = 1.0;    % width of Gaussian kernel
thresh = 1e-6;  % convergence threshold (difference of HSIC values)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LOAD DATA

% audio processing
% load data and randomly select 1500 (successive) samples
S = zeros(50000,3);
[S(:,1), Fs, bits] = wavread('source4.wav');
[S(:,2), Fs, bits] = wavread('source2.wav');
[S(:,3), Fs, bits] = wavread('source3.wav');
S = S';
idx = round(10000*(1+rand));
S = S(:,idx:idx+1499);

[m n] = size(S);    % m dimensions (number of signals); n sample size

% mixing matrix MM
MM = rand(m);
% mixed sources MS
MS = MM * S;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DEMIX

% initial demixing matrix X (should be orthogonal, i.e. X * X' = I)
% here: random matrix
% you may also use the result of Jade or FastICA for initialization
X = rand(m);
[X0 R] = qr(X);

% X0' * MS are estimated sources
% 
% Xout:     demixing matrix at final iteration: estimated sources are
%           Xout'*MS
% XS:       X for each iteration
% hsics:    HSIC value at each iteration
[Xout, XS, hsics] = fastkica(MS, X0, maxiter, sigma, thresh);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  PLOT result

figure;
subplot(1,2,1);
maxind = find(hsics > 0, 1, 'last');
plot(1:maxind, hsics(1:maxind));
axis tight;
xlabel('iteration');
ylabel('HSIC');

subplot(1,2,2);
amari_errors = zeros(maxind+1, 1);
amari_errors(1) = amariD(X0'*MM);       % initial error
for i=1:maxind
    amari_errors(i+1) = amariD(XS(:,:,i)'*MM);
end
plot(0:maxind, amari_errors);
xlabel('iteration');
ylabel('Amari distance');
axis([1 maxind 0 max(amari_errors)]);
