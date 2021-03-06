#!/bin/bash -l

path2ds="/home/rsk3900/Datasets/"
epochs=40
workers=12
lr=0.0005

spack env activate riteyes4

disentangle="0"
curObj="allvsone"
test_mode="allvsone"
declare -a models=("ritnet_v1" "ritnet_v2" "ritnet_v3" "ritnet_v4" "ritnet_v5" "ritnet_v6")

#declare -a selfCorr_list=("0" "1")
declare -a selfCorr_list=("0")

for model in "${models[@]}"
do
    for selfCorr in "${selfCorr_list[@]}"
    do
        baseJobName="RC_e2e_${test_mode}_${model}_${curObj}_${selfCorr}_0"
        str="#!/bin/bash\npython3 train.py --path2data=${path2ds} --expname=${baseJobName} --test_mode=${test_mode} "
        str+="--curObj=${curObj} --batchsize=48 --workers=${workers} --prec=32 --epochs=${epochs} "
        str+="--disp=0 --overfit=0 --lr=${lr} --selfCorr=${selfCorr} --disentangle=${disentangle} --model=${model}"
        echo $str
        echo -e $str > command.lock
        sbatch -J ${baseJobName} -o "rc_log/${test_mode}/${baseJobName}.o" -e "rc_log/${test_mode}/${baseJobName}.e" --mem=16G --cpus-per-task=9 -p tier3 -A riteyes --gres=gpu:v100:1 -t 2-0:0:0 command.lock
    done
done
