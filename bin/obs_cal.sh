#!/bin/bash
usage()
{
echo "obs_cal.sh [-o obsnum] [-m calModel] [-c cluster] 
        -o obs id               : the obs id to calibrate
        -m calibration model    : the calibration model
        -c cluster              : hpc cluster to process data, default=garrawarla" 1>&2;
exit 1;
}

obsnum=
calibration_model=
cluster="garrawarla"


while getopts 'o:m:c:' OPTION
do
    case "$OPTION" in
        o)
            obsnum=${OPTARG}
            ;;
        m)
            calibration_model=${OPTARG}
            ;;
        c)
            cluster=${OPTARG}
            ;;
        ? | : | h)
            usage
            ;;
    esac
done


# if obsid is empty then just pring help
if [[ -z ${obsnum} ]]
then
    usage
fi

base=/astro/mwasci/jchauhan/MWA_XRBs/


### run download job ###
script="${base}queue/download_${obsnum}.sh"
cat ${base}/bin/download.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/download_${obsnum}.o%A"
error="${base}queue/logs/download_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -M ${cluster} -A mwasci ${script}"
jobid1=($(${sub}))
jobid1=${jobid1[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid1}/"`
output=`echo ${output} | sed "s/%A/${jobid1}/"`

echo "Submitted download job for calibration obs as ${jobid1}"


#############################


### run calibration job ###
script="${base}queue/calibrate_${obsnum}.sh"
cat ${base}/bin/calibrate.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/calibrate_${obsnum}.o%A"
error="${base}queue/logs/calibrate_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -M ${cluster} --dependency=afterok:${jobid1} -A mwasci ${script} -z ${calibration_model}"
jobid2=($(${sub}))
jobid2=${jobid2[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid2}/"`
output=`echo ${output} | sed "s/%A/${jobid2}/"`

echo "Submitted calibrate job as ${jobid2}"



