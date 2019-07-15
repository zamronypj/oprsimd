# Operator SIMD

This is repository for collection of operator overloading written in Free Pascal
that allows to do vectors and matrices operation using Intel SIMD SSE/SSE2/SSE3 instructions.

## Requirement

- [Free Pascal > 3.0](https://freepascal.org)

## How to use

### Adding two vectors

```
program simd_vector_add;

uses

   vectypes,
   simdssevec;

var
    v1, v2, tot : TVector;

begin
    //v1.x = 1.0, v1.y = 1.0, v1.z = 1.0, v1.w = 1.0
    v1 := 1.0;

    //v2.x = 2.0, v2.y = 2.0, v2.z = 2.0, v2.w = 2.0
    v2 := 2.0;

    tot := v1 + v2;
    writeln('x:', tot.x, ' y:', tot.y, ' z:', tot.z, ' w:', tot.w);
end.
```

### Subtract two vectors

```
program simd_vector_sub;

uses

   vectypes,
   simdssevec;

var
    v1, v2, tot : TVector;

begin
    //v1.x = 1.0, v1.y = 1.0, v1.z = 1.0, v1.w = 1.0
    v1 := 1.0;

    //v2.x = 2.0, v2.y = 2.0, v2.z = 2.0, v2.w = 2.0
    v2 := 2.0;

    tot := v1 - v2;
    writeln('x:', tot.x, ' y:', tot.y, ' z:', tot.z, ' w:', tot.w);
end.
```

### Multiply a vector with scalar

```
program simd_vector_mulscalar;

uses

   vectypes,
   simdssevec;

var
    v1, tot : TVector;

begin
    //v1.x = 1.0, v1.y = 1.0, v1.z = 1.0, v1.w = 1.0
    v1 := 1.0;

    tot := v1 * 2.0;
    writeln('x:', tot.x, ' y:', tot.y, ' z:', tot.z, ' w:', tot.w);
end.
```

### Calculate dot product of two vector

```
program simd_vector_dot;

uses

   vectypes,
   simdssevec;

var
    v1, v2 : TVector;
    dot : single;

begin
    v1.x := 1.0;
    v1.y := 2.0;
    v1.z := 3.0;
    v1.w := 0.0;

    v2.x := 6.0;
    v2.y := 7.0;
    v2.z := 8.0;
    v2.w := 0.0;

    dot := v1 * v2;

    writeln('dot:', dot);
end.
```

### Calculate cross product of two vector

```
program simd_vector_cross;

uses

   vectypes,
   simdssevec;

var
    v1, v2, res : TVector;

begin
    v1.x := 2.0;
    v1.y := 3.0;
    v1.z := 4.0;
    v1.w := 0.0;

    v2.x := 5.0;
    v2.y := 6.0;
    v2.z := 7.0;
    v2.w := 0.0;

    res := v1 ** v2;

    writeln('x:', res.x, ' y:', res.y, ' z:', res.z, ' w:', res.w);
end.
```

## Compile demo

Run

```
$ ./build-demo.sh
```

## Run demo

For example

```
$ ./demo/simd_vector_add
```
