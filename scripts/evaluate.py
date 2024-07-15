import sys
import os
from turtle import width
import numpy as np

W_BASE = 0x00000000
X_BASE = 0x00001000
Y_BASE = 0x00002000

X_COLS = int(sys.argv[1])
W_COLS = int(sys.argv[2])
W_ROWS = int(sys.argv[3])

mem_file1 = './vivado_project/lab4.sim/sim_1/behav/xsim/memory_init.mem'
mem_file2 = './vivado_project/lab4.sim/sim_1/behav/xsim/memory_out.mem'

def matmul(A, B):
    M = len(A)
    N = len(B)
    K = len(B[0])
    C = []
    for i in range(M):
        row = []
        for j in range(K):
            val = 0
            for k in range(N):
                val += A[i][k] * B[k][j]
            row.append(val)
        C.append(row)
    return C

def main():
    f1 = open(mem_file1, 'r')
    f2 = open(mem_file2, 'r')
    mem = f1.readlines()
    mem_out = f2.readlines()
    W = []
    X = []
    output = []
    print('X_COLS:', X_COLS)
    print('W_COLS:', W_COLS)
    print('W_ROWS', W_ROWS)

    print('\nW:')
    for i in range(W_ROWS):
        row = []
        for j in range(W_COLS):
            val = int(eval('0x'+mem[W_BASE + i * W_COLS + j].strip()))
            row.append(val)
            print("%02X "%val, end='')
        W.append(row)
        print('')

    print('\nX:')
    for i in range(W_COLS):
        row = []
        for j in range(X_COLS):
            val = int(eval('0x'+mem_out[X_BASE + j * W_COLS + i].strip()))
            row.append(val)
            print("%02X "%val, end='')
        print('')
        X.append(row)

    print('\nY:')
    for i in range(W_ROWS):
        row = []
        for j in range(X_COLS):
            try:
                val = int(eval('0x'+mem_out[Y_BASE + i * X_COLS + j].strip()))
                row.append(val)
                print("%08X "%val, end='')
            except:
                row.append(0)
                print("%s "%mem_out[Y_BASE + i * X_COLS + j].strip(), end='')
        print('')
        output.append(row)
    
    groundtruth = matmul(W, X)
    print('\ngroundtruth:')
    for i in range(W_ROWS):
        for j in range(X_COLS):
            print("%08X "%groundtruth[i][j], end='')
        print('')
    
    f1.close()
    f2.close()
    
    print("\n###############")
    if (output == groundtruth):
        print(" Congratulate!")
    else:
        print("Something Wrong!")
    print("###############")
    
if __name__ == '__main__':
    main()
