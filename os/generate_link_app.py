import os

bin_dir = "../user/bin/"
bin_files = os.listdir(bin_dir)
# bin_files = [t for t in bin_files if t.endswith(".bin")]

with open("./linker/link_app.S", 'w', encoding='utf-8') as f:
    f.write("#os/linker/link_app.S\n\t.align 3\n\t.section .data\n\t.global _num_app\n")
    f.write(f"_num_app:\n\t.quad {len(bin_files)}\n")
    for i in range(len(bin_files)):
        f.write(f"\t.quad app_{i}_start\n")
    f.write(f"\t.quad app_{len(bin_files) - 1}_end\n\n")

    for i, b in enumerate(bin_files):
        path = os.path.join(bin_dir, b)
        f.write("\t.section .data\n")
        f.write(f"\t.global app_{i}_start\n")
        f.write(f"\t.global app_{i}_end\n")
        f.write(f"app_{i}_start:\n")
        f.write(f"\t.incbin \"{path}\"\n")
        f.write(f"app_{i}_end:\n\n")