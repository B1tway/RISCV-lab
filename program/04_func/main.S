            .text

start:      addi a0, zero, 25   # t0 = 25  // a
            addi a1, zero, 4    # t1 = 4  // b
            add  a2, a0, a1       # fn a2, a0, a1 00b5062b
            addi a0, zero, 121 
            addi a1, zero, 16 
            add  a2, a0, a1       # fn a2, a0, a1 00b5062b