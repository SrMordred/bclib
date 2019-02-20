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

extern(C)
void main(){
	


	Array!(int) arr;

	arr.push(10,20,30);

	arr.removeValue( 10 );

	print(arr);


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