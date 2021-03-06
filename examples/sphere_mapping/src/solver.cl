/*
   Parallel Computation of Spherical Parameterizations for Mesh Analysis
   Copyright (C) 2011 Athanasiadis Theodoros and Fudos Ioannis

   This software is provided 'as-is', without any express or implied
   warranty.  In no event will the authors be held liable for any damages
   arising from the use of this software.

   Permission is granted to anyone to use this software for any purpose,
   including commercial applications, and to alter it and redistribute it
   freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.
   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.
   3. This notice may not be removed or altered from any source distribution.
   */

#ifndef USE_DOUBLE
#define USE_DOUBLE 0
#endif

#if USE_DOUBLE
#ifdef cl_khr_fp64
    #pragma OPENCL EXTENSION cl_khr_fp64 : enable
#elif defined(cl_amd_fp64)
    #pragma OPENCL EXTENSION cl_amd_fp64 : enable
#else 
    #error "Double precision not supported by OpenCL implementation"
#endif

typedef double scalar_t;
typedef double4 scalar4_t;
#else
typedef float scalar_t;
typedef float4 scalar4_t;
#endif

kernel void solve_conformal( 
        const global scalar4_t *v,
        const global scalar4_t *vf,
        const global int *verts,
        global scalar4_t *v_s,      //output
        const int n,
        const __global scalar_t *w
        )
{
    //Vertex ID
    int id = get_global_id(0);

    if( id >= n )
        return;

    scalar4_t p = vf[id];   //vertex coordinates
    scalar4_t c = (scalar4_t)(0.0f,0.0f,0.0f,0.0f);

    int start = id;
    for( int i = 0; i < STRIDE_SIZE; ++i )
    {
        //neighbor vertex
	      int nid = verts[start];
	      scalar_t weight = w[start];
        c += v[ nid ] * weight;
        start += n;
    }

    c = ONE_MINUS_OMEGA * v[id] + OMEGA * c;

    scalar_t l = dot(c,p) - 1.0f;
    
    v_s[id] = c - p*l;
}

kernel void solve_conformal_res( 
        const global scalar4_t *v,
        const global scalar4_t *vf,
        const global int *verts,
        global scalar4_t *v_s,      //output
        const int n,
        global scalar_t *res,
        const global scalar_t *w
        )
{
    //Vertex ID
    int id = get_global_id(0);

    if( id >= n )
        return;

    scalar4_t p = vf[id];   //vertex coordinates
    scalar4_t c = (scalar4_t)(0.0f,0.0f,0.0f,0.0f);

    int start = id;
    
    for( int i = 0; i < STRIDE_SIZE; ++i )
    {
        //neighbor vertex
	      int nid = verts[start];
	      scalar_t weight = w[start];
        c += v[ nid ] * weight;
        start += n;
    }

    c = ONE_MINUS_OMEGA * v[id] + OMEGA * c;

    scalar_t l = dot(c,p) - 1.0f;
    scalar4_t pos = c - p*l;
    v_s[id] = pos;
    //res[id] = fast_distance(v[id],pos);
    res[id] = distance(v[id],pos);
    //res[id] = dot(v[id]-pos,v[id]-pos);
}

__kernel void solve_equal( 
        const global scalar4_t *v,
        const global scalar4_t *vf,
        const global int *verts,
        global scalar4_t *v_s,      //output
        const int n,
        const global int *bounds)
{
    //Vertex ID
    int id = get_global_id(0);

    if( id >= n )
        return;

    scalar4_t p = vf[id];   //vertex coordinates
    int start = id;
    int size = bounds[id];
    scalar4_t c = v[verts[start]];
    start += n;
    for( int i = 1; i < size; ++i )
    {
        c += v[verts[start]];
        start += n;
    }

    c /= (scalar_t)(size);
    c = ONE_MINUS_OMEGA * v[id] + OMEGA * c;

    scalar_t l = dot(c,p) - 1.0;
    v_s[id] = c - p*l;
}


kernel void solve_equal_res( 
        const global scalar4_t *v,
        const global scalar4_t *vf,
        const global int *verts,
        global scalar4_t *v_s,      //output
        const int n,
        global scalar_t *res,
        const global int *bounds)
{
    //Vertex ID
    int id = get_global_id(0);

    if( id >= n )
        return;

    scalar4_t p = vf[id];   //vertex coordinates
    int start = id;
    int size = bounds[id];
    scalar4_t c = v[verts[start]];
    start += n;
    for( int i = 1; i < size; ++i )
    {
        c += v[verts[start]];
        start += n;
    }

    c /= (scalar_t)(size);
    c = ONE_MINUS_OMEGA * v[id] + OMEGA * c;

    scalar_t l = dot(c,p) - 1.0;
    scalar4_t pos = c - p*l;
    v_s[id] = pos;
    //res[id] = fast_distance(v[id],pos);
    res[id] = distance(v[id],pos);
}

kernel void normalize_solution(const global scalar4_t *v,  const int n, global scalar4_t *vf, global scalar4_t *v_s)
{
    int id = get_global_id(0);

    if( id >= n )
        return;

    vf[id] = v_s[id] = normalize(v[id]);
}

kernel void convergence_conformal_res( 
        const global scalar4_t *v,
        const global int *verts,
        const int n,
        global scalar_t *res,
        const global scalar_t *w
        )
{
    //Vertex ID
    int id = get_global_id(0);

    if( id >= n )
        return;

    scalar4_t c = (scalar4_t)(0.0f,0.0f,0.0f,0.0f);
 
    int start = id;
    
    for( int i = 0; i < STRIDE_SIZE; ++i )
    {
        //neighbor vertex
        //neighbor vertex
	      int nid = verts[start];
	      scalar_t weight = w[start];
        c += v[ nid ] * weight;
        start += n;
    }

    c = normalize(c);

    res[id] = dot(c - v[id],c - v[id]);
}

kernel void convergence_equal_res( 
            const global scalar4_t *v,
            const global int *verts,
            const int n,
            global scalar_t *res,        //residual output
            const global int *bounds)
{
    //Vertex ID
    int id = get_global_id(0);
        
    if( id >= n )
        return;
    
    int start = id;
    int size = bounds[id];
    scalar4_t c = v[verts[start]];
    start += n;
    for( int i = 1; i < size; ++i )
    {
        c += v[verts[start]];
        start += n;
    }

    c /= (scalar_t)(size);
    c = normalize(c);
    
    res[id] = dot(c - v[id],c - v[id]);
}

kernel void lmax_residual(
        const int n, 
        const global scalar_t *res, 
        global scalar_t *res_norma, 
        local scalar_t *work)
{
    //for the recuction the size of the workgroup must be a power of 2
    uint tid = get_global_id(0);
    uint id = get_local_id(0);
 
    work[id] = (tid < n) ? res[tid] : 0;
    barrier(CLK_LOCAL_MEM_FENCE);

    //do reduction in shared mem
    for( uint s = get_local_size(0)/2; s > 0; s >>=1 ) 
    {
        if( id < s && work[id + s] > work[id] )
            work[id] = work[id + s];
        
        barrier(CLK_LOCAL_MEM_FENCE);
    }

    if(id == 0) res_norma[get_group_id(0)] = work[0];
}

kernel void l2_residual(const int n, const const global scalar_t *res, global scalar_t *res_norma, local scalar_t *work )
{
    int id = get_local_id(0);

    scalar_t residue = 0.0;

    for( int i = id; i < n; i += get_local_size(0) )
        residue += res[i];

    work[ id ] = residue;
    barrier(CLK_LOCAL_MEM_FENCE);
    
    //do reduction in shared mem
    for( unsigned int s = get_local_size(0)/2; s > 0; s >>=1 ) 
    {
        if( id < s )
            work[id] += work[id + s];
        
        barrier(CLK_LOCAL_MEM_FENCE);
    }

    if( id == 0 ) 
      res_norma[0] = sqrt( work[0] ) / n;
}

#if 0
__kernel void l2_residual(
        const int n, 
        const const __global scalar_t *res, 
        __global scalar_t *res_norma, 
        __local scalar_t *work)
{
    //for the recuction the size of the workgroup must be a power of 2
    unsigned int tid = get_local_id(0);
    unsigned int i = get_global_id(0);
 
    work[tid] = (i < n) ? res[i] : 0;
    barrier(CLK_LOCAL_MEM_FENCE);

    //do reduction in shared mem
    for( unsigned int s = get_local_size(0)/2; s > 0; s >>=1 ) 
    {
        if( tid < s )
            work[tid] += work[tid + s];
        
        barrier(CLK_LOCAL_MEM_FENCE);
    }

    if(tid == 0) res_norma[get_group_id(0)] = work[0];
}
#endif
