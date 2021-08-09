AS=nasm
ASFLAGS=-f elf32
LINK=gcc
LINKFLAGS=-m32
BUILD=build/cpuinfo

all:
	$(AS) $(ASFLAGS) cpuinfo.asm
	$(LINK) $(LINKFLAGS) cpuinfo.o -o $(BUILD)

clean:
	rm -f *.o bin/*
