#! /bin/bash -l
#BATCH --export=NONE
#SBATCH -p workq
#SBATCH --time=24:00:00
#SBATCH --ntasks=6
#SBATCH --mem=8GB
#SBATCH -J download
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user jaimwalogs@gmail.com

source /group/mwa/software/module-reset.sh
module load singularity


set -x 

{
obsnum=OBSNUM
base=BASE
tres=4
fres=40
csvfile="${obsnum}_dl.csv"

cd ${base}

mkdir ${base}processing/${obsnum}

cd ${base}processing/${obsnum}

echo "obs_id=${obsnum}, job_type=c, timeres=${tres}, freqres=${fres}, edgewidth=80, conversion=ms, allowmissing=true, flagdcchannels=true, usepcentre=true" > ${csvfile}

outfile="${obsnum}_ms.zip"
msfile="${obsnum}.ms"

singularity exec /pawsey/mwa/singularity/manta-ray-client/manta-ray-client_1.0.0.sif mwa_client --csv=${csvfile} --dir=${base}processing/${obsnum}

unzip -n ${outfile}

chmod -R ugo+r ${msfile}
chmod -R ug+w ${msfile}

rm ${outfile}


}
