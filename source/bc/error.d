module bc.error;

import bc.io : print;

auto panic(Values...)(Values values)
{
	import core.stdc.stdlib : exit;
	print(values);
	exit(0);
	return null;
}