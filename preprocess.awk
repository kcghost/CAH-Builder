@include "util.awk"
BEGIN {
	RS = "\n"; 
	FS= "\\\\n";
	ORS = "\n";
}
NR != 1 && preview {
	print "";
}
{
	#defaults
	if(!out_file) {
		out_file = "pre_list"
	}
	if(!debug) {
		debug = "";
	}
	if(!exec) {
		exec = "true";
	}
	if(!preview) {
		preview = "true";
	}

	underscore_width = 0.111197919;
	max_line_width = 2.16666666667;
	min_underscores = 10;

	total_str;

	for(i=1;i<=NF;i++) {
		str = $i;
		#Make all quotes and apostrophes curly
		gsub(/'/,"’",str);
		str = gensub(/"([^"]*)"/,"“\\1”","g",str);

		#lengthen single underscores.
		#must lengthen the underscore until the character after it (usually a period or a colon) is the last character on the line
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

		if(preview && str == "") {
			print "\\n";
		}

		if(i == 1) {
			total_str = str;
		} else {
			total_str = total_str "\\n" str;
		}
	}
	print total_str >out_file;
}
