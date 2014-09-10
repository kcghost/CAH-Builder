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

out_png: $(wildcard out_svg/*.svg) | out_svg
	@echo "Creating PNG files..."
	@mkdir -p out_png
	@files=$?;\
	if [ "$$files" = "" ];\
	then\
		files=out_svg/*;\
	fi;\
	for file in $$files;\
	do\
		name=$$(basename -s .svg $$file);\
		inkscape -z -b white -d 1200 -e out_png/"$$name".png "$$file" >/dev/null;\
	done
	@touch out_png

out_svg: pre_list
	@echo "Creating SVG files..."
	@mkdir -p out_svg
	@gawk -v out_dir="out_svg" -f svg.awk pre_list
	@cp media/white_back.svg out_svg/
	@cp media/black_back.svg out_svg/

#creates pre_list by doing magical things with single underscores and quotes and things
#also creates a file wrap_list that is a text preview in the wrapped (pdf_list) format. Not needed for the images.
pre_list: media/list
	@echo "Preprocessing list..."
	@gawk -v preview="true" -v out_file="pre_list" -f preprocess.awk media/list > wrap_list

#wrapped format should not be used normally. list contains more useful information (forced newlines) than pdf_list
unwrap: media/pdf_list
	@gawk -f unwrap.awk media/pdf_list > media/list

clean:
	@rm -fR out_png
	@rm -fR out_svg
	@rm -f pre_list
	@rm -f wrap_list
