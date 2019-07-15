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
