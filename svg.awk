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

BEGIN {
	FS= "\\\\n";
}

{
	#defaults
	if(!debug) {
		debug = "";
	}
	if(!exec) {
		exec = "true";
	}
	file = "";

	quotes_strip = $$0;
	gsub(/"[^"]*"/,"",quotes_strip);

	# English interrogative words: https://www.hopstudios.com/nep/unvarnished/item/list_of_english_question_words
	# Spanish interrogative words: http://www.spanishdict.com/topics/show/48
	# Its a black card if:
	# It contains an interrogative word base (e.g. 'whom' will match because of 'who') in either english or spanish and ends with a question mark
	# It contains one or more _'s
	# Its the 'Make a haiku' card. I was considering detecting the grammar of a 'command' for black,
	# But I still wouldn't have a way of knowing pick 2, pick 3 etc. So I cheated.
	if(match(tolower(quotes_strip),/(who|what|when|where|why|how|which|whither|qué|cómo|dónde|quién|cuál|cuán).+?\?$/) || match($$0,/[_]/) || match(quotes_strip,/haiku/)) {
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
			file = "media/black_pick2.svg";
		} else if(count == 3) {
			file = "media/black_pick3.svg";
		} else {
			file = "media/black_standard.svg";
		}
	} else {
		file = "media/white_standard.svg";
	}

	runstr = "cat " file " ";
	for(i=1;i<=NF;i++) {
		str = $i;

		# Escape quotes for command line
		gsub(/"/,"\\\"",str);
		runstr = runstr " | xmlstarlet -q ed -s \"//*[@id=\x27textArea\x27]\" --type elem -n flowPara -v '" str "'";
	}
	runstr = runstr " 2>/dev/null";
	run(runstr);
}
