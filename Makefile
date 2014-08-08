mpc_63_88_deck:
	@mkdir -p out
	@awk -F '\\\\n' '\
		{\
			system("cp white_standard.svg temp.svg");\
			for(i=1;i<=10;i++) {\
				if($$i != "") {\
					system("xmlstarlet ed -u \"//*[@id=\x27Line" i "\x27]\" -v \"" $$i "\" temp.svg > temp_pipe.svg");\
					system("cat temp_pipe.svg > temp.svg");\
					system("rm temp_pipe.svg");\
				}\
			}\
			system("inkscape -z -b white -d 1200 -e out/" NR ".png temp.svg");\
			system("rm temp.svg");\
		}\
		\' text_list