module bc.error;

import bc.io : print;

@trusted
void panic(Values...)(Values values)
{
	import core.stdc.stdlib : exit;
	print(values);
	assert(0);
}