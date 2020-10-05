#! /bin/bash -l
#BATCH --export=NONE
#SBATCH -p workq
#SBATCH --time=12:00:00
#SBATCH --ntasks=28
#SBATCH --mem=124GB
#SBATCH -J wsclean
#SBATCH --mail-type FAIL,TIME_LIMIT,TIME_LIMIT_90
#SBATCH --mail-user jaimwalogs@gmail.com

source /group/mwa/software/module-reset.sh
module load singularity


set -x
{

obsnum=OBSNUM
base=BASE

calibration_obs=""

while getopts 'z:' OPTION
do
    case "$OPTION" in
        z)
            calibration_obs=${OPTARG}
            ;;
    esac
done

cd ${base}/processing/${obsnum}

mem=120
cores=28

solutions=${base}processing/${calibration_obs}/${calibration_obs}_solutions.bin


### apply solutions
singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif applysolutions ${obsnum}.ms ${solutions}


### change center
##### NOTE need to include the below syntax
# chgcentre -minw -shiftback ${datadir}/${obsnum}/${obsnum}.ms
singularity exec /astro/mwasci/jchauhan/singularity_local/mwatools chgcentre -minw -shiftback ${obsnum}.ms




### image
imsize="-size 9000 9000"
pixscale="-scale 16asec"
clean="-join-polarizations -multiscale -mgain 0.8 -niter 100000 -auto-mask 3 -auto-threshold 1.2 -local-rms -circular-beam"

singularity exec /pawsey/mwa/singularity/wsclean/wsclean_2.9.2-build-1.sif wsclean -name ${obsnum}-2m ${imsize} \
      -abs-mem 120 \
      -weight briggs 0.0 -mfs-weighting ${pixscale} \
      -pol xx,yy,xy,yx -minuv-l 30 \
      ${clean} ${obsnum}.ms

singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif beam -2016 -proto ${obsnum}-2m-XX-image.fits -ms ${obsnum}.ms -name beam-MFS

singularity exec /pawsey/mwa/singularity/mwa-reduce/mwa-reduce_2020.09.15.sif pbcorrect ${obsnum}-2m image.fits beam-MFS ${obsnum}-2m-pbcorr





}
