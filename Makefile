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

FACES      := $(shell cat -n media/list | cut -f1 | xargs) white_back black_back
SVG_FILES  := $(patsubst %,svg/%.svg,$(FACES))
PNG_FILES  := $(patsubst %,png/%.png,$(FACES))
TIFF_FILES := $(patsubst %,tiff/%.tiff,$(FACES))

.PHONY: all clean strip_svg unwrap

tiff: $(TIFF_FILES)

tiff/%.tiff: png/%.png
	@mkdir -p tiff
	@echo "Creating $@..."
#	@convert out/$*.png -set colorspace RGB -profile HPIndigoGlossExp05.icc $@
	@convert $< -set colorspace RGB -colorspace CMYK $@
	@echo "Created $@."

png: $(PNG_FILES)

png/%.png: svg/%.svg
	@mkdir -p png
	@echo "Creating $@..."
	@inkscape -z -b white -d 1200 -e $@ $< >/dev/null
	@echo "Created $@."

$(SVG_FILES): svg

svg: pre_list media/white_standard.svg media/black_standard.svg media/black_pick2.svg media/black_pick3.svg media/white_back.svg media/black_back.svg
	@mkdir -p svg
	@echo "Creating SVG files..."
	@gawk -v out_dir="svg" -f svg.awk pre_list
	@cp media/white_back.svg svg/
	@cp media/black_back.svg svg/
	@echo "Created SVG files."

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

# Wrapped format should not be used normally. pdf_list contains more useful information (forced newlines) than list
unwrap: media/pdf_list
	@gawk -f unwrap.awk media/pdf_list > media/list

clean:
	@rm -fR svg
	@rm -fR png
	@rm -fR tiff
	@rm -f pre_list
	@rm -f wrap_list
