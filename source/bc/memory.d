module bc.memory;

public import bc.allocator : sys_alloc;

Type* malloc(alias Allocator = sys_alloc, Type)()
{
	import std.traits : hasIndirections;
	return cast(Type*) Allocator.malloc( Type.sizeof );
}

Type* calloc(alias Allocator = sys_alloc, Type)()
{
	import std.traits : hasIndirections;
	return cast(Type*) Allocator.calloc( Type.sizeof );
}

//TODO test if all are pointers;
void release( alias Allocator, Types... )( auto ref Types ptrs )
{
	import std.traits : hasElaborateDestructor, PointerTarget;
	static foreach(ptr ; ptrs)
	{{
		alias Type = PointerTarget!(typeof(ptr));
		if( ptr !is null)
		{
			static if( hasElaborateDestructor!( Type ) )
			{
				ptr.__xdtor;
			}	
			Allocator.free( ptr );
			ptr = null;
		}
	}}
}