#include "mex.h"
#include "math.h"

/* 
   K = getKern(x,y,sigma)
   returns kernel on row vectors x and y (Gaussian),
   length(x) x length(y)

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

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, 
		 const mxArray *prhs[]){

  double *x, *y, *k;
  int nx, ny, i, j;
  double sigma;
  
  x = mxGetPr(prhs[0]);
  y = mxGetPr(prhs[1]);
  sigma = (double) *mxGetPr(prhs[2]);
  nx = mxGetN(prhs[0]);
  ny = mxGetN(prhs[1]);
  sigma *= 2 * sigma;
  
  plhs[0] = mxCreateDoubleMatrix(nx, ny, mxREAL);
  k = mxGetPr(plhs[0]);
  
  for (i=0; i<ny; ++i){
    for (j=0; j<nx; ++j){
      k[i*nx + j] = exp(-(x[j] - y[i]) * (x[j] - y[i]) / sigma);
    }
  }
    
  return;
}
