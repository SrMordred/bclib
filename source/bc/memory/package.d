module bc.memory;

public:
	import core.stdc.stdlib : 
		malloc,
		calloc,
		realloc,
		free;

	import core.stdc.string : 
		memcpy,
		memset;

public import bc.allocator : sys_alloc;

auto alloc( T, alias allocator = sys_alloc )( size_t length = 1)
{
	import std.traits : isDynamicArray;
	import std.range : ElementType;

	static if( isDynamicArray!T )
	{
		alias Element = ElementType!T;
		
		void* ptr = allocator.malloc( Element.sizeof * length );
		return (cast(Element*) ptr)[0 .. length];
	}
	else
	{
		return cast(T*) allocator.malloc( T.sizeof );
	}
}

auto alloc_zero( T, alias allocator = sys_alloc )( size_t length = 1)
{
	import std.traits : isDynamicArray;
	import std.range : ElementType;

	static if( isDynamicArray!T )
	{
		alias Element = ElementType!T;

		void* ptr = allocator.calloc( Element.sizeof * length );
		return (cast(Element*) ptr)[0 .. length];
	}
	else
	{
		return cast(T*) allocator.calloc( T.sizeof );
	}
}

void release( alias allocator = sys_alloc, T )( ref T ptr )
{
	import std.traits : isDynamicArray;
	static if( isDynamicArray!T )
	{
		allocator.free( ptr.ptr );
	}
	else
	{
		allocator.free( ptr );
	}
}

/*
TODO:
1) memcpy may not be the fastest option every time
2) memset must set to zero only parts that matter not the entire value/array
*/
void assign(alias is_r_value = false, Dest, Source )( auto ref Dest dest, auto ref Source source )
{
	pragma(inline, true);

	import bc.traits : isRValue;
	import std.traits : isArray;

	enum is_array   = isArray!Source;

	static if(is_array)
	{
		alias Element = typeof( source[0] );
	}

	auto _ = (){

	static if( is_r_value && is_array )
	{
		pragma(msg, "RVALUE ARRAY");
		memcpy( dest.ptr, source.ptr, Element.sizeof * source.length );
		memset( source.ptr, 0, Element.sizeof * source.length);
	} 
	else static if( is_r_value && !is_array )
	{
		pragma(msg, "RVALUE VALUE");
		memcpy( &dest, &source, Source.sizeof );
		memset( &source, 0, Source.sizeof );
	}
	else static if( !is_r_value && is_array )
	{
		static if( __traits(compiles, dest[0].__ctor( source[0] ) ) )
		{
			pragma(msg, "LVALUE ARRAY COPYCTOR");

			foreach(i, ref val ; source)
				dest[i].__ctor( val );
		}
		else static if( __traits(compiles, dest[0].__xpostblit) )
		{
			pragma(msg, "LVALUE ARRAY POSTBLIT");

			memcpy(dest.ptr, source.ptr, Source.sizeof * source.length);
			foreach(ref val ; dest)
				val.__xpostblit;
		}
		else
		{
			pragma(msg, "LVALUE ARRAY");
			memcpy(dest.ptr, source.ptr, Source.sizeof * source.length);
		}
	}
	else static if( !is_r_value && !is_array )
	{
		static if( __traits(compiles, dest.__ctor( source ) ) )
		{
			pragma(msg, "LVALUE VALUE COPYCTOR");

			dest.__ctor( source );
		}
		else static if( __traits(compiles, dest.__xpostblit) )
		{
			pragma(msg, "LVALUE VALUE POSTBLIT");

			memcpy(&dest, &source, Source.sizeof);
			dest.__xpostblit;
		}
		else
		{
			pragma(msg, "LVALUE VALUE");
			memcpy(&dest, &source, Source.sizeof);
		}
	}
	return null;
	}();
}

void dtor( T )( auto ref T value )
{
	import std.traits : isArray, hasElaborateDestructor;

	static if( isArray!T )
	{
		static if( hasElaborateDestructor!( typeof(value[0]) ) )
		{
			foreach(ref val ; value)
				val.__dtor;
		}
	}
	else
	{
		static if( hasElaborateDestructor!T )
			value.__dtor;		
	}
}