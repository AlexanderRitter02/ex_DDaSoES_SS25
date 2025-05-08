# Super simple test generation for 3-bit multiplier

with open("3bit_mult_test.txt", "w") as f:

    for a in range(8):
        a_bits = [(a >> i) & 1 for i in range(3)]

        # For each A, go through all Bs
        for b in range(8):
            b_bits = [(b >> i) & 1 for i in range(3)]

            # "force" lines
            for i in range(3):
                f.write(f"force a{i} {a_bits[i]}\n")
            for i in range(3):
                f.write(f"force b{i} {b_bits[i]}\n")

            # Simulation
            f.write("run 5\n")