module bc.string;

//import bclib.allocator : sysAlloc;
//import bclib.unbug;

//struct String(alias Alloc = sysAlloc)
//{
//	char* ptr;
//	size_t len;

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
//		import bclib.traits : isRValue, isTemplateOf;
//		import std.traits : TemplateOf;


//		auto new_cap = len;
//		static foreach(value ; values)
//		{{

//			alias Type = typeof(value);
//			pragma(msg, Type);
//			static if( 	is( Type == string ) || 
//						isTemplateOf!( Type, TemplateOf!String ) ||
//						is( type == char[] ) )
//			{
//				new_cap += value.length;
//			}
//			else static if(is(Type == char))
//			{
//				new_cap++;
//			}
			
//		}}

//		auto old_len = len;
//		resize( new_cap );
//		len = old_len;

//		static foreach(value ; values)
//		{{
//			alias Type = typeof(value);

//			static if( 	is( Type == string ) || 
//						isTemplateOf!( Type, TemplateOf!String ) ||
//						is( type == char[] ) )
//			{
//				auto next_len = value.length;
//				static if( isRValue!value ){
//					memMove( ptr + len, cast(char*)value.ptr, next_len );	
//				} else {
//					memCopy( ptr + len, value.ptr, next_len );	
//					blit(ptr + len);
//				}
//				len+=next_len;
//			}
//			else static if(is(Type == char))
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
//		ptr[len] = '\0';

//		return true;
//		}();
//	}

//	this( Values... )( auto ref Values values )
//	{
//		mixin __PUT!values;
//	}

//	this(this)
//	{
//		import bclib.memory : memCopy;
//		auto new_ptr = cast(char*) Alloc.alloc( len + 1 );
//		memCopy(new_ptr, ptr, len);
//		ptr = new_ptr;
//		ptr[len] = '\0';
//	}

//	~this()
//	{
//    	if(ptr)
//    	{
//    		Alloc.free(ptr);
//    		ptr = null;
//    	}
//    	len = 0;
//	}

//	/*
//	RETRIEVE
//	*/

//	size_t length(){ return len; }
//	alias capacity = length;

//	auto opSlice( size_t start, size_t end )
//	{
//		return ptr[start .. end];
//	}

//	auto opSlice()
//	{
//		return ptr[0 .. len];
//	}

//	auto opDollar()
//	{
//		return len;
//	}

//	/*
//	CHANGE
//	*/

//	void resize( size_t size )
//	{
//	import bclib.memory : memCopy;

//		if( size > len )
//		{
//			auto new_ptr = cast(char*)Alloc.alloc( size + 1 );
//			if(ptr)
//			{
//				memCopy( new_ptr, ptr, len );
//				Alloc.free(ptr);
//			}
//			ptr = new_ptr;

//			auto spaces = size - len;
//			import core.stdc.string : memset;
//			memset(ptr + len, ' ', spaces);

//			len = size;
//			ptr[len] = '\0';
//		}
//	}

//	alias length = resize;

//	void put(Values...)(auto ref Values values)
//	{
//		mixin __PUT!values;
//	}

//	alias opOpAssign(string op : "~") = put;
	
//	/*
//	OTHER
//	*/
//	void toIO(alias IO)()
//	{
//		IO.put(ptr[0 .. len]);
//	}

//	auto opBinary(string op : "~", U)( auto ref U other )
//	{
//		return String!(Alloc)( this, other );
//	}

//}
//alias Str = String!();