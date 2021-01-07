# Running ORCA and G09 in HPC

Prepared by **Praveen**

*Last updated on January 07, 2021*

---

## 1. Pre-requists:

Make sure the following:

* You have an working HPC account.
* Your HPC enabled with OpenMPI 2.X or higher and you have permission to accesses it.
* You have accesses to the Orca and/or G09 installation directories. If you're unsure about it, please ask your IT admin where they're installed and try to access them by entering the complete PATH. In case, if you're an IISER-Tirupati user most of the programs are available in /home/app directory.
* For using Gaussion (G09 or any other version) you require an additional permission. Make sure your IT admin provided you one such.
* You should have read and write permission to scratch directory.

If any of the above is missing please contact your IT admin.

## 2. Preparing input files:

1. Design the molecule of interest in an molecular editor (Eg: ChemDraw, ChemSketch or MarvinSketch).
2. Export/Save the file .XYZ format.
3. Prepare an ORCA or G09 input file (refer corresponding manuals) and append the molecular coordinates in the place of molecular input.
4. Prepare a bash script. Corresponding files are given below.

**Sample for ORCA bash script**

```
#!/bin/bash
#PBS -l nodes=1:ppn=20
#PBS -q iiserq
### Send email on abort, begin and end
#PBS -m ae
### Specify mail recipient
#PBS -M yourmail@here.com
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

```

[Click here you download this code](job-orca.sh)

**Sample G09 bash script**

```
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
```

[Click here you download this code](input.sh)

## 3. Running your file:

* Make sure about you CPU utilization policy of your institute. If you're an IISER Tirupati user depending upon your `cput` you will be either directed to short que (less than 24 hrs), mid que (less than 48 hrs) and long que (less than 96 hrs). If you require more CPU time contact the IT admin.

* To run an ORCA job, enter the following command: `qsub job-orca.sh -N jobname` where jobname is the name of your ORCA inputfile (jobname.inp) without the .inp extension

* To run a G09 job, enter `qsub input.sh`

* To know the running status: `qstat -u username`

## 4. Copying and input and output files to the local machine

* In mac and linux use `sftp` to transfer files between server and local machine. In windows PuTTY can be useful.
* In GNOME Linux desktops, you can directly access the files from nautilus itself. Click other locations and in the bottom address bar enter like `sftp://username@serverID` and enter password when prompted. 
