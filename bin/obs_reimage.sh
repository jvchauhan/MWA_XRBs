#!/bin/bash
usage()
{
echo "obs_image.sh [-o obsnum] [-m calibration obs] [-c cluster] 
        -o obs id               : the obs id to calibrate
        -m calibration obs      : the calibration observation
        -c cluster              : hpc cluster to process data, default=garrawarla" 1>&2;
exit 1;
}

obsnum=
calibration_obs=
cluster="garrawarla"


while getopts 'o:m:c:' OPTION
do
    case "$OPTION" in
        o)
            obsnum=${OPTARG}
            ;;
        m)
            calibration_obs=${OPTARG}
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
#script="${base}queue/download_${obsnum}.sh"
#cat ${base}/bin/download.sh | sed -e "s:OBSNUM:${obsnum}:g" \
#                                 -e "s:BASE:${base}:g" > ${script}
#output="${base}queue/logs/download_${obsnum}.o%A"
#error="${base}queue/logs/download_${obsnum}.e%A"
#sub="sbatch --begin=now+15 --output=${output} --error=${error} -M ${cluster} -A mwasci ${script}"
#jobid1=($(${sub}))
#jobid1=${jobid1[3]}
# rename the err/output files as we now know the jobid
#error=`echo ${error} | sed "s/%A/${jobid1}/"`
#output=`echo ${output} | sed "s/%A/${jobid1}/"`

#echo "Submitted download job for imaging as ${jobid1}"


#############################


### run reimaging job ###
script="${base}queue/reimage_${obsnum}.sh"
cat ${base}/bin/reimage.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/reimage_${obsnum}.o%A"
error="${base}queue/logs/reimage_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -M ${cluster} -A mwasci ${script} -z ${calibration_obs}"
jobid1=($(${sub}))
jobid1=${jobid2[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid1}/"`
output=`echo ${output} | sed "s/%A/${jobid1}/"`

echo "Submitted reimaging job as ${jobid1}"
