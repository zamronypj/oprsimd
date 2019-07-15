{*!
 * Operator SIMD (https://oprsimd.github.io)
 *
 * @link      https://github.com/oprsimd
 * @copyright Copyright (c) 2018 Zamrony P. Juhara
 * @license   https://github.com/oprsimd/blob/master/LICENSE (MIT)
 *}
unit simdssevec;

interface

{$MODE OBJFPC}
{$ALIGN 16}

uses
    vectypes;

    {------------------------------------------------
     operator overloading collections to allow fast
     vector operations using Intel SIMD SSE instructions.

     @author Zamrony P. Juhara <zamronypj@yahoo.com>
    -----------------------------------------------}

    {-------------------------------------
     Copy scalar value to vector component
     -------------------------------------
     for example:
     res.x = scalar
     res.y = scalar
     res.z = scalar
     res.w = scalar
     can be written as
     res := scalar
    --------------------------------------}
    operator := (const scalar : single) res : TVector;

    {-------------------------------------
     Add two vectors using SSE instruction
     -------------------------------------
     for example:
     res.x = v1.x + v2.x
     res.y = v1.y + v2.y
     res.z = v1.z + v2.z
     res.w = v1.w + v2.w
     can be written as
     res := v1 + v2
    --------------------------------------}
    operator + (const v1:TVector; const v2:TVector) res : TVector;

    {-------------------------------------
     Subtract two vectors using SSE instruction
     -------------------------------------
     for example:
     res.x = v1.x - v2.x
     res.y = v1.y - v2.y
     res.z = v1.z - v2.z
     res.w = v1.w - v2.w
     can be written as
     res := v1 - v2
    --------------------------------------}
    operator - (const v1 : TVector; const v2 : TVector) res : TVector;

    {-------------------------------------
     Multiply a vector with scalar using SSE instruction
     -------------------------------------
     for example:
     res.x = v1.x * scalar
     res.y = v1.y * scalar
     res.z = v1.z * scalar
     res.w = v1.w * scalar
     can be written as
     res := v1 * scalar
    --------------------------------------}
    operator * (const v1 : TVector; const scalar : single) res : TVector;

    {-------------------------------------
     Multiply a vector with scalar using SSE instruction
     -------------------------------------
     for example:
     res.x = scalar * v1.x
     res.y = scalar * v1.y
     res.z = scalar * v1.z
     res.w = scalar * v1.w
     can be written as
     res := scalar * v1
    --------------------------------------}
    operator * (const scalar : single; const v1 : TVector) res : TVector;

    {-------------------------------------
     Calculate dot product of two vectors using
     SSE instruction
    --------------------------------------
     var res : single;
         v1, v2 :TVector;

     following example
     res = v1.x * v2.x +
           v1.y * v2.y +
           v1.z * v2.z
     can be written as
     res := v1 * v2;
    --------------------------------------}
    operator * (const v1 : TVector; const v2 : TVector) res : single;

    {-------------------------------------
     Cross product of two vectors
     -------------------------------------
     var res, v1, v2 : TVector;
     res.x := v1.y * v2.z - v1.z * v2.y;
     res.y := v1.z * v2.x - v1.x * v2.z;
     res.z := v1.x * v2.y - v1.y * v2.x;
     res.w := 0;
     can be writen as
     res := v1 ** v2;
    --------------------------------------}
    operator ** (const v1 : TVector; const v2 : TVector) : TVector; assembler;

implementation

{$ASMMODE intel}

    {-------------------------------------
     Copy scalar value to vector component
     -------------------------------------
     res.x = scalar
     res.y = scalar
     res.z = scalar
     res.w = scalar
     -------------------------------------
     input:
     For x86-64 architecture
     scalar value will be passed
     in xmm0 in following order
     xmm0 = [ scalar, (not used), (not used), (not used)]
    --------------------------------------
     output:
     result will be stored in xmm0 and xmm1
     register with following order
     xmm0 = [ res.x, res.y, [not used], [not used]]
     xmm1 = [ res.z, res.w, [not used], [not used]]
    --------------------------------------}
    operator := (const scalar : single) res : TVector; assembler;
    asm
        //shuffle xmm0 so that
        //xmm0 = {scalar, scalar, scalar, scalar}
        shufps xmm0, xmm0, 00000000b

        //copy high quadword of xmm0 to low quadword of xmm1
        //xmm1 = {res.z, res.w, [not used], [not used]}
        movhlps xmm1, xmm0
    end;

    {-------------------------------------
     Add two vectors using SSE instruction
     -------------------------------------
     res.x = v1.x + v2.x
     res.y = v1.y + v2.y
     res.z = v1.z + v2.z
     res.w = v1.w + v2.w
     -------------------------------------
     input:
     For x86-64 architecture
     v1 and v2 value will be passed
     in xmm0, xmm1, xmm2, xmm3 in following order
     xmm0 = [ v1.x, v1.y, (not used), (not used)]
     xmm1 = [ v1.z, v1.w, (not used), (not used)]
     xmm2 = [ v2.x, v2.y, (not used), (not used)]
     xmm3 = [ v2.z, v2.w, (not used), [not used]]
    --------------------------------------
     output:
     result will be stored in xmm0 and xmm1
     register with following order
     xmm0 = [ res.x, res.y, [not used], [not used]]
     xmm1 = [ res.z, res.w, [not used], [not used]]
    --------------------------------------}
    operator + (const v1:TVector; const v2:TVector) res : TVector; assembler;
    asm
        //copy low quadword of xmm1 to high quadword of xmm0
        //xmm0 = {v1.x, v1.y, v1.z, v1.w}
        movlhps xmm0, xmm1

        //copy low quadword of xmm3 to high quadword of xmm2
        //xmm2 = {v2.x, v2.y, v2.z, v2.w}
        movlhps xmm2, xmm3

        //add xmm0 and xmm2
        //xmm0 = {v1.x + v2.x,
        //        v1.y + v2.y,
        //        v1.z + v2.z,
        //        v1.w + v2.w}
        addps xmm0, xmm2

        //copy high quadword of xmm0 to low quadword of xmm1
        //xmm1 = {res.z, res.w, [not used], [not used]}
        movhlps xmm1, xmm0
    end;

    {-------------------------------------
     Substract two vector using SSE instruction
     -------------------------------------
     result.x = v1.x - v2.x
     result.y = v1.y - v2.y
     result.z = v1.z - v2.z
     result.w = v1.w - v2.w
     -------------------------------------
     input:
     For x86-64 architecture
     v1 and v2 value will be passed
     in xmm0, xmm1, xmm2, xmm3 in following order
     xmm0 = [ v1.x, v1.y, (not used), (not used)]
     xmm1 = [ v1.z, v1.w, (not used), (not used)]
     xmm2 = [ v2.x, v2.y, (not used), (not used)]
     xmm3 = [ v2.z, v2.w, (not used), [not used]]
    --------------------------------------
     output:
     res will be stored in xmm0 and xmm1
     register with following order
     xmm0 = [ res.x, res.y, [not used], [not used]]
     xmm1 = [ res.z, res.w, [not used], [not used]]
    --------------------------------------}
    operator - (const v1 : TVector; const v2 : TVector) res : TVector; assembler;
    asm
        //copy low quadword of xmm1 to high quadword of xmm0
        //xmm0 = {v1.x, v1.y, v1.z, v1.w}
        movlhps xmm0, xmm1

        //copy low quadword of xmm3 to high quadword of xmm2
        //xmm2 = {v2.x, v2.y, v2.z, v2.w}
        movlhps xmm2, xmm3

        //subtract xmm0 and xmm2
        //xmm0 = {v1.x - v2.x,
        //        v1.y - v2.y,
        //        v1.z - v2.z,
        //        v1.w - v2.w}
        subps xmm0, xmm2

        //copy high quadword of xmm0 to low quadword of xmm1
        //xmm1 = {res.z, res.w, [not used], [not used]}
        movhlps xmm1, xmm0
    end;

    {-------------------------------------
     multiply a vector with a scalar using
     SSE instruction
     --------------------------------------
     res.x = v1.x * scalar
     res.y = v1.y * scalar
     res.z = v1.z * scalar
     res.w = v1.w * scalar
     -------------------------------------
     input:
     For x86-64 architecture
     v1 and scalar value will be passed
     in xmm0, xmm1, xmm2 in following order
     xmm0 = [ v1.x, v1.y, (not used), (not used)]
     xmm1 = [ v1.z, v1.w, (not used), (not used)]
     xmm2 = [ scalar, (not used), (not used), (not used)]
     --------------------------------------
     output:
     result will be stored in xmm0 and xmm1
     register with following order
     xmm0 = [ res.x, res.y, [not used], [not used]]
     xmm1 = [ res.z, res.w, [not used], [not used]]
    --------------------------------------}
    operator * (const v1 : TVector; const scalar : single) res : TVector; assembler;
    asm
        //copy low quadword of xmm1 to high quadword of xmm0
        //xmm0 = {v1.x, v1.y, v1.z, v1.w}
        movlhps xmm0, xmm1

        //shuffle xmm2 so that
        //xmm2 = {scalar, scalar, scalar, scalar}
        shufps xmm2, xmm2, 00000000b

        //multiply xmm0 and xmm2
        //xmm0 = {v1.x * scalar,
        //        v1.y * scalar,
        //        v1.z * scalar,
        //        v1.w * scalar}
        mulps xmm0, xmm2

        //copy high quadword of xmm0 to low quadword of xmm1
        //xmm1 = {res.z, res.w, [not used], [not used]}
        movhlps xmm1, xmm0
    end;

    {-------------------------------------
     multiply a vector with a scalar using
     SSE instruction
     --------------------------------------
     res.x = v1.x * scalar
     res.y = v1.y * scalar
     res.z = v1.z * scalar
     res.w = v1.w * scalar
     -------------------------------------
     input:
     For x86-64 architecture
     v1 and scalar value will be passed
     in xmm0, xmm1, xmm2 in following order
     xmm0 = [ scalar, (not used), (not used), (not used)]
     xmm1 = [ v1.x, v1.y, (not used), (not used)]
     xmm2 = [ v1.z, v1.w, (not used), (not used)]
     --------------------------------------
     output:
     result will be stored in xmm0 and xmm1
     register with following order
     xmm0 = [ res.x, res.y, [not used], [not used]]
     xmm1 = [ res.z, res.w, [not used], [not used]]
    --------------------------------------}
    operator * (const scalar : single; const v1 : TVector) res : TVector; assembler;
    asm
        //copy low quadword of xmm2 to high quadword of xmm1
        //xmm1 = {v1.x, v1.y, v1.z, v1.w}
        movlhps xmm1, xmm2

        //shuffle xmm2 so that
        //xmm2 = {scalar, scalar, scalar, scalar}
        shufps xmm0, xmm0, 00000000b

        //multiply xmm0 and xmm1
        //xmm0 = {v1.x * scalar,
        //        v1.y * scalar,
        //        v1.z * scalar,
        //        v1.w * scalar}
        mulps xmm0, xmm1

        //copy high quadword of xmm0 to low quadword of xmm1
        //xmm1 = {res.z, res.w, [not used], [not used]}
        movhlps xmm1, xmm0
    end;

    {-------------------------------------
     Dot product of two vectors using SSE instruction
     -------------------------------------
     res = v1.x * v2.x +
           v1.y * v2.y +
           v1.z * v2.z
     -------------------------------------
     input:
     For x86-64 architecture
     v1 and v2 value will be passed
     in xmm0, xmm1, xmm2, xmm3 in following order
     xmm0 = [ v1.x, v1.y, (not used), (not used)]
     xmm1 = [ v1.z, v1.w, (not used), (not used)]
     xmm2 = [ v2.x, v2.y, (not used), (not used)]
     xmm3 = [ v2.z, v2.w, (not used), (not used)]
    --------------------------------------
     output:
     result will be stored in xmm0 register with following order
     xmm0 = [ dotProd, (not used), (not used), (not used)]
    --------------------------------------}
    operator * (const v1 : TVector; const v2 : TVector) res : single; assembler;
    asm
        //this is just to ensure that v1.w = 0.0
        //before shuffle
        //xmm1 = {v1.z, v1.w, 0, 0}
        //after shuffle
        //xmm1 = {v1.z, 0, 0, 0}
        shufps xmm1, xmm1, 11101000b

        //this is just to ensure that v2.w = 0.0
        //before shuffle
        //xmm3 = {v2.z, v2.w, 0, 0}
        //after shuffle
        //xmm3 = {v2.z, 0, 0, 0}
        shufps xmm3, xmm3, 11101000b

        //copy low quadword of xmm1 to high quadword of xmm0
        //xmm0 = {v1.x, v1.y, v1.z, 0}
        movlhps xmm0, xmm1

        //copy low quadword of xmm3 to high quadword of xmm2
        //xmm2 = {v2.x, v2.y, v2.z, 0}
        movlhps xmm2, xmm3

        //multiply xmm0 and xmm2
        //xmm0 = {v1.x * v2.x,
        //        v1.y * v2.y,
        //        v1.z * v2.z,
        //        0}
        //xmm0 = {resx, resy, resz, 0}
        mulps xmm0, xmm2

        //copy high quadword of xmm0 to low quadword of xmm1
        //xmm1 = {resz, 0, [not used], [not used]}
        movhlps xmm1, xmm0

        //xmm0 = {resx, resy, resz, 0}
        //xmm1 = {resz, 0, [not used], [not used]}
        //add horizontal fields so that
        //xmm0 = {resx + resz, resy + 0, [not used], [not used]}
        addps xmm0, xmm1

        //copy xmm0 to xmm1
        //xmm1 = {resx + resz, resy, [not used], [not used]}
        movaps xmm1, xmm0

        //shuffle so that
        //xmm1 = {resy, [not used], [not used], [not used]}
        shufps xmm1, xmm0, 0000001b

        //xmm0 = {resx + resz, resy, [not used], [not used]}
        //xmm1 = {resy, [not used], [not used], [not used]}
        //add so that
        //xmm0 = {resx + resy + resz, [not used], [not used], [not used]}
        addps xmm0, xmm1
    end;

    {-------------------------------------
     Cross product of two vectors
     -------------------------------------
     res.x := v1.y * v2.z - v1.z * v2.y;
     res.y := v1.z * v2.x - v1.x * v2.z;
     res.z := v1.x * v2.y - v1.y * v2.x;
     res.w := 0;
     -------------------------------------
     input:
     For x86-64 architecture
     v1 and v2 value will be passed
     in xmm0, xmm1, xmm2, xmm3 in following order
     xmm0 = [ v1.x, v1.y, (not used), (not used)]
     xmm1 = [ v1.z, v1.w, (not used), (not used)]
     xmm2 = [ v2.x, v2.y, (not used), (not used)]
     xmm3 = [ v2.z, v2.w, (not used), (not used)]
    --------------------------------------
     output:
     result will be stored in xmm0 register with following order
     xmm0 = [ res.x, res.y, res.z, (not used)]
    --------------------------------------}
    operator ** (const v1 : TVector; const v2 : TVector) : TVector; assembler;
    asm
        //copy low quadword of xmm1 to high quadword of xmm0
        //xmm0 = {v1.x, v1.y, v1.z, v1.w}
        movlhps xmm0, xmm1

        //copy low quadword of xmm3 to high quadword of xmm2
        //xmm2 = {v2.x, v2.y, v2.z, v2.w}
        movlhps xmm2, xmm3

        //xmm1 = {v1.x, v1.y, v1.z, v1.w}
        //xmm4 = {v1.x, v1.y, v1.z, v1.w}
        movaps xmm1, xmm0
        movaps xmm4, xmm0

        //xmm3 = {v2.x, v2.y, v2.z, v2.w}
        //xmm5 = {v2.x, v2.y, v2.z, v2.w}
        movaps xmm3, xmm2
        movaps xmm5, xmm2

        //xmm1 = {v1.y, v1.z, v1.x, v1.w}
        //xmm4 = {v1.z, v1.x, v1.y, v1.w}
        shufps xmm1, xmm0, 11001001b
        shufps xmm4, xmm0, 11010010b

        //xmm3 = {v2.z, v2.x, v2.y, v2.w}
        //xmm5 = {v2.y, v2.z, v2.x, v2.w}
        shufps xmm3, xmm2, 11010010b
        shufps xmm5, xmm2, 11001001b

        //before multiplication
        //xmm1 = {v1.y, v1.z, v1.x, v1.w}
        //xmm3 = {v2.z, v2.x, v2.y, v2.w}
        //after multiplication
        //xmm1 = {v1.y * v2.z, v1.z * v2.x, v1.x * v2.y, v1.w * v2.w}
        mulps xmm1, xmm3

        //before multiplication
        //xmm4 = {v1.z, v1.x, v1.y, v1.w}
        //xmm5 = {v2.y, v2.z, v2.x, v2.w}
        //after multiplication
        //xmm4 = {v1.z * v2.y, v1.x * v2.z, v1.y * v2.x, v1.w * v2.w}
        mulps xmm4, xmm5

        //before subtraction
        //xmm1 = {v1.y * v2.z, v1.z * v2.x, v1.x * v2.y, v1.w * v2.w}
        //xmm4 = {v1.z * v2.y, v1.x * v2.z, v1.y * v2.x, v1.w * v2.w}
        //after subtraction
        //xmm1 = {(v1.y * v2.z - v1.z * v2.y) , (v1.z * v2.x - v1.x * v2.z), (v1.x * v2.y - v1.y * v2.x) , 0}
        subps xmm1, xmm4

        //xmm0 = {(v1.y * v2.z - v1.z * v2.y) , (v1.z * v2.x - v1.x * v2.z), (v1.x * v2.y - v1.y * v2.x) , 0}
        movaps xmm0, xmm1

        //xmm0 = {(v1.y * v2.z - v1.z * v2.y) , (v1.z * v2.x - v1.x * v2.z), not used, not used}
        //xmm1 = {(v1.x * v2.y - v1.y * v2.x) , 0, not used, not used}
        movhlps xmm1, xmm0
    end;
end.
