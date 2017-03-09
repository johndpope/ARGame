//
//  AssimpModelLoaderCInterface.c
//  ARGame
//
//  Created by James Rogers on 27/02/2017.
//  Copyright © 2017 James Rogers. All rights reserved.
//

#include "AssimpModelLoaderCInterface.h"
#include "AssimpModelLoader.hpp"

const void* mlLoadAssimpModel(const char *path)
{
    // Create instance of AssimpModelLoader
    AssimpModelLoader *loader = new AssimpModelLoader();
    
    // Load the model
    loader->loadAssimpModel(path);
    
    // Return a void pointer to loader
    return (void *)loader;
}

void mlDestroyAssimpModelLoader(const void *loader)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    if(ptrLoader)
        delete ptrLoader;
}

const unsigned int mlGetNumMeshes(const void *loader)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the float array retrieved from AssimpModelLoader
    return ptrLoader->getNumMeshes();
}

const unsigned int mlGetNumVerticesInMesh(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the float array retrieved from AssimpModelLoader
    return ptrLoader->getNumVerticesInMesh(index);
}


const unsigned int mlGetNumIndicesInMesh(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the float array retrieved from AssimpModelLoader
    return ptrLoader->getNumIndicesInMesh(index);
}

const float* mlGetMeshVertices(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the float array retrieved from AssimpModelLoader
    return ptrLoader->getMeshVertices(index);
}

const unsigned int* mlGetMeshIndices(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the unsigned int array retrieved from AssimpModelLoader
    return ptrLoader->getMeshIndices(index);
}

const int mlGetMeshIsDiffuseMapLoaded(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the bool retrieved from AssimpModelLoader
    return ptrLoader->getMeshIsDiffuseMapLoaded(index);
}

const char* mlGetMeshDiffuseMap(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the char array retrieved from AssimpModelLoader
    return ptrLoader->getMeshDiffuseMap(index);
}

const int mlGetMeshIsSpecularMapLoaded(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the bool retrieved from AssimpModelLoader
    return ptrLoader->getMeshIsSpecularMapLoaded(index);
}

const char* mlGetMeshSpecularMap(const void *loader, const unsigned int index)
{
    // Cast void pointer, loader to AssimpModelLoader type
    AssimpModelLoader *ptrLoader = (AssimpModelLoader *)loader;
    
    // Return the char array retrieved from AssimpModelLoader
    return ptrLoader->getMeshSpecularMap(index);
}