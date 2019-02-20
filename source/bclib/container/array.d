module bclib.container.array;

import bclib.allocator : sysAlloc;
import bclib.io : print;

struct Array(T, alias Alloc = sysAlloc )
{	

	import bclib.traits : isDArray, isTemplateOf;

	T* ptr;
	size_t len;
	size_t cap;

	/*
	CTOR/BLIT/DTOR
	*/

	this( Values... )( auto ref Values values )
	{
		import bclib.memory : memCopy, memMove, blit;
		import bclib.traits : isRValue;
		import std.traits : TemplateOf;

		auto new_cap = 0;
		static foreach(value ; values)
		{{

			alias Type = typeof(value);
			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
			{
				new_cap += value.length;
			}
			else
			{
				new_cap++;
			}
			
		}}

		reserve( new_cap );

		static foreach(value ; values)
		{{
			alias Type = typeof(value);

			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
			{
				auto next_len = value.length;
				static if( isRValue!value ){
					memMove( ptr + len, value.ptr, next_len );	
				} else {
					memCopy( ptr + len, value.ptr, next_len );	
					blit(ptr + len);
				}
				len+=next_len;
			}
			else
			{
				static if( isRValue!value ) {
					memMove( ptr + len, &value );	
				} else {
					memCopy( ptr + len, &value );	
					blit(ptr + len);
				}

				++len;
			}
		}}
	}

	this(this)
	{
		import bclib.memory : memCopy, blit;
		auto new_ptr = cast(T*)Alloc.alloc( T.sizeof * len );
		memCopy( new_ptr, ptr, len );
		blit( new_ptr, len );
		cap = len;
	}

	~this()
    {
    	import bclib.memory : dtor;
    	if(ptr)
    	{
    		dtor(ptr, len);
    		Alloc.free(ptr);
    		ptr = null;
    	}
    	len = 0;
    	cap = 0;
    }

	/*
	RETRIEVE
	*/

	size_t length(){ return len; }
	size_t capacity(){ return cap; }

	ref opIndex(size_t index)
	{
		return ptr[index];
	}

	int opApply(scope int delegate(ref T) fun ) 
    {
        int result;
        foreach(i ; 0 .. len)
        {
        	result = fun( ptr[i] );
			if( result ) break;
        }
        return result;
    }

    int opApply(scope int delegate(size_t, ref T) fun ) 
    {
        int result;
        foreach(i ; 0 .. len)
        {
        	result = fun( i, ptr[i] );
			if( result ) break;
        }
        return result;
    }

    auto opSlice()
    {
    	return ptr[0 .. len];
    }

    size_t opDollar()
    {
    	return len;
    }

	/*
	CHANGE
	*/

	void reserve(size_t size)
	{
		import bclib.memory : memCopy;
		if( size > cap )
		{
			auto new_ptr = cast(T*)Alloc.alloc( T.sizeof * size );
			if( ptr )
			{
				memCopy( new_ptr, ptr, len );
				Alloc.free( ptr );
			}
			ptr = new_ptr;
			cap = size;
		}
	}

	void resize(size_t size)
	{

	}

	alias length = resize;

	void put(Values...)(auto ref Values values)
	{
		import bclib.memory : memCopy, memMove, blit;
		import bclib.traits : isRValue;
		import std.traits : TemplateOf;

		auto new_cap = cap;
		static foreach(value ; values)
		{{
			alias Type = typeof(value);
			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
			{
				new_cap += value.length;
			}
			else
			{
				new_cap++;
			}
			
		}}

		reserve( new_cap );

		static foreach(value ; values)
		{{
			alias Type = typeof(value);

			static if( isDArray!Type || isTemplateOf!( Type, TemplateOf!Array ) )
			{
				auto next_len = value.length;
				static if( isRValue!value ){
					memMove( ptr + len, value.ptr, next_len );	
				} else {
					memCopy( ptr + len, value.ptr, next_len );	
					blit(ptr + len);
				}
				len+=next_len;
			}
			else
			{
				static if( isRValue!value ) {
					memMove( ptr + len, &value );	
				} else {
					memCopy( ptr + len, &value );	
					(ptr + len).blit;
				}

				++len;
			}
		}}
	}

	alias opOpAssign(string op : "~") = put;
	alias push                        = put;

	void removeIndex( string op = "" )(size_t index)
	{
		import bclib.memory : dtor, memMove;

		if( index < len ) 
		{
			dtor( ptr + index );
			static if( op == "stable" )
				memMove( ptr + index , ptr + index + 1, len - index - 1 );
			else
				memMove( ptr + index, ptr + len - 1 );

			--len;		
		}
	}

	void removeIndexStable(size_t index)
	{
		import bclib.memory : dtor, memMove;

		dtor( ptr + index );
		memMove( ptr + index, ptr + len - 1 );

		--len;	
	}

	void removeValue(string op = "", U : T)(auto ref U value)
	{
		import bclib.memory : dtor, memMove;

		foreach(index ; 0 .. len)
		{
			if( ptr[index] == value )
			{
				dtor( ptr + index );
				static if( op == "stable" )
					memMove( ptr + index , ptr + index + 1, len - index - 1 );
				else
					memMove( ptr + index, ptr + len - 1 );
				--len;
				return;
			}
		}
	}



	/*
	OTHER
	*/

	auto dup()
	{
	}

	auto opBinary(string op : "~", U)( auto ref U other )
	{
		return Array!T( this, other );
	}

	void toIO(alias IO)()
	{
		import bclib.io : printl;

		printl!IO("[ ");
    	if( len )
    	{
    		foreach( i ; 0 .. len - 1 )
    			printl!IO( ptr[i] , ", " );
    	}
    	printl!IO( ptr[len-1] );
    	printl!IO(" ]");
	}
}


