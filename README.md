# A4091 logic

This project contains the GAL logic used on the A4091 board.

 - `source/` contains the original source code as released in the
   Dave Haynie files. The chronological order of the files has been
   analyzed and is reflected in the history of this repository.
   The source code is written in CUPL.
 - `jedec/` contains the jedec fuse files that can be programmed to
   GAL chips with a programmer of your choice. We have used a [Galep 5](http://www.conitec.net/english/galep5.php)
   but a Super MiniPRO TL866II Plus will probably work as well.

## Compilation

 - First, you will need to install [WinCUPL](https://www.microchip.com/en-us/products/fpgas-and-plds/spld-cplds/pld-design-resources).
   You can install with wine, which is what we did.
 - Compile with:
   ```
   $ make
   ```

## Original Timings

The original chips use the following timings

|  ID  |   Type   |
|------|----------|
| U304 | 22V10-10 |
| U207 | 22V10-15 |
| U205 | 22V10-15 |
| U203 | 22V10-15 |
| U306 | 22V10-10 |
| U202 | 22V10-15 |
| U305 | 22V10-10 |
| U303 | 22V10-15 |

## A word on using Atmel ATF22V10

During the bring-up of the first ReA4091 prototype we used all ATF22V10C-10
chips. This lead to a non functional ReA4091. Also, using a mix of ATF22V10C-10
and ATF22V10C-15 as described above did not yield the desired result.
Atmel chips have pin-keeper circuits that can influence the signal quality,
particularly if there are a lot of inputs hanging off an output signal, like
in the case of DOE and MTCR. There are also subtle differences in pin-to-pin
propagation delay (and possibly other differences).

### Using the original logic files from the Dave Haynie Archive

If you want to use the original files, you will have to use two Lattice chips
in combination with 6 Atmel chips. In our tests we have found that the card works
most stable if you use a Lattice 22V10-6 or 22V10-7 for U306 and a Lattice 22V10-15
for U205. All the remaining chips should be Atmel ATF22V10-10.

### Using the latest version of logic files

We still recommend the same GAL configuration as with the original logic files.
While some issues have been mitigated, some signals are impacted by Atmel's
pinkeepers that make an all Atmel implementation highly likely to fail due to
the voltage drop observed on these signals.

There is a speedup of approximately 14% over the original GAL set.

