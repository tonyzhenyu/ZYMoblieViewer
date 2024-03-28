#ifndef INCLUDE_JDM_MATH
#define INCLUDE_JDM_MATH

    ///////////////////////////////////////////////////////////////////////////////
    //                  <Function> Remap                                         //
    ///////////////////////////////////////////////////////////////////////////////

    float4 Remap(float4 oa, float4 ob, float4 na, float4 nb, float4 val)
    {
        return (val - oa) / (ob - oa) * (nb - na) + na;
    }
    float Remap(float oa, float ob, float na, float nb, float val)
    {
        return (val - oa) / (ob - oa) * (nb - na) + na;
    }

    // -------------------------------------
    // snap function
    // -------------------------------------
    float Snap(float value,float increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float2 Snap(float2 value,float2 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float3 Snap(float3 value,float3 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float4 Snap(float4 value,float4 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    //

    // -------------------------------------
    // Mod function
    // -------------------------------------
    float mod(float x,float threshold) {
        return x - floor(x * (1.0 /threshold)) * threshold;
    }
    

#endif