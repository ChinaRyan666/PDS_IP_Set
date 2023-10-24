@echo off
set bin_path=F:/modeltech64_10.4/win64
cd C:/Users/ch/Desktop/2022.1/ip_1port_ram/prj/sim/synth
call "%bin_path%/modelsim"   -do "do {run_post_syn_compile.tcl};do {run_post_syn_simulate.tcl}" -l run_post_syn_simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
