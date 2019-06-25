'''
_trimesh2pointcloud.pyx

author  : cfeng
created : 11/05/17 11:45 AM
'''

# cimport openmp
cimport cython
# from cython.parallel cimport prange, parallel, threadid

from libcpp.vector cimport vector
import numpy as np
cimport numpy as np


cdef extern from "utils_sampling.hpp" namespace "Utils_sampling":
    void poisson_disk_raw(
        int nb_samples, const float *pVerts, const int nVerts,
        const float *pNormals,
        const int *pTris, const int nTris,
        vector[float] &sampled_pos,
        vector[float] &sampled_normals
    )


@cython.boundscheck(False)
@cython.wraparound(False)
def _cy_trimesh2pointcloud(
    np.ndarray[np.float32_t, ndim=2, mode="c"]  V,
    np.ndarray[int, ndim=2, mode="c"]           F,
    np.ndarray[np.float32_t, ndim=2, mode="c"]  Nin,
    int                                         k
    ):
    '''
    Input:
        V <Nx3>: tri-mesh vertices of N vertices
        F <Mx3>: tri-mesh indices of M triangles
        Nin <Nx3>: tri-mesh normals of N vertices
        k <1>:   number of points to be sampled on the tri-mesh using poisson disk sampling
    Output:
        P <lx3>: sampled points, l almost equal to k
        Nout <lx3>: sampled points, l almost equal to k
    '''
    cdef vector[float] Praw
    cdef vector[float] Nraw
    poisson_disk_raw(
        k,
        &V[0,0], V.shape[0],
        &Nin[0,0],
        &F[0,0], F.shape[0],
        Praw, Nraw
    )
    cdef np.ndarray P = np.array(Praw).reshape((Praw.size()/3, 3))
    cdef np.ndarray Nout = np.array(Nraw).reshape((Nraw.size()/3, 3))
    return P, Nout


def cy_trimesh2pointcloud(V, F, Nin, k):
    V = np.require(V, dtype=np.float32, requirements=['C'])
    Nin = np.require(Nin, dtype=np.float32, requirements=['C'])
    F = np.require(F, dtype=np.int32, requirements=['C'])
    k2= int(k)
    #while True:
    P, Nout = _cy_trimesh2pointcloud(V, F, Nin, k2)
        #if P.shape[0]<k:
        #    k2*=2
        #else:
        #    break
    #np.random.shuffle(P)
    return P[:k, :], Nout[:k, :]