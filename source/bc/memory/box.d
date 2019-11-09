module bc.memory.box;

import bc.memory.allocator : default_alloc;
import bc.error : panic;

//struct SafePtr( Type )
//{
//	Type* __ptr;

//	ref opUnary( string op: "*")(string file = __FILE__, int line = __LINE__)
//	{
//		import bc.error : panic;
//		if( __ptr !is null ) return *__ptr;
//		panic( "Dereferencing from null pointer in ",file, ": ", line);
//		assert(0);
//	}

//	bool opCast()
//	{
//		return __ptr !is null;
//	}

//	auto match( alias SomeFunction, alias NoneFunction )()
//	{
//		if( __ptr !is null )
//			SomeFunction( __ptr );
//		else
//			NoneFunction();
//	}

//}

//void safePtr( Type )( Type* ptr )
//{
//	return SafePtr!Type(ptr);
//}

struct Box(Type, alias TAllocator = default_alloc)
{
	import std.traits : isArray, Select, Unqual;
	import std.range : ElementType;

	alias IsArray   = isArray!Type;
	alias DataType  = Select!( IsArray , Type, Type* );
	alias Allocator = TAllocator;

	private DataType __ptr;

	/*
		Constructors, Destructors, Assign, and Free Boxes
	*/
	this(Type value)
	{
		import std.algorithm : moveEmplace, moveEmplaceAll;
		import bc.memory : malloc, moveTo;

		import std.traits : ReturnType;

		static if( IsArray )
		{
			__ptr = malloc!(Type, Allocator)( value.length );
			value.copyTo( __ptr );
		}
		else
		{
			__ptr = malloc!(Type, Allocator);
			value.moveTo( *__ptr );			
		}
	}

	this(ref Box other)
	{
		import bc.memory : malloc, copyTo;

		if( other )
		{
			static if( IsArray )
			{
				__ptr = malloc!( Type, Allocator )( other.capacity );
				other.__ptr.copyTo( __ptr );
			}
			else
			{
				__ptr = malloc!( Type, Allocator )();
				other.__ptr.copyTo( __ptr );
			}	
		}
	}

	void opAssign( Self : Box )( auto ref Self other )
	{
		import bc.memory : malloc, copyTo;

		free();

		if( other )
		{
			static if( IsArray )
			{
				__ptr = malloc!( Type, Allocator )( other.capacity );
				other.__ptr.copyTo( __ptr );
			}
			else
			{
				__ptr = malloc!( Type, Allocator )();
				other.__ptr.copyTo( __ptr );
			}	
		}
	}

	static fromPtr( ref DataType ptr )
	{
		Box!( Type, Allocator ) tmp;
		tmp.__ptr = ptr;
		ptr = null;
		return tmp;
	}

	~this()
	{
		free();
	}

	void free()
	{
		import bc.memory : _free = free, destructor;
		if ( this )
		{
			static if(IsArray)
				destructor(__ptr);
			else
				destructor(*__ptr);

			_free!(Allocator)(__ptr);
		}
	}

	static if( IsArray )
	{
		import bc.memory : calloc, copyTo, _free = free;
		void reserve( size_t size )
		{
			if( size > __ptr.length )
			{
				//TODO: every calloc call can be replaced with malloc call if the type don´t have indirections
				auto tmp = calloc!(Type, Allocator)( size );
				__ptr.copyTo( tmp );
				free();
				__ptr = tmp;
			}
		}
		
		size_t opDollar(){ return __ptr.length; }
		alias capacity = opDollar;

		@safe
		ref  opIndex( size_t index ) { 
			import bc.error : panic;

			if( index >= capacity ) panic("Box[index] is out of bounds!");
			if( !this ) panic("Box[index] indexing an empty box!");
			return __ptr[ index ]; 
		}

		@safe
		auto opSlice() { 
			import bc.error : panic;

			if( !this ) panic("Box[] slicing an empty box!");
			return __ptr[0 .. $];
		}

		@safe
		auto opSlice(size_t start, size_t end) {
			if( !this ) panic("Box[start .. end] slicing an empty box!");
			if( start >= capacity || end > capacity) panic("Box[start .. end] os out of bounds!");

			return __ptr[start .. end]; 
		}

	}

	@safe
	ref opUnary( string op: "*")(string file = __FILE__, int line = __LINE__)
	{
		import bc.error : panic;
		static if( IsArray ){
			if( this ) return __ptr;
			panic( "Dereferencing an empty box in ",file, ": ", line);
		} 
		else{
			if( this ) return *__ptr;
			panic( "Dereferencing an empty box in ",file, ": ", line);
		}
		assert(0);
	}

	/*
		Internal data access functions
	*/
	@safe
	bool opCast()
	{
		return __ptr !is null;
	}


	@system
	auto ptr()
	{
		return __ptr;
	}
	/*
		Change box ownership
	*/

	@trusted
	auto move()
	{
		import std.algorithm : move_ = move;
		return move_(this);
	}

	@system
	auto releasePtr()
	{
		auto tmp = __ptr;
		__ptr = null;
		return tmp;
	}

	@trusted
	auto match( alias SomeFunction, alias NoneFunction )()
	{
		import bc.traits : ReturnType;

		if( this ) 
		{
			static if( IsArray )
				return SomeFunction( __ptr );
			else
				return SomeFunction( *__ptr );
		}
		else
		{
			return NoneFunction();
		}

	}

}

struct box
{
	static opCall(Type, alias Allocator = default_alloc)(auto ref Type value)
	{
		import std.functional : forward;
		return Box!(Type, Allocator)(forward!value);	
	}
	static fromPtr(Type, alias Allocator = default_alloc)(ref Type* value)
	{
		return Box!(Type, Allocator).fromPtr( value );
	}
	static fromPtr(Type, alias Allocator = default_alloc)(ref Type[] value)
	{
		return Box!(Type[], Allocator).fromPtr( value );
	}
}

unittest{

	
	{ Box!int box_int = Box!int(123); }
	{ Box!int box_int = box(123); }
	{ auto box_int = box(123); } 
	{ auto box_int = Box!(int, default_alloc)(123); } 

	import std.array : staticArray;

	auto array_ptr   = [1,2,3].staticArray;
	auto array_slice = array_ptr[];

	{ Box!(int[]) box_int = Box!(int[])( array_slice ); }
	{ Box!(int[]) box_int = box( array_slice ); }
	{ auto box_int = box( array_slice ); } 
	{ auto box_int = Box!(int[], default_alloc)( array_slice ); } 

	{
		auto a = box(123);
		auto b = a;
		*a = 100;

		assert(cast(bool)a, "b = a, is a copy, not move.");
		assert(cast(bool)b, "b = a, is a copy, not move.");

		assert( *a != *b, "a and b boxes are have different values" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}

	{
		auto a = box(100);
		auto b = box(200);

		a = b;

		assert(cast(bool)a, "a and b have values");
		assert(cast(bool)b, "a and b have values");

		assert( *a == *b, "a and b have the same value" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}
	{
		auto ptr = cast(int*) default_alloc.malloc(4);
		*ptr = 100;
		auto a = box.fromPtr( ptr );

		assert(ptr is null, "box.fromPtr must move the pointer to gain ownership");
		assert(*a == 100, "box value must be from the pointer");
	}
	{
		auto x = box(100);
		x.free();
		assert(x.ptr is null, "free() testing");
	}
	{
		auto a = box(100);
		auto b = a.move();

		assert( cast(bool)a == false, "a was moved" );
		assert( cast(bool)b , "b have the value" );
		assert( *b == 100 , "b have the value" );
	}
	{
		auto a = box(100);
		auto ptr = a.releasePtr();
		assert( cast(bool)a == false, "a must be empty" );
		assert( *ptr == 100);

		typeof(a).Allocator.free(ptr);
	}
	{
		auto x = box(123);

		auto right_value = x.match!(
			v => v,
			() => 0,
		);
		assert(right_value == 123, "box.match some value" );

		x.free();

		right_value = x.match!(
			v => v,
			() => 0,
		);
		assert(right_value == 0, "box.match none value" );

	}

	//slices

	auto buffer1 = [1,2,3].staticArray;
	auto arr1 = buffer1[];

	auto buffer2 = [1,2,3,4].staticArray;
	auto arr2 = buffer2[];

	{
		auto a = box(arr1);
		auto b = a;
		a[0] = 100;

		assert(cast(bool)a, "b = a, is a copy, not move.");
		assert(cast(bool)b, "b = a, is a copy, not move.");

		assert( a[0] != b[0], "a and b boxes are have different values" );
		assert( a.ptr != b.ptr, "a and b have different pointers" );
	}

	{
		auto a = box(arr1);
		auto b = box(arr2);

		a = b;

		assert(cast(bool)a, "a and b have values");
		assert(cast(bool)b, "a and b have values");

		assert( *a == *b, "a and b have the same value" );
		assert( a.ptr.ptr != b.ptr.ptr, "a and b have different pointers" );
	}
	{
		auto ptr = (cast(int*) default_alloc.malloc(int.sizeof * 3))[0 .. 3];
		ptr[0] = 100;
		ptr[1] = 200;
		ptr[2] = 300;
		auto a = box.fromPtr( ptr );

		assert(ptr is null, "box.fromPtr must move the pointer to gain ownership");
		assert(a[0] == 100, "box value must be from the pointer");
		assert(a[1] == 200, "box value must be from the pointer");
		assert(a[2] == 300, "box value must be from the pointer");
	}
	{
		auto x = box(arr1);
		x.free();
		assert(x.ptr is null, "free() testing");
	}
	{
		auto a = box(arr1);
		auto b = a.move();

		assert( cast(bool)a == false, "a was moved" );
		assert( cast(bool)b , "b have the value" );
		assert( b[0] == 1 , "b have the value" );
	}
	{
		auto a = box(arr1);
		auto ptr = a.releasePtr();
		assert( cast(bool)a == false, "a must be empty" );
		assert( ptr[0] == 1);

		typeof(a).Allocator.free(ptr.ptr);
	}
	{
		auto x = box(arr1);

		auto right_value = x.match!(
			v => v,
			() => [],
		);
		assert(right_value == arr1, "box.match some value" );

		x.free();

		right_value = x.match!(
			v => v,
			() => [],
		);
		assert(right_value == [], "box.match none value" );

	}

	//{
		
	//	int* ptr = cast(int*)default_alloc.malloc( 4 );
	//	auto box_int = box.fromPtr( ptr );
	//	assert( ptr is null , "Box.fromPtr must move to own the pointer" );
	//}

	//auto box_int = box(123);
	//auto ptr_int = box_int.ptr();
	//assert( *ptr_int == 123, "Box value don't match with ptr() captured value" );
	//assert( *box_int == 123, "Dereferencing box must have the right value" );
	//box_int.match!(
	//	v => {},
	//	() => { assert(false, "Box.match!() must return a value when there is a value inside"); }
	//);
	//*ptr_int = 321;
	//auto ptr_int2 = box_int.releasePtr();
	//assert( *ptr_int == 321, "Box value don't match with ptr() captured value" );
	//import bc.io;
	//auto box_again = box.fromPtr( ptr_int2 );
	//box_again.free();

	//box_int.free();

	//box_int.match!(
	//	(v){ 
	//		assert(false, "Box.match!() must not return a value when is null"); 
	//	}, 
	//	(){}
	//);

	//box_int = box(123);
	//if( !box_int ) assert(false, "if(Box) must return true is the pointer is not null");

	//auto box2_int = box_int.move();


	//assert( cast(bool)box2_int == true, "this Box must have a value from another moved box" );
	//assert( *box2_int == 123 , "this Box value must be the same as the moved box" );
	//assert( cast(bool)box_int == false , "the moved Box must be null" );

	//auto ptr2_int = box2_int.releasePtr();
	//scope(exit) default_alloc.free(ptr2_int);
	//assert( *ptr2_int == 123, "Pointer must have the value of the released Box" );
	//assert( cast(bool)box2_int == false, "Box must have null ptr after being released" );

	


	//auto a = box(10);
	//auto b = a;
	//*a = 11;
	//assert( *a != *b, "box_a = box_b must be a copy" );

	//int[] ptr = (cast(int*)default_alloc.malloc( 4 * 3 ))[0 .. 3];
	//scope(exit) default_alloc.free( ptr.ptr );
	//ptr[0] = 1;
	//ptr[1] = 2;
	//ptr[2] = 3;

	//auto box_slice = box( ptr );
	//assert( box_slice[] == ptr, "Box.get() return the inner slice, and must be equal to that." );
	//box_slice.reserve(10);
	//assert( box_slice.capacity == 10, "Box slice must have capacity of reserved value" );
	
	//auto slice = *box_slice;
	//slice[1] = 100;
	//assert( box_slice.ptr()[1] == 100 , "Box.get() return the inner slice, pointing to the same ptr");
	//assert( box_slice.ptr()[2] == 3 , "Box.ptr[index] return a pointer to the inner slice position" );
	//import std.array: staticArray;
	//assert( box_slice[0 .. 3] == [1,100,3].staticArray()[] , "Box.get(start, end) return a slice" );

	//box_slice.match!(
	//	(slice){},
	//	() { assert(false, "BoxSlice.match!() must return a value when the slice capacity is > 0"); }
	//);

	//auto slice_ptr = box_slice.releasePtr();

	//box_slice.match!(
	//	(slice){ assert(false, "BoxSlice.match!() must not return a value when the slice capacity is == 0"); },
	//	() {}
	//);

	//auto box2_slice = box.fromPtr( slice_ptr );
	//auto box_copy = box2_slice;

	//box2_slice.ptr()[0] = 100;
	//assert( box2_slice[0] != box_copy[0], "Assigned Box slice must be a copy" );

	//auto moved_box = box2_slice.move();
	//assert( cast(bool)box2_slice == false, "Moved from Box must be null" );
	//assert( cast(bool)moved_box == true, "Moved to Box must be have values" );
	//assert( moved_box.capacity == 10, "Moved box must have the same capacity (because they have the same values)");

	//moved_box.free();

}