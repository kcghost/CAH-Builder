# Copyright (C) 2014 Casey Fitzpatrick

# This file is part of CAH Builder.
# 
# CAH Builder is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# CAH Builder is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with CAH Builder.  If not, see <http://www.gnu.org/licenses/>.

@include "util.awk"

function get_length(arg_str) {
	#line_width = get_run("echo \"/NimbusSanL-Bold findfont 18 scalefont setfont ("\
	#	 arg_str ") stringwidth pop 90 div ==\" | gs -dQUIET -sDEVICE=nullpage 2>/dev/null - ");
	#return line_width;
	px_width = get_run("echo '<svg><flowRoot id=\"id1\" xml:space=\"preserve\" " \
		"style=\"font-size:18px;font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;" \
		"text-align:start;line-height:125%;writing-mode:lr-tb;text-anchor:start;font-family:Nimbus Sans L;-inkscape-font-specification:Nimbus Sans L Bold\">" \
		arg_str "</flowRoot></svg>' | inkscape --without-gui --query-id=id1 -W /dev/stdin 2>/dev/null");
	if(debug) {
		print px_width / 90;
	}
	return px_width / 90;
}

BEGIN {
	RS = "\n"; 
	FS= "\\\\n";
	ORS = "\n";
}

{
	#defaults
	if(!debug) {
		debug = "";
	}
	if(!exec) {
		exec = "true";
	}
	if(!preview) {
		preview = "";
	}

	#width of additional underscore to existing 10 underscores
	underscore_width = 0.11132811111; 
	#used to be 174.39761 (text area width) / 90 (1.937751222), but Inkscape adds/subtracts space in front of the line for some characters
	#Using trial and error, using the width of string of "I'm sorry, Professor," (an edge case) to make sure it wraps
	max_line_width = 1.920;
	min_underscores = 10;

	total_str = "";

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

			word = cap[1];
			brk = cap[2];

			#evaluate line_width without ending space
			#eval line_width with min_underscores
			#escape stuff for command line, eval dynamic underscore as a single underscore
			arg_str = line word;
			under_str =  gensub(/ /, "_", "g", sprintf("%*s", min_underscores, ""));
			arg_str = gensub(/([^_]|^)_([^_]|$)/,"\\1" under_str "\\2",1,arg_str);
			gsub(/"/,"\\\"",arg_str);
			gsub(/\\/,"\\\\\\\\\\",arg_str);
			#eval with a space at the end, inkscape line wrap seems to calc that way
			#arg_str = arg_str " ";

			line_width = get_length(arg_str);

			if(line_width >= max_line_width) {
				#start a new line
				if(preview) {
					print line >preview;
				}
				line = "";
				continue;
			}
			if(match(word,/([^_]|^)_([^_]|$)/)) {
				#handle dynamic underscores in word
				#extend word to end of line
				underscores = ((max_line_width - line_width) / underscore_width);
				#inkscape's wrapping is a little lenient with underscores for some reason, rounding up if its close
				if(underscores % 1 > 0.9) {
					underscores = underscores + 1;
				}
				underscores = int(underscores);
				#print ((max_line_width - line_width) / underscore_width);

				under_str =  gensub(/ /, "_", "g", sprintf("%*s", underscores + min_underscores, ""));
				str = gensub(/([^_]|^)_([^_]|$)/,"\\1" under_str "\\2",1,str);
				word = gensub(/([^_]|^)_([^_]|$)/,"\\1" under_str "\\2",1,word);

				char_index = char_index + progress + min_underscores + underscores - 1;

				if(preview) {
					line = line word;
					print line >preview;
				}
				#start a new line
				line = "";
				continue;
			} 

			#normal progress
			line = line word brk;
			char_index = char_index + progress;
			#if last line
			if(preview && char_index >= length(str)) {
				print line >preview;
			}
		}

		if(preview && str == "") {
			print "\\n" >preview;
		}

		if(i == 1) {
			total_str = str;
		} else {
			total_str = total_str "\\n" str;
		}
	}
	print total_str;
}
