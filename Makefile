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

LINES       := $(shell cat -n media/list | cut -f1 | xargs)
FACES       := $(LINES) white_back black_back
TMP_FILES   := $(patsubst %,tmp/%,$(LINES))
TXT_FILES   := $(patsubst %,txt/%,$(LINES))
PRE_FILES   := $(patsubst %,pre/%,$(LINES))
WRAP_FILES  := $(patsubst %,wrap/%,$(LINES))
SVG_FILES   := $(patsubst %,svg/%.svg,$(FACES))
PNG_FILES   := $(patsubst %,png/%.png,$(FACES))
TIFF_FILES  := $(patsubst %,tiff/%.tiff,$(FACES))

# Check updates to TXT_FILES on every run.
# They depend on the lines of media/list, but using media/list directly as a dependency 
# would cause make to rebuild all files when a single line of media/list has changed.
# need to update the modification date of ONLY the TXT_FILES whose corresponding
# lines in media/list have changed.
$(shell mkdir -p tmp; gawk '{ print > "tmp/" NR }' media/list; rsync -cr tmp/ txt/)

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
	@inkscape -z -b white -d 2438 -e $@ $< >/dev/null
	@echo "Created $@."

svg: $(SVG_FILES)

svg/%_back.svg: media/%_back.svg
	@mkdir -p svg
	@cp $< $@
	@echo "Copied $@."

svg/%.svg: pre/% media/white_standard.svg media/black_standard.svg media/black_pick2.svg media/black_pick3.svg
	@mkdir -p svg
	@echo "Creating $@..."
	@cat $< | gawk -f svg.awk > $@
	@echo "Created $@."

wrap_list: $(WRAP_FILES)
	@echo "Creating $@..."
	@gawk 'NR!=1&&FNR==1{print ""}{print}' $(WRAP_FILES) > wrap_list
	@echo "Created $@."

pre: $(PRE_FILES)

# Creates preprocessed text by doing magical things with single underscores and quotes and things
# Also creates a file wrapped version that is a text preview in the wrapped (pdf_list) format. Not needed for the images.
pre/% wrap/%: txt/%
	@mkdir -p pre
	@mkdir -p wrap
	@echo "Creating pre/$*,wrap/$*..."
	@gawk -v preview="wrap/$*" -f preprocess.awk < $< > pre/$*
	@echo "Created pre/$*,wrap/$*."

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
	@rm -fR tmp
	@rm -fR txt
	@rm -fR wrap
	@rm -fR pre
	@rm -fR svg
	@rm -fR png
	@rm -fR tiff
	@rm -f pre_list
	@rm -f wrap_list
