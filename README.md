# SNESDRONE-emulation
A ROM image for the Super NES to control the internal wavetable synthesizer chip for profit.

# What?
Yes! Well, actually, no. There's no profit in this. I'm doing this little hardware project where I'm building a SNES cart with potentiometers and an ARM co-processor, that exposes the internal audio hardware directly to the user.

# Why?
With some potentiometers on the cart, and a user interface, it's possible to control the audio hardware to generate sounds and, in the best case, use the SNES as a musical instrument.

# How?
I developed a cartridge that connects an ARM cortex m7 MCU directly to the SNES CPU. This means, the ARM MCU simulates ROM and feeds the SNES CPU with instructions and data. Also, the MCU reads potentiometers on the cart and converts those values to instructions for the SNES DSP.

# Where?
Here: snesdrone.com

# And what is this git?
It's me working on the SNES firmware that will have to go onto the ARM MCU in the end. The ROM simulation is working, but now I have to write the code that actually make the SNES do audio. So, what I am doing here is writing a SNES ROM file that can be opened with an emulator to generate audio with the SNES DSP. Except for the potentiometers, everything should work on the emulator too.

# Which emulator?
I use BSNES, since this project is very hardware based and uses some tricks that only real hardware can do. BSNES acts the most like real hardware.

# How far is it?
* Sound is working (4 out of 8 oscillators, only one waveform, no efx)
* GUI is in the making (right now it's a single frame that you can't interact with)

# What's next?
* Make the GUI work
