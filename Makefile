default: test

boostrap:
	@bin/bootstrap

test:
	@bin/test

.PHONY: bootstrap test
