function anova1w(dat,alpha)
%ANOVA1W One way analysis of variance
%  Calculates one way ANOVA table and tests significance of
%  between factors variation (it is assumed that each column
%  of the data represents a different treatment). Inputs
%  are the data table (dat) and the desired confidence level
%  (alpha), expressed as a fraction (e.g. .95, .99, etc.).
%  The output is an ANOVA table.
%
%I/O: anova1w(dat,alpha)
%
%See also: ANOVA2W, FTEST, STATDEMO

%Copyright Eigenvector Research 1994-99
%Modified NBG 1996
%Checked on MATLAB 5 by BMW  1/4/97, 3/99
%Modified BMW 12/98 via Paul Gemperline

[n,k]     = size(dat);
a_mean    = mean(mean(dat));
a_tr_mean = mean(dat);

sst     = sum(sum((dat - a_mean).^2));
sstr    = n*sum((a_tr_mean - a_mean).^2);
sse     = sum(sum((dat - a_tr_mean(ones(1,n),:)).^2));

msstr   = sstr/(k-1);
msse    = sse/((n-1)*k);
ff      = msstr/msse;
disp('  ')
disp('___________________________________________________________')
disp('  Source of           Sum  of        Degrees          Mean')
disp('  Variation           Squares      of  Freedom       Square')
disp('___________________________________________________________')
s = sprintf('Between factors   %11.5g       %4.0f        %10.4g',...
sstr,k-1,msstr);
disp(s)
disp('(columns)')
s = sprintf('Residual          %11.5g       %4.0f        %10.4g',...
sse,(n-1)*k,msse);
disp(s), disp('  ')
s = sprintf('Total             %11.5g       %4.0f',sst,(k-1)+(n-1)*k);
disp(s)
disp('  ')
s = sprintf('Effect of factor = %g/%g = %g',msstr,msse,ff);
disp(s)
disp('  ')
fstatf = ftest(1-alpha,k-1,(n-1)*k);
pc = (alpha)*100;
s = sprintf('F at %g percent confidence = %g',pc,fstatf); disp(s)
if fstatf < ff
  disp('Effect of factors IS significant')
else
  disp('Effect of factors IS NOT significant')
end
disp('  ')



