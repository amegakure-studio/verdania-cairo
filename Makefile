katana:
	katana --disable-fee --invoke-max-steps 4294967295

setup:
	@./scripts/setup.sh

torii:
	torii --world $(word 2,$(MAKECMDGOALS))