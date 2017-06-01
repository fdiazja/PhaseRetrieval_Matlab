%%
%EMPA 2016
%Felipe Diaz
%
%This function is a platform to implement 3 different types of filters ('Binary','Butterworth' or 'Gauss') in
%their High pass and Low pass versions. It also calculates the intensity modulation profile of the original image and the filtered image.
%The intensity modulation profile,
%is by default in the middle of the image, to change this, change both values of the vector y (see IMAGING AND PLOTTING section) to whatever height you want.
%Syntax: [out] = filt_platform(in,cutoff,filter_type,pass,init)
%INPUTS:
%in: (Matrix) Image to be filtered
%cutoff: (Positive real number) Cutoff frecquency to set treshold for
%filtering.
%filter_type: (string) Type of filter. This function supports 'Butterworth',
%'Binary' and 'Gauss' filters.
%pass: (string) Either 'Low Pass' or 'High Pass'
%init: (integer) input 1 if you want to see all the images and Intensity
%modulation plots. Any other number will not display anything.
%OUTPUTS:
%out: (Matrix) Filtered image

function [out] = filt_platform(in,cutoff,filter_type,pass,init)

%% PARAMETERS

n = 1; % Filtering order (Butterworth)
M = size(in,1);
N = size(in,2);
Im_f = fftshift(fft2(fftshift(in)));
[fx,fy] = meshgrid(-(N / 2):(N - 1) / 2,-(M / 2):(M - 1) / 2);
fx = 0.5 .* (fx ./ max(fx(:)));
fy = 0.5 .* (fy ./ max(fy(:)));
r = sqrt(fx.^2 + fy.^2);

%% FILTER SELECTION AND DEFINITION

if cutoff > 0.5
    
    disp('Due to sampling, the maximum cut off frcquency is 0.5 (Nyquist).');
    return;
    
end

switch lower(filter_type)
    
    case {'binary'}
        
        filt = ones(size(in));
        filt(r > cutoff) = zeros;
        
    case {'butterworth'}
        
        filt = 1 ./ (1 + (r ./ cutoff).^(2 * n));
        
    case {'gauss'}
        
        filt = exp(-(r.^2 ./ (2 * cutoff^2))); 
        
    otherwise
        
       disp('Please enter a valid filter type. Options (Binary, Butterworth, Gaussian)');
       return;
       
end

switch lower(pass)
    
    case {'low pass'}
        
    case {'high pass'}
        
        filt = 1 - filt;
        
    otherwise 
        
        disp('Enter a valid type of filter (High Pass or Low Pass)');
        return;
        
end

%% CONVOLUTION

Im_filt_f = Im_f .* filt;
out = ifftshift(ifft2(ifftshift(Im_filt_f)));

%% IMAGING AND PLOTTING

if init == 1
    
    figure;
    imagesc(in); colormap gray; title('Original Image')
    figure;
    imagesc(out); colormap gray; title('Filtered Image')
    figure;
    imagesc(fx(1,:),fy(:,1),filt); title('Filter')
    x = [1 N];
    y = [M/2 M/2];
    Prof = improfile(in,x,y);
    Prof_filt = improfile(out,x,y);
    figure;
    plot(Prof,'r'); hold on;
    plot(Prof_filt,'b'); title('Intensity modulation');
    xlabel('Pix. index'); ylabel('Pix. value');
    legend('Non-filtered', 'Filtered'); grid on;
    
else

end

