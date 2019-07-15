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
