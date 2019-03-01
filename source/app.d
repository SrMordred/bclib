import bclib.io;
import bclib.string;
import bclib.container;

struct teste{
	int ptr;

	this(int v)
	{
		ptr = v;
		print("ctor");
	}

	this(this)
	{
		print("blitting...");
		if(ptr) print("blit");
	}

	~this()
	{
		if(ptr) print("dtor", ptr);
	}
}
import bclib.allocator;
import bclib.memory;

import std.algorithm;



extern(C) void main(){

	import bclib.memory : move;

	Array!teste arr;

	arr.push(teste(1));

	auto t = teste.ctor;

	arr.resize(4);
	arr.resize(1);

	//Array!teste arr;

	//arr.push( teste(1) );
	//auto x = teste(2);
	//arr.push(x.move);


	

	//import std.traits;
	//print(typeof(arr2).stringof);

	//print( __traits(isSame, TemplateOf!(typeof(arr2)), Array) );
	



	//print(arr4);


	//auto t = teste(1);
	//arr.push(teste(2));
	//auto t2 = t.move();

	//arr.push(t);
	//print(t);

	//teste t;
	//arr.push(t);





}