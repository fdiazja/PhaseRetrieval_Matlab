function [out] = data_scale(in,bit)
M = max(max(in));
m = min(min(in));
s_factor = 2^bit;
out = s_factor * (in - m) / (M - m);