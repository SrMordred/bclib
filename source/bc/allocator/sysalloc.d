module bc.allocator.sysalloc;


static alloc_counter = 0 ;

struct SysAlloc
{
	import core.stdc.stdlib:
	_malloc = malloc,
	_calloc = calloc,
	_free   = free;

	import bc.io : printf;

	void* malloc(size_t size)
	{
		auto ptr = _malloc(size);
		printf("#(%d) Alloc(%d)  -> %p\n", alloc_counter, size, ptr);
		alloc_counter++;
		return ptr;
	}

	void* calloc(size_t size)
	{
		auto ptr = _calloc(1, size);
		printf("#(%d) Calloc(%d) -> %p\n", alloc_counter, size, ptr);
		alloc_counter++;
		return ptr;
	}

	void free( void* ptr )
	{
		--alloc_counter;
		printf("#(%d) Free()     -> %p\n", alloc_counter, ptr);
		_free(ptr);
	}
}

SysAlloc sys_alloc;
