            .text

start:      addi a4, zero, 0      # t4 = 0    // success counter
loop:       addi a3, zero, 2041   # t3 = 2041 // y
            addi a0, zero, 25   # t0 = 157  // a
            addi a1, zero, 4    # t1 = 169  // b
            add  a2, a0, a1       # lsr a2, a0, a1 00b5062b
            add  a2, a2, a2