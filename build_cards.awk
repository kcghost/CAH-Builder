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
	#debug = "true";
	exec = "true";
	preview = "true";

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
		#Make all quotes and apostrophes curly
		gsub(/'/,"’",str);
		str = gensub(/"([^"]*)"/,"“\\1”","g",str);

		#lengthen single underscores.
		#must lengthen the underscore until the character after it (usually a period or a colon) is the last character on the line
		if(preview) {
			print str;
		}
		line = "";
		char_index = 1;
		#iterate words, predict line wraps
		while(char_index < length(str)) {
			#TODO: not handling '-' breaks for preview
			match(substr(str,char_index),/([^ ]*)([ ]|$)+/,cap);
			progress = RLENGTH;
			char_index = char_index + progress;

			word = cap[1];
			brk = cap[2];

			#evaluate line_width without ending space
			#escape stuff for command line, eval dynamic underscore as a single underscore
			arg_str = line word;
			gsub(/"/,"\\\"",arg_str);
			gsub(/\\/,"\\\\\\\\\\",arg_str);

			line_width = get_run("echo \"/NimbusSanL-Bold findfont 18 scalefont setfont ("\
		 		arg_str ") stringwidth pop 90 div ==\" | gs -dQUIET -sDEVICE=nullpage 2>/dev/null - ");

			#handle dynamic underscores in word
			if(match(word,/([^_]|^)_([^_]|$)/)) {
				#extend word to end of line
				underscores = int((max_line_width - line_width + underscore_width) / underscore_width);
				if(underscores < min_underscores) {
					#word needs to take up whole line
					#force line to wrap and try again with no progress
					if(preview) {
						print line;
					}
					line = "";
					char_index = char_index - progress;
					continue;
				}
				under_str =  gensub(/ /, "_", "g", sprintf("%*s", underscores, ""));

				str = gensub(/([^_]|^)_([^_]|$)/,"\\1" under_str "\\2",1,str);
				word = gensub(/([^_]|^)_([^_]|$)/,"\\1" under_str "\\2",1,word);

				char_index = char_index + underscores - 1;

				if(preview) {
					line = line word;
					print line;
				}
				#start a new line
				line = "";
			} else {
				if(line_width > max_line_width) {
					#start a new line
					if(preview) {
						print line;
					}
					line = word brk;
				} else {
					line = line word brk;
					#if last line
				}
				if(preview && char_index >= length(str)) {
					print line;
				}
			}
		}
		if(preview) {
			print "";
		}

		#escape quotes for command line
		gsub(/"/,"\\\"",str);
		run("xmlstarlet -q ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v \"" str "\" temp.svg 2>/dev/null > temp_pipe.svg");
		run("cat temp_pipe.svg > temp.svg");
		run("rm temp_pipe.svg");
	}
	run("inkscape -z -b white -d 1200 -e out/" NR ".png temp.svg > /dev/null");
	#run("rm temp.svg");
}