.POSIX:

ECHO	:=	@echo
QUIET	:=  @

ASM     := FUNK00.COM.asm
ASM     += PAR8003.COM.asm
ASM     += PAR8003.relocated.asm
ASM     += SLF80037.COM.asm
ASM     += SLF80037.relocated.asm
ASM     += COPY8003.COM.asm

CHK_FILENAME := md5sum.txt

BIN     := $(patsubst %.asm, build/%, $(ASM))

CHK     := $(patsubst %.asm, %.chk, $(ASM))

all: tests

.PHONY: tests
tests: checksum

.PHONY: checksum
checksum: $(CHK)

.PHONY: assemble
assemble: $(BIN)

build/%: %.asm
	$(QUIET) mkdir -p `dirname $@`
	$(ECHO) '	ASM $<'
	$(QUIET) z80asm -b -o$@ $<

%.chk: build/%
	$(ECHO) '	SUM $<'
	$(QUIET) grep "`md5sum "$<"`" $(CHK_FILENAME) > /dev/null

.PHONY: clean
clean:
	$(ECHO) '	RM'
	$(QUIET) rm -rf build
