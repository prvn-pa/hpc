#!/bin/bash
#PBS -l nodes=1:ppn=20
#PBS -q iiserq
### Send email on abort, begin and end
#PBS -m ae
### Specify mail recipient
#PBS -M praveen@criptext.com
# Usage of this script:
#qsub job-orca.sh -N jobname where jobname is the name of your ORCA inputfile (jobname.inp) without the .inp extension

# Jobname below is set automatically when using "qsub job-orca.sh -N jobname". Can alternatively be set manually here. Should be the name of the inputfile without extension (.inp or whatever).
export job=$PBS_JOBNAME

#Setting OPENMPI paths here:
export PATH=/home/app/openmpi-2.0.2:$PATH
export LD_LIBRARY_PATH=/home/app/openmpi-2.0.2:$LD_LIBRARY_PATH

# Here giving the path to the ORCA binaries and giving communication protocol
export orcadir=/home/app/orca_4_0_1_2_linux_x86-64_openmpi202
export RSH_COMMAND="/usr/bin/ssh -x"
export PATH=$orcadir:$PATH


# Creating local scratch folder for the user on the computing node. /scratch directory must exist. 
if [ ! -d /home/scratch/$USER ]
then
  mkdir -p /home/scratch/$USER
fi
tdir=$(mktemp -d /home/scratch/$USER/orcajob__$PBS_JOBID-XXXX)

# Copy only the necessary stuff in submit directory to scratch directory. Add more here if needed.
cp $PBS_O_WORKDIR/*.inp $tdir/
cp $PBS_O_WORKDIR/*.gbw $tdir/
cp $PBS_O_WORKDIR/*.xyz $tdir/
cp $PBS_O_WORKDIR/*.hess $tdir/

# Creating nodefile in scratch
cat ${PBS_NODEFILE} > $tdir/$job.nodes

# cd to scratch
cd $tdir

# Copy job and node info to beginning of outputfile
echo "Job execution start: $(date)" >> $PBS_O_WORKDIR/$job.out
echo "Shared library path: $LD_LIBRARY_PATH" >> $PBS_O_WORKDIR/$job.out
echo "PBS Job ID is: ${PBS_JOBID}" >> $PBS_O_WORKDIR/$job.out
echo "PBS Job name is: ${PBS_JOBNAME}" >> $PBS_O_WORKDIR/$job.out
cat $PBS_NODEFILE >> $PBS_O_WORKDIR/$job.out

#Start ORCA job. ORCA is started using full pathname (necessary for parallel execution). Output file is written directly to submit directory on frontnode.
$orcadir/orca $tdir/$job.inp >> $PBS_O_WORKDIR/$job.out

# ORCA has finished here. Now copy important stuff back (xyz files, GBW files etc.). Add more here if needed.
cp $tdir/*.gbw $PBS_O_WORKDIR
cp $tdir/*.xyz $PBS_O_WORKDIR
cp $tdir/*.hess $PBS_O_WORKDIR
cp $tdir/*.asa.* $PBS_O_WORKDIR
