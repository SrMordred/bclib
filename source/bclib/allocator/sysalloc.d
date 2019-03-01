module bclib.allocator.sysalloc;


static alloc_counter = 0 ;

struct SysAlloc
{
	import core.stdc.stdlib :
	_malloc = malloc,
	_calloc = calloc,
	_free = free;

	import core.stdc.stdio;

	void* alloc(size_t size)
	{
		auto ptr = _malloc(size);
		printf("#(%d) Alloc(%d) -> %p\n", alloc_counter, size, ptr);
		alloc_counter++;
		return ptr;
	}

	void* calloc(size_t size)
	{
		auto ptr = _calloc(1, size);
		printf("Calloc(%d) -> %p\n", size, ptr);
		return ptr;
	}

	void free( void* ptr )
	{
		--alloc_counter;
		printf("#(%d) Free() -> %p\n", alloc_counter, ptr);
		_free(ptr);
	}
}

SysAlloc sysAlloc;
