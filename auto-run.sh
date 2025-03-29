#!/usr/bin/bash
#set -x
APPS=(silo xapian img-dnn masstree)
declare -A APP_QPS_PARAMS=(
    [silo]="1000 1000 10000"     # 起始值 步长 结束值
    [xapian]="500 500 5000"
    [img-dnn]="200 200 2000"
    [masstree]="2000 2000 20000"
)
DEST=${DEST:-$(realpath .)/result-$(date -Iseconds).txt}
STRESSES=(
    "stress-ng -c $(($(nproc) / 2))"
    "stress-ng -c $(nproc) -l 50 --cpu-method=fft"
)
ITER=1

for app in "${APPS[@]}"; do
    echo "$app" >> "$DEST"
    # 提取应用的QPS参数
    IFS=' ' read -ra params <<< "${APP_QPS_PARAMS[$app]}"
    start=${params[0]}
    step=${params[1]}
    end=${params[2]}
    for stress in "${STRESSES[@]}"; do
        echo "$stress" >> "$DEST"
        $stress &>/dev/null &
        sleep 1
        # 生成该应用的QPS序列
        for qps in $(seq "$start" "$step" "$end"); do
            echo "QPS: $qps" | tee -a "$DEST"
            for _ in $(seq 1 "$ITER"); do
                docker exec tailbench-in-container-tailbenchenv-1 bash -c \
                    "cd src/tailbench/$app && QPS=$qps ./run.sh &>/dev/null && 
                    python ../utilities/parselats.py lats.bin >be-tmp.txt"
                cat "$app/be-tmp.txt" >> "$DEST"
                rm -f "$app/be-tmp.txt"
            done
        done
        pkill stress-ng
    done
done
