module bc.string;

import bc.memory : default_alloc;


//struct TString(alias allocator = default_alloc)
//{
//	import bc.memory : Box;

//	Box!(char[]) __data;

//	this( immutable(char[]) str )
//	{
		
//		//__data = 
//	}	
//}

//alias String = TString!();




//import bc.memory : alloc, alloc_zero, release , sys_alloc;

//import bc.io : printf;

//struct String
//{
//	alias allocator = sys_alloc;
//	alias Type      = char;
//	alias SelfType  = String;

//	Type[] data;
//	size_t len;


//	char* ptr(){ return data.ptr; }
//	size_t length(){ return len; }
//	size_t capacity(){ return data.length; }

//	this(ref SelfType other)
//	{
//		import std.traits : hasIndirections;
//		import bc.memory : memcpy;

//		static if( hasIndirections!Type )  
//			alias _alloc = alloc_zero;
//		else
//			alias _alloc = alloc;

//		immutable other_len = other.length;

//		/*
//		need to cast because of bug
//		https://issues.dlang.org/show_bug.cgi?id=19960
//		*/
//		data = cast(Type[])_alloc!(Type[], allocator)( other.length + 1 );	
//		memcpy( data.ptr, other.ptr, other_len * Type.sizeof );
//		len = other.len;
//		data[len] = 0;
//	}

//	this( Values... )( auto ref Values values )
//	{
//		import bc.traits:  isRValue;
//		import std.math : nextPow2;
//		import bc.memory : assign;

//		size_t new_cap = 0;
//		foreach( ref val ; values ) new_cap+= val.length;
//		reserve( new_cap );
	
//		static foreach(value ; values)
//		{{
//			assign!(isRValue!value)( data[len .. $] , value );
//			len += value.length;
//		}}
//	}

//	~this()
//	{
//		if( data ) 
//			release!(allocator)(data);

//		data = null;
//	}

//	void push( Values... )( auto ref Values values )
//	{
//		import bc.traits:  isRValue;
//		import std.math : nextPow2;
//		import bc.memory : assign;

//		size_t new_len = len;

//		static foreach(value ; values)
//		{
//			new_len += value.length;
//		}

//		if( new_len > capacity )
//			reserve( new_len );

//		static foreach(value ; values)
//		{{
//			assign!(isRValue!value)( data[len .. $] , value );
//			len += value.length;
//		}}
//	}

//	void pop()
//	{
//		import std.traits : hasElaborateDestructor;
//		import bc.memory : dtor;
//		--len;
//		data[ len ].dtor;
//	}

//	void reserve( size_t new_cap )
//	{
//		import std.traits : hasIndirections;
//		import bc.memory : memcpy;

//		//TODO:
//		//this should be decided by alloc .. or not ?
//		static if( hasIndirections!Type )  
//			alias _alloc = alloc_zero;
//		else
//			alias _alloc = alloc;

//		if( capacity() == 0 )
//		{
//			//look bug above
//			data = cast(Type[])_alloc!(Type[], allocator)( new_cap + 1 );	
//			data[new_cap] = 0;
//		}
//		else
//		{
//			//look bug above
//			auto new_data = cast(Type[])_alloc!(Type[], allocator)( new_cap + 1 );	
//			memcpy( new_data.ptr, data.ptr, Type.sizeof * len );
//			release!(allocator)(data);
//			data = new_data;
//			data[ new_cap ] = 0;
//		}
//	}

//	ref front(){ return data[0]; }  
//	ref back() { return data[len-1]; }  

//	ref opIndex( size_t index )
//	{
//		return data[ index ];
//	}

//	auto opSlice()
//	{
//		return data[0 .. len];
//	}

//	auto opSlice( size_t start, size_t end )
//	{
//		return data[start .. end];
//	}

//	String opBinary(alias op = "~", T)( auto ref T other )
//	{
//		return String( this, other );
//	}

//	void opOpAssign( string op = "~", T )( auto ref T other )
//	{
//		push( other );
//	}

//	auto opDollar(){ return len; }

	
//	void toIO(alias IO)()
//	{
//		import bc.io : printl;

//		printl!IO( cast(string)data );
//	}

	

//}

//auto str(T... )( auto ref T t )
//{
//	return String(t);
//}

