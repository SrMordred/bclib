module bclib.traits.traits;

import std.traits : TemplateOf;

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

enum isTemplateOf( A, alias B ) =  __traits(isSame, TemplateOf!A, B) ;

enum isDArray( T ) = T.stringof[$-2 .. $] == "[]";

/*
Work with auto ref Templates
*/
enum isRValue(alias value) = !__traits(isRef, value);
