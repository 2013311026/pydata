% PLS_Toolbox.
% Version 2.1 23-Nov-2000
% For use with MATLAB 5.2, 5.3, 6.0
% Copyright (c) 1995-2000 Eigenvector Research, Inc.
% Barry M. Wise and Neal B. Gallagher
%
% Help and information.
%   contents - This file.
%   helppls  - GUI for browsing toolbox functions.
%   readme   - Release notes on PLS_Toolbox 2.1.
%   plslogo  - Generates the PLS_Toolbox 2 logo.
%
% Data Scaling and Preprocessing.
%   auto     - Autoscales data.
%   delsamps - Deletes samples from data matrices.
%   dogscl   - Group scales sub-matrices.
%   dogsclr  - Scales sub-matrices to group scaling parameters.
%   gscale   - Group scaling for a single block.
%   gscaler  - Scales block to group scaling parameters.
%   lamsel   - Determines indices of specified wavelength ranges.
%   mdauto   - Autoscaling with missing data.
%   mdmncn   - Mean centering with missing data.
%   mdrescal - Rescaling a matrix with missing data.
%   mdscale  - Scales matrix with missing data.
%   mncn     - Mean centers data.
%   normaliz - Normalizes rows of matrix to unit vectors.
%   oscapp   - Applies OSC model to new data.
%   osccalc  - Calculates orthogonal signal correction (OSC).
%   refoldr  - Rearranges (folds) a vector to a matrix.
%   rescale  - Scales data back to original scaling.
%   savgol   - Savitsky-Golay smoothing and derivatives.
%   savgolcv - Savitsky-Golay with cross validation.
%   scale    - Scales data using specified means and std. devs.
%   shuffle  - Randomly re-orders matrix rows.
%   specedit - GUI for selecting regions on a plot.
%   unfoldm  - Rearranges (unfolds) an augmented matrix to row vectors.
%   unfoldmw - Unfolds multiway arrays along specified order.
%   unfoldr  - Rearranges (unfolds) a matrix to a row vector.
%
% Plotting, Analysis Aids, and I/O Functions.
%   areadr1  - Reader(s) for ascii data with header (see areadr1-4).
%   dp       - Adds a diagonal line to prediction plots.
%   ellps    - Plots an ellipse on an existing figure.
%   gline    - Places line on figure with mouse input
%   highorb  - GUI for rotating 3D plots.
%   hline    - Plots horizontal lines from left to right axis.
%   plttern  - Plots a 2D ternary diagram.
%   pltternf - Plots a 3D ternary diagram with frequency of occurence.
%   rwb      - Red white and blue color map
%   sampidr  - Identifies a sample indice on an x,y plot.
%   vline    - Plots vertical lines from bottom to top axis.
%   xclgetdata - Extracts matrix from an Excel spreadsheet.
%   xclputdata - Write matrix to an Excel spreadsheet.
%   xclreadr - Reads ASCII flat files from MS Excel and other spreadsheets.
%   xpldst   - extracts variables from a structure array.
%   zoompls  - GUI for zooming in plots.
%
% Statistics, ANOVA, Experimental design, Miscellaneous.
%   anova1w  - One-way analysis of variance.
%   anova2w  - Two-way analysis of variance.
%   corrmap  - Correlation map with variable grouping.
%   factdes  - Full factorial design of experiments.
%   fastnnls - Fast non-negative least squares.
%   ffacdes1 - Fractional factorial design of experiments.
%   ftest    - F test and inverse F test statistic.
%   ttestp   - T test and inverse T test statistic.
%
% Principal Components, Cluster and Evolving Factor Analysis.
%   bigpca   - PCA for large matrices.
%   cluster  - K-means and KNN cluster analysis with dendrograms.
%   evolvfa  - Evolving factor analysis.
%   ewfa     - Evaolving window factor analysis.
%   gcluster - Graphical user interface for cluster.
%   mdpca    - PCA for matrices with missing data.
%   mlpca    - Maximum liklihood principal components.
%   pca      - Principal components analysis.
%   pcagui   - GUI for Principal components analysis.
%   pcapro   - Applies existing PCA model to new data.
%   pltloads - Two and three dimensional loadings plots.
%   pltscrs  - Two and three dimensional scores plots by class.
%   reslim   - Confidence limits for PCA Q residuals.
%   resmtx   - Calculates residuals for contribution plots.
%   scrpltr  - Scores plotter routine with confidence limits (gui).
%   simca    - Soft Independent Method of Class Analogy.
%   simcaprd - Project new data into a SIMCA model.
%   tsqlim   - Confidence limits for Hotelling's T^2.
%   tsqmtx   - Calculates T^2 matrix for contribution plots.
%   varcap   - Variance captured for each variable in PCA model.
%
% Multiway and Curve Resolution
%   gram     - Generalized rank anhilation.
%   imgpca   - PCA on multivariate images
%   imgselct - Select an area on an image and return the pixel indices.
%   imgsimca - SIMCA Classification for Multivariate Images.
%   isimcapr - Applies IMGSIMCA models to new images.
%   mcr      - Multivariate curve resolution.
%   mpca     - Multiway principal components analysis.
%   mwfit    - Fits existing TLD, PARAFAC, MPCA or IPCA model to new data.
%   outer    - Computes outer product of any number of vectors.
%   outerm   - Computes outer product of any number of vectors.
%   parafac  - Parallel factor analysis.
%   tld      - Trilinear Decomposition.
%
% Linear Regression.
%   cr       - Continuum regression by SIMPLS algorithm
%   crcvrnd  - Cross-validation for continuum regression.
%   crossval - Cross-validation for linear regression.
%   crossvus - Cross-validation with user defined test sets.
%   figmerit - Analytical figures of merit for multivariate calibration.
%   mlrcvblk - Block cross-validation for ordinary least squares.
%   modlgui  - Graphical user interface for linear regression.
%   modlpred - Predictions based on MODLGUI models.
%   modlrder - Displays MODLGUI and PCAGUI model info.
%   pcr      - Principal components regression for multivariate y.
%   pls      - Partial least squares regression for multivariate y.
%   plsnipal - NIPALS algorithm for one PLS latent variable.
%   regcon   - Converts regression model to y = ax + b form.
%   ridge    - Ridge regression by Hoerl-Kennard method.
%   ridgecv  - Ridge regression by cross-validation.
%   rinverse - Gives pseudo inverse for PLS, PCR and RR models.
%   simpls   - PLS by SIMPLS for multivariate Y.
%   ssqtable - Prints formatted sum-of-squares for PCAGUI and MODLGUI 
%   updatemod- Updates MODLGUI models to be 2.0.1d compatible
%
% Non-Linear Regression Methods.
%   collapse - Converts neural net-PLS models to NN form.
%   lwrpred  - Predictions based on LWR model.
%   lwrxy    - LWR predictions with y-distance weighting.
%   nnpls    - Cross validation of PLS models with neural net inner relations.
%   nnplsbld - Parameterizes neural net-PLS models with given form.
%   nnplsprd - Predictions from collapsed neural net-PLS models.
%   polypls  - PLS with polynomial inner-relationships.
%   polypred - New predictions with poly-PLS models.
%   splnfit  - Spline fits to bivariate data.
%   splnpred - New predictions based on spline fits.
%   splspred - New predictions with SPL_PLS.
%   spl_pls  - PLS with spline inner-relationships.
%
% Variable Selection
%   calibsel - Statistical procedure for variable selection.
%   gaselctr - GA for variable selection without GUI.
%   genalg   - Genetic algorithm for variable selection.
%
% Multivariate Instrument Standardization.
%   baseline - Subtracts a baseline from absorbance spectra.
%   deresolv - Changes high resolution spectra to low resolution.
%   mscorr   - Multiplicative scatter correction.
%   stdfir   - Standardization based on FIR modelling.
%   stdgen   - Instrument standardization transform generator.
%   stdgendw - Double Piece-wise direct standardization.
%   stdgenns - Std transform generator for non-square systems.
%   stdize   - Applys transfrom from STDGEN to new spectra.
%   stdsslct - Selects data subsets for use in standardization.
%
% Multivariate Statistical Process Control.
%   plsrsgn  - Generates a matrix of PLS models for MSPC.
%   plsrsgcv - Cross-validation for PLSRSGN models.
%   replace  - Replaces variables based on PCA or PLS models.
%
% Identification of Finite Impulse Response Models. 
%   autocor  - Auto-correlation function for time series data.
%   crosscor - Cross-correlation function for time series data.
%   fir2ss   - Transforms FIR model to equiv. state space model.
%   plspulsm - Identifies FIR models by PLS for MISO systems.
%   writein2 - Writes matrices for dynamic model identification.
%   wrtpulse - Writes matrices with delays for identification.
%
% PLS_Toolbox Demonstrations.
%   crdemo   - Continuum regression using the cr routine.
%   ccordemo - Cross- and auto-correlation.
%   clstrdmo - Statistical cluster analysis and dendrograms.
%   efa_demo - Evolving factor analysis.
%   gramdemo - Generalized rank anhilation
%   lwrdemo  - Locally weighted regression functions.
%   mddemo   - PCA for missing data.
%   nnplsdmo - PLS with neural net inner relationships.
%   parademo - Demonstration of PARAFAC.
%   pcademo  - Pricipal components analysis.
%   plsdemo  - Partial least squares regression and PCR.
%   polydemo - PLS with polynomial inner relationship.
%   projdemo - Projection demo.
%   pulsdemo - Identification of FIR models with PLS.
%   ridgdemo - Ridge regression functions.
%   rplcdemo - Replacement of failed sensors with MSPC models.
%   rsgndemo - Collections of PLS models for MSPC.
%   sgdemo   - Savitsky-Golay smoothing and derivatives.
%   splndemo - PLS with spline inner relationships.
%   statdemo - t test, F test, one and two-way ANOVA.
%   stddemo  - Multivariate instrument standardization.
%
% PLS_Toolbox Test Data Sets.
%   arch     - Archeological artifact data set for PCA example.
%   etchdata - Batch semiconductor etch data (e.g. for MSPC).
%   nir_data - NIR spectra of pseudo gasoline samples for STDDEMO.
%   nmr_data - NMR data for GRAM demo.
%   paint    - Non-linear paint formulation data.
%   pcadata  - Liquid-fed ceramic melter (LFCM) data for the PCA demo.
%   plsdata  - LFCM data for the PLS demo PLSDEMO.
%   plslogo  - CR PRESS surface and colormap for PLSLOGO
%   pol_data - Non-linear surge tank data for POLYPLS demo POLYDEMO.
%   projdat  - Projection demo data for PROJDEMO.
%   pulsdata - Liquid-fed ceramic melter data for PLSPULSM demo.
%   repdata  - LCFM data for replace demo RPLCDEMO.
%   ridgdata - Hald data set of cement samples.
%   simcadat - SAW data for demonstrating SIMCA function.
%   smbread  - Images of bread at 5 wavelengths.
%   splndata - Synthetic data for spline demo SPLNDEMO.
%   statdata - Data sets for ANOVA and statistics STATDEMO.
%   wine     - Wine data set for PCA example.
%
% Functions used as subroutines which may be of general interest.
%   bckprpnn   cgrdsrch   cndlgpls   erdlgpls   fun1      
%   grad1      gradnet    gradnet1   inner      inner1     
%   ldlgpls    mlrcvblk   nnpls1     qlsearch   svdlgpls
%
% Functions used only as subroutines to PLS_Toolbox functions.
%   modlplts   modlplt1   modlpset   nplsbld1   pcaplots
%   pcaplots1  pcapset 
