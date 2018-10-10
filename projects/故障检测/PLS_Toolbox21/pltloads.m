function pltloads(loads,labels)
%PLTLOADS Plots loadings from PCA
%  This function may be used to make 2-D and 3-D plots
%  of loadings vectors against each other. The inputs to
%  the function are the matrix of loadings vectors (loads)
%  where each column represents a loadings vector from the
%  PCA function and an optional variable of labels (labels)
%  which describe the original data variables.
%
%  Note: labels must be a "column vector" where each label
%  is in single quotes and has the same number of letters.
%  Example: labels = ['Height'; 'Weight'; 'Waist '; 'IQ    ']
%  The function will prompt to select 2 or 3-D plots,
%  for for the numbers of the PCs, and if you would like
%  "drop lines" and axes on the 3-D plots.
%
%I/O: pltloads(loads,labels)
%
%See also:  DP, HIORB, HLINE, PCA, PLTLOADS, VLINE, XPLDSTR, ZOOMPLS

%Copyright Eigenvector Research, Inc. 1993-98
%Modified by BMW 11/93, NBG 2/96, 10/96

[m,n] = size(loads);
if nargin > 1
  [ml,nl] = size(labels);
else
  ml  = 0;
  nl  = 0;
end
if m > 100
  disp('  ')
  disp('These plots are pretty messy with this many variables!')
end
lflag = 0;
disp('  ')
s = input('Do you want eliminate the labels on the points? (Yes = 1) ');
if (~isempty(s))&(s == 1)
  lflag = s;
end
dflag = 0; dlflag = 0; aflag = 0;
if n > 2
  disp('  ')
  s = input('Would you like to do 3-D loadings plots? (Yes = 1) ');
  if (~isempty(s))&(s == 1)
    dflag = 1;
    disp('  ')
    s = input('Would you like to show "drop-lines?" (Yes = 1) ');
    if (~isempty(s))&(s == 1)
      dlflag = 1;
    end
    disp('  ')
    s = input('Would you like to show axes? (Yes = 1) ');
    if (~isempty(s))&(s == 1)
      aflag = 1;
    end
    disp('  ')
	s = input('Would you like to show a grid? (Yes = 1) ');
	if (~isempty(s))&(s == 1)
	  gflag = 1;
	end
  end
end
flag = 1;
while flag == 1
  disp('   ')
  txt = sprintf('What PC do you want on the x-axis? (Max = %g) ',n);
  input(txt);
  xpc = ans;
  disp('   ')
  txt = sprintf('What PC do you want on the y-axis? (Max = %g) ',n);
  input(txt);
  ypc = ans;
  zpc = 0;
  if dflag == 1
    disp('   ')
    txt = sprintf('What PC do you want on the z-axis? (Max = %g) ',n);
    input(txt);
    zpc = ans;
  end
  if xpc > n
    disp('  ')
    s = sprintf('Sorry there are only %g PCs available to plot, please try again!',n);
    disp('  ')
    disp(s)
  elseif ypc > n
    disp('  ')
    s = sprintf('Sorry there are only %g PCs available to plot, please try again!',n);
    disp('  ')
    disp(s)
  elseif zpc > n
    disp('  ')
    s = sprintf('Sorry there are only %g PCs available to plot, please try again!',n);
    disp('  ')
    disp(s)
  else
  	space = [' '];
    if dflag == 0
      plot(loads(:,xpc),loads(:,ypc),'+r')
      if lflag ~= 1
	    if (nargin==1)|(m~=ml)
		  if (m~=ml)&(nargin>1)
            disp('  ')
		    disp('number of Labels not equal to number of samples')
          end
          for i = 1:m
            s = int2str(i);
			s = [space s];
            text(loads(i,xpc),loads(i,ypc),s)
          end
        else
		  nlabels = [space(ones(m,1)) labels];
          text(loads(:,xpc),loads(:,ypc),nlabels)
        end
      end
      hold on
	  xt = get(gca,'XTick');
	  yt = get(gca,'YTick');
	  [mxt,nxt] = size(xt);
	  [myt,nyt] = size(yt);
	  if sign(xt(1)*xt(nxt)) == -1
	    plot([0 0],[yt(1) yt(nyt)],'-g')
	  end
	  if sign(yt(1)*yt(nyt)) == -1
	    plot([xt(1) xt(nxt)],[0 0],'-g')
	  end
      hold off
      s = sprintf('Loadings for PC# %g',xpc);
      xlabel(s)
      s = sprintf('Loadings for PC# %g',ypc);
      ylabel(s)
      s = sprintf('Loadings for PC# %g versus PC# %g',xpc,ypc);
      title(s)
	else
	  plot3(loads(:,xpc),loads(:,ypc),loads(:,zpc),'og')
	  if lflag ~= 1
	    if (nargin==1)|(m~=ml)
		  if (m~=ml)&(nargin>1)
            disp('  ')
		    disp('number of Labels not equal to number of samples')
          end
		  for i = 1:m
            s = int2str(i);
            s = [space s];
            text(loads(i,xpc),loads(i,ypc),loads(i,zpc),s)
		  end
        else
		  nlabels = [space(ones(m,1)) labels];
          text(loads(:,xpc),loads(:,ypc),loads(:,zpc),nlabels)
        end
      end
	  if dlflag == 1
	    hold on
		z = axis;
        for i = 1:m
          mat = [loads(i,xpc),loads(i,ypc),loads(i,zpc)
          loads(i,xpc),loads(i,ypc),z(5)];
          plot3(mat(:,1),mat(:,2),mat(:,3))
        end 
        hold off
	  end
	  if aflag == 1
	    hold on
	    xt = get(gca,'XTick');
	    yt = get(gca,'YTick');
		zt = get(gca,'ZTick');
	    [mxt,nxt] = size(xt);
	    [myt,nyt] = size(yt);
		[mzt,nzt] = size(zt);
	    if sign(xt(1)*xt(nxt)) == -1
		  if sign(zt(1)*zt(nzt)) == -1
	        plot3([0 0],[yt(1) yt(nyt)],[0 0],'-g')
		  end
		  if sign(yt(1)*yt(nyt)) == -1
	        plot3([0 0],[ 0 0],[zt(1) zt(nzt)],'-g')
		  end
	    end
	    if sign(yt(1)*yt(nyt)) == -1
		  if sign(zt(1)*zt(nzt)) == -1
	        plot3([xt(1) xt(nxt)],[0 0],[0 0],'-g')
		  end
	    end
		hold off
	  end
	  if gflag == 1
	    grid on
      end
      s = sprintf('Loadings for PC# %g',xpc);
      xlabel(s)
      s = sprintf('Loadings for PC# %g',ypc);
      ylabel(s)
	  s = sprintf('Loadings for PC# %g',zpc);
      zlabel(s)
      s = sprintf('Loadings for PC# %g versus PC# %g versus PC# %g',xpc,ypc,zpc);
      title(s)
      disp('  ')
	  input('Do you want to change the 3-D view? (Yes = 1) ');
	  vf = ans;
	  while vf == 1
	    [az,el] = view;
        disp('  ')
		sv = sprintf('Current view is az = %g and el = %g',az,el);
		disp(sv) 
        disp('  ')
	    input('Enter new azimuth (default = 322.5) ');
		naz = ans;
		if abs(naz) <= 360
		  az = abs(naz);
		else
          disp('  ')
		  disp('Origninal azimuth retained')
		end
        disp('  ')
		input('Enter new elevation (default = 30) ');
		nel = ans;
		if abs(nel) <= 90
		  el = abs(nel);
		else
          disp('  ')
		  disp('Origninal azimuth retained')
		end
		view([az,el])
        disp('  ')
		input('Would you like to change the view again? (Yes = 1) ');
		vf = ans;
      end
	end
    disp('  ')
    input('Do you want to make another plot? (Yes = 1) ');
    flag = ans;
  end
end
