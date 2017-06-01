function [dark_mean] = dark_gen(ddir,name,N_ps)
addpath(ddir)
init = imread(strcat(name,'_dark','_1'),'tif');
dark = zeros(size(init,1),size(init,2),N_ps);
for i = 1:N_ps
    dark(:,:,i) = double(imread(strcat(name,'_','dark_',num2str(i)),'tif'));
end
dark_mean = sum(dark,3) / size(dark,3);