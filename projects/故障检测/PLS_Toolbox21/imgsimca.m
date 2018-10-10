function model = imgsimca(img,data)%IMGSIMCA SIMCA Classification for Multivariate Images%  This function allows the user to build SIMCA class models%  by outlining areas on a reference image (img) that correspond%  to areas on a multivariate image (data). This image must%  be the same size (pixels by pixels) as the multivariate%  image data but can have a different depth (possibly due to%  having preprocessed the original data with IMGPCA). The%  output is a structured array (model) which may be applied to %  new images with ISIMCAPR. The elements of the model are:%%          imgname: name of original image variable%          mwaname: name of original multivariate image data%             name: model type, always IMGSIMCA%             date: date stamp%             time: time stamp%             size: size of the image data%         simcamod: simca model parameters (see SIMCA)%         in_class: array which gives pixels within 95% Q limits for each class%    closest_class: array which gives closest class for each pixel%            rqmat: reduced Q values for all classes for all pixels%          rtsqmat: reduced T^2 values for all classes for all pixels%%I/O: model = imgsimca(img,data);%%See also IMGSELCT, IMGPCA, ISIMCAPR%Copyright Eigenvector Research, Inc. 1999-2000%bmw April 27, 1999%nbg 11/00 added ;h0 = image(img);    %nbg 11/00title('Input image for selecting class areas')datadim = size(data);flag = 0;k = 0;while flag == 0  disp('select an area')  [xinds,yinds] = imgselct;  k = k+1;  cn = input('what class number is this? ');  xlength = length(xinds);  if k > 1;    inds = [inds; [xinds yinds cn*ones(xlength,1)]];  else    inds = [xinds yinds cn*ones(xlength,1)];  end  nc = input('Do you want to do another area? ','s');  if ~(nc(1) == 'y' | nc(1) == 'Y')     flag = 1;  endendout = inds;[mi,ni] = size(inds);ndat = zeros(mi,datadim(3));for i = 1:mi  ndat(i,:) = squeeze(data(inds(i,2),inds(i,1),:))';endmodel = simca(ndat,inds(:,3));h = get(0,'children');close(h(1:2));data = reshape(data,datadim(1)*datadim(2),datadim(3));[nclass,rtsq,rq] = simcaprd(double(data),model,0);[mr,nr] = size(rtsq);classclose = ones(datadim(1),datadim(2),nr)*255;classin = ones(datadim(1),datadim(2),nr+1)*255;rqmat = zeros(datadim(1),datadim(2),nr);rtsqmat = rqmat;for i = 1:nr  rqmat(:,:,i) = reshape(rq(:,i),datadim(1),datadim(2));  rtsqmat(:,:,i) = reshape(rtsq(:,i),datadim(1),datadim(2));endk = 0;for i = 1:datadim(2);  for j = 1:datadim(1);    k = k+1;    classclose(j,i,nclass(k)) = 0;	if ~isempty(find(rq(k,:)<=1))	  classin(j,i,find(rq(k,:)<=1)) = zeros(size(find(rq(k,:)<=1)));     end	if min(rq(k,:))>1	  classin(j,i,nr+1) = 0;	end  endendcolormap(hot(256));for i = 1:nr  if i == 1    h1 = figure;	image(classin(:,:,i)); 	title('Areas in Class 1 Shown in Black')    colormap(hot(256));	h2 = figure;	image(classclose(:,:,i));	title('Areas Closest to Class 1 Shown in Black')	colormap(hot(256))	h3 = figure;    imagesc(sqrt(rqmat(:,:,i)));	title('Q values on Class 1 for Entire Image, 95% Limit = 1')  else    figure(h1); image(classin(:,:,i));	title(sprintf('Areas in Class %g Shown in Black',i));    figure(h2); image(classclose(:,:,i));    title(sprintf('Areas Closest to Class %g Shown in Black',i));	    figure(h3); imagesc(sqrt(rqmat(:,:,i)));	title(sprintf('Q values on Class %g for Entire Image, 95% Limit = 1',i))  end  colormap(hot(256));  colorbar  pauseendfigure(h1); image(classin(:,:,nr+1));title('Areas in Not in Any Class Shown in Black');% Save the model as a structured array    model = struct('imgname',inputname(1),'mwaname',inputname(2),'name','IMGSIMCA',...        'date',date,'time',clock,'size',datadim,'simcamod',model,...		'in_class',classin,'closest_class',classclose,'rqmat',rqmat,'rtsqmat',rtsqmat);