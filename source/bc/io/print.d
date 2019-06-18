module bc.io.print;

import bc.io.stdout;


void printl(alias IO = std_out, Values...)( auto ref Values values )
{	
	static foreach(value ; values)
	{{
		import bc.traits : isAny, isDArray;
		import std.traits : isPointer, Unqual;

		alias Type = Unqual!(typeof(value));

		static if( is(typeof(Type.toIO)) )
		{
			value.toIO!IO();
		}
		else static if( isAny!( Type, string, char[] ) )
		{
			IO.put( value[0 .. $] );
		}
		else static if( is(Type == struct) )
		{
			printl!IO( Type.stringof, "{");
			static if( Type.tupleof.length )
			{
				static foreach( index ; 0 .. Type.tupleof.length-1 )
				{{
	    			alias FieldType = typeof(Type.tupleof[index]);

	    			printl!IO('"', Type.tupleof[index].stringof ,"\" : ");

	    			static if( is( FieldType == string ) )
	    				printl!IO('"', value.tupleof[index], "\", " );	
	    			else
	    				printl!IO(value.tupleof[index], ", " );	
	    			
				}}

				alias FieldType = typeof(Type.tupleof[$-1]);

    			printl!IO('"', Type.tupleof[$-1].stringof ,"\" : ");

    			static if( is( FieldType == string ) )
    				printl!IO('"', value.tupleof[$-1], "\"" );	
    			else
    				printl!IO(value.tupleof[$-1] );	
			}
			printl!IO("}");
			
		}
		else static if(is(Type == bool))
	    {
			IO.put( value ? "true" : "false" );
	    }
	    else static if( isDArray!Type )
	    {
	    	printl!IO("[");
	    	if( value.length )
	    	{
	    		foreach( i ; 0 .. value.length - 1 )
	    			printl!IO( value[i] , ", " );
	    		
	    		printl!IO( value[$-1] );
	    	}
	    	printl!IO("]");
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
	        else static if( isPointer!Type )
	            enum format = "#%llx";

	        import core.stdc.stdio : sprintf;  
	        //316, maybe the max char possible (double.max)
	        char[512] tmp;
	        
	        size_t length = sprintf(tmp.ptr, format , value );
			IO.put( tmp[0 .. length] );
	    }
				
	}}
	
	
}

void print(alias IO = Stdout() , Values...)( auto ref Values values )
{
	printl!IO(values);
	printl!IO('\n');
}