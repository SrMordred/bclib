import bc.io;

//enum DefaultCopyCtor = `
//this(ref typeof(this) other)
//{
//	foreach (i, ref field; other.tupleof)
//		this.tupleof[i] = field;
//};`;

@trusted struct Dummy
{
	int x;
	this(int x)
	{
		this.x = x;
		print("CTOR(", x, ")");
	}

	this(ref Dummy other)
	{
		if (x)
		{
			print("DTOR(", x, ")");
		}

		if (other.x)
		{
			x = other.x;
			print("COPY_CTOR(", x, ")");
		}
	}

	~this()
	{
		if (x)
		{
			print("DTOR(", x, ")");
		}
	}
}

import bc.memory;

struct A{
	int a,b,c;
}





//@safe
void main()
{	
	import std.array;
	import bc.string;

	import bc.io.stdout : stdout;



	//sprintf(stdout, "%d", 100);
	//print( "1 + ".String , " 2 = ".String , " 3!".String );

//pragma(msg, string.stringof);
	//immutable(char)[] ptr = cast(string)malloc!(char[])(100);
	//ptr = cast(string)malloc!(char[])(100);
	

}

