module bclib.traits.traits;

template isAny(Value, Values...)
{
    static if(Values.length)
    {
        static if( is( Value == Values[0] ) )  
        {
            enum isAny = true;
        }
        else
        {
            enum isAny = isAny!(Value, Values[1 .. $]);
        }
    }
    else
    {
        enum isAny = false;
    }
}