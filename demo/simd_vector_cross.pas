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
