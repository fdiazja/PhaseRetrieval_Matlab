%%
%EMPA 2016
%Felipe Diaz and Rolf Kaufmann
%
%This script generates the Absorption, Dark field and Differential Phase
%Contrast images for every projection of a full tomography.

tic
clear;
proj_dir = ('C:\Users\dif\Desktop\Phase contrast Setup\X17-0077\sample2'); %Directory of the tomography images
addpath(proj_dir);

%% PARAMETERS

N_projections = 720; %Number of projections
flat_step = 30; %Step to acquire flat field images
N_ps = 7; %Number of phase steps
N_flats = floor(N_projections / flat_step); %Number of flat field images per phase step
flat_max = N_flats * flat_step; %Last projection where a flat field image was taken
bin = 1; %Binning factor
rep = 1; %Number of repetitions of the phase stepping procedures
cutoff = 1 / 50; %Cutoff frecquency to filter Moire fringes
name_data = 's2'; %Name of the sample
dark = dark_gen(proj_dir,name_data,N_ps);
%dark = double(imread(strcat(name_data,'_dark'),'tif')); %Dark flat image
M = size(dark,1);
N = size(dark,2);
row = 1:M;
col = 1:N;
rfin = 1:floor(length(row) / bin);
cfin = 1:floor(length(col) / bin);
rr = floor(mean(row)); 
cc = ceil(mean(col));

%% DIRECTORY CREATION (SAVING)

save_dir_abs = strcat(name_data,'_abs'); 
mkdir(proj_dir,save_dir_abs);
save_dir_dpc = strcat(name_data,'_dpc'); 
mkdir(proj_dir,save_dir_dpc);
save_dir_dfi = strcat(name_data,'_dfi'); 
mkdir(proj_dir,save_dir_dfi);

%% READING FLAT FIELD IMAGES

[flat] = flat_array_gen(N_ps,flat_step,flat_max,N_flats,name_data,proj_dir,M,N); 
flat = permute(flat,[1 2 4 3]); %WARNING: This permutation changes the order of the projections and phase steps in the array!!
test = 2 * flat_step;
cont = 2;

for l = 1:N_projections
    
    data_f = zeros(M,N,N_ps); %Initialization of data array
    ABt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of absorption image
    DPt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of differential phase image
    DCt = zeros(floor(length(row) / bin),floor(length(col) / bin)); %Initialization of dark field image
    projection = num2str(l,'%4.4d');
    
%% CHOOSING FLAT FIELD

    if l <= flat_step
        
        flat_f = flat(:,:,:,1); 
        
    elseif l < test 
        
        flat_f = flat(:,:,:,cont); 
        
    elseif l >= flat_max
        
        flat_f = flat(:,:,:,N_flats); 
        
    else
        
        flat_f = flat(:,:,:,cont); 
        cont = cont + 1;
        test = test + flat_step;
        
    end  
    
%% LOADING PROJECTIONS

    for k = 1:N_ps
        
        flat_f(:,:,k) = flat_f(:,:,k) - dark;
%         flat_f(:,:,k) = filt_platform(flat_f(:,:,k),cutoff,'Butterworth','High Pass',0);
        data_f(:,:,k) = read_im(l,k,name_data,proj_dir) - dark;
%         data_f(:,:,k) = filt_platform(data_f(:,:,k),cutoff,'Butterworth','High Pass',0);
        
    end
   
%% GENERATION OF THE ABS, DFI AND DPC IMAGES USING FOURIER COEFFICIENTS
    
    data_f = (fft(data_f,[],3));
    flat_f = (fft(flat_f,[],3));
    
    ABt(:,:) = ABt(:,:) + abs(data_f(:,:,1)) ./ abs(flat_f(:,:,1)) / rep;
    DPt(:,:) = DPt(:,:) + wrap(angle(data_f(:,:,2)) - angle(flat_f(:,:,2)),2) / rep;  
    DCt(:,:) = DCt(:,:) + abs(data_f(:,:,2)) .* abs(flat_f(:,:,1)) ./ abs(flat_f(:,:,2)) ./ abs(data_f(:,:,1)) / rep;
    
    AB = -log(ABt(rfin,cfin));
    DP = DPt(rfin,cfin) - mean(mean(DPt(rfin,cfin)));
    DC = -log(DCt(rfin,cfin));
    
%% FILTERING
    
    AB = cleanup(AB);
%     AB = filt_platform(AB,cutoff,'Butterworth','High Pass',0);
%     DP = filt_platform(DP,cutoff,'Butterworth','High Pass',0);
    DC = cleanup(DC);
%     DC = filt_platform(DC,cutoff,'Butterworth','High Pass',0);

%% VISIBILITY

%     vis = abs(flat_f(:,:,2)) ./ abs(flat_f(:,:,1)) * 2;
%     vavg = mean(mean(vis(rr - 50:rr + 50, cc - 50:cc + 50)));
%     figure;
%     imagesc(vis,[0 0.25]);title('Visibility of the phase stepping curve wo object');xlabel('columns');ylabel('rows');colorbar;

%% DATA SAVING

    AB_s = permute(AB,[2 1]);
    DP_s = permute(DP,[2 1]);
    DC_s = permute(DC,[2 1]);

    sname_abs = strcat(proj_dir,'\',save_dir_abs, '\', name_data, '_');
    sname_dpc = strcat(proj_dir,'\',save_dir_dpc, '\', name_data, '_');
    sname_dfi = strcat(proj_dir,'\',save_dir_dfi, '\', name_data, '_');
    fidAB = fopen(strcat(sname_abs,'abs','_',num2str(N),'x',num2str(M),'_',projection,'.raw'), 'w');
    fidDP = fopen(strcat(sname_dpc,'dpc','_',num2str(N),'x',num2str(M),'_',projection,'.raw'), 'w');
    fidDC = fopen(strcat(sname_dfi,'dfi','_',num2str(N),'x',num2str(M),'_',projection,'.raw'), 'w');
    fwrite(fidAB, single(AB_s), 'float32');
    fwrite(fidDP, single(DP_s), 'float32');
    fwrite(fidDC, single(DC_s), 'float32');
    fclose(fidAB);
    fclose(fidDP);
    fclose(fidDC);
    
%% DELETING DATA

clear AB* DP* DC* data_f flat_f vis

end
toc
    
    
    
    
    
    
    
    
    
    