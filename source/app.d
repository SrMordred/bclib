import bc.io;
import bc.string;

import bc.allocator;
import bc.memory;

auto error(Values...)(auto ref Values values)
{
	print(values);
	exit(0);
	return null;
}

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
		variable = box( value ); //fine
		var1 = var2; //nop!
	*/
	void opAssign( Box other )
	{	
		import std.algorithm : moveEmplace;
		if( data !is null ) free();
		other.moveEmplace( this );
	}

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
			
		error(Box.stringof, " is null!");
		assert(0);
	}			
}

auto box(Type, alias Allocator = default_alloc)(auto ref Type value)
{
	import std.functional : forward;
	return Box!(Type, Allocator)(forward!value);
}

unittest{
	import fluent.asserts;

	true.should.equal(true);
}

enum DefaultCopyCtor = `
this(ref typeof(this) other)
{
	foreach (i, ref field; other.tupleof)
		this.tupleof[i] = field;
};`;

@trusted struct Dummy
{
	int x;
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




//TODO: Some/None will be nice to be implemented with ADT, tag should dissapear in case of Maybe

//@safe
void main()
{
	import core.stdc.stdlib;
	import core.stdc.time;
	import std.range;
	import std.algorithm;
	import std.array;


	//alias dummy_arr = Dummy[2];
	import bc.memory;

	/*Box!(Dummy[]) box1 = [Dummy(1), Dummy(2)];
	auto box2 = box1.dup;

	print(box1.data);
	print(box2.data);*/

	Box!(int) a;

	a =  box(100);


	//auto box1 = Dummy(2).box;

	//auto box2 = box1.dup;
	
	//print(*box1.data);
	//print(*box2.data);


	//v[0] = 0;

	//(*a.get).print;

	//auto z = a.get()[0 .. 10];

	//release!(default_alloc)(a.get);

	//auto arr = ( cast(int*) default_alloc.malloc( 4 * 10 ) )[0 .. 5];

	//arr[0] = 0;
	//arr[1] = 1;
	//arr[2] = 2;
	//arr[3] = 3;
	//arr[4] = 4;

	//Ptr!(int[]) ptr;

	//Ptr!(int[]) ptr2 = ptr;

	//print(arr);
	//print(ptr.data);

	//print(*a.value.data, " - " , *b.value.data);

	//a = b;

	//c = d;

	//Ptr!Data c;

	//auto cc = Data(40);

	//c = cc.move;

	//a = Data(20);

	//Ptr!Data b = Data(11);

	//auto c = b.move;

	//(*a.get).print;

	//auto a2 = *a.get;

	//   	for (auto __rangeCopy = r;
	//     !__rangeCopy.empty;
	//     __rangeCopy.popFront())
	// {

	//    // Loop body...
	//}
	//  	print(r);

	//x.match!(ok => print(ok), err=>print(""));

}

