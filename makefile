template.smc: main.asm link
	wla-65816 -v -o main.obj main.asm
	wlalink -v link template.smc
	rm main.obj
	bsnes template.smc
