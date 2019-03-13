# Operator SIMD

This is repository for collection of operator overloading written in Free Pascal
that allows to do vectors and matrices operation using Intel SIMD SSE/SSE2/SSE3 instructions.

## Requirement

- [Free Pascal > 3.0](https://freepascal.org)

## How to use

```
program simd_vector_add;

uses

   vectypes,
   simdssevec;

var
    v1, v2, tot : TVector;

begin    
    v1 := 1.0;
    v2 := 2.0;
    tot := v1 + v2;
    writeln('x:', tot.x, ' y:', tot.y, ' z:', tot.z, ' w:', tot.w);    
end.
```
