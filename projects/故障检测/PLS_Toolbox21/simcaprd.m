function [class,rtsq,rq] = simcaprd(newx,mod,out);
%SIMCAPRD Projects new data into SIMCA model.
%  Compares new data to an existing SIMCA model. The inputs
%  are the new data (newx) and the SIMCA model (model).
%  The outputs are predicted class for each new sample (nclass)
%  and the reduced T^2 (rtsq) and reduced Q values (nq),
%  i.e. the T^2 and Q values divided by their previously
%  determined 95% limit. SIMCAPRD also prints information
%  on the samples to the screen about the assigned class(es) 
%  of each sample unless the optional variable (out = 0).
%
%I/O: [nclass,rtsq,rq] = simcaprd(newx,model,out);
%
%See also: PCA, SIMCA

%Copyright Eigenvector Research, Inc. 1996-98
%Checked by BMW 1/11/97
%Fixed help nbg 9/24/98

if nargin == 2
  out = 1;
end
noclass = mod(1,10);
[mx,nx] = size(newx);
[mm,mn] = size(mod);
modinds = [mod(2,1:noclass) mm+1];
rtsq = zeros(mx,noclass);
rq = zeros(mx,noclass);
classes = zeros(noclass,1);
for i = 1:noclass
  m = mod(modinds(i):modinds(i+1)-1,:);
  [mm,mn] = size(m);
  q = m(1,15); tsq = m(1,16); mo = m(1,7); ssq = zeros(m(1,14),4);
  classes(i) = m(1,10); 
  if m(1,12) == 1
    loads = m(3:mm,1:m(1,8))';
    sx = newx;
	ssq(:,2) = m(2,1:m(1,14))'; 
  elseif m(1,12) == 2
    loads = m(4:mm,1:m(1,8))';
    sx = scale(newx,m(2,1:m(1,8)));
    ssq(:,2) = m(3,1:m(1,14))';
  elseif m(1,12) == 3
    loads = m(5:mm,1:m(1,8))';
    sx = scale(newx,m(2,1:m(1,8)),m(3,1:m(1,8)));
	ssq(:,2) = m(4,1:m(1,14))';
  end
  [nscores,nres,ntsq] = pcapro(sx,loads,ssq,q,tsq,0,mo);
  rtsq(:,i) = ntsq/tsq;
  rq(:,i) = nres/q;
end
rt2rqsum = sqrt(rtsq.^2 + rq.^2);
[mnt2q,ind] = min(rt2rqsum');
class = classes(ind);
if out ~= 0
  for i = 1:mx
    indc = find(rt2rqsum(i,:)<sqrt(2));
    [mi,ni] = size(indc);
    if ni == 1
      s = sprintf('Sample %g belongs to class %g',i,classes(indc));
	  disp(s)
    elseif ni == 0
      disp('  ')
      s = sprintf('Sample %g does not belongs to any class,',i);
	  disp(s)
	  s = sprintf('it is closest to class %g',class(i));
	  disp(s)
	  s = sprintf('with reduced Q = %g and reduced T^2 = %g', ...
	  rq(i,ind(i)),rtsq(i,ind(i)));
	  disp(s), disp('  ')
    elseif ni > 1
      disp('  ')
	  s = sprintf('Sample %g belongs to %g classes',i,ni);
	  disp(s), kclass = classes(indc); sk = [];
	  for k = 1:ni
	    sk = [sk '  ' int2str(kclass(k))];
	  end
	  disp(['They are classes ' sk])
	  s = sprintf('It is nearest the center of class %g',class(i));
	  disp(s), disp('  ')
    end
  end  
end
