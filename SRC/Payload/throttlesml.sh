#!/bin/bash
##################################################################
# @Command:      throttlesml
# @Suite:        sml-magic-tools
# @Description:  Expert System & Inference Engine for Hardware.
#                Uses Forward Chaining to diagnose system health.
# @Author:       Sergio Melas <sergiomelas@gmail.com>
# @Version:      2.0.0
##################################################################

# --- INFERENCE ENGINE STATE ---
EMA_PERF=100
STATE_FILE="/tmp/.sml_expert_ema"

trap "printf '\033[?25h\033[0m'; exit" SIGINT SIGTERM
printf "\033[?25l"
clear

# --- HELPER: ASCII GAUGE ---
draw_gauge() {
    local val=$1; local color=$2; local width=20
    local filled=$(( val * width / 100 ))
    [[ $filled -gt $width ]] && filled=$width
    printf "[\e[${color}m"
    for ((i=0; i<filled; i++)); do printf "■"; done
    printf "\e[0m"
    for ((i=filled; i<width; i++)); do printf " "; done
    printf "]"
}

while true; do
    printf "\033[H"

    # --- 1. FACT COLLECTION (The Evidence) ---
    # Fact A: Clock Capacity (u)
    MAX_F=$(lscpu | grep "CPU max MHz" | awk '{print $4}' | tr -d ',' | cut -d'.' -f1)
    CUR_F=$(lscpu | grep "CPU MHz" | awk '{print $3}' | tr -d ',' | cut -d'.' -f1)
    [[ -z "$MAX_F" || "$MAX_F" -le 0 ]] && MAX_F=1
    U_PERF=$(( 100 * CUR_F / MAX_F ))

    # Apply SML Filter (x = x*0.3 + 0.7*u)
    EMA_PERF=$(( (EMA_PERF * 3 + U_PERF * 7) / 10 ))

    # Fact B: Thermal State
    TEMP=$(( $(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0) / 1000 ))

    # Fact C: Energy Flux (Watts)
    POWERCAP="/sys/class/powercap/intel-rapl:0"
    if [ -d "$POWERCAP" ]; then
        E1=$(cat $POWERCAP/energy_uj); sleep 0.1; E2=$(cat $POWERCAP/energy_uj)
        WATTS=$(( (E2 - E1) / 100000 ))
    else WATTS=0; fi

    # Fact D: Kernel Interrupts (BD-PROCHOT / External)
    PROCHOT=$(dmesg | grep -iE "prochot|critical" | tail -n 1)

    # --- 2. THE INFERENCE ENGINE (Forward Chaining) ---
    # Rule 1: High Heat + Low Perf -> Thermal Saturation
    # Rule 2: Low Heat + Low Perf + Low Watts -> Power Starvation
    # Rule 3: Low Heat + Low Perf + High Watts -> Silicon Degradation or Background Hijack
    # Rule 4: High Heat + High Watts -> Normal Stress (Healthy Load)

    DIAGNOSIS="\033[1;32mOPTIMAL\033[0m"
    ADVICE="Hardware is operating within nominal silicon parameters."

    if [ "$TEMP" -gt 85 ]; then
        if [ "$EMA_PERF" -lt 80 ]; then
            DIAGNOSIS="\033[1;31mTHERMAL SATURATION\033[0m"
            ADVICE="CPU is self-throttling to prevent physical damage. Check cooling fins."
        else
            DIAGNOSIS="\033[1;33mTHERMAL DANGER\033[0m"
            ADVICE="High load detected. Efficiency is dropping due to heat soak."
        fi
    elif [ "$EMA_PERF" -lt 75 ]; then
        if [ "$WATTS" -lt 12 ]; then
            DIAGNOSIS="\033[1;34mPOWER STARVATION\033[0m"
            ADVICE="Motherboard is limiting current (PL1). Check AC adapter or Battery."
        elif [ -n "$PROCHOT" ]; then
            DIAGNOSIS="\033[1;31mEXTERNAL INTERRUPT\033[0m"
            ADVICE="BD_PROCHOT detected. Another component (GPU/VRM) is forcing CPU lag."
        fi
    fi

    # --- 3. THE MAGIC INTERFACE ---
    echo "##################################################################"
    echo "  SML EXPERT SYSTEM v2.0             [Real-Time Inference]        "
    echo "##################################################################"

    printf " TELEMETRY:  PERF: %3d%% %s  TEMP: %2d°C  PWR: %2dW\n" \
           "$EMA_PERF" "$(draw_gauge $EMA_PERF "1;32")" "$TEMP" "$WATTS"
    echo "------------------------------------------------------------------"

    echo -e " \033[1;37m[STATE]:\033[0m $DIAGNOSIS"
    echo -e " \033[1;37m[ADVISORY]:\033[0m $ADVICE"
    echo "------------------------------------------------------------------"

    # Pulse indicator for inference cycle
    PULSE=("." ".." "..." "   ")
    printf " Analyzing Logic Gates %s\r" "${PULSE[$(( (SECONDS) % 4 ))]}"

    sleep 0.5
done
