%%
%EMPA 2016
%Felipe Diaz
%
%This function reads flat field images and converts them to double precision for tomographies.
%INPUTS:
%i: (integer) Projection where the flat field image was taken.
%j: (integer) Phase step.
%name: (string) Name of the sample.
%proj_dir: (string) Name of the directory where the images are saved.
%OUTPUT:
%Im: (2D matrix) Image

function [Im] = read_im_flat_tomo(i,j,name,proj_dir)

addpath(proj_dir);
projection = num2str(i);
step = num2str(j);
string1 = strcat(name,'_',projection,'_flat_');
Im = double(imread(strcat(string1,step),'tif'));