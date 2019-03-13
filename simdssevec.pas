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
     vt1 and v2 value will be passed
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

        //add xmm0 and xmm2
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
end.
