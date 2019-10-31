
import bc.io : print;

//enum DefaultCopyCtor = `
//this(ref typeof(this) other)
//{
//	foreach (i, ref field; other.tupleof)
//		this.tupleof[i] = field;
//};`;

@trusted struct Dummy
{
	int x;
	int* xx;
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

import bc.container : Dict;

template match(Visitors...){

	auto match( Type )( auto ref Type value )
	{
		import bc.traits: isPointer, isArray, isTemplateOf;
		import bc.adt : ADT;

		static if( isPointer!Type )
		{
			static assert(Visitors.length == 2, 
				"Function pointer.match!(Visitors...) must have 2 visitors.");
			
			if( value !is null )
			{
				static if( __traits( compiles, Visitors[0](value) ) )
					Visitors[0](value);
				else static if( __traits( compiles, Visitors[0]() ) )
					Visitors[0]();
			}
			else
			{
				static if( __traits( compiles, Visitors[1](value) ) )
					Visitors[1](value);
				else static if( __traits( compiles, Visitors[1]() ) )
					Visitors[1]();
			}
		}
		else static if( isArray!Type )
		{
			static assert(Visitors.length == 2, 
				"Function array.match!(Visitors...) must have 2 visitors.");

			if( value.length > 0 )
			{
				static if( __traits( compiles, Visitors[0](value) ) )
					Visitors[0](value);
				else static if( __traits( compiles, Visitors[0]() ) )
					Visitors[0]();
			}
			else
			{
				static if( __traits( compiles, Visitors[1](value) ) )
					Visitors[1](value);
				else static if( __traits( compiles, Visitors[1]() ) )
					Visitors[1]();
			}
		}
		else static if( isTemplateOf!( Type, ADT ) )
		{
			import std.meta: staticIndexOf;
			import std.algorithm : find;

			//TODO: How to implement default Visitor ?
			//enum hasDefaultVisitor = staticIndexOf!( _, Visitors ) != -1;

			alias ADT_Types = Type.Types;

			enum VisitorsIndex = (){

				import bc.traits : isFunction, isFunctionPointer, isDelegate, Parameters;

				int[ ADT_Types.length ] indices;
				string[ ADT_Types.length ] indices_types;
				indices[] = -1;

				static foreach( Index, T ; ADT_Types )
				{
					indices_types[ Index ] = T.stringof;
				}

				static foreach(Index, Visitor ; Visitors )
				{
                	static if (isFunction!Visitor || isFunctionPointer!Visitor || isDelegate!Visitor)
                	{
                    	indices[staticIndexOf!(Parameters!( Visitor )[0], ADT_Types )] = Index;
                	}
				}
				static foreach(Index, Visitor ; Visitors )
				{
                	static if ( __traits( isTemplate , Visitor ) )
                	{{
                		auto f = indices[].find(-1);
                        if (f.length)
                            f[0] = Index;
                	}}
				}

				//static if( !hasDefaultVisitor )
				//{
					foreach( index, type ; indices_types )
					{
						if( indices[ index ] == -1)
						{
							assert(0, "You must implement a Visitor with paramater: " ~ type );
						}
					}	
				//}
				

				return indices;
			}();

			final switch (value.tag)
		    {
		        static foreach (TypeIndex; 0 .. ADT_Types.length)
		        {
		    		case TypeIndex:
		            	return Visitors[VisitorsIndex[TypeIndex]](value.values[TypeIndex]);
		        }
		    }
		}
	}
}

enum _;



//@safe
void main()
{	
	import std.array : staticArray;
	import std.range : iota;

	import bc.traits;
	import bc.memory;
	import std.array : staticArray;
	import bc.adt;

	ADT!(int, float) type;


	type.match!(
		(float x) => print("float : ",x),
		(int x) => print("int : ", x),
	);



}

