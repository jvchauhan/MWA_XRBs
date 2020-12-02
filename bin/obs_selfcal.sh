#!/bin/bash
usage()
{
echo "obs_selfcal.sh [-o obsnum] [-c cluster] 
        -o obs id               : the obs id to calibrate
        -c cluster              : hpc cluster to process data, default=garrawarla" 1>&2;
exit 1;
}

obsnum=
cluster="garrawarla"


while getopts 'o:c:' OPTION
do
    case "$OPTION" in
        o)
            obsnum=${OPTARG}
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


### run selfcal and imaging job ###
script="${base}queue/selfcal_${obsnum}.sh"
cat ${base}/bin/selfcal.sh | sed -e "s:OBSNUM:${obsnum}:g" \
                                 -e "s:BASE:${base}:g" > ${script}
output="${base}queue/logs/selfcal_${obsnum}.o%A"
error="${base}queue/logs/selfcal_${obsnum}.e%A"
sub="sbatch --begin=now+15 --output=${output} --error=${error} -M ${cluster} -A mwasci ${script}"
jobid2=($(${sub}))
jobid2=${jobid2[3]}
# rename the err/output files as we now know the jobid
error=`echo ${error} | sed "s/%A/${jobid2}/"`
output=`echo ${output} | sed "s/%A/${jobid2}/"`

echo "Submitted selfcal and imaging job as ${jobid2}"



