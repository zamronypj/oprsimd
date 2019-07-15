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
