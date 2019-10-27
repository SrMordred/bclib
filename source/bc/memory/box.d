module bc.memory.box;

import bc.memory.allocator : default_alloc;
import bc.error : panic;

struct Box(Type, alias Allocator = default_alloc)
{
	import std.traits : isArray, Select, Unqual;
	import std.range : ElementType;

	alias IsArray = isArray!Type;
	alias DataType = Select!( IsArray , Type, Type* );

	DataType ptr;

	/*
		Constructors, Destructors, Assign, and Free Boxes
	*/

	this(Type value)
	{
		import std.algorithm : moveEmplace, moveEmplaceAll;
		import bc.memory : malloc, moveTo;

		import std.traits : ReturnType;

		static if( IsArray )
		{
			ptr = malloc!(Type, Allocator)( value.length );
			value.moveTo(ptr);
		}
		else
		{
			ptr = malloc!(Type, Allocator);
			value.moveTo( *ptr );			
		}
	}

	static fromPtr( DataType ptr )
	{
		Box!( Type, Allocator ) tmp;
		tmp.ptr = ptr;
		return tmp;
	}

	@disable this(this);
	/*
		Nice discovery:
		Since copy is disable, this only work with rvalues
		var1 = box( value ); //fine
		var1 = var2; //nop!
	*/
	void opAssign( Box other )
	{	
		import bc.traits : hasElaborateDestructor;
		import bc.memory : moveTo;
		if( this ) free();
		other.moveTo( this );
	}

	~this()
	{
		free();
	}

	void free()
	{
		import bc.memory : _free = free, destructor;
		if ( this )
		{
			static if(IsArray)
				destructor(ptr);
			else
				destructor(*ptr);

			_free!(Allocator)(ptr);
		}
	}

	Box dup()
	{
		static if( IsArray )
		{
			import std.algorithm : move;
			import bc.memory : assignAllTo, calloc;

			Box!( Type, Allocator ) new_box;

			if( ptr.length )
			{
				auto new_ptr = calloc!(Type, Allocator)( ptr.length );
				ptr.assignAllTo( new_ptr );
				new_box.ptr = new_ptr;
			}

			return new_box;
		}
		else
			return Box!( Type, Allocator )( *ptr );
	}

	static if( IsArray )
	{
		import bc.memory : calloc, copyTo, _free = free;
		void reserve( size_t size )
		{
			if( size > ptr.length )
			{
				//TODO: every calloc call can be replaced with malloc call if the type don´t have indirections
				auto tmp = calloc!(Type, Allocator)( size );
				ptr.copyTo( tmp );
				free();
				ptr = tmp;
			}
		}
		
		size_t opDollar(){ return ptr.length; }
		alias capacity = opDollar;

		ref  opIndex( size_t index ) { return ptr[ index ]; }
		auto opSlice() { return ptr[0 .. $]; }
		auto opSlice(size_t start, size_t end) { return ptr[start .. end]; }

	}

	/*
		Internal data access functions
	*/
	bool opCast()
	{
		return ptr !is null;
	}

	ref opUnary( string op: "*")()
	{
		static if( IsArray ) return ptr;
		else return *ptr;
	}
	
	auto getOr(Type default_value)
	{
		if ( this )
		{
			static if( IsArray ) return ptr;
			else return *ptr;
		}
		else
		{
			return default_value;
		}
	}

	/*
		Change box ownership
	*/
	auto move()
	{
		import std.algorithm : move_ = move;
		return move_(this);
	}

	auto releasePtr()
	{
		auto tmp = ptr;
		ptr = null;
		return tmp;
	}
}

struct box
{
	static opCall(Type, alias Allocator = default_alloc)(auto ref Type value)
	{
		import std.functional : forward;
		return Box!(Type, Allocator)(forward!value);	
	}
	static fromPtr(Type, alias Allocator = default_alloc)(Type* value)
	{
		return Box!(Type, Allocator).fromPtr( value );
	}
}
