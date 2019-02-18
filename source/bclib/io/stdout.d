module bclib.io.stdout;

struct Stdout
{
    void put( Values... )(auto ref Values values)
    {
    	import core.stdc.stdio : 
    	fwrite, 
    	c_stdout = stdout,
    	fputc;

        static foreach(value ; values)
        {
            static if( is( typeof(value) == char) )
            {
            	fputc(value, c_stdout);
            }
            else
            {
                fwrite( value.ptr, char.sizeof, value.length, c_stdout );	
            }
        }
    }
}

