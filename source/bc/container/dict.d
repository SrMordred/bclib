module bc.container.dict;

//import bc.allocator : sys_alloc;
//import bc.memory : swap, alloc, alloc_zero, release, assign;
//import bc.util : hashof;


//struct Dict( Key, Value, alias EMPTY_VALUE, alias allocator = sys_alloc )
//{
//	Key[]    keys;
//	Key[]    values;
//	size_t[] distances;

//	size_t cap;
//	size_t mask;
//	size_t distance_to_grow;

//	void opIndexAssign(K,V)(auto ref V value, auto ref K key)
//	{
//		import bc.traits : isRValue;

//		START:
//		if(cap == 0) initialize();

//		size_t index        = hashof( key ) & mask;
//		size_t dist_to_grow = index + distance_to_grow;
//		size_t distance     = 0;

//		for( ; index <= dist_to_grow ; ++index, ++distance  )
//		{
//			if( keys[ index ] == EMPTY_VALUE || keys[ index ] == key )
//			{
//				assign!(isRValue!key)( keys[ index ], key,  );
//				assign!(isRValue!key)( values[ index ], value,  );
//				distances[ index ] = distance;
//				return;
//			}

//			if( distance > distances[ index ] )
//			{
//				swap( distance, distances[index] );
//				swap( key, keys[index] );
//				swap( value, values[index] );
//			}
//		}

//		resize();
//		goto START;
//	}

//	auto opIndex( ref Key key )
//	{
//		size_t index               = hashof( key ) & mask;
//		immutable distance_to_grow = index + distance_to_grow;

//		for(; index < distance_to_grow; ++index)
//		{
//			if( keys[ index ] == key ) 			return &values[ index ];
//			if( keys[ index ] == EMPTY_VALUE ) 	return null;
//		}
//		return null;
//	}

//	void initialize()
//	{
//		import std.math : log2;
//		import bc.memory : alloc, alloc_zero;

//		immutable init_cap  = 8;
//		distance_to_grow    = cast(size_t) log2( init_cap );
//		immutable alloc_cap = init_cap + distance_to_grow;

//		keys      = alloc!( typeof(keys), allocator )( alloc_cap );
//		values    = alloc_zero!( typeof(values), allocator )( alloc_cap );
//		distances = alloc_zero!( typeof(distances), allocator )( alloc_cap );

//		foreach(ref key ; keys) assign(key , EMPTY_VALUE);

//		cap              = init_cap;
//		mask             = cap - 1;
//	}

//	void resize()
//	{
//		import std.math : nextPow2, log2;
//		import bc.memory : release, alloc, alloc_zero;

//		immutable old_cap       = cap;
//		immutable new_cap       = nextPow2(old_cap + 1);
//		distance_to_grow        = cast(size_t) log2( new_cap );
//		immutable new_alloc_cap = new_cap;

//		auto old_keys      = keys;
//		auto old_values    = values;
//		auto old_distances = distances;

//		keys      = alloc!(typeof( keys ) , allocator)( new_alloc_cap );
//		values    = alloc_zero!(typeof( values ) , allocator)( new_alloc_cap );
//		distances = alloc_zero!(typeof( distances ) , allocator)( new_alloc_cap );

//		foreach(ref key ; keys) assign(key , EMPTY_VALUE);

//		foreach( i,  ref key ; old_keys)
//		{
//			if( old_keys[ i ] != EMPTY_VALUE ) 
//			{
//				this[ old_keys[ i ] ] = old_values[ i ];
//			}
//		}

//		release!(allocator)(old_keys);
//		release!(allocator)(old_values);
//		release!(allocator)(old_distances);

//		cap              = new_cap;
//		mask             = cap - 1;
//	}

//	void toIO(alias IO)()
//	{

//		import bc.io : printl;
//		import bc.container.array : Array;
	
//		static struct Pair{ size_t index; Key key; } 		
		
//		Array!( Pair ) _keys;

//		foreach(i, ref key ; keys)
//		{
//			if( key != EMPTY_VALUE )
//				_keys.push( Pair(i, key) );
//		}

//		printl!IO("[");
//		if( _keys.length )
//		{
//			foreach(ref pair ; _keys[0 .. $-1])
//			{
//				printl!IO( pair.key , " : ", values[ pair.index ] ,", ");
//			}
//			printl!IO( _keys.back.key, " : ", values[_keys.back.index] );
			
//		}
//		printl!IO("]");
//	}

//	int opApply( scope int delegate(ref Key ,ref Value) fun )
//	{	
//		int result;
//		foreach(i, ref key ; keys)
//        {
//        	if( key != EMPTY_VALUE )
//        	{
//	            result = fun(key, values[ i ]);
//	            if(result)
//	                break;
//        	}
//        }
//        return result;
//	}

//	~this()
//	{
//		import bc.memory : release;

//		if(cap)
//		{
//			release!(allocator)(keys);
//			release!(allocator)(values);
//			release!(allocator)(distances);			
//		}

//		keys      = null;
//		values    = null;
//		distances = null;
		
//	}

//}