module bc.container.dict;

import bc.allocator : sys_alloc;

size_t hashof(T)( size_t mask,  ref T value )
{
	return 0;
}

void swap(T)(ref T a, ref T b)
{

}

struct Dict( Key, Value, alias EMPTY_VALUE, alias allocator = sys_alloc )
{
	Key[]    keys;
	Key[]    values;
	size_t[] distances;

	size_t cap;
	size_t mask;
	size_t distance_to_grow;

	void opIndexAssign(K,V)(auto ref V value, auto ref K key)
	{
		import bc.io;
		import bc.traits : isRValue;

		START:
		if(cap == 0) initialize();

		size_t index        = hashof( mask, key );
		size_t dist_to_grow = index + distance_to_grow;
		size_t distance     = 0;

		for( ; index < dist_to_grow ; ++index, ++distance  )
		{
			if( keys[ index ] == EMPTY_VALUE || keys[ index ] == key )
			{
				static if( isRValue!key )
					key.move_to( keys[ index ] );
				else 
					key.assign_to( keys[ index ] );

				static if( isRValue!value )
					value.move_to( values[ index ] );
				else 
					value.assign_to( values[ index ] );

				distances[ index ] = distance;
				
				return;
			}

			if( distance > distances[ index ] )
			{
				swap( distance, distances[index] );
				swap( key, keys[index] );
				swap( value, values[index] );
			}
		}

		resize();
		goto START;
	}

	auto opIndex( ref Key key )
	{
		size_t index               = hashof( mask , key );
		immutable distance_to_grow = index + distance_to_grow;

		for(; index < distance_to_grow; ++index)
		{
			if( keys[ index ] == key ) 			return &values[ index ];
			if( keys[ index ] == EMPTY_VALUE ) 	return null;
		}
		return null;
	}

	void initialize()
	{
		import std.math : log2;
		import bc.memory : alloc, alloc_zero;

		immutable starting_size = 64;

		keys      = alloc!( typeof(keys) , allocator)( starting_size );
		values    = alloc_zero!( typeof(keys) , allocator)( starting_size );
		distances = alloc_zero!(typeof(distances), allocator)( starting_size );

		foreach(ref key ; keys) key = EMPTY_VALUE;

		cap  = starting_size;
		mask = cap-1;
		distance_to_grow = cast(size_t) log2(cap);
	}

	void resize()
	{
		import std.math : nextPow2;
		import bc.memory : release, alloc, alloc_zero;

		immutable old_cap = cap;
		immutable new_cap = nextPow2(old_cap + 1);

		auto old_keys      = keys;
		auto old_values    = values;
		auto old_distances = distances;

		keys      = alloc_zero!( typeof(keys) , allocator)( new_cap );
		values    = alloc!( typeof(keys) , allocator)( new_cap );
		distances = alloc_zero!(typeof(distances), allocator)( new_cap );

		foreach( i ; 0 .. old_cap )
		{
			if( old_keys[ i ] != EMPTY_VALUE ) 
			{
				this[ old_keys[ i ] ] = old_values[ i ];
			}
		}

		release!(allocator)(old_keys);
		release!(allocator)(old_values);
		release!(allocator)(old_distances);

	}

	~this()
	{
		import bc.memory : release;

		if(cap)
		{
			release!(allocator)(keys);
			release!(allocator)(values);
			release!(allocator)(distances);			
		}

		keys      = null;
		values    = null;
		distances = null;
		
	}

}