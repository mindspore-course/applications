#!/bin/bash
# Copyright 2021 Huawei Technologies Co., Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

if [ $# != 3 ] && [ $# != 4 ]
then 
    echo "Usage: bash scripts/run_train_cpu.sh [squeezenet|squeezenet_residual] [cifar10|imagenet] [DATA_PATH] [PRETRAINED_CKPT_PATH](optional)"
exit 1
fi

if [ $1 != "squeezenet" ] && [ $1 != "squeezenet_residual" ]
then 
    echo "error: the selected net is neither squeezenet nor squeezenet_residual"
exit 1
fi

if [ $2 != "cifar10" ] && [ $2 != "imagenet" ]
then 
    echo "error: the selected dataset is neither cifar10 nor imagenet"
exit 1
fi

get_real_path(){
  if [ "${1:0:1}" == "/" ]; then
    echo "$1"
  else
    echo "$(realpath -m $PWD/$1)"
  fi
}

PATH1=$(get_real_path $3)

if [ $# == 4 ]
then
    PATH2=$(get_real_path $4)
fi

if [ ! -d $PATH1 ]
then 
    echo "error: DATASET_PATH=$PATH1 is not a directory"
exit 1
fi

if [ $# == 4 ] && [ ! -f $PATH2 ]
then
    echo "error: PRETRAINED_CKPT_PATH=$PATH2 is not a file"
exit 1
fi

BASE_PATH=$(dirname "$(cd "$(dirname "$0")" || exit; pwd)")
CONFIG_FILE="${BASE_PATH}/squeezenet_cifar10_config.yaml"

if [ $1 == "squeezenet" ] && [ $2 == "cifar10" ]; then
    CONFIG_FILE="${BASE_PATH}/squeezenet_cifar10_config.yaml"
elif [ $1 == "squeezenet" ] && [ $2 == "imagenet" ]; then
    CONFIG_FILE="${BASE_PATH}/squeezenet_imagenet_config.yaml"
elif [ $1 == "squeezenet_residual" ] && [ $2 == "cifar10" ]; then
    CONFIG_FILE="${BASE_PATH}/squeezenet_residual_cifar10_config.yaml"
elif [ $1 == "squeezenet_residual" ] && [ $2 == "imagenet" ]; then
    CONFIG_FILE="${BASE_PATH}/squeezenet_residual_imagenet_config.yaml"
else
     echo "error: the selected dataset is not in supported set{squeezenet, squeezenet_residual, cifar10, imagenet}"
exit 1
fi

if [ -d "train" ];
then
    rm -rf ./train
fi
mkdir ./train
cp ./train.py ./train
cp -r ./src ./train
cp -r ./model_utils ./train
cp -r ./*.yaml ./train
cd ./train || exit
echo "start training for device CPU"
env > env.log
if [ $# == 3 ]
then
   python train.py --net_name=$1 --dataset=$2 --device_target=CPU --data_path=$PATH1 --config_path=$CONFIG_FILE --output_path './output' &> log &
fi

if [ $# == 4 ]
then
    python train.py --net_name=$1 --dataset=$2 --device_target=CPU --data_path=$PATH1 --pre_trained=$PATH2 --config_path=$CONFIG_FILE --output_path './output' &> log &
fi
cd ..
