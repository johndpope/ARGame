//
//  objLoader.swift
//  ARGame
//
//  Created by James Rogers on 16/02/2017.
//  Copyright © 2017 James Rogers. All rights reserved.
//

import Foundation
import SceneKit

class ModelLoader
{
    /**  Loads a model from file using the Assimp library.
     *
     *  @param resource Name of the resource to be loaded.
     *  @return The loaded model.
     */
    static public func loadObjModelFromFile(_ resource: String) -> Model
    {
        // Find obj path of resource
        let objPath = Bundle.main.path(forResource: resource, ofType: "obj")
        
        // Convert path to C string
        let cpath = objPath?.cString(using: .utf8)
        
        // Load model using C code
        let loader = UnsafeRawPointer(mlLoadAssimpModel(cpath))
        
        // Get number of meshes loaded
        let numMeshes: UInt32 = mlGetNumMeshes(loader)
        
        // Instantiate meshes array to fill
        var meshes: Array<Mesh> = Array()
        
        // Loops over meshes
        for i in 0..<numMeshes
        {
            //
            // Load Vertex data
            // 
            
            // Get vertex data from mesh
            var vertices:Array<Vertex> = Array()
            let numVertices: Int = Int(mlGetNumVerticesInMesh(loader, i))
            
            // Get temporary vertex array from loader
            let cvertices = Array(UnsafeBufferPointer(start: mlGetMeshVertices(loader, i), count: numVertices))
            
            // Fill vertices array
            for j in stride(from: 0, to: numVertices, by: 8)
            {
                // Extract vertex data from vertices array
                let position: GLKVector3 = GLKVector3Make(cvertices[j], cvertices[j+1], cvertices[j+2])
                let normal: GLKVector3 = GLKVector3Make(cvertices[j+3], cvertices[j+4], cvertices[j+5])
                let texCoord: GLKVector2 = GLKVector2Make(cvertices[j+6], cvertices[j+7])
                
                // Add data to new vertex array
                vertices.append(Vertex(position, normal, texCoord))
            }
            
            //
            // Load Index data
            //
            
            // Get index data from mesh
            let numIndices: Int = Int(mlGetNumIndicesInMesh(loader, i))
            let indices = Array(UnsafeBufferPointer(start: mlGetMeshIndices(loader, i), count: numIndices))
            
            //
            // Create Mesh
            //
            let mesh:Mesh = Mesh(vertices, indices)
            
            //
            // Load Material data
            //
            
            var diffuseTexture: GLKTextureInfo? = nil
            var specularTexture: GLKTextureInfo? = nil

            var diffTexName: String? = nil
            var specTexName: String? = nil
            
            let opt:[String: NSNumber] = [GLKTextureLoaderGenerateMipmaps:false]
            
            // Diffuse map
            let isDiffuseLoaded: Bool = Int(mlGetMeshIsDiffuseMapLoaded(loader, i)) != 0
            
            if(isDiffuseLoaded)
            {
                // Load diffuse texture
                diffTexName = String(cString: mlGetMeshDiffuseMap(loader, i))
                
                // Cut extension off of tex name
                let index = diffTexName?.range(of: ".", options: .backwards)?.lowerBound
                let diffTexName2 = diffTexName?.substring(to: index!)
                let diffTexExt = diffTexName?.substring(from: (diffTexName?.index(after: index!))!)
                
                // Get resource path
                let path = Bundle.main.path(forResource: diffTexName2, ofType: diffTexExt)
                
                do
                {
                    // Load texture
                    diffuseTexture = try GLKTextureLoader.texture(withContentsOfFile: path!, options: opt)
                    
                    // Add texture to the mesh
                    mesh.setDiffuseTexture(diffuseTexture!)
                }catch
                {
                    print("Could not load diffuse texture for model: \(resource)")
                }
                
            }
            
            // Specular map
            let isSpecularLoaded: Bool = Int(mlGetMeshIsSpecularMapLoaded(loader, i)) != 0
            if(isSpecularLoaded)
            {
                // Load diffuse texture
                specTexName = String(cString: mlGetMeshSpecularMap(loader, i))
                
                // Cut extension off of tex name
                let index = specTexName?.range(of: ".", options: .backwards)?.lowerBound
                let specTexName2 = specTexName?.substring(to: index!)
                let specTexExt = specTexName?.substring(from: (specTexName?.index(after: index!))!)
                
                // Get resource path
                let path = Bundle.main.path(forResource: specTexName2, ofType: specTexExt)
                
                do
                {
                    // Load texture
                    specularTexture = try GLKTextureLoader.texture(withContentsOfFile: path!, options: opt)
                    
                    // Add texture to the mesh
                    mesh.setSpecularTexture(specularTexture!)
                }catch
                {
                    print("Could not load specular texture for model: \(resource)")
                }
            }
            
            //
            //   Mesh Loading complete
            //
            
            // Add mesh to new mesh array
            meshes.append(mesh)
        }
        
        // Destroy assimp model
        mlDestroyAssimpModelLoader(loader)
        
        return Model(meshes);
    }
}
