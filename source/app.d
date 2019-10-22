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

struct String
{
	import bc.memory : Box;

	Box!(string) ptr;

	size_t length(){ return ptr.capacity; }

	this(Type)(Type str){
		ptr = box(str[]);
	}

	String dup()
	{
		String tmp;
		tmp.ptr = ptr.dup;
		return tmp;
	}

	String opBinary(alias op = "~", T)( auto ref T other )
		if( is(T == String) || is(T == string) )
	{
		import bc.memory : copyTo;

		String new_string;
		new_string.resize( length + other.length );
		ptr[].copyTo( new_string[] );
		other[].copyTo( new_string[length .. $] );
		return new_string;
	}

	void opOpAssign( string op = "~", T )( auto ref T other )
		if( is(T == String) || is(T == string) )
	{
		auto start = length;
		ptr.resize( length + other.length );
		other[].copyTo( ptr[start .. $] );
	}

	void resize(size_t size){ ptr.resize(size); }

	auto opSlice(){ return ptr.opSlice(); }
	auto opSlice( size_t start, size_t end ){ return ptr.opSlice(start , end); }
	auto opDollar(){ return ptr.opDollar(); }

}


//@safe
void main()
{
	
	String x = "1 + ".String ~ " 2 = ".String ~ " 3!".String;
	//print( "1 + ".String , " 2 = ".String , " 3!".String );

//pragma(msg, string.stringof);
	//immutable(char)[] ptr = cast(string)malloc!(char[])(100);
	//ptr = cast(string)malloc!(char[])(100);
	

}

