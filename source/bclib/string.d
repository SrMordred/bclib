module bclib.string;

import bclib.allocator : sysAlloc;
import bclib.unbug;

struct String(alias Alloc = sysAlloc)
{
	char* ptr;
	size_t len;

	/*
	CTOR/BLIT/DTOR
	*/

	this(string str)
	{
		ptr = cast(char*)Alloc.alloc( str.length + 1 );
		len = str.length;
		ptr[0 .. len] = cast(char[])str[0 .. len];
		ptr[len] = '\0';
	}

	this(String str)
	{
		ptr = cast(char*)Alloc.alloc( str.length + 1 );
		len = str.length;
		ptr[0 .. len] = str[0 .. len];	
		ptr[len] = '\0';
	}

	this(this)
	{
		auto tmp = cast(char*) Alloc.alloc( len + 1 );
		tmp[0 .. len] = ptr[0 .. len];
		ptr = tmp;
		ptr[len] = '\0';
	}

	~this()
	{
		if(ptr)
		{
			Alloc.free(ptr);
			len = 0;
		}
	}

	/*
	RETRIEVE
	*/

	size_t length(){ return len; }
	alias capacity = length;

	auto opSlice( size_t start, size_t end )
	{
		return ptr[start .. end];
	}

	auto opSlice()
	{
		return ptr[0 .. len];
	}

	auto opDollar()
	{
		return len;
	}

	/*
	CHANGE
	*/

	void resize( size_t size )
	{
		if( size > len )
		{
			auto new_ptr = cast(char*)Alloc.alloc( size + 1 );
			if(ptr)
			{
				new_ptr[0 .. len] = ptr[0 .. len];
				Alloc.free(ptr);
			}
			ptr = new_ptr;

			auto spaces = size - len;
			import core.stdc.string : memset;
			memset(ptr + len, ' ', spaces);

			len = size;
			ptr[len] = '\0';
		}
	}

	alias length = resize;

	void put(Value)(auto ref Value value)
	{
		auto new_len        = len + value.length;
		auto tmp            = cast(char*)Alloc.alloc(new_len + 1);
		tmp[0 .. len]       = ptr[0 .. len];
		tmp[len .. new_len] = value[0 .. $];
		Alloc.free(ptr);
		ptr = tmp;
		len = new_len;
		ptr[len] = '\0';
	}

	alias opOpAssign(string op : "~") = put;
	
	/*
	OTHER
	*/
	void toIO(alias IO)()
	{
		IO.put(ptr[0 .. len]);
	}

}
alias Str = String!();