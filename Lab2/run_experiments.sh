#!/bin/bash

# timer
start_time=$SECONDS

# paths
GEM5_DIR="$HOME/gem5"
GEM5_OPT="$GEM5_DIR/build/RISCV/gem5.opt"
SE_SCRIPT="$GEM5_DIR/configs/run_riscv_se.py"
SRC_DIR="$GEM5_DIR/../src_codes"
BASE_OUTDIR="$GEM5_DIR/m5out_lab2"

CMD_LIST="commands.list"
# clean up any old command list
rm -f "$CMD_LIST"

queue_sim() {
    local question=$1
    local prog=$2
    local cpu=$3
    local config_name=$4
    local extra_args=$5

    local cmd="${SRC_DIR}/${prog}.riscv"
    local options=""

    # program-specific arguments
    if [ "$prog" == "cpu" ]; then
        options="5000000"
    elif [ "$prog" == "mem" ]; then
        options="65536 2000000"
    fi

    # results path: m5out_lab2/Q2_caches/mem/minor_Config_A
    local outdir="${BASE_OUTDIR}/${question}/${prog}/${cpu}_${config_name}"
    mkdir -p "$outdir"

    # command to run
    local full_cmd="$GEM5_OPT --outdir=\"$outdir\" \"$SE_SCRIPT\""
    full_cmd="$full_cmd --cpu \"$cpu\" --cmd \"$cmd\" --options \"$options\" $extra_args"
    full_cmd="$full_cmd > \"$outdir/terminal_output.log\" 2>&1"
    full_cmd="$full_cmd && echo \"Finished: [$question] $prog - $cpu - $config_name\""
    full_cmd="$full_cmd || echo \"ERROR: [$question] $prog - $cpu - $config_name (Check log!)\""

    # append it to list of jobs
    echo "$full_cmd" >> "$CMD_LIST"
}

echo "Generating simulation queue..."

################################################################################
# Question 1: Minor vs O3 CPU (Default Params)
################################################################################
for prog in "cpu" "mem"; do
    for cpu in "minor" "o3"; do
        queue_sim "Q1_Base" "$prog" "$cpu" "default" ""
    done
done

################################################################################
# Question 2: Caches (Minor and O3)
################################################################################
declare -A cache_configs
cache_configs["Config_A"]="--l1i_size 16KiB --l1d_size 16KiB --l2_size 256KiB"
cache_configs["Config_B"]="--l1i_size 16KiB --l1d_size 16KiB --l2_size 64KiB"
cache_configs["Config_C"]="--l1i_size 8KiB  --l1d_size 8KiB  --l2_size 1MiB"
cache_configs["Config_D"]="--l1i_size 32KiB --l1d_size 32KiB --l2_size 1MiB"

for prog in "cpu" "mem"; do
    for cpu in "minor" "o3"; do
        for conf in "Config_A" "Config_B" "Config_C" "Config_D"; do
            queue_sim "Q2_Caches" "$prog" "$cpu" "$conf" "${cache_configs[$conf]}"
        done
    done
done

################################################################################
# Question 3: ROB Entries (O3 CPU)
################################################################################
declare -A rob_configs
rob_configs["Default"]="--rob_entries 192"
rob_configs["ROB_A"]="--rob_entries 32"
rob_configs["ROB_B"]="--rob_entries 48"
rob_configs["ROB_C"]="--rob_entries 96"

for prog in "cpu" "mem"; do
    for conf in "Default" "ROB_A" "ROB_B" "ROB_C"; do
        queue_sim "Q3_ROB" "$prog" "o3" "$conf" "${rob_configs[$conf]}"
    done
done

################################################################################
# Question 4: Physical Registers (O3 CPU)
################################################################################
declare -A prf_configs
prf_configs["Default"]="--num_phys_int_regs 256"
prf_configs["PRF_A"]="--num_phys_int_regs 64"
prf_configs["PRF_B"]="--num_phys_int_regs 128"
prf_configs["PRF_C"]="--num_phys_int_regs 192"

for prog in "cpu" "mem"; do
    for conf in "Default" "PRF_A" "PRF_B" "PRF_C"; do
        queue_sim "Q4_PRF" "$prog" "o3" "$conf" "${prf_configs[$conf]}"
    done
done

################################################################################
# Run parallel execution
################################################################################
# read the first argument passed to the script, default to 4 if empty
MAX_CONCURRENT=${1:-4}

total_jobs=$(wc -l < "$CMD_LIST")
echo "========================================================="
echo " Queue complete! Found $total_jobs simulations to run."
echo " Launching $MAX_CONCURRENT parallel workers..."
echo " Note: Terminal output is hidden. Check 'terminal_output.log' inside each folder."
echo "========================================================="

# xargs reads the commands.list file and keeps exactly $MAX_CONCURRENT jobs running
xargs -d '\n' -P $MAX_CONCURRENT -a "$CMD_LIST" -I {} sh -c '{}'

# clean up the temp file
rm -f "$CMD_LIST"

# timer
elapsed=$(( SECONDS - start_time ))
hours=$(( elapsed / 3600 ))
minutes=$(( (elapsed % 3600) / 60 ))
seconds=$(( elapsed % 60 ))

echo "========================================================="
echo " ALL SIMULATIONS COMPLETED SUCCESSFULLY!"
echo " Total Execution Time: ${hours}h ${minutes}m ${seconds}s"
echo "========================================================="