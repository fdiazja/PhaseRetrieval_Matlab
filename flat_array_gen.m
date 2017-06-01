%%
%EMPA 2016
%Felipe Diaz
%
%This function generates a 4D array where all the flat field images of a
%tomography are stored
%INPUTS:
%N_ps: (integer) Number of phase steps.
%flat_step: (integer) Step to acquire flat field images.
%flat_max: (integer) Maximum projection where a flat field image was
%taken.
%N_flats: (integer) Number of flat field images per phase step.
%name: (string) Name of the sample.
%proj_dir: (string) Name of the directory where the images are saved.
%M: (integer) Number of rows to initialize arrays.
%N: (integer) Number of columns to initialize arrays.
%M and N should be the same as the lenghts of the images.
%OUTPUTS:
%flat_array: (4D array) Array where all the flat field images are stored

function [flat_array] = flat_array_gen(N_ps,flat_step,flat_max,N_flats,name,proj_dir,M,N)

addpath(proj_dir);

%% INITIALIZATION OF VARIABLES

flat_array = zeros(M,N,N_flats,N_ps); %Initialization of array of flat field images

%% GENERATION OF ARRAY OF FLAT FIELD IMAGES

for i = flat_step:flat_step:flat_max
    
    for j = 1:N_ps  
        
        Im = read_im_flat_tomo(i,j,name,proj_dir);
        flat_array(:,:,i / flat_step,j) = Im;
        
    end 
    
end

