
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

struct ITeste
{
	mixin Interface;

	ref int showme( int x );
	void showme2( int x, int y );
}

struct T1{
	int a;
	void showme2(){ 
		print("T1 showme2",a);
	}
}

struct T2{
	int a,b;
	void showme2(){ 
		print("T2 showme2",a,b);
	}
}

//static foreach( i; 0 .. 10 )
//{{
//	enum teste;
//}}





import bc.memory.allocator;




void nullMe( ref int[] slice )
{
	slice = null;
}

//extern(C)
void main()
{	
	static foreach(u; __traits(getUnitTests, bc.memory.allocator )) {
		u();
	}

	static foreach(u; __traits(getUnitTests, bc.memory.box )) {
		u();
	}




	//auto x = teste.make;

	//{
	//	print("oi");
	//}

	//import std.array : staticArray;
	//import std.range : iota;

	//import bc.traits;
	//import bc.memory;
	//import std.array : staticArray;
	//import bc.adt;
	//import bc.match;

	//import core.stdc.stdlib : _calloc = calloc;

	//T1 t1;
	//T2 t2;


	//alias F = void function();

	//auto ptr = cast(F)(&ITeste().showme2).funcptr;

	//t1.a = 123;

	//void delegate() ptr2;

	//ptr2.funcptr = ptr;
	//ptr2.ptr = &t1;

	//ptr2();

	//auto ptr2 = cast(void delegate()) ptr;

	//ptr();
	

	//x.x= 10;
	//x.showme();

	//ITeste ptr;

	//T1 t1;
	//T2 t2;

	//alias Fun = void function(ITeste*);

	//Fun showme = cast(Fun)(&(ITeste().showme2)).funcptr;

	//pragma(msg, typeof(showme));
	//showme(cast(ITeste*)&t1);

	//ptr = t1;

	//ptr.showme2();

	//ADT!(int, float) type;


	//type.match!(
	//	(float x) => print("float : ",x),
	//	(int x) => print("int : ", x),
	//);



}

