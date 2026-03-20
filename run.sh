#It has all the commands stacked so that it follows the order of
#water minimisation(energy minimisation) --> min2(water+protein minimisation) --> heating --> density equilibriation --> equilibriation run --> Final MD run
###################
####################

pmemd.cuda -O -i wat_min1.in -o  solv_min1.out -p  solv.prmtop -c  solv.inpcrd -ref solv.inpcrd -r  solv_min1.rst -AllowSmallBox

mpirun -n 16 sander.MPI -O -i wat_min1.in -o  solv_min1.out -p  solv.prmtop -c  solv.inpcrd -ref  solv.inpcrd -r  solv_min1.rst

pmemd.cuda -O -i wat_min2.in -o  solv_min2.out  -p  solv.prmtop -c  solv_min1.rst  -r  solv_min2.rst -AllowSmallBox

mpirun -n 16 sander.MPI -O -i wat_min2.in -o  solv_min2.out  -p  solv.prmtop -c  solv_min1.rst  -r solv_min2.rst

pmemd.cuda -O -i wat_heat.in -o  solv_heat.out -p  solv.prmtop -c solv_min2.rst -ref  solv_min2.rst -r  solv_heat.rst -x  solv_heat.mdcrd -AllowSmallBox

pmemd.cuda.MPI -O -i wat_density.in -o  solv_density.out -p solv.prmtop -c  solv_heat.rst -ref  solv_heat.rst -r  solv_density.rst -x  solv_density.nc -AllowSmallBox

mpirun -n 16 sander.MPI -O -i wat_density.in -o  solv_density.out  -p  solv.prmtop -c  solv_heat.rst  -r solv_density.rst -ref solv_heat.rst -x solv_density.nc

mpirun -np 16 sander.MPI -O -i wat_density.in -o  solv_density_2.out  -p  solv.prmtop -c  solv_density.rst  -r solv_density_2.rst -ref solv_density.rst -x solv_density_2.nc

mpirun -np 16 sander.MPI -O -i wat_eq.in -o  solv_eq.out -p solv.prmtop -c  solv_density.rst -ref  solv_density.rst -r  solv_eq.rst -x  solv_eq.nc

pmemd.cuda -O -i wat_eq.in -o  solv_eq.out -p solv.prmtop -c  solv_density.rst -ref  solv_density.rst -r  solv_eq.rst -x  solv_eq.nc

pmemd.cuda -O -i wat_md.in -o  solv_run1.out -p  solv.prmtop -c  solv_eq.rst -r  solv_run1.rst -x  solv_run1.nc

pmemd.cuda -O -i wat_md.in -o  solv_run2.out -p  solv.prmtop -c  solv_run1.rst -r solv_run2.rst -x  solv_run2.nc

pmemd.cuda -O -i wat_md.in -o solv_run3.out -p solv.prmtop -c solv_run2.rst -r solv_run3.rst -x solv_run3.nc

#we can run this one by one either from cuda or mpirun depending upon GPU or CPU usage ( -AllowSmallBox command allows to run for small box systems in case of normal systems it s not required)
#To run we can use the command 
sh run.sh &
