'''
test.py in trimesh2pointcloud

author  : simbaforrest
created : 11/5/17 4:29 PM
'''

import os
import sys
import glob
import time
import argparse

import numpy as np
import pymesh

import pyximport
pyximport.install(inplace=True, language_level=3)
from _trimesh2pointcloud import cy_trimesh2pointcloud as tri2pts


def main(args):
    

    mesh = pymesh.load_mesh("/home/prashant/Documents/gitforks/3PU/test_mesh/cupid_aligned.off")
    mesh.add_attribute('vertex_normal')
    V = mesh.vertices.astype(np.float32)
    F = mesh.faces.astype(np.int32)
    Nin = mesh.get_vertex_attribute('vertex_normal').astype(np.float32)

    data = tri2pts(V,F, Nin,5000)
    print(type(data), len(data))
    P, Nout = data
    print(P.shape)
    print(Nout.shape)

    xyzn = np.hstack((P,Nout))
    print(xyzn.shape)
    np.savetxt('cupid.xyzn', xyzn)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(sys.argv[0])

    args = parser.parse_args(sys.argv[1:])
    args.script_folder = os.path.dirname(os.path.abspath(__file__))

    main(args)