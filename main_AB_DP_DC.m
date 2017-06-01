%%
%EMPA 2016
%Felipe Diaz and Rolf Kaufmann
%
%This script generates the Absorption, Dark field and Differential Phase
%Contrast images of a PCI radiagraphy. 

tic
close all;
clear;
proj_dir = ('C:\Users\dif\Desktop\Phase contrast Setup\trial_after_aligned'); %Directory of the tomography images
addpath(proj_dir);

%% PARAMETERS

N_ps = 15; %Number of phase steps
bin = 1; %Binning factor
rep = 1; %Number of repetitions of the phase stepping procedures
name_data = 'trial'; %Name of the sample
%dark = dark_gen(proj_dir,name_data,N_ps);
%dark = double(imread('dark_mean.tif')); %Dark flat image
dark  = zeros(size(imread(strcat(name_data, '_1_1.tif'))));
M = size(dark,1);
N = size(dark,2);
row = 1:M;
col = 1:N;
rfin = 1:floor(length(row)/bin);
cfin = 1:floor(length(col)/bin);
rr = floor(mean(row)); 
cc = ceil(mean(col));
data_save_type = 16; %Type of data you want to save (16 bit tiff or 32 bit raw)
cutoff = 0.005;
%Length of Visualization window calculation 
% pixel_size = 48e-4; 
% Det_lengthx = N * pixel_size; %Length of the detection area in the x-axis
% Det_lengthy = M * pixel_size; %Length of the detection area in the y-axis
% x = (-Det_lengthx / 2):pixel_size:(Det_lengthx) / (2 - pixel_size); %Vector array to display axes in x
% y = (-Det_lengthy / 2):pixel_size:(Det_lengthy) / (2 - pixel_size); %Vector array to display axes in y

%% Array Generation

data_f = zeros(M,N,N_ps); %Initialization of data array
flat_f = zeros(M,N,N_ps); %Initialization of flat field array
ABt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of absorption image
DPt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of differential phase image
DCt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of dark field image

for k = 1:N_ps

    flat_f(:,:,k) = read_im_flat(k,name_data,proj_dir);
    flat_f(:,:,k) = flat_f(:,:,k) - dark;
%     flat_f(:,:,k) = filt_platform(flat_f(:,:,k),cutoff,'Butterworth','High Pass',0);
    data_f(:,:,k) = read_im(1,k,name_data,proj_dir);
    data_f(:,:,k) = data_f(:,:,k) - dark;
%     data_f(:,:,k) = filt_platform(data_f(:,:,k),cutoff,'Butterworth','High Pass',0);

end

%% GENERATION OF THE ABS, DFI AND DPC IMAGES USING FOURIER COEFFICIENTS !!!

data_f = (fft(data_f,[],3));
flat_f = (fft(flat_f,[],3));

ABt(:,:) = ABt(:,:) + abs(data_f(:,:,1)) ./ abs(flat_f(:,:,1)) / rep;
DPt(:,:) = DPt(:,:) + wrap(angle(data_f(:,:,2)) - angle(flat_f(:,:,2)),2) / rep;  
DCt(:,:) = DCt(:,:) + abs(data_f(:,:,2)) .* abs(flat_f(:,:,1)) ./ abs(flat_f(:,:,2)) ./ abs(data_f(:,:,1)) / rep;

AB = -log(ABt(rfin,cfin));
DP = DPt(rfin,cfin) - mean(mean(DPt(rfin,cfin)));
DC = -log(DCt(rfin,cfin));

%% IMAGING

% visibility in the center of the FOV

vis = abs(flat_f(:,:,2)) ./ abs(flat_f(:,:,1)) * 2;
vavg = mean(mean(vis(rr - 50:rr + 50, cc - 50:cc + 50)));
AB = cleanup(AB);
% AB = filt_platform(AB,cutoff,'Butterworth','High Pass',0);
% DP = filt_platform(DP,cutoff,'Butterworth','High Pass',0);
DC = cleanup(DC);
% DC = filt_platform(DC,cutoff,'Butterworth','High Pass',0);

%% IMAGING

figure;
imagesc(vis,[0 0.32]);title('Visibility of the phase stepping curve wo object');xlabel('columns');ylabel('rows');colorbar;
% figure;
% imagesc(x,y,AB); title('Absorption image'); xlabel('x(cm)'); ylabel('y(cm)'); colormap gray; colorbar
% figure;
% imagesc(x,y,DP); title('Diff. Phase contrast'); xlabel('x(cm)'); ylabel('y(cm)'); colormap gray; colorbar
% figure;
% imagesc(x,y,DC); title('Dark Field image'); xlabel('x(cm)'); ylabel('y(cm)'); colormap gray; colorbar

%% 16 BIT SAVING PROCEDURE !

if data_save_type == 16

% Data scaling

AB_s = data_scale(AB,16);
DP_s = data_scale(DP,16);
DC_s = data_scale(DC,16);

% Data saving

absname = strcat(proj_dir,'\abs','\'); mkdir(absname);
dpcname = strcat(proj_dir,'\dpc','\'); mkdir(dpcname);
dfiname = strcat(proj_dir,'\dfi','\'); mkdir(dfiname);
imwrite(uint16(AB_s),strcat(absname,'\',name_data,'_abs','.tif'));
imwrite(uint16(DP_s),strcat(dpcname,'\',name_data,'_dpc','.tif'));
imwrite(uint16(DC_s),strcat(dfiname,'\',name_data,'_dfi','.tif'));

end

%% 32 BIT SAVING PROCEDURE ! 

if data_save_type == 32

AB_s = permute(AB,[2 1]);
DP_s = permute(DP,[2 1]);
DC_s = permute(DC,[2 1]);

% Data saving

sname_abs = strcat(proj_dir,'\', name_data, '_');
sname_dpc = strcat(proj_dir,'\', name_data, '_');
sname_dfi = strcat(proj_dir,'\', name_data, '_');
fidAB = fopen(strcat(sname_abs,'abs','_',num2str(N),'x',num2str(M),'.raw'), 'w');
fidDP = fopen(strcat(sname_dpc,'dpc','_',num2str(N),'x',num2str(M),'.raw'), 'w');
fidDC = fopen(strcat(sname_dfi,'dfi','_',num2str(N),'x',num2str(M),'.raw'), 'w');
fwrite(fidAB, single(AB_s), 'float32');
fwrite(fidDP, single(DP_s), 'float32');
fwrite(fidDC, single(DC_s), 'float32');
fclose(fidAB);
fclose(fidDP);
fclose(fidDC);

end

toc



