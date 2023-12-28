.POSIX:

ECHO	:=	@echo
QUIET	:=	@

ASM     := cpm_bios.asm
ASM     += cpm_loader.asm

BIN     := $(patsubst %.asm, build/%.bin, $(ASM))

CHK     := $(patsubst %.asm, %.chk, $(ASM))

all: tests

.PHONY: tests
tests: checksum

.PHONY: checksum
checksum: $(CHK)

.PHONY: assemble
assemble: $(BIN)

build/%.bin: %.asm
	$(QUIET) mkdir -p `dirname $@`
	$(ECHO) '	ASM $<'
	$(QUIET) zcc +z80 -subtype=none -o $@ $<

%.chk: %.bin build/%.bin
	$(ECHO) '	SUM $<'
	$(QUIET) diff build/$< $<

.PHONY: clean
clean:
	$(ECHO) '	RM'
	$(QUIET) rm -rf build
