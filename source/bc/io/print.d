module bc.io.print;

import bc.io.stdout : stdout;

void formatter( alias IO = stdout, Values... )( auto ref Values values )
{
	static foreach(value ; values)
	{{
		import bc.traits : isAny;
		import bc.string : String;
		import std.traits : isPointer, Unqual, isArray;

		alias Type = Unqual!(typeof(value));

		static if( is(typeof(Type.toString)) )
		{
			value.toString( IO );
		}
		else static if( isAny!( Type, string, String, char[] ) )
		{
			IO.put( value[0 .. $] );
		}
		else static if( is(Type == struct) )
		{
			formatter!IO( Type.stringof, '{');
			static if( Type.tupleof.length )
			{
				static foreach( index ; 0 .. Type.tupleof.length-1 )
				{{
	    			alias FieldType = typeof(Type.tupleof[index]);

	    			formatter!IO('"', Type.tupleof[index].stringof ,"\" : ");

	    			static if( is( FieldType == string ) )
	    				formatter!IO('"', value.tupleof[index], "\", " );	
	    			else
	    				formatter!IO(value.tupleof[index], ", " );	
	    			
				}}

				alias FieldType = typeof(Type.tupleof[$-1]);

    			formatter!IO('"', Type.tupleof[$-1].stringof ,"\" : ");

    			static if( is( FieldType == string ) )
    				formatter!IO('"', value.tupleof[$-1], "\"" );	
    			else
    				formatter!IO(value.tupleof[$-1] );	
			}
			formatter!IO('}');
			
		}
		else static if(is(Type == bool))
	    {
			IO.put( value ? "true" : "false" );
	    }
	    else static if( isArray!Type )
	    {
	    	formatter!IO("[");
	    	if( value.length )
	    	{
	    		foreach( i ; 0 .. value.length - 1 )
	    			formatter!IO( value[i] , ", " );
	    		
	    		formatter!IO( value[$-1] );
	    	}
	    	formatter!IO("]");
	    }
	    else
	    {
	        static if( isAny!(Type, size_t, ulong ) )
	            enum format = "%Iu";
	        else static if( is( Type == long ) )
	            enum format = "%Id";
	        else static if( is( Type == uint ) )
	            enum format = "%u";
	        else static if( is( Type == int ) )
	            enum format = "%d";
	        else static if( is( Type == float ) )
	            enum format = "%f";
	        else static if( is( Type == double ) )
	            enum format = "%lf";
	        else static if( is( Type == char ) )
	            enum format = "%c";
			else static if( is( Type == byte ) || is( Type == ubyte ) )
	            enum format = "%x";
	        else static if( isPointer!Type )
	            enum format = "#%llx";
			else
				pragma(msg, "Type ", Type.stringof, " is not implemented!");

	        import core.stdc.stdio : sprintf;  
	        //316, maybe the max char possible (double.max)
	        char[512] tmp;
	        
	        size_t length = sprintf(tmp.ptr, format , value );
			IO.put( tmp[0 .. length] );
	    }
	}}
}

void print( Values... )( auto ref Values values )
{
	import std.functional : forward;
	formatter!(stdout)(forward!values);
	formatter!(stdout)('\n');
}



void print(alias string fmt, Values... )( auto ref Values values )
{
	import core.stdc.stdio;
	import std.algorithm : countUntil;

	static gen(){

		import bc.ctfe : Code;

		Code!(4096) code;

		code( "alias f = formatter;\n" );
		code( "alias s = stdout;\n" );

		size_t current = 0;
		size_t limit = fmt.length;
		size_t start = current;
		size_t value_index = 0;
		
		while( current != limit )
		{
			if( fmt[ current ] == '?'  )
			{
				if( current+1 != limit && fmt[current+1] == '?' )
				{
					++current;
				}
				else
				{
					code("f!s(fmt[", start ," .. ",current ,"]);\n");
					code("f!s(values[", value_index ,"]);\n");	
					start = current+1;
					++value_index;
				}
			}
			++current;
		}

		if( start != current )
		{
			code("f!s(fmt[", start ," .. ",current ,"]);\n");
		}

		code("f!s('\\n');");
		return code[];

	}
	//pragma(msg, gen());
	mixin(gen());
}