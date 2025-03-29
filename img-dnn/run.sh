#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${DIR}/../configs.sh

THREADS=1
REQS=100000000 # Set this very high; the harness controls maxreqs
QPS=${QPS:-500}

TBENCH_WARMUPREQS=5000 TBENCH_MAXREQS=10000 TBENCH_QPS=${QPS} \
    TBENCH_MINSLEEPNS=10000 TBENCH_MNIST_DIR=${DATA_ROOT}/img-dnn/mnist \
    ./img-dnn_integrated -r ${THREADS} \
    -f ${DATA_ROOT}/img-dnn/models/model.xml -n ${REQS}
