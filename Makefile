.POSIX:

ECHO	:=	@echo
QUIET	:=	@

all: tests

.PHONY: tests
tests: checksum

.PHONY: checksum
checksum: assemble
	$(ECHO) '	SUM'
	$(QUIET) diff build/cpm_bios.bin cpm_bios.bin

.PHONY: assemble
assemble: build/cpm_bios.bin

build/%.bin: %.asm
	$(QUIET) mkdir -p `dirname $@`
	$(ECHO) '	ASM' $<
	$(QUIET) zcc +z80 -subtype=none -o $@ $<

.PHONY: clean
clean:
	$(ECHO) '	RM'
	$(QUIET) rm -rf build
