module bc.memory;

public import bc.allocator : default_alloc;

Type* malloc(alias Allocator = sys_alloc, Type)()
{
	import std.traits : hasIndirections;
	return cast(Type*) Allocator.malloc( Type.sizeof );
}

Type[] malloc(alias Allocator = sys_alloc, Type : Type[])( const size_t size )
{
	import std.traits : hasIndirections;
	return ( cast(Type*) Allocator.malloc( Type.sizeof * size ) )[0 .. size];
}

Type* calloc(alias Allocator = sys_alloc, Type)()
{
	import std.traits : hasIndirections;
	return cast(Type*) Allocator.calloc( Type.sizeof );
}

Type[] calloc(alias Allocator = sys_alloc, Type : Type[])( const size_t size )
{
	import std.traits : hasIndirections;
	return ( cast(Type*) Allocator.calloc( Type.sizeof * size ) )[0 .. size];
}

void release( alias Allocator, Type )( auto ref Type* value )
{
	import std.traits : 
		hasElaborateDestructor;

	if( value !is null)
	{
		static if( hasElaborateDestructor!( Type ) )
		{
			value.__xdtor;	
		}		

		Allocator.free( value );
		value = null;
	}

}

void release( alias Allocator, Type )( ref Type[] value )
{
	import std.traits : 
		hasElaborateDestructor;

	if( value.ptr !is null)
	{
		static if( hasElaborateDestructor!( Type ) )
		{
			foreach(ref val; value)
				val.__xdtor;	
		}		
		Allocator.free( value.ptr );
		value = null;
	}
}

void memZero( Type )( ref Type value ) 
{
	import core.stdc.string : memset;
	memset(&value, 0, Type.sizeof);
}

void memZero( Type  )( Type[] slice ) 
{
	import core.stdc.string : memset;
	memset(slice.ptr, 0, Type.sizeof * slice.length);
}
