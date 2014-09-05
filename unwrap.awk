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