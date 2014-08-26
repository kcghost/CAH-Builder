function run(cmd) {
	if(debug) {
		print cmd;
	} else {
		system(cmd);
	}
}

{
	#debug = "true";

	underscore_width = 0.111197919;
	line_max_width = 2.16666666667;

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
		#replace quotes with commas? Helvetica-ify?

		#lengthen underscores. Look for \_: The best thing since \_.
		#must lengthen the underscore until the character after it (usually a period or a colon) is the last character on the line
		str = $$i;
		build_str = "";
		while(match(str,/\\_./)) {
			match_rstart = RSTART;
			match_rlength = RLENGTH;

			tmp_str = str;
			match(str,/\_(.)/,cap);
			sub(/\_.(.*)/,"_" cap[1],tmp_str);
			sub(/\\/,"",tmp_str);

			cmd = "echo \x27/NimbusSanL-Bold findfont 18 scalefont setfont (" tmp_str ") stringwidth pop 90 div ==\x27 | gs -dQUIET -sDEVICE=nullpage 2>/dev/null - ";
			#print cmd;
			cmd | getline line_width;
			#print line_width;

			underscores = int((line_max_width - (line_width % line_max_width) + underscore_width) / underscore_width);
			#print underscores;
			under_str =  gensub(/ /, "_", "g", sprintf("%*s", underscores, ""));

			tmp_str = str;
			sub(/\_/,under_str,tmp_str);
			sub(/\\/,"",tmp_str);
			match(tmp_str,/[^_]*_+./,cap);
			#print cap[0];
			build_str = build_str cap[0];

			str = substr(str,match_rstart+match_rlength);
		}
		if(length(build_str) > 0) {
			str = build_str str;
		}

		gsub(/"/,"\\\"",str);
		run("xmlstarlet ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v \"" str "\" temp.svg > temp_pipe.svg");
		run("cat temp_pipe.svg > temp.svg");
		run("rm temp_pipe.svg");
	}
	run("inkscape -z -b white -d 1200 -e out/" NR ".png temp.svg");
	run("rm temp.svg");
}