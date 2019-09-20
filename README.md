# SNESDRONE emulator ROM image (V0.1.1)
A ROM image for the Super NES to control the internal wavetable synthesizer chip (SONY DSP) for profit.

![alt text](https://github.com/hirschmensch/SNESDRONE-Emulation/blob/master/screen.png "Example")

## What?
Yes! Well, actually, no. There's no profit in this. I'm doing this little hardware project where I'm building a SNES cart with potentiometers and an ARM co-processor, that exposes the internal audio hardware directly to the user.

## Why?
With some potentiometers on the cart, and a user interface, it's possible to control the audio hardware to generate sounds and, in the best case, use the SNES as a musical instrument.

## How?
I developed a cartridge that connects an ARM Cortex M4 MCU directly to the SNES CPU. This means, the ARM MCU simulates ROM and feeds the SNES CPU with instructions and data. Also, the MCU reads potentiometers on the cart and converts those values to instructions for the SNES DSP. I'd also like to add CV inputs for Eurorack modules or even a midi interface. This assembler ROM image for the SNES CPU can copy certain routines into the SNES' internal RAM and execute them from there. This way, the MCU doesn't have to do so much work. Basically, it'd possible to remove the cartridge as soon as everything is runnning from RAM. Of cource without updating any DSP values in that case.

## Where?
Here: www.snesdrone.com

Feel free to contact me if you want to try this on real hardware. You will need following things:
* A SNES DRONE PCB: I have the Altium project for the PCB on github, but you can also order one from me.
* Some kind of STM32 programming/debugging device. I use the Segger J-Link.
* Free version of Keil uVision. The firmware for the MCU is a Keil project. I would love to transfer it to a CMAKE project but didn't do so yet... sorry.
* A Super Nintendo Entertainment System console (NTSC or PAL)
* Any NTSC or PAL cartridge. :) You see, in order to use this on any unmodded console, I had to include a CIC chip which I am desoldering mostly from Rise of the Robots cartridges. It's the cheapest game I could find.

This isn't plug and play at the moment I'm afraid. But if you want to work with this, just contact me!

## And what is this git?
It's me working on the SNES firmware (software?)  that will have to go onto the ARM MCU in the end. So basically, this is the ROM image that's going to be provided by the MCU. This ROM simulation is already working, but now I have to write the code that actually make the SNES do audio. So, what I am doing here is writing a SNES ROM file that can be opened with an emulator to generate audio with the SNES DSP. Except for the potentiometers, everything should work on the emulator too.

## Which emulator?
I use BSNES, since this project is very hardware based and uses some tricks that only real hardware can do. BSNES acts the most like real hardware. For assembly I am using WLA-65816.

## How far is it?
This is alpha release V0.1.1 (2019.09.20)
* Sound is working (4 out of 8 oscillators, 4 waveforms to choose (sine, rect, triangle, saw and NOISE!), no efx yet...)
* GUI is working, well the basics at least. It's possible to turn channels on and off, choose a waveform, display pitch value in hex and a bar for volume per channel. Displayed volume is only for left stereo channel though.
* Only four of eight potentiometers used. For testing, the first channel frequency pot also controls volume.

## What's next?
* Well, obviously write some kind of documentation or instruction for people who want to test this out.
* Too much jitter on frequency input.
