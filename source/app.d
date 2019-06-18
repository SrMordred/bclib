import std.stdio : writeln;
import bc.memory;
import bc.container;
import core.stdc.stdio;

import bc.io;

version(D_BetterC)
{
	pragma(msg,"BetterC: ON");
}


struct Teste
{
	int x;
	import bc.string;



	this(int xx){ x = xx;}

	//this(this)
	//{
	//	print("postblit");
	//}

	//this(ref Teste other)
	//{
	//	print("copy ctor");
	//	x = other.x;
	//}

	~this()
	{
		print("~this");
		if(x)
			print("DTOR");
	}

	size_t hashof(){ return 0; }
}

struct R
{
	int opApply( scope int delegate(int ,int) fun )
	{	
		int result;
        foreach(v ; 0 .. 10)
        {
            result = fun(v,v);
            if(result)
                break;
        }
        return result;
	}
}

extern(C) void main(){

	import bc.container.dict;
	import std.array : staticArray;

	import std.range : ElementType;

	import bc.util;

	import bc.string;

	



	String a = "teste";
	String b = "world";
	b~= "teste";
	auto c = a ~ b;

	print(c);



	//	static dest = [0,0,0,0];
	//	static from = [1,2,3,4];

	//	assign!true( dest, from );

	//	print(dest);
	//	print(from);
		


	//{
	//	static dest1 = [ Teste(), Teste() ];
	//	static from1 = [ Teste(1), Teste(2) ];

	//	assign!false( dest1, from1 );

	//	print(dest1);
	//	print(from1);
	//}

	//{
	//	static dest1 = [ Teste(), Teste() ];
	//	static from1 = [ Teste(1), Teste(2) ];

	//	assign!false( dest1, from1 );

	//	print(dest1);
	//	print(from1);
	//}


	//int x = 10;
	//add(x);

	

	
	
	//arr.push(Teste(1));
	//Teste t = Teste(1);
	//arr.push(t);



	//auto v1 = Array!int(1,2,3);
	//arr.push( v1 );

	//print(arr);

	//memcpy(&a,&b,Teste.sizeof);
	////a.__postblit;
	//a.__xcopyctor(b);

	//a.__xdtor;

	//a.opAssign( Teste() );



	//Array!int arr;

	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(1);

	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(2);

	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(3);
	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(4);
	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(5);
	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(6);
	//printf(" len( %d ) cap( %d ) \n", arr.length, arr.capacity);
	//arr.push(7);

	//foreach(v ; arr) printf(" -> %d\n", v);

	//arr.push(100);

	//foreach(v ;  arr[0 .. $])  printf("%d\n",v);

	//printf("%d\n", arr[0]);


	//printf("after arr\n");
	//import std.traits;
	//printf("hasElaborateAssign -> %d\n", hasElaborateAssign!Teste  );
	//printf("hasElaborateCopyConstructor -> %d\n", hasElaborateCopyConstructor!Teste  );
	//printf("hasElaborateDestructor -> %d\n", hasElaborateDestructor!Teste  );
	//auto x = Teste(2);
	//Teste b = a;

	//b=  a;


	//arr.push( Teste() );





}