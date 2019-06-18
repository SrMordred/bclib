module bc.container.array;

import bc.memory : alloc, alloc_zero, release , sys_alloc;

import bc.io : printf;

struct Array(Type, alias allocator = sys_alloc )
{
	Type[] data;
	size_t len;

	Type* ptr(){ return data.ptr; }
	size_t length(){ return len; }
	size_t capacity(){ return data.length; }

	
	this(ref Array other)
	{
		import std.traits : hasIndirections;
		import bc.memory : memcpy;

		static if( hasIndirections!Type )  
			alias _alloc = alloc_zero;
		else
			alias _alloc = alloc;

		immutable other_len = other.length;
		data = _alloc!(Type[], allocator)( other.length );	
		memcpy( data.ptr, other.ptr, other_len * Type.sizeof );
		len = other.len;
	}

	this( Values... )( auto ref Values values )
	{
		import bc.traits:  isRValue;
		import std.math : nextPow2;
		import bc.memory : assign;

		reserve( Values.length );

		static foreach(value ; values)
		{{
			assign!( isRValue!value )( data[len] , value );
			++len;
		}}
	}

	~this()
	{
		import bc.memory : dtor;
		dtor( data[ 0 .. len ] );

		if( data ) 
			release!(allocator)(data);

		data = null;
	}

	void push( Values... )( auto ref Values values )
	{
		import bc.traits:  isRValue;
		import std.math : nextPow2;
		import bc.memory : assign;

		size_t new_len = len + Values.length;

		if( new_len > capacity )
			reserve( nextPow2( new_len ) );

		static foreach(value ; values)
		{{
			assign!( isRValue!value )( data[len], value );
			++len;
		}}
	}

	void pop()
	{
		import std.traits : hasElaborateDestructor;
		import bc.memory : dtor;
		--len;
		data[ len ].dtor;
	}

	void reserve( size_t new_cap )
	{
		import std.traits : hasIndirections;
		import bc.memory : assign;

		//TODO:
		//this should be decided by alloc, or not
		static if( hasIndirections!Type )  
			alias _alloc = alloc_zero;
		else
			alias _alloc = alloc;

		if( capacity() == 0 )
		{
			data = _alloc!(Type[], allocator)( new_cap );	
		}
		else
		{
			auto new_data = _alloc!(Type[], allocator)( new_cap );	
			assign(new_data, data);
			release!(allocator)(data);
			data = new_data;
		}
	}

	ref front(){ return data[0]; }  
	ref back() { return data[len-1]; }  

	ref opIndex( size_t index )
	{
		return data[ index ];
	}

	auto opSlice()
	{
		return data[0 .. len];
	}

	auto opSlice( size_t start, size_t end )
	{
		return data[start .. end];
	}

	auto opDollar(){ return len; }

	
	void toIO(alias IO)()
	{
		import bc.io : printl;

		printl!IO("[");
		if( len )
		{
			foreach(ref val ; data[0 .. len - 1])
			{
				printl!IO(val , ", ");
			}
			printl!IO(data[len-1] );	
		}
		printl!IO("]");
	}

}

auto array( T... )( auto ref T t )
{
	return Array!(T[0])(t);
}

//{	

//	T* ptr;
//	size_t len;
//	size_t cap;

//	/*
//	CTOR/BLIT/DTOR
//	*/

//	/*
//	ctor and put methods uses the same logic.
//	So for now i'm keeping only one code with mixin template tricks
//	*/
//	mixin template __PUT( values... )
//	{
//		bool action = {
//		import bclib.memory : memCopy, memMove, blit;
//		import bclib.traits : isRValue, isTemplateOf, isDArray;
//		import std.traits : TemplateOf;

//		auto new_cap = cap;
//		static foreach(value ; values)
//		{{

//			alias Type = typeof(value);
//			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
//			{
//				new_cap += value.length;
//			}
//			else
//			{
//				new_cap++;
//			}
			
//		}}

//		reserve( new_cap );

//		static foreach(value ; values)
//		{{
//			alias Type = typeof(value);

//			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
//			{
//				auto next_len = value.length;
//				static if( isRValue!value ){
//					memMove( ptr + len, value.ptr, next_len );	
//				} else {
//					memCopy( ptr + len, value.ptr, next_len );	
//					blit(ptr + len);
//				}
//				len+=next_len;
//			}
//			else
//			{
//				static if( isRValue!value ) {
//					memMove( ptr + len, &value );	
//				} else {
//					memCopy( ptr + len, &value );	
//					blit(ptr + len);
//				}

//				++len;
//			}
//		}}
//		return true;
//		}();
//	}

//	this( Values... )( auto ref Values values )
//	{
//		mixin __PUT!values;
//	}

//	this(this)
//	{
//		import bclib.memory : memCopy, blit;
//		auto new_ptr = cast(T*)Alloc.alloc( T.sizeof * len );
//		memCopy( new_ptr, ptr, len );
//		blit( new_ptr, len );
//		ptr = new_ptr;
//		cap = len;
//	}

//	~this()
//    {
//    	import bclib.memory : dtor;
//    	if(ptr)
//    	{
//    		dtor(ptr, len);
//    		Alloc.free(ptr);
//    		ptr = null;
//    	}
//    	len = 0;
//    	cap = 0;
//    }

//	/*
//	RETRIEVE
//	*/

//	size_t length(){ return len; }
//	size_t capacity(){ return cap; }

//	ref opIndex(size_t index)
//	{
//		return ptr[index];
//	}

//	int opApply(scope int delegate(ref T) fun ) 
//    {
//        int result;
//        foreach(i ; 0 .. len)
//        {
//        	result = fun( ptr[i] );
//			if( result ) break;
//        }
//        return result;
//    }

//    int opApply(scope int delegate(size_t, ref T) fun ) 
//    {
//        int result;
//        foreach(i ; 0 .. len)
//        {
//        	result = fun( i, ptr[i] );
//			if( result ) break;
//        }
//        return result;
//    }

//    auto opSlice()
//    {
//    	return ptr[0 .. len];
//    }

//    size_t opDollar()
//    {
//    	return len;
//    }

//	/*
//	CHANGE
//	*/

//	void reserve(size_t size)
//	{
//		//TODO: initialize new memory
//		//HOW? ctor method?
//		import bclib.memory : memCopy;
//		if( size > cap )
//		{
//			auto new_ptr = cast(T*)Alloc.alloc( T.sizeof * size );
//			if( ptr )
//			{
//				memCopy( new_ptr, ptr, len );
//				Alloc.free( ptr );
//			}
//			ptr = new_ptr;
//			cap = size;
//		}
//	}

//	void resize(size_t size)
//	{
//		import bclib.memory : blit, dtor;

//		immutable diff = cast(int)(size - len);
//		import bclib.io;
//		if( diff > 0 )
//		{
//			if( size > cap ) reserve( size );
//			blit(ptr + len, diff);
//			len = size;
//		}
//		else if( diff < 0 )
//		{
//			dtor(ptr + diff , -diff );
//			len = size;
//		}
//	}

//	alias length = resize;

//	void put(Values...)(auto ref Values values)
//	{
//		mixin __PUT!values;
//	}

//	alias opOpAssign(string op : "~") = put;
//	alias push                        = put;

//	void removeIndex( string op = "" )(size_t index)
//	{
//		import bclib.memory : dtor, memMove;

//		if( index < len ) 
//		{
//			dtor( ptr + index );
//			static if( op == "stable" )
//				memMove( ptr + index , ptr + index + 1, len - index - 1 );
//			else
//				memMove( ptr + index, ptr + len - 1 );

//			--len;		
//		}
//	}

//	void removeIndexStable(size_t index)
//	{
//		import bclib.memory : dtor, memMove;

//		dtor( ptr + index );
//		memMove( ptr + index, ptr + len - 1 );

//		--len;	
//	}

//	void removeValue(string op = "", U : T)(auto ref U value)
//	{
//		import bclib.memory : dtor, memMove;

//		foreach(index ; 0 .. len)
//		{
//			if( ptr[index] == value )
//			{
//				dtor( ptr + index );
//				static if( op == "stable" )
//					memMove( ptr + index , ptr + index + 1, len - index - 1 );
//				else
//					memMove( ptr + index, ptr + len - 1 );
//				--len;
//				return;
//			}
//		}
//	}



//	/*
//	OTHER
//	*/

//	auto dup()
//	{
//	}

//	auto opBinary(string op : "~", U)( auto ref U other )
//	{
//		return Array!(T, Alloc)( this, other );
//	}

//	void toIO(alias IO)()
//	{
//		import bclib.io : printl;

//		printl!IO("[ ");
//    	if( len )
//    	{
//    		foreach( i ; 0 .. len - 1 )
//    			printl!IO( ptr[i] , ", " );
//    	}
//    	printl!IO( ptr[len-1] );
//    	printl!IO(" ]");
//	}
//}


