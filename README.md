# CP/M for Sanco 800x

This repository was created to analyse the floppy image of the Sanco 8001 CP/M.
The original source code is not available, so we are going to disassemble it.
The image, copied from a physical disk using a gotek, was provided by "pconseil" on [archive.org](https://archive.org/details/sanco-8003-cpm-2.2fr.dsqd).

![Splash screen of the original Sanco CP/M](./img/sanco-cpm-splash.jpg)

## How the CP/M is loaded in memory

![CP/M memory map when loaded from disk](./img/sanco-cpm-memory-map.jpg)

The Sanco BIOS ROM loads Head 0, Track 0, Sector 0 in memory (addr $0080), see [cpm_loader](cpm_loader.asm).
This code acts as loader for the various parts of the CP/M. It loads:

- 5120 bytes from Head 1, Track 0, Sectors 0-4 in $dc00-$f000. This code contains the CP/M command processor (CCP) and part of the CP/M Basic DOS (BDOS) (confirmed by "Soul of CP/M" manual).
- 3840 bytes from Head 0, Track 0, Sectors 1-15 in $f000-$ff00. It contains the remaining part of the BDOS, but it mostly contain the CP/M BIOS (confirmed by "Soul of CP/M" manual), see [cpm_bios](cpm_bios.asm)

After loading these sectors, the loader routine jumps to $f200, which is the first entry of the BIOS jump table (BOOT).

### Binary files

To better handle the disassmbley and analysis of the CP/M components, each one was extracted from the raw floppy image and recomposed with the correct memory layout, so we have:

- [cpm_bios.bin](./cpm_bios.bin), 3328 bytes long, loaded from `$f200`;
- [cpm_bdos.bin](./cpm_bdos.bin), 3584 bytes long, loaded from `$e400`;
- [cpm_ccp.bin](./cpm_ccp.bin), 2048 bytes long, loaded from `$dc00`.

### How to

At the moment, only the loader and the BIOS are disassemblied.
To build them, just run

    cd cpm
    make assemble

To check the asm file consistency, run

    cd cpm
    make test

### Handle CP/M file system

The CP/M file system onto the `SANCO8003_CPM_2.2fr.bin` image may be accessed using the [cpmtools](http://www.moria.de/~michael/cpmtools/).
An appropriate disk definition file is needed (`diskdefs`), which is included in this repository.
Some of the applications, in particular the ones that are implemented for the Sanco computers, can be found dissassembled and commented in [applications](applications/README.md) folder.

#### Print the content of the disk

```bash
$ cpmls -f sanco SANCO8003_CPM_2.2fr.bin
0:
asm.com
config80.com
copy8003.com
# ...
submit.com
term80.com
trx62.com
xsub.com
```

#### Extract a file from the image

A single file

```bash
$ cpmcp -f sanco SANCO8003_CPM_2.2fr.bin "0:ASM.COM" .
```

Multiple files

```bash
$ cpmcp -f sanco SANCO8003_CPM_2.2fr.bin "0:*" disk/
```

#### Add a file to the image

```bash
$ cpmcp -f sanco SANCO8003_CPM_2.2fr.bin test.bin "0:TEST.COM"
```

## External references

- [CP/M BIOS documentation](https://www.seasip.info/Cpm/bios.html).
- [CP/M sources](http://www.gaby.de/cpm/source.html), see CP/M 2.2 section.
