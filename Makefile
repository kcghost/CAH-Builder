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

LINES      := $(shell cat -n media/list | cut -f1 | xargs)
BACKS      := white_back black_back
FACES      := $(LINES) $(BACKS)
TXT_FILES  := $(patsubst %,txt/%,$(LINES))
SVG_BACKS  := $(patsubst %,svg/%.svg,$(BACKS))
MEDIA_BACKS  := $(patsubst %,media/%.svg,$(BACKS))
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

svg: $(SVG_FILES)

$(SVG_BACKS): $(MEDIA_BACKS)
	@mkdir -p svg
	@cp $< $@
	@echo "Copied $@."

svg/%.svg: txt/% media/white_standard.svg media/black_standard.svg media/black_pick2.svg media/black_pick3.svg
	@mkdir -p svg
	@echo "Creating $@..."
	@cat $< | gawk -f svg.awk > $@
	@echo "Created $@."

txt: $(TXT_FILES)

txt/%: media/list
	@mkdir -p txt
	@echo "Creating $@..."
	@head -$* media/list | tail -1 | gawk -f preprocess.awk > $@
	@echo "Created $@."

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
	@rm -fR txt
	@rm -fR svg
	@rm -fR png
	@rm -fR tiff
	@rm -f pre_list
	@rm -f wrap_list
