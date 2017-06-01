%%
%EMPA 2016
%Felipe Diaz and Rolf Kaufmann
%
%This script generates the Absorption, Dark field and Differential Phase
%Contrast images of a PCI serial radiagraphy. 



close all;
clear all;
proj_dir = ('C:\Users\dif\Desktop\Phase contrast Setup\X17-0046'); %Directory of the tomography images
addpath(proj_dir);
absdir = strcat(proj_dir,'\abs','\'); mkdir(absdir);
dpcdir = strcat(proj_dir,'\dpc','\'); mkdir(dpcdir);
dfidir = strcat(proj_dir,'\dfi','\'); mkdir(dfidir);

%% PARAMETERS

N_ps = 7; %Number of phase steps
bin = 1; %Binning factor
series = 33; %Number of time series
rep = 1; %Number of repetitions of the phase stepping procedures
name_data = 'rao'; %Name of the sample
%dark = double(imread(strcat(name_data,'_dark'),'tif')); %Dark flat image
dark = dark_gen(proj_dir,name_data,N_ps);
cutoff = 1/250; % cutoff-frequency for the high-pass filter
M = size(dark,1);
N = size(dark,2);
row = 1:M;
col = 1:N;
rfin = 1:floor(length(row)/bin);
cfin = 1:floor(length(col)/bin);
rr = floor(mean(row)); 
cc = ceil(mean(col));
data_save_type = 32; %Type of data you want to save (16 bit tiff or 32 bit raw)
%Length of Visualization window calculation 
% pixel_size = 48e-4; 
% Det_lengthx = N * pixel_size; %Length of the detection area in the x-axis
% Det_lengthy = M * pixel_size; %Length of the detection area in the y-axis
% x = (-Det_lengthx / 2):pixel_size:(Det_lengthx) / (2 - pixel_size); %Vector array to display axes in x
% y = (-Det_lengthy / 2):pixel_size:(Det_lengthy) / (2 - pixel_size); %Vector array to display axes in y

flat_f = zeros(M,N,N_ps); %Initialization of flat field array

for ii = 1:N_ps

    flat_f(:,:,ii) = read_im_flat(ii,name_data,proj_dir);
    flat_f(:,:,ii) = flat_f(:,:,ii) - dark;
    %flat_f(:,:,ii) = filt_platform(flat_f(:,:,ii),cutoff,'Butterworth','High Pass',0);

end
flat_f = (fft(flat_f,[],3));
for jj = 1:series
    clear ABt DCt DPt data_f;
    ABt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of absorption image
    DPt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of differential phase image
    DCt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of dark field image
    data_f = zeros(M,N,N_ps); %Initialization of data array

    for k = 1:N_ps

        data_f(:,:,k) = read_im(jj,k,name_data,proj_dir);
        data_f(:,:,k) = data_f(:,:,k) - dark;
        %data_f(:,:,k) = filt_platform(data_f(:,:,k),cutoff,'Butterworth','High Pass',0);

    end

    %% GENERATION OF THE ABS, DFI AND DPC IMAGES USING FOURIER COEFFICIENTS !!!

    data_f = (fft(data_f,[],3));


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
    DC = cleanup(DC);
	% AB = filt_platform(AB,cutoff,'Butterworth','High Pass',0);
	% DP = filt_platform(DP,cutoff,'Butterworth','High Pass',0);
	% DC = filt_platform(DC,cutoff,'Butterworth','High Pass',0);

    %% IMAGING

    % figure;
    % imagesc(vis,[0 0.25]);title('Visibility of the phase stepping curve wo object');xlabel('columns');ylabel('rows');colorbar;
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


        imwrite(uint16(AB_s),strcat(absdir,name_data,num2str(jj),'_abs','.tif'));
        imwrite(uint16(DP_s),strcat(dpcdir,name_data,num2str(jj),'_dpc','.tif'));
        imwrite(uint16(DC_s),strcat(dfidir,name_data,num2str(jj),'_dfi','.tif'));

    end

    %% 32 BIT SAVING PROCEDURE ! 

    if data_save_type == 32

        AB_s = permute(AB,[2 1]);
        DP_s = permute(DP,[2 1]);
        DC_s = permute(DC,[2 1]);

        % Data saving

        sname_abs = strcat(absdir, name_data, '_');
        sname_dpc = strcat(dpcdir,'\', name_data, '_');
        sname_dfi = strcat(dfidir,'\', name_data, '_');
        fidAB = fopen(strcat(sname_abs,'abs','_',num2str(jj),'_',num2str(N),'x',num2str(M),'.raw'), 'w');
        fidDP = fopen(strcat(sname_dpc,'dpc','_',num2str(jj),'_',num2str(N),'x',num2str(M),'.raw'), 'w');
        fidDC = fopen(strcat(sname_dfi,'dfi','_',num2str(jj),'_',num2str(N),'x',num2str(M),'.raw'), 'w');
        fwrite(fidAB, single(AB_s), 'float32');
        fwrite(fidDP, single(DP_s), 'float32');
        fwrite(fidDC, single(DC_s), 'float32');
        fclose(fidAB);
        fclose(fidDP);
        fclose(fidDC);

    end


end

