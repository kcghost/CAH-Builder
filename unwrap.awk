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

BEGIN {
	RS = ""; 
	FS= "\n";
	ORS = "";
}
NR != 1 {
	print "\n";
}
{
	for(i=1;i<NF;i++) {
		if($i == "\\n") {
			print "\\n\\n";
		} else {
			if($(i+1) == "\\n") {
				print $i;
			} else {
				print $i " ";
			}
		}
	}
	print $i;
}