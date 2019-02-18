module bclib.unbug;

/*
This is me, trying to solve betterC bugs that even i dont understand completely
*/

extern(C):

void _d_array_slice_copy(void* dst, size_t dstlen, void* src, size_t srclen, size_t elemsz)
{
	import core.stdc.string : memcpy;
	memcpy( dst, src, dstlen );
}

//I have NO clue wtf is this
int _d_eh_personality(int, int, ulong, void*, void*) { return 0;}