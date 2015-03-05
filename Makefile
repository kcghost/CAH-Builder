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

TIFFS := $(patsubst svg/%.svg,out/%.tiff,$(wildcard svg/*.svg))

.PHONY: all clean strip_svg unwrap

all: pre_list svg $(TIFFS)

out/%.tiff: svg/%.svg
	@mkdir -p out
	@echo "Creating $@..."
	@inkscape -z -b white -d 1200 -e out/$*.png $< >/dev/null
#	@convert out/$*.png -set colorspace RGB -profile HPIndigoGlossExp05.icc $@
	@convert out/$*.png -set colorspace RGB -colorspace CMYK $@
#	@rm -f out/$*.png
	@echo "Created $@."

svg: pre_list media/white_standard.svg media/black_standard.svg media/black_pick2.svg media/black_pick3.svg media/white_back.svg media/black_back.svg
	@echo "Creating SVG files..."
	@mkdir -p svg
	@gawk -v out_dir="svg" -f svg.awk pre_list
	@cp media/white_back.svg svg/
	@cp media/black_back.svg svg/
	@echo "Created SVG files."
# Need recursive make since TIFFS var will need to be updated at this point
	@$(MAKE) all --no-print-directory

# Creates pre_list by doing magical things with single underscores and quotes and things
# Also creates a file wrap_list that is a text preview in the wrapped (pdf_list) format. Not needed for the images.
pre_list: media/list
	@echo "Preprocessing list..."
	@gawk -v preview="true" -v out_file="pre_list" -f preprocess.awk media/list > wrap_list
	@echo "List preprocessed."

# Re-export inkscape svgs in media to plain svgs
strip_svg: media/white_standard.svg media/black_standard.svg media/black_pick2.svg media/black_pick3.svg
	@inkscape -l media/white_standard.svg media/white_standard.svg
	@inkscape -l media/black_standard.svg media/black_standard.svg
	@inkscape -l media/black_pick2.svg media/black_pick2.svg
	@inkscape -l media/black_pick3.svg media/black_pick3.svg

# Wrapped format should not be used normally. list contains more useful information (forced newlines) than pdf_list
unwrap: media/pdf_list
	@gawk -f unwrap.awk media/pdf_list > media/list

clean:
	@rm -fR out
	@rm -fR svg
	@rm -f pre_list
	@rm -f wrap_list
