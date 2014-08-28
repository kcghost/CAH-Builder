all:
	@mkdir -p out
	@gawk -F '\\\\n' -f build_cards.awk text_list