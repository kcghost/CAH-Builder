out_png: out_svg
	@echo "Creating PNG files..."
	@mkdir -p out_png
	@for file in out_svg/*;\
	do\
		name=$$(basename -s .svg $$file);\
		inkscape -z -b white -d 1200 -e out_png/"$$name".png "$$file" >/dev/null;\
	done

out_svg: pre_list
	@echo "Creating SVG files..."
	@mkdir -p out_svg
	@gawk -v out_dir="out_svg" -f svg.awk pre_list

#creates pre_list by doing magical things with single underscores and quotes and things
#also creates a file wrap_list that is a text preview in the wrapped (pdf_list) format. Not needed for the images.
pre_list: list
	@echo "Preprocessing list..."
	@gawk -v preview="true" -v out_file="pre_list" -f preprocess.awk list > wrap_list

#wrapped format should not be used normally. list contains more useful information (forced newlines) than pdf_list
unwrap: pdf_list
	@gawk -f unwrap.awk pdf_list > list

clean:
	@rm -fR out_png
	@rm -fR out_svg
	@rm -f pre_list
	@rm -f wrap_list
