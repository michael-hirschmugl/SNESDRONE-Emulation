# SNESDRONE emulator ROM image
A ROM image for the Super NES to control the internal wavetable synthesizer chip (SONY DSP)  for profit.

## What?
Yes! Well, actually, no. There's no profit in this. I'm doing this little hardware project where I'm building a SNES cart with potentiometers and an ARM co-processor, that exposes the internal audio hardware directly to the user.

## Why?
With some potentiometers on the cart, and a user interface, it's possible to control the audio hardware to generate sounds and, in the best case, use the SNES as a musical instrument.

## How?
I developed a cartridge that connects an ARM Cortex M4 MCU directly to the SNES CPU. This means, the ARM MCU simulates ROM and feeds the SNES CPU with instructions and data. Also, the MCU reads potentiometers on the cart and converts those values to instructions for the SNES DSP. I'd also like to add CV inputs for Eurorack modules or even a midi interface. This assembler ROM image for the SNES CPU can copy certain routines into the SNES' internal RAM and execute them from there. This way, the MCU doesn't have to do so much work. Basically, it'd possible to remove the cartridge as soon as everything is runnning from RAM. Of cource without updating any DSP values in that case.

## Where?
Here: www.snesdrone.com

## And what is this git?
It's me working on the SNES firmware (software?)  that will have to go onto the ARM MCU in the end. So basically, this is the ROM image that's going to be provided by the MCU. This ROM simulation is already working, but now I have to write the code that actually make the SNES do audio. So, what I am doing here is writing a SNES ROM file that can be opened with an emulator to generate audio with the SNES DSP. Except for the potentiometers, everything should work on the emulator too.

## Which emulator?
I use BSNES, since this project is very hardware based and uses some tricks that only real hardware can do. BSNES acts the most like real hardware. For assembly I am using WLA-65816.

## How far is it?
* Sound is working (4 out of 8 oscillators, only one waveform, no efx)
* GUI is working, well the basics at least. It's possible to turn channels on and off, display pitch value in hex and a bar for volume per channel. Volume is only for left stereo channel though.

## What's next?
* Change Wave in GUI