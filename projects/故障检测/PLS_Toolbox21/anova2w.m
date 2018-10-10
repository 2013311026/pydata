function anova2w(dat,alpha)
%ANOVA2W Two way analysis of variance
%  Calculates two way ANOVA table and tests significance of
%  between factors variation (it is assumed that each column
%  of the data represents a different factor) and between
%  blocks variation (it is assumed that each row represents
%  a block). Inputs are the data table (dat) and the
%  desired confidence level (alpha), expressed as a fraction
%  (e.g. .95, .99, etc.). The output is an ANOVA table.
%
%I/O: anova2w(dat,alpha)
%
%See also: ANOVA1W, FTEST, STATDEMO

%Copyright Eigenvector Research 1994-99
%Modified NBG 1996
%Checked on MATLAB 5 by BMW  1/4/97,3/99
%Modified BMW 12/98 via Paul Gemperline

[n,k] = size(dat);
xbar  = mean(mean(dat));
xbari = mean(dat);
xbarj = mean(dat');

sst   = sum(sum((dat - xbar).^2));
sstr   = n*sum((xbari - xbar).^2);
ssb  = k*sum((xbarj - xbar).^2);

sse   = sst - sstr - ssb;
mssb  = ssb/(n-1);
msstr = sstr/(k-1);
msse  = sse/((n-1)*(k-1));
ff    = msstr/msse;
fb    = mssb/msse;
disp('  ')
disp('___________________________________________________________')
disp('  Source of           Sum  of        Degrees          Mean')
disp('  Variation           Squares      of  Freedom       Square')
disp('___________________________________________________________')
s = sprintf('Between factors   %11.5g       %4.0f        %10.4g',...
sstr,k-1,msstr);
disp(s)
disp('(columns)')
s = sprintf('Between blocks    %11.5g       %4.0f        %10.4g',...
ssb,n-1,mssb);
disp(s)
disp('(rows)')
s = sprintf('Residual          %11.5g       %4.0f        %10.4g',...
sse,(n-1)*(k-1),msse);
disp(s), disp('  ')
s = sprintf('Total             %11.5g       %4.0f',...
sst,(k-1)+(n-1)+((n-1)*(k-1)));
disp(s), disp('  ')
s = sprintf('Effect of factor = %g/%g = %g',msstr,msse,ff);
disp(s)
fstatf = ftest(1-alpha,k-1,(n-1)*(k-1));
pc = alpha*100;
s = sprintf('F at %g percent confidence = %g',pc,fstatf);
disp(s)
if fstatf < ff
  disp('Effect of factors IS significant')
else
  disp('Effect of factors IS NOT significant')
end
disp('  ')
s = sprintf('Effect of block  = %g/%g = %g',mssb,msse,fb);
disp(s)
fstatb = ftest(1-alpha,n-1,(n-1)*(k-1));
s = sprintf('F at %g percent confidence = %g',pc,fstatb);
disp(s)
if fstatb < fb
  disp('Effect of blocks IS significant')
else
  disp('Effect of blocks IS NOT significant')
end
disp('  ')

