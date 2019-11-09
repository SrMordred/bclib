/++
	This module provides a basic allocator that implements `malloc, calloc and free.`

	Also set a global variable called `default_alloc` that is used as the default allocator for 
	all the lib.	

	A basic allocator must have this signature:
	---
	struct IAllocator
	{
		void* malloc(size_t);
		void* calloc(size_t);
		void free(void*);
	}
	---
+/
module bc.memory.allocator;

///
unittest{
	struct LogAllocator
	{
    	import core.stdc.stdlib : 
    		_malloc = malloc,
    		_calloc = calloc,
    		_free = free;
		import core.stdc.stdio : printf;

		void* malloc(size_t size ){
			printf("Malloc : (%d)\n", size);
			return _malloc( size );
		}
		void* calloc(size_t size){
			printf("Calloc : (%d)\n", size);
			return _calloc( 1, size );
		}
		void free(void* ptr){
			_free(ptr);
			printf("Free : (%p)\n", ptr);
		}
	}

	auto log_allocator = LogAllocator();
	auto buffer        = log_allocator.malloc(100);
	log_allocator.free(buffer);
}

static alloc_counter = 0;

/**
	Basic Default Allocator
*/
struct DefaultAllocator
{
    import core.stdc.stdlib : _malloc = malloc, _calloc = calloc, _free = free;

    import core.stdc.stdio : printf;
    /**
	Allocate memory
	Params: size = Size in bytes of memory to be allocated
	Returns: Pointer to new allocated memory
	*/
    void* malloc(size_t size)
    {
        auto ptr = _malloc(size);
        printf("#(%d) Alloc(%d)  -> %p\n", alloc_counter, size, ptr);
        alloc_counter++;
        return ptr;
    }

    /**
	Allocate zeroed memory
	Params: size = Size in bytes of memory to be allocated
	Returns: Pointer to new allocated memory
	*/
    void* calloc(size_t size)
    {
        auto ptr = _calloc(1, size);
        printf("#(%d) Calloc(%d) -> %p\n", alloc_counter, size, ptr);
        alloc_counter++;
        return ptr;
    }
    
    
    /**
	Free memory
	Params: ptr = Pointer to the memory address to be freed
	*/
    void free(void* ptr)
    {
        --alloc_counter;
        printf("#(%d) Free()     -> %p\n", alloc_counter, ptr);
        _free(ptr);
    }
}

///global variable that are used by default on implementations that require an allocator.
public DefaultAllocator default_alloc;


unittest{

	DefaultAllocator allocator;
	auto ptr = allocator.malloc(100);
	byte* bytes = cast(byte*)allocator.calloc(100);
	bool iszero = true;
	foreach(v ; bytes[0 .. 100])
		if(v != 0) iszero = false;

	assert( iszero );
	assert( ptr !is null );

	allocator.free(ptr);
	allocator.free(bytes);
}