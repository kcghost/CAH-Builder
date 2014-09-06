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