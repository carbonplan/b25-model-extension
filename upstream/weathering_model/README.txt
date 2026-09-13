System Requirements: 
MATLAB 2019a. Later and previous versions should work.
Linux. Windows with minor modifications to path variables.

Installation Guide: 
No installation required

Demo
run_1_v5.mat: Function that takes 'point' (1-437:ind) as an argument. 
Info on the point and its climate drivers will be read from the run_strc_6.mat file. Adjust path accordingly.

Variable inps.yy defines the years for the run (5-51). Higher number of years will require more computing time.

Calls the mod5 function which in turn calls the weathering model for said inputs. Adjust paths accordingly.

Replace "parfor" with "for" if multiple CPUs are not available for a parallel run. Also all code relevant to 
parallel runs can be removed.

Will produce matlab structure with monthly time series of different variables.