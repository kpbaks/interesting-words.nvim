.PHONY: test
test:
	nvim --noplugin -u test/minimal.vim -c "lua require(\"interesting-words\").setup()"
