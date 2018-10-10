function [fit,pop] = gaselctr(x,y,np,mg,mt,wn,cn,bf,cr,ml,cv,sp,it)
%GASELCTR genetic algorithm for variable selection with PLS
%  GASELCTR uses a genetic algorithm optimization to
%  minimize cross validation error for variable selection.
%  Inputs are: (x) the predictor block, (y) the predicted
%  block [all scaling should be done prior to running the
%  GA], (np) the population size [16 to 256 and must be
%  divisible by 4], (mg) the maximum number of generations
%  [25 to 500], (mt) the mutation rate [typically 0.001 to
%  0.01], (wn) the number of variables in a window (window
%  width), (cn) per cent of population the same at
%  convergence, (bf) per cent terms included at initiation
%  [10 to 50], (cr) breeding cross over rule [1 = single,
%  2 = double], (ml) maximum number of latent variables for
%  the PLS models, (cv) cross validation option [0 = random,
%  1 = contiguous blocks], (sp) number of subsets to divide
%  data into for cross validation, (it) number of iterations
%  for cross validation at each generation. The outputs are:
%  (pop) the unique populations at either convergence
%  or maximum generations, and (fit) the fitness [cross
%  valdation error] for each population in (pop).
%
%I/O: [fit,pop] = gaselctr(x,y,np,mg,mt,wn,cn,bf,cr,ml,cv,sp,it);
%
%Example:
%  [fit,pop] = gaselctr(mncn(x),mncn(y),32,100,0.005,5,80,50,2,4,0,5,1)
%  
%See also: GENALG

% Copyright Eigenvector Research, Inc. 1995-2000
% Modified 2/9/97,2/10/98 NBG
% Modified 4/30/98 BMW
% 10/27/00, nbg change in main loop to check if pop(i,:) is all zeros

% Set Metaparameters
nopop     = np;   %Population size
maxgen    = mg;   %Max number of generations
mut       = mt;   %Mutation Rate
window    = wn;   %Window width for spectral channels
converge  = cn;   % % of pop the same at convergence
begfrac   = bf/100;   %Fraction of terms included in beginning
cross     = cr;   %Double or single cross over, 1 = single
reg       = 1;    %Regression method, 0 = MLR, 1 = PLS
maxlv     = ml;   %No. LVs, only needed with reg = 1
cvopt     = cv;   %CV option, 0 = random, 1 = contiguous
split     = sp;   %No. subsets to divide data into
iter      = it;   %No. iterations of CV at each generation

[m,n]     = size(x);
fig       = figure;
  gcount    = 1;
  specsplit = ceil(n/window);
  %Check to see that nopop is divisible by 4
  dp1        = nopop/4;
  if ceil(dp1) ~= dp1
    nopop   = ceil(dp1)*4;
    disp('Population size not divisible by 4')
    s       = sprintf('Resizing to a population of %g',nopop);
    disp(s)
  end
  %Generate initial population
  pop     = rand(nopop,specsplit);
  for i = 1:nopop
    for j = 1:specsplit
      if pop(i,j) < begfrac
        pop(i,j) = 1;
      else
        pop(i,j) = 0;
      end
    end
	if sum(pop(i,:)')<0.5
	  colm        = round(rand(1)*specsplit);
	  if colm <0.5
	    colm      = 1;
	  end
	  pop(i,colm) = 1;
	end
  end

%Set limit on number of duplicates in population
maxdups = ceil(nopop*converge/100);
%Iterate until dups > maxdups
dat = [x y];

  dups     = 0;
  cavterms = zeros(1,maxgen);
  cavfit   = zeros(1,maxgen);
  cbfit    = zeros(1,maxgen);

% Main Loop

  while dups < maxdups
    drawnow

    %Shuffle data and form calibration and test sets
    s        = sprintf('At generation %g the number of duplicates is %g',gcount,dups);
    disp(s)
    avterms  = mean(sum(pop'));
    cavterms(gcount) = avterms;
    s        = sprintf('The average number of terms is %g',avterms);
    disp(s)
    dups     = 0; 
    if reg == 1
      fit    = zeros(maxlv,nopop); 
    else
      fit    = zeros(1,nopop);
    end
    %Test each model in population
	drawnow
    for kk = 1:iter       %Number of iterations
      if cvopt == 0
        dat  = shuffle(dat);
      else
        di   = shuffle([2:m]');
        dat  = [dat(di(1):m,:); dat(1:di(1)-1,:)];
      end
      for i = 1:nopop
	    drawnow
      %Check to see that model isn't a repeat
        dflag = 0;
        if i > 1
          for ii = 1:i-1
	           dif = sum(abs(pop(i,:) - pop(ii,:)));
            if dif == 0
              dflag = 1;
              fit(:,i) = fit(:,ii);
            end
          end
        end
        if dflag == 1;
          if kk == 1
            dups = dups + 1;
          end
        else
          %Select the proper columns for use in modeling
          inds = find(pop(i,:))*window;
          [smi,sni] = size(inds);
          if inds(1) <= n
            ninds = [inds(1)-window+1:inds(1)];
          else
            ninds = [inds(1)-window+1:n];
          end
          for aaa = 2:sni
            if inds(aaa) <= n
              ninds = [ninds [inds(aaa)-window+1:inds(aaa)]];
            else
              ninds = [ninds [inds(aaa)-window+1:n]];
            end
          end
          xx = dat(:,ninds);
          [mxx,nxx] = size(xx);
          yy = dat(:,n+1);
          if reg == 1
	  	    lvs = min([nxx,maxlv]);
            %[press,cumpress,minlv] = plscvbkf(xx,yy,split,lvs); 
            [press,cumpress] = crossval(xx,yy,'sim','con',lvs,split,[],[],0);   
            fit(1:lvs,i) = fit(1:lvs,i) + (sqrt(cumpress/m)/iter)';
		    if lvs < maxlv
		      fit(lvs+1:maxlv,i) = Inf*ones(maxlv-lvs,1);
		    end
          else
            press = mlrcvblk(xx,yy,split);
			fit(i) = fit(i) + sqrt(press/m)/iter;  
          end
        end
      end
    end
    %Sort models based on fitness
	drawnow
	if reg == 1
	  if maxlv ==1
	    mfit       = fit;
	  else
        mfit       = min(fit);
	  end
	else
      mfit = fit;
	end
    [mfit,ind]     = sort(mfit);
    s              = sprintf('The best fitness is %g',mfit(1));
    disp(s)
    cbfit(gcount)  = mfit(1);
    s              = sprintf('The average fitness is %g',mean(mfit));
    disp(s)
    cavfit(gcount) = mean(mfit);
    pop            = pop(ind,:);
    figure(fig)
    subplot(2,2,1)
    sumpop         = sum(pop');
    plot(sumpop,mfit,'og'), mnfit = min(mfit); mxfit = max(mfit);
    dfit           = mxfit - mnfit; if dfit == 0, dfit=1; end
    axis([min(sumpop)-1 max(sumpop)+1 mnfit-dfit/10 mxfit+dfit/10])
    if window > 1
      xlabel('Number of Windows')
      s = sprintf('Fitness vs. # of Windows at Generation %g',gcount);
    else
      xlabel('Number of Variables')
	  s = sprintf('Fitness vs. # of Variables at Generation %g',gcount);
    end  
    title(s)
    ylabel('Fitness')
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    subplot(2,2,2)
    plot(1:gcount,cavfit(1:gcount),1:gcount,cbfit(1:gcount))
    xlabel('Generation')
    ylabel('Average and Best Fitness')
    title('Evolution of Average and Best Fitness')
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    subplot(2,2,3)
    plot(cavterms(1:gcount))
    xlabel('Generation')
    if window > 1
      ylabel('Average Windows Used')
	  title('Evolution of Number of Windows')
    else
      ylabel('Average Variables Used')
	  title('Evolution of Number of Variables')	
    end
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    subplot(2,2,4)
    bar(sum(pop))
    if window > 1
      xlabel('Window Number')
      ylabel('Models Including Window')
	  s = sprintf('Models with Window at Generation %g',gcount);
    else
      xlabel('Variable Number')
      ylabel('Models Including Variable')
      s = sprintf('Models with Variable at Generation %g',gcount);
    end
    title(s)
    axis([0 ceil(n/window)+1 0 nopop+2])
	set(gca,'FontSize',9)
    set(get(gca,'Ylabel'),'FontSize',9)
    set(get(gca,'Title'),'FontSize',9)
    set(get(gca,'Xlabel'),'FontSize',9)
    drawnow
    % Check to see if maxgen has been met
    if gcount >= maxgen
      dups = maxdups;
    end
    % Breed best half of population and replace worst half
    pop(1:nopop/2,:) = shuffle(pop(1:nopop/2,:));
    pop((nopop/2)+1:nopop,:) = pop(1:nopop/2,:);
    for i = 1:nopop/4
      for j = 1:cross
        %Select twist point at random
        tp = ceil(rand(1)*(specsplit-1));
        %Twist pairs and replace
	    p1 = (nopop/2)+(i*2)-1;
	    p2 = (nopop/2)+(i*2);
	    p1rep = [pop(p1,1:tp) pop(p2,tp+1:specsplit)];
	    p2rep = [pop(p2,1:tp) pop(p1,tp+1:specsplit)];
        pop(p1,:) = p1rep;
        pop(p2,:) = p2rep;
      end
    end
    %Mutate the population if dups < maxdups
    if dups < maxdups
      [mi,mj] = find(rand(nopop,specsplit)<mut);
      [ms,ns] = size(mi);
      for i=1:ms
        if pop(mi(i),mj(i)) == 1
          pop(mi(i),mj(i)) = 0;
        else
          pop(mi(i),mj(i)) = 1;
        end
      end
      for i=1:nopop                %nbg 10/27/00, start, check if any row of pop all zero, 
        if isempty(find(pop(i,:)))
          pop(i,1+round(rand(1)*(size(pop,2)-1))) = 1;
        end
      end                          %nbg 10/27/00, end
    end 
    gcount = gcount + 1;
  end
%End of Main Loop

if dups >= maxdups
  drawnow
  %Extract unique models from final population
  fpop = zeros(nopop-dups,specsplit);
  unique = 0; dups = 0;
  for i = 1:nopop
    dflag = 0;
    if i > 1
      for ii = 1:i-1
        dif = sum(abs(pop(i,:) - pop(ii,:)));
        if dif == 0
          dflag = 1;
        end
      end 
    end
    if dflag == 1
      dups = dups + 1;
    else
	  unique = unique + 1;
	  fpop(unique,:) = pop(i,:);
    end
  end
  s = sprintf('There are %g unique models in final population',unique);
  disp(s)
  %Testing final population
  if reg == 1
    fit = zeros(maxlv,unique); 
  else
    fit = zeros(1,unique);
  end
  disp('Now testing models in final population')
  for kk = 1:3*iter       %Number of iterations 
    if cvopt == 0
      dat = shuffle(dat);
    else
      di = shuffle([2:m]');
      dat = [dat(di(1):m,:); dat(1:di(1)-1,:)];
    end
    for i=1:unique
      %Select the proper columns for use in modeling
      inds      = find(fpop(i,:))*window;
      [smi,sni] = size(inds);
      if inds(1)<=n
        ninds = [inds(1)-window+1:inds(1)];
      else
        ninds = [inds(1)-window+1:n];
      end
      for aaa=2:sni
        if inds(aaa) <= n
          ninds = [ninds [inds(aaa)-window+1:inds(aaa)]];
        else
          ninds = [ninds [inds(aaa)-window+1:n]];
        end
      end
      xx = dat(:,ninds);
      [mxx,nxx] = size(xx);
      yy = dat(:,n+1);
      if reg==1
        lvs = min([nxx,maxlv]);
        %[press,cumpress,minlv] = plscvbkf(xx,yy,split,lvs); 
        [press,cumpress] = crossval(xx,yy,'sim','con',lvs,split,[],[],0);   
        fit(1:lvs,i) = fit(1:lvs,i) + (sqrt(cumpress/m)/(iter*3))';
	      if lvs < maxlv
	  	    fit(lvs+1:maxlv,i) = Inf*ones(maxlv-lvs,1);
        end
      else
        press = mlrcvblk(xx,yy,split);
        fit(i) = fit(i) + sqrt(min(press)/m)/(iter*3);
      end
	    if kk == iter*3
        if reg == 1
          [mf,ind] = min(fit(:,i));
          s = sprintf('Number %g fitness is %g at %g LVs',i,mf,ind);
          %s = sprintf('Number %g fitness is %g at %g LVs',i,min(fit(:,i)),minlv);
        else
          s = sprintf('Number %g fitness is %g',i,min(fit(:,i)));	  
	      end
	      disp(s)
      end
    end
  end
  if reg==1
    if size(fit,1)==1 %modified 2/10/98
      mfit = fit;
    else
      mfit = min(fit,[],1);
    end %end modification 2/10/98
  else
    mfit = fit;
  end
  [mfit,ind] = sort(mfit);
  s          = sprintf('The best fitness is %g',mfit(1));
  disp(s)
  s          = sprintf('The average fitness is %g',mean(mfit));
  disp(s)
  fpop       = fpop(ind,:);
  ffit       = mfit;
  % Translate the population (in terms of windows) into the
  % actual variables used in the final population.
  if window == 1
    gpop = fpop;
  else
    gpop = zeros(unique,n);
    for jk = 1:unique
      inds = find(fpop(jk,:))*window;
      [smi,sni] = size(inds);
      if inds(1) <= n
        ninds = [inds(1)-window+1:inds(1)];
      else
        ninds = [inds(1)-window+1:n];
      end
      for aaa = 2:sni
        if inds(aaa) <= n
          ninds = [ninds [inds(aaa)-window+1:inds(aaa)]];
        else
          ninds = [ninds [inds(aaa)-window+1:n]];
        end
	  end
      [snmi,snni] = size(ninds);
	  gpop(jk,ninds) = ones(1,snni);
	end
  end
end  
  
fit = ffit;
pop = gpop;
