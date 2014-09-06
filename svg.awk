@include "util.awk"
BEGIN {
	FS= "\\\\n";
}
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
	#its a black card if:
	#it contains an interrogative word and ends with a question mark
	#it contains one or more _'s
	#its the 'Make a haiku' card. I was considering detecting the grammar of a 'command' for black,
	#but I still wouldn't have a way of knowing pick 2, pick 3 etc. So I cheated.
	if(match(tolower(quotes_strip),/(who|what|when|where|why|how|which|whatever|whom|whose|wherewith|whither|whence).+?\?$/) || match($$0,/[_]/) || match(quotes_strip,/haiku/)) {
		#count the blanks
		count=0;
		str = $$0;
		while (match(str,/_+/)) {
			count++;
			str = substr(str,RSTART+RLENGTH);
		}

		if(match(quotes_strip,/haiku/)) {
			count = 3;
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
		run("xmlstarlet -q ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v '" str "' temp.svg 2>/dev/null > temp_pipe.svg");
		run("cat temp_pipe.svg > temp.svg");
		run("rm temp_pipe.svg");
	}
	run("mv temp.svg " out_dir "/" NR ".svg");
}
