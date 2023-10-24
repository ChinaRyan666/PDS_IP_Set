@echo off
set bin_path=F:/modeltech64_10.4/win64
cd C:/Users/ch/Desktop/2021.4-SP1.2/ip_pll/prj/sim/behav
call "%bin_path%/modelsim"   -do "do {run_behav_compile.tcl};do {run_behav_simulate.tcl}" -l run_behav_simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
