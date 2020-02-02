# bstr

A collection of functions for working with byte strings in Zig. Much of
it is ported from the Go standard library. Currently there is no support
for simd operations, but those will be added a support comes along.


## Questions?

- Should I make bstr a struct of some sort? probably not...
- 

## Notes

Search: https://golang.org/src/strings/search.go
General: https://golang.org/src/strings/strings.go
Optimized Native: https://golang.org/src/internal/bytealg/index_native.go


Also look into burntsushi's bstr library


