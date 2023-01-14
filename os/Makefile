build:
	python generate_link_app.py
	zig build -Dtarget=riscv64-freestanding-none -Drelease-fast=true --verbose
	llvm-objcopy --binary-architecture=riscv64 --strip-all ./zig-out/bin/zig_os -O binary ./zig-out/bin/zig_os.bin

run:
	qemu-system-riscv64 -machine virt -nographic -bios ./bin/rustsbi-qemu.bin -device loader,file=./zig-out/bin/zig_os.bin,addr=0x80200000

debug:
	qemu-system-riscv64 -machine virt -nographic -bios ./bin/rustsbi-qemu.bin -device loader,file=./zig-out/bin/zig_os.bin,addr=0x80200000 -s -S

server:
	gdb-multiarch -ex 'file ./zig-out/bin/zig_os' -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'