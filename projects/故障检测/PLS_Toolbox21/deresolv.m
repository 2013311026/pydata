function lrspec = deresolv(hrspec,a)
%DERESOLV Changes high resolution spectra to low resolution
%  Uses a FFT to convolve spectra with a resolution function in order to 
%  make it appear as if it had been taken on a lower resolution instrument.
%  The inputs are the high resolution spectra to be de-resolved (hrspec)
%  and the number of channels to convolve them over (a). The output
%  is the estimate of the lower resolution spectra (lrspec).
%
%I/O: lrspec = deresolv(hrspec,a);
%
%See also: STDGEN, BASELINE, STDGENNS, STDGENDW

%Copyright Eigenvector Research, Inc. 1991-98
%Modified BMW  April 97
[m,n] = size(hrspec);
lrspec = zeros(m,n);
tlrspec = lrspec;
dif = -1;
i = 0;
while dif < 0 
  i = i+1;
  fftl = 2^i;
  dif = fftl - n;
end
conf = zeros(1,fftl);


for k = 1:a
  conf = zeros(1,fftl);
  if k == 1
    conf(1) = .5;
    conf(fftl) = .5;
  else
    conf(1:k+1) = 1:(-1/(k)):0;
    conf(fftl-(k):fftl) = 0:(1/(k)):1;
    conf = conf/(sum(conf));
  end
  conffft = fft(conf);
  for i = 1:m
    padspec = [hrspec(i,:) zeros(1,fftl-n)];
    specfft = fft(padspec);
    convspec = ifft(specfft.*conffft);
    tlrspec(i,:) = real(convspec(1:n));
  end  
  lrspec(:,k:n-k+1) = tlrspec(:,k:n-k+1);
end
