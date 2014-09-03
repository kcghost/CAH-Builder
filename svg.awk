@include "util.awk"

{
	#defaults
	if(!out_dir) {
		out_dir = "out_svg";
	}
	if(!debug) {
		debug = "";
	}
	if(!exec) {
		exec = "true";
	}

	underscore_width = 0.111197919;
	max_line_width = 2.16666666667;
	min_underscores = 10;

	quotes_strip = $$0;
	gsub(/"[^"]*"/,"",quotes_strip);
	if(match(quotes_strip,/[?]/) || match($$0,/[_]/)) {
		#count the blanks
		count=0;
		str = $$0;
		while (match(str,/_+/)) {
			count++;
			str = substr(str,RSTART+RLENGTH);
		}

		#print count;
		if(count == 2) {
			run("cp black_pick2.svg temp.svg");
		} else if(count == 3) {
			run("cp black_pick3.svg temp.svg");
		} else {
			run("cp black_standard.svg temp.svg");
		}
	} else {
		run("cp white_standard.svg temp.svg");
	}

	for(i=1;i<=NF;i++) {
		str = $i;

		#escape quotes for command line
		gsub(/"/,"\\\"",str);
		run("xmlstarlet -q ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v \"" str "\" temp.svg 2>/dev/null > temp_pipe.svg");
		run("cat temp_pipe.svg > temp.svg");
		run("rm temp_pipe.svg");
	}
	run("mv temp.svg " out_dir "/" NR ".svg");
}
