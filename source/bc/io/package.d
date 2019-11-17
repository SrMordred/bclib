module bc.io;

public:
	import bc.io.print;


import core.stdc.stdlib : exit;

void stdoutFlush(){
	import core.stdc.stdio;
	stdout.fflush();
}