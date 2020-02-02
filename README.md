# bstr

A collection of functions for working with byte strings in Zig. Much of
it is ported from the Go standard library. Currently there is no support
for simd operations, but those will be added a support comes along.

## Goals

- Keep this very simple and filling only the most common use cases. 
- Avoid allocations if possible
- Return iterators where possible
- Avoid an actual string type. []u8 is already a type

## Questions?

- Should I make bstr a struct of some sort? probably not...
- 

## Notes

Search: https://golang.org/src/strings/search.go
General: https://golang.org/src/strings/strings.go
Optimized Native: https://golang.org/src/internal/bytealg/index_native.go
Rust: https://github.com/BurntSushi/bstr

Other Zig work:
https://github.com/clownpriest/strings/blob/master/src/strings.zig


Also look into burntsushi's bstr library


