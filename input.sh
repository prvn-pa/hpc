#!/bin/bash
#PBS -q iiserq
#PBS -l nodes=1:ppn=20
#PBS -l cput=124:00:00
#PBS -l walltime=24:00:00
#PBS -j oe
#PBS -V
#PBS -M yourmailid@server.com
#PBS -m ae
#PBS -N Job Name Here

export g09root=/home/app/gaussian/g09
export GAUSS_SCRDIR=/home/scratch/$USER
export GAUSS_EXEDIR=$g09root
export GAUSS_ARCHDIR=$g09root/g09/arch

export WORK_DIR=$PBS_O_WORKDIR
cd $WORK_DIR

cat $PBS_NODEFILE | sort | uniq > /tmp/.nodes.$PBS_JOBID
export GAUSS_LFLAGS="-nodefile /tmp/.nodes.$PBS_JOBID"

/home/app/gaussian/g09/g09 < input-file.inp > output-file.log
