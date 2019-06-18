module bc.traits.traits;

public import std.traits : 
    TemplateOf,
    hasElaborateAssign, 
    hasElaborateCopyConstructor;

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

enum isTemplateOf( A, alias B ) =  __traits(isSame, TemplateOf!(A), B) ;

template hasMember( T, Members... )
{
    static if( Members.length == 1 )
        enum hasMember = mixin("is( typeof( T.init."~Members[0]~" ) )");
    else
        enum hasMember = hasMember!(T, Members[0]) && hasMember!(T, Members[1 .. $]);
}

template isBCArray( T )
{
    enum isBCArray = hasMember!( T, "ptr", "length" );
}

enum isDArray( T ) = T.stringof[$-2 .. $] == "[]";

/*
Work with auto ref Templates
*/
enum isRValue(alias value) = !__traits(isRef, value);
