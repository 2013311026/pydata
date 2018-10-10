function b = plspulsm(u,y,n,maxlv,split,delay)
%PLSPULSM Identifies FIR dynamics models for MISO systems
%  This function determines the coefficients for finite impulse
%  response (FIR) models using PLS for multi-input single
%  output (MISO) systems. The inputs are the matrix or vector
%  of system inputs (u), the system output (y), the number of
%  FIR coefficients to include for each input (n), the maximum
%  number of latent variables to consider (maxlv), the number of
%  times to split the data set for cross validation (split) and
%  the number of time units of delay for each input (delay).
%  The output is the vector of FIR coefficients (b) given in
%  in the order they appear in the input.
%
%  Example: b = plspulsm([u1 u2],y,[25 15],5,10,[0 3]);
%  This system has 2 inputs, with 25 and 15 coeffs, max of 5 lvs,
%  10 splits of the data, and 0 and 3 unit delays on each of
%  the two inputs. Note that this function uses contiguous blocks
%  of data for cross-validation.
%
%I/O: b = plspulsm(u,y,n,maxlv,split,delay);
%
%See also: AUTOCOR, CROSSCOR, FIR2SS, PULSDEMO, WRITEIN2, WRTPULSE

%Copyright Eigenvector Research, Inc. 1991-2000
%Modified BMW 4/94
%Modified BMW 3/98
%nbg 11/00 added out=0 to crossval function

[mu,nu] = size(u);
[my,ny] = size(y);
%  Check to see that matrices are of consistant dimensions
if nu > mu
  error('the input u is supposed to be colmn vectors')
end
if ny ~= 1
  error('the output y is supposed to be a colmn vector')
end
if mu ~= my
  error('There must be an equal number of points in the input and output vectors')
end
sum(n);
if maxlv > ans
  error('The max no. of latent variables must be <=  sum(n)')
end
test = mu - n;
%  Find maximum number of terms for all inputs
a = max(n+delay);
%  Write out file using maximum number of terms
for i = 1:nu 
  [temp,y2] = writein2(u(:,i),y,a);
%  Delete proper number of columns according to delay and # of coeffs
  temp = temp(:,delay(:,i)+1:n(:,i)+delay(:,i));
%  Construct total matrix from each input part
  if i == 1
    umat = temp;
  else
    umat = [umat temp];
  end
end
%[press,cumpress,minlv,b] = plscvblk(umat,y2,split,maxlv);
%[press,cumpress] = crossval(umat,y2,'sim','con',maxlv,split);
[press,cumpress] = crossval(umat,y2,'sim','con',maxlv,split,[],[],0); %nbg 11/00
b = pls(umat,y2,maxlv);
subplot(2,1,1)
plot(press','-o')
title('Individual PRESS Curves')
xlabel('Number of LVs')
ylabel('PRESS')
subplot(2,1,2)
plot(cumpress,'-o')
title('Cumulative PRESS Curve')
xlabel('Number of LVs')
ylabel('PRESS')
flag = 0;
while flag == 0;
  minlv = input('How many LVs would you like to retain?  ');
  if (minlv > 0 & minlv <= maxlv)
    flag = 1;
  else
    disp(sprintf('Number of LVs retained must be between 1 and %g',maxlv))
  end
end
b = b(minlv,:)';
subplot(1,1,1);
plot(b,'-o')
z = axis;
yh = ((z(4) - z(3))*0.6)+z(3);
if nu > 1
  cn = cumsum(n);
  hold on, plot(cn(1:nu-1),zeros(1,nu-1),'+b'), hold off
  for i = 1:nu
    s = sprintf('FIR Model Input %g',i);
	if i == 1
	  text(2,yh,s);
	else
	  text(cn(i-1)+2,yh,s);
	end  
  end
else
  text(2,yh,'FIR Model Regression Coefficients')
end  
pause
ypred = umat*b;
[mb,nb] = size(ypred);
plot(1:mb,ypred,1:mb,ypred,'+r',1:mb,y2,1:mb,y2,'og')
txt = sprintf('Actual (o) and Predicted (+) Outputs from %g LV PLS Model',minlv);
title(txt)
xlabel('Sample Number')
ylabel('Output')
