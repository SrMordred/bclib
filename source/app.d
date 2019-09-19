import bc.io;
import bc.string;

import bc.allocator;
import bc.memory;

template error(Values...)
{
	auto error(auto ref Values values, string file, size_t line)
	{
		print( file, ":" ,line , " -> ", values );
		exit(0);
		return null;
	}	
}

@trusted
struct Box(Type, alias Allocator = sys_alloc)
{
	Type* value;

	this(Type value)
	{	
		import std.algorithm : moveEmplace;
		this.value = malloc!(Allocator, Type);
		value.moveEmplace( *this.value );
	}

	this(ref Box other)
	{	
		if( other.value !is null )
		{
			if( value is null )
			{
				value  = calloc!(Allocator, Type);
			}
			*value = *other.value;
		}
	}

	~this()
	{
		release!(Allocator)(value);
	}

	auto move()
	{
		import std.algorithm : move_ = move;
		return move_(this);
	}

	auto free()
	{
		if( value !is null )
		{
			release!(Allocator)(value);
		}
	}

	auto get( string file = __FILE__, size_t line = __LINE__ )
	{
		if( value !is null)
		{
			return value;
		}
		return error( Box.stringof , " is null!", file, line );
	}
}

enum DefaultCopyCtor = `
this(ref typeof(this) other)
{
	foreach (i, ref field; other.tupleof)
		this.tupleof[i] = field;
};`;

@trusted
struct Dummy
{
	int x;
	this(int x)
	{
		this.x = x;
		print("CTOR(",x,")");
	}
	this(ref Dummy other)
	{
		if( x )
		{
			print("DTOR(",x,")");
		}

		if(other.x)
		{
			x = other.x;
			print("COPY_CTOR(",x,")");	
		}
	}
	~this()
	{
		if(x)
		{
			print("DTOR(",x,")");
		}
	}
}



@safe
void main()
{
    import core.stdc.stdlib;
    import core.stdc.time;
    import std.range;
    import std.algorithm;


    Box!Dummy a = Dummy(1);
    Box!Dummy b = Dummy(2);

    (*a.get).print;

    //auto z = a.get()[0 .. 10];

    //release!(sys_alloc)(a.get);




    

    //auto arr = ( cast(int*) sys_alloc.malloc( 4 * 10 ) )[0 .. 5];

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
