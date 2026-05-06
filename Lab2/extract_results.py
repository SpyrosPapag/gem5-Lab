import os

RESULTS_DIR = os.path.expanduser("~/gem5/m5out_lab2")
OUTPUT_FILE = "lab2_results.txt"

# stats
STAT_MAP = {
    "Cycles"     : "board.processor.cores.core.numCycles",
    "Insts"      : "simInsts",
    "IPC"        : "board.processor.cores.core.ipc",
    "L1I_Miss"   : "board.cache_hierarchy.l1i-cache-0.overallMissRate::total",
    "L1D_Miss"   : "board.cache_hierarchy.l1d-cache-0.overallMissRate::total",
    "L2_Miss"    : "board.cache_hierarchy.l2-cache-0.overallMissRate::total",
    "Idle_Cycles": "board.processor.cores.core.idleCycles",
    "ROB_Full"   : "board.processor.cores.core.rename.ROBFullEvents",
    "Reg_Full"   : "board.processor.cores.core.rename.fullRegistersEvents"
}

def get_stat(folder_path, stat_key):
    filepath = os.path.join(folder_path, "stats.txt")
    if not os.path.exists(filepath):
        # stat file doesnt exist
        return "N/A"
    
    target_string = STAT_MAP[stat_key]
    
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith(target_string):
                parts = line.split()
                if len(parts) > 1:
                    val = parts[1]
                    try:
                        if "." in val:
                            return f"{float(val):.6f}"
                        return val
                    except ValueError:
                        return val

    # file exists but stat is missing i.e. value=0
    return "0"

def build_path(q, prog, config):
    return os.path.join(RESULTS_DIR, q, prog, config)

def write_q1(f):
    f.write("============================\n")
    f.write("Question 1: Minor vs O3 CPU\n")
    f.write("============================\n\n")
    
    f.write(f"| {'Metric':^8} | {'Prog':^4} | {'Minor CPU':^9} | {'O3 CPU':^9} |\n")
    f.write(f"|{'-'*10}|{'-'*6}|{'-'*11}|{'-'*11}|\n")
    
    metrics = ["Cycles", "Insts", "IPC", "L1I_Miss", "L1D_Miss", "L2_Miss"]
    for m in metrics:
        for prog in ["cpu", "mem"]:
            minor_val = get_stat(build_path("Q1_Base", prog, "minor_default"), m)
            o3_val = get_stat(build_path("Q1_Base", prog, "o3_default"), m)
            
            f.write(f"| {m:^8} | {prog:^4} | {minor_val:>9} | {o3_val:>9} |\n")

def write_q2(f):
    f.write("\n\n\n==================================\n")
    f.write("Question 2: Caches (Minor and O3)\n")
    f.write("==================================\n\n")
    
    headers = ["Minor A", "Minor B", "Minor C", "Minor D", "O3 A", "O3 B", "O3 C", "O3 D"]
    header_str = " | ".join([f"{h:^9}" for h in headers])
    f.write(f"| {'Metric':^8} | {'Prog':^4} | {header_str} |\n")
    
    # Generate the exact number of dashes needed for the columns
    dashes = f"|{'-'*10}|{'-'*6}|" + "|".join(["-"*11]*8) + "|\n"
    f.write(dashes)

    metrics = ["Cycles", "Insts", "IPC", "L1I_Miss", "L1D_Miss", "L2_Miss"]
    configs = ["minor_Config_A", "minor_Config_B", "minor_Config_C", "minor_Config_D",
               "o3_Config_A", "o3_Config_B", "o3_Config_C", "o3_Config_D"]
               
    for m in metrics:
        for prog in ["cpu", "mem"]:
            vals = [get_stat(build_path("Q2_Caches", prog, c), m) for c in configs]
            vals_str = " | ".join([f"{v:>9}" for v in vals])
            f.write(f"| {m:^8} | {prog:^4} | {vals_str} |\n")

def write_q3(f):
    f.write("\n\n\n=================================\n")
    f.write("Question 3: ROB Entries (O3 CPU)\n")
    f.write("=================================\n\n")
    
    f.write(f"| {'Metric':^11} | {'Prog':^4} | {'Default':^9} | {'ROB A':^9} | {'ROB B':^9} | {'ROB C':^9} |\n")
    f.write(f"|{'-'*13}|{'-'*6}|{'-'*11}|{'-'*11}|{'-'*11}|{'-'*11}|\n")
    
    metrics = ["Cycles", "Insts", "IPC", "Idle_Cycles", "ROB_Full", "Reg_Full"]
    configs = ["o3_Default", "o3_ROB_A", "o3_ROB_B", "o3_ROB_C"]
    
    for m in metrics:
        for prog in ["cpu", "mem"]:
            vals = [get_stat(build_path("Q3_ROB", prog, c), m) for c in configs]
            f.write(f"| {m:^11} | {prog:^4} | {vals[0]:>9} | {vals[1]:>9} | {vals[2]:>9} | {vals[3]:>9} |\n")

def write_q4(f):
    f.write("\n\n\n========================================\n")
    f.write("Question 4: Physical Registers (O3 CPU)\n")
    f.write("========================================\n\n")
    
    f.write(f"| {'Metric':^11} | {'Prog':^4} | {'Default':^9} | {'PRF A':^9} | {'PRF B':^9} | {'PRF C':^9} |\n")
    f.write(f"|{'-'*13}|{'-'*6}|{'-'*11}|{'-'*11}|{'-'*11}|{'-'*11}|\n")
    
    metrics = ["Cycles", "Insts", "IPC", "Idle_Cycles", "ROB_Full", "Reg_Full"]
    configs = ["o3_Default", "o3_PRF_A", "o3_PRF_B", "o3_PRF_C"]
    
    for m in metrics:
        for prog in ["cpu", "mem"]:
            vals = [get_stat(build_path("Q4_PRF", prog, c), m) for c in configs]
            f.write(f"| {m:^11} | {prog:^4} | {vals[0]:>9} | {vals[1]:>9} | {vals[2]:>9} | {vals[3]:>9} |\n")

if __name__ == "__main__":
    if not os.path.exists(RESULTS_DIR):
        print(f"Error: Could not find the results directory at {RESULTS_DIR}")
        exit(1)
        
    print(f"Extracting results...")
    # save to file
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        write_q1(f)
        write_q2(f)
        write_q3(f)
        write_q4(f)
    print(f"Done! Extracted results saved in: {os.path.abspath(OUTPUT_FILE)}")