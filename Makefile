mpc_63_88_deck:
	@mkdir -p out
	@awk -F '\\\\n' '\
		{\
			if(match($$0,/[_?]/)) {\
				#count the blanks\
				count=0;\
				str = $$0;\
				while (match(str,/_+/)) {\
					count++;\
					str = substr(str,RSTART+RLENGTH);\
				}\
\
				#print count;\
				if(count == 2) {\
					system("cp black_pick2.svg temp.svg");\
				} else if(count == 3) {\
					system("cp black_pick3.svg temp.svg");\
				} else {\
					system("cp black_standard.svg temp.svg");\
				}\
			} else {\
				system("cp white_standard.svg temp.svg");\
			}\
\
			for(i=1;i<=NF;i++) {\
				gsub(/"/,"\\\"",$$i);\
				#print "xmlstarlet ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v \"" $$i "\" temp.svg > temp_pipe.svg";\
				system("xmlstarlet ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v \"" $$i "\" temp.svg > temp_pipe.svg");\
				system("cat temp_pipe.svg > temp.svg");\
				system("rm temp_pipe.svg");\
			}\
			system("inkscape -z -b white -d 1200 -e out/" NR ".png temp.svg");\
			system("rm temp.svg");\
		}\
		\' text_list