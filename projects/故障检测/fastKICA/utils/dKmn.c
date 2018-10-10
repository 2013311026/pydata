#include "mex.h"

/*
  dK = dKmn(Knm, inds, w, T, sigma)
  Knm: n x d kernel submatrix, the result is the derivative of this matrix
  inds: indices from incomplete Cholesky decomposition
  K is constructed on wT (row vector w of demixing matrix), nonsparse
  T is original data
  sigma: kernel width

  computes dvec(Knm)/dw

*/

/*
***** BEGIN LICENSE BLOCK *****
Version: MPL 1.1/GPL 2.0/LGPL 2.1

The contents of this file are subject to the Mozilla Public License Version
1.1 (the "License"); you may not use this file except in compliance with
the License. You may obtain a copy of the License at
http://www.mozilla.org/MPL/

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
for the specific language governing rights and limitations under the
License.

The Original Code is Fast Kernel Independent Component Analysis using
an Approximate Newton Method.

The Initial Developers of the Original Code are
Stefanie Jegelka, Hao Shen,  Arthur Gretton, and Francis Bach.
Portions created by the Initial Developers are Copyright (C) 2007
the Initial Developers. All Rights Reserved.

Contributors:
Stefanie Jegelka,
Hao Shen,
Arthur Gretton,
Francis Bach

Alternatively, the contents of this file may be used under the terms of
either the GNU General Public License Version 2 or later (the "GPL"), or
the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
in which case the provisions of the GPL or the LGPL are applicable instead
of those above. If you wish to allow use of your version of this file only
under the terms of either the GPL or the LGPL, and not to allow others to
use your version of this file under the terms of the MPL, indicate your
decision by deleting the provisions above and replace them with the notice
and other provisions required by the GPL or the LGPL. If you do not delete
the provisions above, a recipient may use your version of this file under
the terms of any one of the MPL, the GPL or the LGPL.

***** END LICENSE BLOCK *****
*/

#ifdef _WIN32
  double ddot(int*, double*, int*, double*, int*);
#else
  double ddot_(int*, double*, int*, double*, int*);
#endif

void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[])
{

  double *k, *dK, *t, *w, *tdiff;
  double *inds;
  double sigma, dprod, oneD=-1.0;
  int n, m, nw, i, j, colind, oneI = 1, nm;

  k = mxGetPr(prhs[0]);
  inds = (double*) mxGetPr(prhs[1]);
  w = mxGetPr(prhs[2]);
  t = mxGetPr(prhs[3]);
  sigma = *mxGetPr(prhs[4]);
  sigma *= -sigma;
  sigma = 1/sigma;
  n = mxGetM(prhs[0]);  /* number of samples */
  m = mxGetN(prhs[0]);  /* number of indices (called d elsewhere) */
  nw = mxGetN(prhs[2]); /* length of w: number of sources */
  nm = n*m;

  plhs[0] = mxCreateDoubleMatrix(nm, nw, mxREAL);
  dK = mxGetPr(plhs[0]);

  tdiff = mxCalloc(nw, sizeof(double));

  for (i=0; i<m; ++i){ /* column index */
    colind = (int)(inds[i]) - 1;
    for (j=0; j<n; ++j){
      
      /* tdiff = tj - ti */
      dcopy(&nw, &t[j*nw], &oneI, tdiff, &oneI);
      daxpy(&nw, &oneD, &t[colind*nw], &oneI, tdiff, &oneI);
      
      /* dprod = w * (ti - tj) */
      dprod = ddot(&nw, w, &oneI, tdiff, &oneI);
      
      /* dK( (i,j),:) = -K(i,j)/sigma * w * (tj - ti)(tj - ti)' */
      dcopy(&nw, tdiff, &oneI, &dK[i*n + j], &nm);
      dprod *= k[i*n + j] * sigma;
      dscal(&nw, &dprod, &dK[i*n + j], &nm);

    }
  }

  mxFree(tdiff);
  return;

}
