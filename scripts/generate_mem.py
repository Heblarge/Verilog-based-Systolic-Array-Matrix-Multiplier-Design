import random
import sys

mem_file = "./sim/memory_init.mem"
testbench_file = "./sim/testbench.v"

MEM_SIZE = 0x5000
W_BASE = 0x00000000
X_BASE = 0x00001000

X_COLS = int(sys.argv[1])
W_COLS = int(sys.argv[2])
W_ROWS = int(sys.argv[3])
DEBUG = 0

def init_mem():
    mem_list = []
    for i in range(MEM_SIZE):
        mem_list.append(0)
    return mem_list

def write_mem(mem_list):
    file = open(mem_file, 'w')
    file.seek(0)
    file.truncate()
    for val in mem_list:
        file.write('%08X\n'%val)
    file.close()
    
def main():
    mem_list = init_mem()

    print('W: ')
    for i in range(W_ROWS):
        for j in range(W_COLS):
            val = random.randint(0, 255)
            mem_list[W_BASE + i * W_COLS + j] = val
            print("%02X "%(val), end='')
        print('')

    print('\nX: ')
    for i in range(W_COLS):
        for j in range(X_COLS):
            val = random.randint(0, 255)
            mem_list[X_BASE + j * W_COLS + i] = val
            print("%02X "%val, end='')
        print('')

    write_mem(mem_list)
    modify_testbench()

def modify_testbench():
    f_testbench = open(testbench_file, "r+")
    testbench = f_testbench.read().split('\n')
    testbench[1] = '`define X_COLS ' + str(X_COLS)
    testbench[2] = '`define W_COLS ' + str(W_COLS)
    testbench[3] = '`define W_ROWS ' + str(W_ROWS)
    testbench[4] = '`define DEBUG ' + str(DEBUG)

    f_testbench.seek(0)
    f_testbench.truncate()
    f_testbench.write("\n".join(testbench))
    f_testbench.close()

if __name__ == '__main__':
    main()