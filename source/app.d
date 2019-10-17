import bc.io;
import bc.string;

import bc.allocator;
import bc.memory;

template error(Values...)
{
	auto error(auto ref Values values, string file, size_t line)
	{
		print(file, ":", line, " -> ", values);
		exit(0);
		return null;
	}
}

@trusted struct Box(Type, alias Allocator = default_alloc)
{
	import std.traits : isArray, Select;
	import std.range : ElementType;

	alias IsArray = isArray!Type;

	Select!( IsArray , Type, Type* ) data;

	this(Type value)
	{
		import std.algorithm : moveEmplace, moveEmplaceAll;

		static if( IsArray )
		{
			data = malloc!(Allocator, Type)( value.length );
			value.moveEmplaceAll(data);
		}
		else
		{
			data = malloc!(Allocator, Type);
			value.moveEmplace(*data);			
		}
	}

	this(ref Box other)
	{
		//if (other.ptr !is null)
		//{
		//	if (ptr is null)
		//	{
		//		ptr = calloc!(Allocator, Type);
		//	}
		//	*ptr = *other.ptr;
		//}
	}

	void opAssign(Type_ : Type)(Type_ value)
	{
		import std.algorithm : move;

		//value.move(*ptr);
	}

	~this()
	{
		release!(Allocator)( data );
	}

	auto move()
	{
		import std.algorithm : move_ = move;

		return move_(this);
	}

	auto free()
	{
		if (data !is null)
		{
			release!(Allocator)(data);
		}
	}

	auto releasePtr()
	{
		auto tmp = data;
		return data;
	}

	ref get(string file = __FILE__, size_t line = __LINE__)
	{
		//if (ptr !is null)
		//{
		//	return *ptr;
		//}
		error(Box.stringof, " is null!", file, line);
		assert(0);
		//static immutable unreachable = Type.init;
		//return unreachable;
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

	//auto a = Dummy(1).asBox;

	//auto x = [Dummy(1), Dummy(2)].staticArray;

	//auto box1 = box( Dummy(1) );
	import std.traits : Select;

	template TypeSelect( alias condition, if_true, if_false )
	{
		static if( condition )
			alias TypeSelect = if_true;
		else
			alias TypeSelect = if_false;
	}

	Select!(false, void, void*) ptr;

	alias dummy_arr = Dummy[2];

	Box!(Dummy[]) box1 = [Dummy(1), Dummy(2)];


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
