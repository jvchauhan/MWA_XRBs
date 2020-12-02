#! /bin/bash -l
#BATCH --export=NONE
#SBATCH -p workq
#SBATCH --time=12:00:00
#SBATCH --ntasks=28
#SBATCH --mem=124GB
#SBATCH -J calibrate
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user jaimwalogs@gmail.com

source /group/mwa/software/module-reset.sh
module load singularity


set -x
{

obsnum=OBSNUM
base=BASE

calibration_model=""

while getopts 'z:' OPTION
do
    case "$OPTION" in
        z)
            calibration_model=${OPTARG}
            ;;
    esac
done

cd ${base}/processing/${obsnum}

mem=120
cores=28

solutions=${obsnum}_${calibration_model%%.txt}_solutions_initial.bin

singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif calibrate -absmem ${mem} -j ${cores} -m ${base}models/model-${calibration_model}*withalpha.txt -minuv 20 -maxuv 2700 ${obsnum}.ms ${solutions}

singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif applysolutions ${obsnum}.ms ${solutions}


singularity exec /pawsey/mwa/singularity/cotter/cotter_4.5.sif aoflagger -j ${cores} ${obsnum}.ms

solutions=${obsnum}_${calibration_model%%.txt}_solutions.bin

singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif calibrate -absmem ${mem} -j ${cores} -m ${base}models/model-${calibration_model}*withalpha.txt -minuv 20 -maxuv 2700 ${obsnum}.ms ${solutions}

singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif
applysolutions ${obsnum}.ms ${solutions}


mv ${solutions} ${obsnum}_solutions.bin

### ploting phase and amp solutions for the tiles

#singularity exec /pawsey/mwa/singularity/python/python-ubuntu-20.04_2020-10-02.sif ./astro/mwasci/jchauhan/mwa-calplots/aocal_plot.py /astro/mwasci/jchauhan/MWA_XRBs/processing/${obsnum}/${obsnum}_solutions.bin


}
