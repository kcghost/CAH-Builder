function run(cmd) {
	if(debug) {
		print cmd;
	} 
	if(exec) {
		system(cmd);
	}
}

function get_run(cmd) {
	if(debug) {
		print cmd;
	} 
	if(exec) {
		while ( (cmd | getline tmp) > 0) { }
		close(cmd); 
		if(debug) {
			print tmp;
		}
	}

	return tmp;
}

{
	debug = "true";
	exec = "true";

	underscore_width = 0.111197919;
	max_line_width = 2.16666666667;
	min_underscores = 6;
	max_underscores = 18;

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
		str = $i;
		#replace special underscores one by one until they are gone
		while(match(str,/\\_./)) {
			#text up to and including underscore plus the character after it
			match(str,/(.*?)\\_(.)(.*)/,cap);
			next_char = cap[2];
			tmp_str = cap[1] "_" next_char;
			rest = cap[3];

			line = "";
			char_index = 1;
			print tmp_str;
			#iterate words, predict line wraps
			while(match(substr(tmp_str,char_index),/([^ ]*)([ ]|$)/,cap)) {
				if(RLENGTH == 0) {
					print line;
					break;
				}
				#evaluate line_width without ending space
				#escape stuff for command line
				arg_str = line cap[1];
				gsub(/"/,"\\\"",arg_str);
				gsub(/\\/,"\\\\\\\\\\",arg_str);

				line_width = get_run("echo \"/NimbusSanL-Bold findfont 18 scalefont setfont ("\
			 		arg_str ") stringwidth pop 90 div ==\" | gs -dQUIET -sDEVICE=nullpage 2>/dev/null - ");
				if(line_width > max_line_width) {
					#start a new line
					print line;
					line = cap[0];
				} else {
					line = line cap[0];
				}

				char_index = char_index + RLENGTH;
			}
			#line is now the last line with the underscore,
			#escape stuff for command line
			arg_str = line;
			gsub(/"/,"\\\"",arg_str);
			gsub(/\\/,"\\\\\\\\\\",arg_str);

			line_width = get_run("echo \"/NimbusSanL-Bold findfont 18 scalefont setfont ("\
		 		arg_str ") stringwidth pop 90 div ==\" | gs -dQUIET -sDEVICE=nullpage 2>/dev/null - ");

			print line_width;
			underscores = int((max_line_width - line_width + underscore_width) / underscore_width);
			print underscores;
			if(underscores < min_underscores) {
				#take up whole line
				underscores = max_underscores;
			}

			under_str =  gensub(/ /, "_", "g", sprintf("%*s", underscores, ""));
			sub(/\\_/,under_str,str);
		}

		#escape quotes for command line
		gsub(/"/,"\\\"",str);
		run("xmlstarlet ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v \"" str "\" temp.svg > temp_pipe.svg");
		run("cat temp_pipe.svg > temp.svg");
		run("rm temp_pipe.svg");
	}
	run("inkscape -z -b white -d 1200 -e out/" NR ".png temp.svg");
	run("rm temp.svg");
}