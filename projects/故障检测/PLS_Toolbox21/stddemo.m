%STDDEMO Demos STDSSLCT, STDGEN and OSCCALC for instrument standardization
disp('This script demonstrates the functions STDSSLCT, STDGEN,')
disp('STDGENDW and OSCCALC for doing instrument standardization.')
disp(' ')

% Copyright Eigenvector Research, Inc. 1994-99
% Modified by BMW 3/98
% Modified by BMW 3/99

disp('We are going to use some NIR spectrometer data from two')
disp('instruments.')
disp('First we will load the data and plot it up.')
disp(' '),  
echo on
load nir_data
plot(lamda,spec1,'-r',lamda,spec2,'-b')
echo off
title('NIR Spectra','FontSize',14,'fontweight','bold')
xlabel('Wavelength (nm)','FontSize',14)
ylabel('Absorbance','FontSize',14)
text(825,1.5,'Instrument number 1 spectras shown in red','fontsize',14)
text(850,1.25,'Instrument number 2 spectras shown in blue','fontsize',14)
disp(' ')
disp('This plot shows both sets of spectra.  Here they do not')
disp('look all that different, so lets plot the difference.')
disp(' ')
pause
plot(lamda,spec1-spec2,'-r'), hline(0)
title('Difference between NIR Spectra from Instruments 1 and 2',...
'FontSize',14,'fontweight','bold')
xlabel('Wavelength (nm)','FontSize',14)
ylabel('Absorbance Difference','FontSize',14)
disp('Now the difference is much more apparent.')
disp(' ')
pause 
disp('Now we will construct PLS calibration models that predict')
disp('the concentration of each of the 5 analytes in the mixtures.')
disp('We will make 5 models. Each model will use the spectra from')
disp('instrument 1 as the predictor block i.e. the X-block. The 5')
disp('Y-blocks will consist of vectors of the known concentrations')
disp('of the analytes. Later, we will use the models along with the')
disp('transformed spectra from instrument 2.  We will not attempt')
disp('to optimize the models for this excercise.  Instead, we will')
disp('just use 5 LVs in each one, since we know the spectra should')
disp('have a true rank of 5 beause there are 5 analytes.')
disp(' ')
pause
disp('Please wait while the models are constructed')
disp(' ')
[mspec1,mns1] = mncn(spec1);
[mspec2,mns2] = mncn(spec2);
[mconc,mnsc]  = mncn(conc);
[b1p,ssq,p1,q1,w1,t1] = pls(mspec1,mconc(:,1),5);
b2p           = pls(mspec1,mconc(:,2),5);
b3p           = pls(mspec1,mconc(:,3),5);
b4p           = pls(mspec1,mconc(:,4),5);
b5p           = pls(mspec1,mconc(:,5),5);
c1p           = mspec1*b1p(5,:)';
c2p           = mspec1*b2p(5,:)';
c3p           = mspec1*b3p(5,:)';
c4p           = mspec1*b4p(5,:)';
c5p           = mspec1*b5p(5,:)';      
disp(' ')
disp('Now that we have the models, we can look at the actual')
disp('concentrations and the fit based on the PLS models.')
disp(' ')
pause 
plot(conc,rescale([c1p c2p c3p c4p c5p],mnsc),'o'), dp
axis([0 50 0 50])
title('Actual versus Fit Concentrations Based on Instrument 1',...
'FontSize',14,'fontweight','bold')
xlabel('Actual Analyte Concentration','FontSize',14)
ylabel('Analyte Concentration Fit to Model','FontSize',14)
text(5,40,'Each analyte shown as different color','FontSize',14)
disp(' ')
pause 

disp('You can see that our PLS models, all based on 5 LVs, fit the data')
disp('quite well.  Now we will use the STDSSLCT function for selecting')
disp('samples with high leverage to use for calibration transfer. We')
disp('will select 5 samples out of the 30 available for calculating')
disp('the transform between instruments. To select the samples, however,')
disp('we need to know the pseudo inverse used by the PLS model in')
disp('calculating the regression vector. We have several models to ')
disp('choose from, lets just use the one for the first analyte.')
disp(' ')
pause 
echo on
rinv = rinverse(p1,t1,w1,5);

echo off
disp(' ')
disp('Now that we have the inverse we can select the subset')
disp(' ')
pause 
echo on
[specsub,specnos] = stdsslct(spec1,5,rinv);

echo off
pause
disp(' ')
disp('Oddly enough, direct standardization works better when the')
disp('samples are chosen based on distance from the mean. Thus, we')
disp('can use the subset selection function to choose transfer')
disp('samples for the direct standardization method as follows:')
disp(' ')
echo on
[specsub,specnosd] = stdsslct(spec1,5);

echo off
pause
disp(' ')
disp('We can now use these subsets of the samples to calculate the')
disp('transform. (In this case, all the samples have already')
disp('been measured on both instruments. If only the instrument 1')
disp('samples had been measured, STDSSLCT would tell you which samples')
disp('should be measured on instrument 2.)')
disp(' ')
disp('Now we can use the STDGEN and STDGENDW functions to obtain a transform')
disp('that converts the response of intrument 2 to look like that of')
disp('instrument 1.  STDGEN can be used to generate direct or')
disp('piecewise direct standardizations with or without additive')
disp('background correction. STDGENDW uses the double window approach to')
disp('forming piecewise direct models. In this case we will use additive')
disp('background correction for all 3 models and compare results. For the') 
disp('piecewise direct standardization we will use a window of 3 channels and')
disp('a tolerance of 1e-3. For double window we will use an inner window of 5')
disp('channels, an outer window of 3 channels, and a tolerance of 1e-4. These')
disp('window widths and tolerances were choosen because we know (since we''ve')
disp('done this before) that they optimize the performance of the transform.')
disp(' ')
pause
echo on
[stdmatd,stdvectd] = stdgen(spec1(specnosd,:),spec2(specnosd,:),0);
[stdmatp,stdvectp] = stdgen(spec1(specnos,:),spec2(specnos,:),3,1e-2);
[stdmatdw,stdvectdw] = stdgendw(spec1(specnos,:),spec2(specnos,:),5,3,1e-2); 
  

echo off
disp(' ')
disp('Now we can convert the second spectra by multiplying by the')
disp('transform matrices, and adding the background correction')
disp('using the STDIZE function as follows:')
disp(' ')
pause
echo on
cspec2d = stdize(spec2,stdmatd,stdvectd);
cspec2p = stdize(spec2,stdmatp,stdvectp);
cspec2dw = stdize(spec2,stdmatdw,stdvectdw);

echo off
disp(' ')
disp('We can also develop a transform using Orthogonal Signal')
disp('Correction (OSC). To do this we''ll use the same 5 samples')
disp('that we''ve selected for developing the PDS transform.')
disp('The 5 samples from each of the instruments will be put')
disp('into one matrix, then the OSC factors will be determined.')
disp('The objective is to find the part of the difference between')
disp('the instruments that is orthogonal to the concentrations, and')
disp('subtract it out of the data.')
disp('   ')
disp('First we will make the matrices with the samples from both')
disp('instruments then we''ll call the OSCCALC function to find')
disp('the factors to remove from the data:')
echo on
[augspec,augsmns] = mncn([spec1(specnos,:); spec2(specnos,:)]);
[augconc,augcmns] = mncn([conc(specnos,:); conc(specnos,:)]);
[nx,nw,np,nt] = osccalc(augspec,augconc,3,20,96);

echo off
pause
disp('  ')
disp('Note that we calculated 3 OSC factors, iterated 20 times')
disp('to find the direction of maximum variance orthogonal to Y')
disp('and calculated a PLS model to reproduce the factor scores')
disp('which captured at least 96% of the variance in the scores.')
disp('These are parameters that must be determined in order to ')
disp('optimize the transform.')
disp('  ')
disp('Now we can use the transform we developed and apply it to our')
disp('two instruments:')
echo on
oscspec1 = scale(spec1,augsmns) - scale(spec1,augsmns)*nw*inv(np'*nw)*np';
oscspec2 = scale(spec2,augsmns) - scale(spec2,augsmns)*nw*inv(np'*nw)*np';

echo off
pause
disp('   ')
disp('We now need to calculate the PLS models that we will use with the')
disp('OSC corrected data. Note that, unlike PDS and DS, when OSC is used')
disp('both the data sets are changed, and new models are required')
disp('for the standard instrument. We will calculate the models quickly')
disp('and won''t bother to show you the variance captured tables.')
disp(' ')
[moscspec1,omns1] = mncn(oscspec1);
ob1 = simpls(moscspec1,mconc(:,1),5);
ob2 = simpls(moscspec1,mconc(:,2),5);
ob3 = simpls(moscspec1,mconc(:,3),5);
ob4 = simpls(moscspec1,mconc(:,4),5);
ob5 = simpls(moscspec1,mconc(:,5),5);
echo off
disp(' ')
disp('Lets look at the difference between instrument 1 spectra')
disp('and the corrected instrument 2 spectra. Note that piecewise')
disp('and double window are very similar, so we''ll only show piecewise.')
disp(' ')
pause
plot(lamda,spec1-spec2,'-r'), hold on, 
title('Difference between NIR Spectra from Instruments 1 and 2',...
'FontSize',14,'fontweight','bold')
xlabel('Wavelength (nm)','FontSize',14)
ylabel('Absorbance Difference','FontSize',14)
text(825,-.05,'Difference before correction shown in red','FontSize',14)
pause
plot(lamda,spec1-cspec2d,'-g')
text(850,-.075,'Difference after direct correction shown in green','FontSize',14)
pause
plot(lamda,spec1-cspec2p,'-b')
text(875,-.1,'Difference after piecewise correction shown in blue','FontSize',14)
pause
plot(lamda,oscspec1-oscspec2,'-m')
text(900,-.125,'Difference after OSC shown in magenta','FontSize',14), hold off
disp('You can see that the differences are much smaller.  Now lets')
disp('see how the predictions look based on the instrument 1 models')
disp('and the standardized instrument 2 spectra.')  
disp(' ')

cmspec2p = scale(cspec2p,mns1);
cmspec2dw = scale(cspec2dw,mns1);
cmspec2d = scale(cspec2d,mns1);
mspec2   = scale(spec2,mns1);
soscspec2 = scale(oscspec2,omns1);
c1p2cp   = cmspec2p*b1p(5,:)';
c2p2cp   = cmspec2p*b2p(5,:)';
c3p2cp   = cmspec2p*b3p(5,:)';
c4p2cp   = cmspec2p*b4p(5,:)';
c5p2cp   = cmspec2p*b5p(5,:)';
c1p2cdw  = cmspec2dw*b1p(5,:)';
c2p2cdw  = cmspec2dw*b2p(5,:)';
c3p2cdw  = cmspec2dw*b3p(5,:)';
c4p2cdw  = cmspec2dw*b4p(5,:)';
c5p2cdw  = cmspec2dw*b5p(5,:)';
c1p2cd   = cmspec2d*b1p(5,:)';
c2p2cd   = cmspec2d*b2p(5,:)';
c3p2cd   = cmspec2d*b3p(5,:)';
c4p2cd   = cmspec2d*b4p(5,:)';
c5p2cd   = cmspec2d*b5p(5,:)';
c1p2     = mspec2*b1p(5,:)';
c2p2     = mspec2*b2p(5,:)';
c3p2     = mspec2*b3p(5,:)';
c4p2     = mspec2*b4p(5,:)';
c5p2     = mspec2*b5p(5,:)';

oc1     = soscspec2*ob1(5,:)';
oc2     = soscspec2*ob2(5,:)';
oc3     = soscspec2*ob3(5,:)';
oc4     = soscspec2*ob4(5,:)';
oc5     = soscspec2*ob5(5,:)';
pause
plot(conc,rescale([c1p c2p c3p c4p c5p],mnsc),'o'), dp
axis([0 50 0 50])
title('Actual versus Fit Concentrations Based on Instrument 1',...
'FontSize',14,'fontweight','bold')
xlabel('Actual Analyte Concentration','FontSize',14)
ylabel('Analyte Concentration Fit to Model','FontSize',14)
text(5,40,'Each analyte shown as different color','FontSize',14)
disp(' ')
disp('Recall that this is how good the fit was based on intrument 1')
pause
disp(' ')
disp('Lets look at some predictions based on the UNSTANDARDIZED')
disp('instrument 2 spectra using the instrument 1 models.')
disp(' ')
  
plot(conc,rescale([c1p2 c2p2 c3p2 c4p2 c5p2],mnsc),'o'), dp
title('Actual Concentrations vs. Predictions Based on Instrument 2',...
'FontSize',14,'fontweight','bold');
axis([0 50 -10 50]), hline(0)
xlabel('Actual Analyte Concentration','FontSize',14)
ylabel('Predicted Analyte Concentration','FontSize',14)
text(5,45,'Each analyte shown as different color','FontSize',14)
pause 
disp(' ')
disp('As you can see, this doesn''t look great.  Now we can')
disp('look at predictions for instrument 2 based on the ')
disp('STANDARDIZED spectra.')
disp(' ')
plot(conc,rescale([c1p2cp c2p2cp c3p2cp c4p2cp c5p2cp],mnsc),'o')
hold on, axis([0 50 -10 50]), dp, hline(0),
title('Actual Concentrations vs. Predictions Based on Standardized Instrument 2',...
'FontSize',14,'fontweight','bold');
xlabel('Actual Analyte Concentration','FontSize',14)
ylabel('Predicted Analyte Concentration','FontSize',14)
text(3,47,'Each analyte shown as different color','FontSize',14)
text(5,44,'o Piecewise direct standardized samples','FontSize',14)
pause
plot(conc,rescale([c1p2cd c2p2cd c3p2cd c4p2cd c5p2cd],mnsc),'*')
text(7,41,'* Direct standardized samples','FontSize',14)
pause
plot(conc,rescale([oc1 oc2 oc3 oc4 oc5],mnsc),'+')
hold off
text(9,38,'+ OSC standardized samples','FontSize',14)
pause
disp(' ')
disp('I think you will agree that the predictions from the piecewise')
disp('direct method are pretty good. The predictions using direct')
disp('standardization are not as good.')
disp(' ')
disp('Lets put some numbers on the difference by calculating the')
disp('root mean sum of squares errors.')
disp(' ')
ssq1 = sqrt(sum(sum((conc-rescale([c1p c2p c3p c4p c5p],mnsc)).^2))/150);
ssq2 = sqrt(sum(sum((conc-rescale([c1p2 c2p2 c3p2 c4p2 c5p2],mnsc)).^2))/150);
ssq2p = sqrt(sum(sum((conc-rescale([c1p2cp c2p2cp c3p2cp c4p2cp c5p2cp],mnsc)).^2))/150);
ssq2d = sqrt(sum(sum((conc-rescale([c1p2cd c2p2cd c3p2cd c4p2cd c5p2cd],mnsc)).^2))/150);
ssq2dw = sqrt(sum(sum((conc-rescale([c1p2cdw c2p2cdw c3p2cdw c4p2cdw c5p2cdw],mnsc)).^2))/150);
ssqo = sqrt(sum(sum((conc-rescale([oc1 oc2 oc3 oc4 oc5],mnsc)).^2))/150);
disp('  ')
disp('Root Mean Sum of Squares Error for')
disp(sprintf('Instrument 1 Fit Error              = %g',ssq1));
disp(sprintf('Unstandardized Instrument 2         = %g',ssq2));
disp(sprintf('Piecewise Standardized Instrument 2 = %g',ssq2p));
disp(sprintf('DWPDS Standardized Instrument 2     = %g',ssq2dw));
disp(sprintf('Direct Standardized Instrument 2    = %g',ssq2d));
disp(sprintf('OSC Standardized Instrument 2       = %g',ssqo));
disp('  ')
pause
disp('So things did get quite a bit better with standardization!')
disp('How much better?')
disp('  ')
disp(sprintf('By a factor of %g for piecewise,',ssq2/ssq2p));
disp(sprintf('a factor of %g for DWPDS, and',ssq2/ssq2dw));
disp(sprintf('by %g for direct standardization.',ssq2/ssq2d));
disp(sprintf('by %g for OSC standardization.',ssq2/ssqo));
disp('  ')
disp('Note that the PDS and DWPDS models have the same form, i.e. they produce')
disp('a transfer function matrix that is a banded diagonal. Here the DWPDS model')
disp('has a band width of 5, while the PDS model had a band width of 3. DWPDS')
disp('was actually developed to use on spectra with very sharp features such as')
disp('FTIR, rather than NIR. Thus, it isn''t surprising that it does not')
disp('out perform PDS in this application. Our work indicates that DWPDS does')
disp('work better in FTIR applications.')
