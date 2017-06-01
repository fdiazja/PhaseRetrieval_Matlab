%% name: wrap
%%
%% syntax: [datout] = wrap(datin,wdim)
%%
%% description:
%%		imgin/out - input/output 2D data set
%%		wdim - wrap along which dimension

function [datout] = wrap(datin,wdim)

datout = zeros(size(datin));

if (nargin ~= 2)
    
    fprintf('Usage:\n');
    fprintf('[datout] = wrap(datin,wrapdimension);\n');
    return;
    
end

if wdim == 1
    
    for i = 1:size(datin,2)
        
        datout(:,i) = ((datin(:,i)+pi) - 2*pi*floor((datin(:,i)+pi)/(2*pi))) - pi;
        
    end   
    
end

if wdim == 2
    
    for i = 1:size(datin,1)
        
        datout(i,:) = ((datin(i,:)+pi) - 2*pi*floor((datin(i,:)+pi)/(2*pi))) - pi;
        
    end    
    
end