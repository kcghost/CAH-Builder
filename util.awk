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