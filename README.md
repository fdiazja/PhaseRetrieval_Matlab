# PhaseRetrieval_Matlab
Phase retrieval algorithms for Matlab

Empa 2016/2017 (Felipe Diaz and Rolf Kaufmann)

This folder contains the differents functions and scripts needed to perform a pahse retrieval of a XPCI measurement. 

For normal radiographies, see main_AB_DP_DC.m.
For serial radiographies, see main_AB_DP_DC_serial.m.
For tomographies, see main_AB_DP_DC_tomo.m.

All dependencies are in this folder. In oreder to succesfully run these scripts, all the files have to be in the same folder.

Things to be carefull with:
Usage of the filt_platform.m function may depend on the sample and measurement settings. It may be applied on the original data set (on data and flat field) 
or on the resulting images (AB, DC, DP). 

If you have any question please contact Felipe Diaz: dsibfelipediaz@gmail.com (Personal Email) or fdiazja@eafit.edu.co (university Email)
