.POSIX:

ECHO	:=	@echo
QUIET	:=	@

ASM     := cpm_bios.asm
ASM     += cpm_loader.asm

CHK_FILENAME := md5sum.txt

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

%.chk: build/%.bin
	$(ECHO) '	SUM $<'
	$(QUIET) grep "`md5sum "$<"`" $(CHK_FILENAME) > /dev/null

.PHONY: clean
clean:
	$(ECHO) '	RM'
	$(QUIET) rm -rf build
