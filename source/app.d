
import bc.io : print;

//enum DefaultCopyCtor = `
//this(ref typeof(this) other)
//{
//	foreach (i, ref field; other.tupleof)
//		this.tupleof[i] = field;
//};`;

@trusted struct Dummy
{
	int x;
	int* xx;
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

import bc.container : Dict;


//TODO: ADT pointers 
//TODO: Result and Maybe types
//Some()
//None()
//Ok()
//Err()

//@safe


mixin template Interface()
{

	import bc.traits : 
		getAllMembers, 
		getMember_, 
		isFunction,
		getFunctionReturnType,
		getFunctionParamsType;

	import std.meta : AliasSeq;

	alias Self = typeof(this);

	void* ptr;

	void opAssign( T )(auto ref T other)
	{
		ptr = cast(void*)&other;
	}

	//pragma(msg, getAllMembers!Self );
	mixin( 
		(){
		static foreach( member ; getAllMembers!Self )
		{
			static if( member != "Self" )
			{{
				alias Member = getMember_!( Self , member );	
			
		        static if( isFunction!( Member ) )
		        {{
		            alias ReturnType = getFunctionReturnType!( Member );
		            alias Params     = getFunctionParamsType!( Member );

		            pragma(msg, ReturnType);
		            pragma(msg, Params );

		        }}
			}}
		}
			return "";
		}()
	);


	pragma(msg, typeof(this));
}

import bc.memory;
import bc.container : Array, array;

//extern(C)
@safe
void main()
{
	import std.range;
	import std.array;
	import bc.traits;

	auto arr = array(1,2, [3,4].staticArray , iota( 5 , 7 ), array(7,8) );

	auto arr2 = Array!int();	

	arr2.push(1,2, [3,4].staticArray , iota( 5 , 7 ), array(7,8) );

	print(arr);
	print(arr2);
	




}



