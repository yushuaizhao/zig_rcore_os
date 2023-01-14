import os
import subprocess

output_dir = "./bin"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

build_zig_cmd = r"zig build -Dtarget=riscv64-freestanding-none -Drelease-fast=true --verbose"
print(build_zig_cmd)
os.system(build_zig_cmd)
zig_out_dir = "./zig-out/bin"

exes = os.listdir(zig_out_dir)
for e in exes:
    strip_cmd = f"llvm-objcopy --binary-architecture=riscv64 --strip-all {os.path.join(zig_out_dir, e)} -O binary {os.path.join(output_dir, e)}.bin"
    print(strip_cmd)
    os.system(strip_cmd)
