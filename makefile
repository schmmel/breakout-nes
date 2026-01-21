build:
	cl65 breakout.s --target nes -o breakout.nes

test:
	cl65 breakout.s --target nes -o breakout.nes
	fceux breakout.nes
