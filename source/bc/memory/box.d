module bc.memory.box;

import bc.memory.allocator : default_alloc;
import bc.error : panic;

@trusted struct Box(Type, alias Allocator = default_alloc)
{
	
	import std.traits : isArray, Select;
	import std.range : ElementType;

	alias IsArray = isArray!Type;

	alias DataType = Select!( IsArray , Type, Type* );

	DataType data;

	this(Type value)
	{
		import std.algorithm : moveEmplace, moveEmplaceAll;
		import bc.memory : malloc;

		static if( IsArray )
		{
			data = malloc!(Type, Allocator)( value.length );
			value.moveEmplaceAll(data);
		}
		else
		{
			data = malloc!(Type, Allocator);
			value.moveEmplace(*data);			
		}
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
		import std.algorithm : moveEmplace;
		if( data !is null ) free();
		other.moveEmplace( this );
	}

	@system
	ref opUnary( string op: "*")()
	{
		static if( IsArray )   return data;
		else return *data;
	}

	Box dup()
	{
		static if( IsArray )
		{
			import std.algorithm : move;
			import bc.memory : assignAllTo;

			auto new_data = calloc!(Type, Allocator)( data.length );
			data.assignAllTo( new_data );

			Box!( Type, Allocator ) new_box;
			new_box.data = new_data;
			return new_box;
		}
		else
			return Box!( Type, Allocator )( *data );
	}

	~this()
	{
		import bc.memory : free;

		free!(Allocator)( data );
	}

	auto move()
	{
		import std.algorithm : move_ = move;

		return move_(this);
	}

	auto free()
	{
		import bc.memory : _free = free;
		if (data !is null)
			_free!(Allocator)(data);
	}

	auto releasePtr()
	{
		auto tmp = data;
		return data;
	}

	ref get()
	{
		if (data !is null)
		{
			static if( IsArray )   return data;
			else return *data;
		}
			
		panic(Box.stringof, " is null!");
		assert(0);
	}			
}

auto box(Type, alias Allocator = default_alloc)(auto ref Type value)
{
	import std.functional : forward;
	return Box!(Type, Allocator)(forward!value);
}