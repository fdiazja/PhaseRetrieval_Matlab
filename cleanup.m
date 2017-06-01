%%
%EMPA 2016
%Felipe Diaz
%
%This function detects NaNs, and infinite values. After detection they are
%corrected using cubic interpolation.
%INPUTS:
%in: (Matrix) Input image
%OUTPUTs:
%in: (Matrix) Processed image

function [in] = cleanup(in)

[lim_r,lim_c] = size(in);
[r,c] = find(isinf(in) | isnan(in));

for i = 1:length(r)
    
     in(r(i),c(i)) = 0;
     t = 0;
     
     if r(i) - 1 > 0
         if ~isnan(in(r(i) - 1,c(i))) && ~isinf(in(r(i) - 1,c(i)))
             
             in(r(i),c(i)) = in(r(i) - 1,c(i));
             t = t + 1;
             
         end
     end
     
     if (r(i) - 1 > 0) && (c(i) - 1 > 0)
         if ~isnan(in(r(i) - 1,c(i) - 1)) && ~isinf(in(r(i) - 1,c(i) - 1))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i) - 1,c(i) - 1);
             t = t + 1;
             
         end
     end
     
     if c(i) - 1 > 0
         if ~isnan(in(r(i),c(i) - 1)) && ~isinf(in(r(i),c(i) - 1))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i),c(i) - 1);
             t = t + 1;
             
         end
     end
     
     if (r(i) + 1 <= lim_r) && (c(i) - 1 > 0)
         if ~isnan(in(r(i) + 1,c(i) - 1)) && ~isinf(in(r(i) + 1,c(i) - 1))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i) + 1,c(i) - 1);
             t = t + 1;
             
         end
     end
     
     if r(i) + 1 <= lim_r
         if ~isnan(in(r(i) + 1,c(i))) && ~isinf(in(r(i) + 1,c(i)))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i) + 1,c(i));
             t = t + 1;
             
         end
     end
     
     if (r(i) + 1 <= lim_r) && (c(i) + 1 <= lim_c)
         if ~isnan(in(r(i) + 1,c(i) + 1)) && ~isinf(in(r(i) + 1,c(i) + 1))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i) + 1,c(i) + 1);
             t = t + 1;
             
         end
     end
     
     if c(i) + 1 <= lim_c
         if ~isnan(in(r(i),c(i) + 1)) && ~isinf(in(r(i),c(i) + 1))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i),c(i) + 1);
             t = t + 1;
             
         end
     end
     
     if (c(i) + 1 <= lim_c) && (r(i) - 1 > 0)
         if ~isnan(in(r(i) - 1,c(i) + 1)) && ~isinf(in(r(i) - 1,c(i) + 1))
             
             in(r(i),c(i)) = in(r(i),c(i)) + in(r(i) - 1,c(i) + 1);
             t = t + 1;
             
         end
     end
     
     in(r(i),c(i)) = in(r(i),c(i)) / t;
end
end
