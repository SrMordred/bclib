module bc.memory.util;

import bc.memory.allocator : default_alloc;

auto malloc(Type, alias Allocator = default_alloc)(const size_t size = 1)
{
    import std.traits : isArray;
    import std.range : ElementType;

    static if (isArray!Type)
    {
        alias Element = typeof(Type.init[0]);
        return (cast(Element*) Allocator.malloc(Element.sizeof * size))[0 .. size];
    }
    else
    {
        return cast(Type*) Allocator.malloc(Type.sizeof);
    }
}

auto calloc(Type, alias Allocator = default_alloc)(const size_t size = 1)
{
    import std.traits : isArray;
    import std.range : ElementType;

    static if (isArray!Type)
    {
        alias Element = typeof(Type.init[0]);
        return (cast(Element*) Allocator.calloc(Element.sizeof * size))[0 .. size];
    }
    else
    {
        return cast(Type*) Allocator.calloc(Type.sizeof);
    }
}

void free(alias Allocator, Type)(ref Type value)
{
    import std.traits : isArray, isPointer, PointerTarget, Unqual, hasElaborateDestructor;
    import bc.error : panic;

    static if (isArray!Type)
    {
        alias Element = typeof(Type.init[0]);
        if (value !is null)
        {
            static if (hasElaborateDestructor!(Element))
            {
                foreach (ref val; value)
                    val.__xdtor;
            }

            Allocator.free(cast(Unqual!(Type)*) value.ptr);
            value = null;
        }
    }
    else static if (isPointer!Type)
    {
        alias Element = PointerTarget!Type;
        if (value !is null)
        {
            static if (hasElaborateDestructor!(Type))
            {
                value.__xdtor;
            }
            Allocator.free(cast(Unqual!(Type)*) value);
            value = null;
        }
    }
    else
        panic("'free' argument must be a pointers or an array.");
}

void memZero(Type)(ref Type value)
{
    import core.stdc.string : memset;

    memset(&value, 0, Type.sizeof);
}

void memZero(Type)(Type[] slice)
{
    import core.stdc.string : memset;

    memset(slice.ptr, 0, Type.sizeof * slice.length);
}

void copyTo(Type)(Type source, Type target)
{
    import bc.traits : isArray, ArrayElement, PointerTarget, Unqual;
    import core.stdc.string : memcpy;

    alias CleanType = Unqual!(Type);

    static if( isArray!Type )
    {
        memcpy(cast(CleanType*) target.ptr , cast(CleanType*) source.ptr, ArrayElement!Type.sizeof * source.length);
    }
    else static if( isPointer!Type )
    {
        memcpy(target, source, PointerTarget!(Type).sizeof);
    }
    else
    {
        panic("'copyTo' arguments must be pointers of arrays");
    }
}

void moveTo(Type)(ref Type source, ref Type target)
{
    import bc.traits : isPointer, isArray, Unqual, PointerTarget, hasIndirections, ArrayElement;
    import bc.error : panic;
    import core.stdc.string : memcpy, memset;

    alias CleanType = Unqual!(Type);

    static if (isPointer!Type)
    {
        alias RealType = PointerTarget!Type;
        memcpy(target, source, RealType.sizeof);

        static if (hasIndirections!RealType)
            memZero(source);
    }
    else static if (isArray!Type)
    {
        memcpy(cast(CleanType*) target.ptr, cast(CleanType*) source.ptr,
                ArrayElement!(Type).sizeof * source.length);
        source = null;
    }
    else
    {
        memcpy(&target, &source, Type.sizeof);
        static if (hasIndirections!Type)
            memZero(source);
    }
}

void assignAllTo(Type)(Type[] source, Type[] target)
{
    import std.traits : hasIndirections;

    static if (hasIndirections!Type)
    {
        foreach (index; 0 .. source.length)
        {
            target[index] = source[index];
        }
    }
    else
    {
        source.copyTo(target);
    }
}
