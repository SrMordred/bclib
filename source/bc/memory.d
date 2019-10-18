module bc.memory;

public import bc.allocator : default_alloc;

auto malloc(Type, alias Allocator = default_alloc)( const size_t size = 1 )
{
	import std.traits : isArray;
	import std.range : ElementType;

	static if( isArray!Type )   
	{
		alias Element = ElementType!Type;
		return ( cast(Element*) Allocator.malloc( Element.sizeof * size ) )[0 .. size];
	}
	else
	{
		return cast(Type*) Allocator.malloc( Type.sizeof );
	}
}

auto calloc(Type, alias Allocator = default_alloc)( const size_t size = 1 )
{
	import std.traits : isArray;
	import std.range : ElementType;

	static if( isArray!Type )   
	{
		alias Element = ElementType!Type;
		return ( cast(Element*) Allocator.calloc( Element.sizeof * size ) )[0 .. size];
	}
	else
	{
		return cast(Type*) Allocator.calloc( Type.sizeof );
	}
}

void free( alias Allocator, Type )( auto ref Type* value )
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

void copyTo( Type )( Type source, Type target )  
{
	import std.traits : isPointer, isArray;
	import std.range : ElementType;
	import core.stdc.string : memcpy;

	static if( isPointer!Type )
		memcpy( target, source, Type.sizeof );
	else static if( isArray!Type )
		memcpy( target.ptr, source.ptr, ElementType!(Type).sizeof * source.length );
	else
		error( "'memCopy' arguments must be both pointers or arrays." );

}

void assignAllTo( Type )( Type[] source, Type[] target )
{
	foreach(index ; 0 .. source.length)
	{
		target[index] = source[index];
	}
}