# CP/M for Sanco 800x

This repository was created to analyse the floppy image of the Sanco 8001 CP/M.
The original source code is not available, so we are going to disassemble it.

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

    make assemble

To check the asm file consistency, run

    make test

## Other contributions

- [RetroNewbie/Sanco_8000](https://github.com/RetroNewbie/Sanco_8000/tree/main/CP-M), some disassemblies of the software inside in this floppy.

## External references

- [CP/M BIOS documentation](https://www.seasip.info/Cpm/bios.html).
- [CP/M sources](http://www.gaby.de/cpm/source.html), see CP/M 2.2 section.
