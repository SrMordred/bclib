module bclib.memory;

void memCopy( T )( auto ref T* to, auto ref T* from )
{
	import core.stdc.string : memcpy;
	memcpy( to, from, T.sizeof );
}

void memCopy( T )( auto ref T* to, auto ref T* from, size_t len )
{
	import core.stdc.string : memcpy;
	memcpy( to, from, T.sizeof * len );
}

void blit( T )( auto ref T* from )
{
	import std.traits : hasElaborateAssign;

	static if( hasElaborateAssign!T )
		from.__xpostblit;
}

void blit( T )( auto ref T* from, size_t len )
{
	import std.traits : hasElaborateAssign;

	static if( hasElaborateAssign!T )
	{
		foreach(i ; 0 .. len)
			from[i].__xpostblit;
	}
}

void dtor( T )( auto ref T *from )
{
	import std.traits : hasElaborateDestructor;

	static if( hasElaborateDestructor!T )
		from.__xdtor;
}

void dtor( T )( auto ref T* from, size_t len )
{
	import std.traits : hasElaborateDestructor;

	static if( hasElaborateDestructor!T )
	{
		foreach(i ; 0 .. len)
			from[i].__xdtor;
	}
}

/*
Create a RValue
*/
auto move(T)(auto ref T from)
{
	import core.stdc.string : memcpy;

	T rvalue = void;
	memcpy(&rvalue, &from, T.sizeof);

	static immutable T __init = T.init;
	memcpy(&from, cast(T*)&__init, T.sizeof);
	return rvalue;
}

void memMove(T)( auto ref T* to, auto ref T* from )
{
	import std.traits : hasElaborateDestructor;

	memCopy(to, from, T.sizeof);

	if( hasElaborateDestructor!T )
	{
		static immutable T __init = T.init;
		memCopy(from, cast(T*)&__init);
	}
}

void memMove(T)( auto ref T* to, auto ref T* from, size_t len )
{
	import std.traits : hasElaborateDestructor;

	memCopy(to, from, T.sizeof * len);

	if( hasElaborateDestructor!T )
	{
		static immutable T __init = T.init;
		foreach(i; 0 .. len)
			memCopy(from + i, cast(T*)&__init, T.sizeof);
	}
}