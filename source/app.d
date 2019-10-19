import bc.io;
import bc.string;

import bc.memory;




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
	default_alloc = DefaultAllocator();
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

