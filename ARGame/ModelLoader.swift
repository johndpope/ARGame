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
    /**
     Loads a static model from file using the Assimp library.
     
     - parameters:
        - resource: Name of the resource to be loaded.
        - type: The type of object to be loaded eg. obj.
     
     - returns:
     The loaded model.
     */
    static public func loadStaticModelFromFile(_ resource: String, _ type: String) -> Model
    {
        // Find obj path of resource
        let objPath = Bundle.main.path(forResource: resource, ofType: type)
        
        // Convert path to C string
        let cpath = objPath?.cString(using: .utf8)
        
        // Load model using C code
        let loader = UnsafeRawPointer(mlLoadStaticAssimpModel(cpath))
        
        // Extract the meshes from the assimp loader
        let meshes: Array<Mesh> = extractMeshesFromLoader(loader!)
        
        // Destroy assimp model
        mlDestroyAssimpModelLoader(loader)
        
        return Model(meshes);
    }
    
    /**
     Loads a animated model from file using the Assimp library.
     
     - parameters:
     - resource: Name of the resource to be loaded.
     - type: The type of object to be loaded eg. fbx.
     
     - returns:
     The loaded animated model.
     */
    static public func loadAnimatedModelFromFile(_ resource: String, _ type: String) -> ModelAnimated
    {
        // Find obj path of resource
        let objPath = Bundle.main.path(forResource: resource, ofType: type)
        
        // Convert path to C string
        let cpath = objPath?.cString(using: .utf8)
        
        // Load model using C code
        let loader = UnsafeRawPointer(mlLoadAnimatedAssimpModel(cpath))
        
        // Extract the meshes from the assimp loader
        let meshes: Array<Mesh> = extractMeshesFromLoader(loader!)
        
        // Extract the animations from the assimp loader
        let animations: Array<Animation> = extractAnimationsFromLoader(loader!)
        
        // Destroy assimp model
        mlDestroyAssimpModelLoader(loader)
        
        return ModelAnimated(meshes, animations);
    }
    
    /**
     Extracts a mesh array from the assimp loader class.
     
     - parameters:
        - loader: An unsafe pointer to the C++ AssimpModelLoader object.
     
     - returns:
     A Mesh array.
     */
    static private func extractMeshesFromLoader(_ loader:UnsafeRawPointer) -> Array<Mesh>
    {
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
            
            // Diffuse texture
            var diffuseTexture: GLKTextureInfo = GLKTextureInfo()
            var diffTexName: String? = nil
            let opt:[String: NSNumber] = [GLKTextureLoaderGenerateMipmaps:false]
            
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
                    //mesh.setDiffuseTexture(diffuseTexture!)
                }catch
                {
                    
                    print("Could not load diffuse texture for model")
                }
                
            }
            
            // Specular texture
            var specularTexture: GLKTextureInfo = GLKTextureInfo()
            var specTexName: String? = nil
            
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
                    //mesh.setSpecularTexture(specularTexture!)
                }catch
                {
                    print("Could not load specular texture for model")
                }
            }
            
            // Diffuse colour
            let diffCol = Array(UnsafeBufferPointer(start: mlGetMeshDiffuseCol(loader, i), count: 4))
            let diffuseColour:GLKVector4 = GLKVector4Make(diffCol[0], diffCol[1], diffCol[2], diffCol[3])
            print("Diffuse Colour R: \(diffCol[0]) G: \(diffCol[1]) B: \(diffCol[2]) A: \(diffCol[3])")
            
            
            // Specular colour
            let specCol = Array(UnsafeBufferPointer(start: mlGetMeshSpecularCol(loader, i), count: 4))
            let specularColour:GLKVector4 = GLKVector4Make(specCol[0], specCol[1], specCol[2], specCol[3])
            print("Specular Colour R: \(specCol[0]) G: \(specCol[1]) B: \(specCol[2]) A: \(specCol[3])")
            
            // Shininess
            let shininess: Float = Float(mlGetMeshShininess(loader, i))
            
            let material: Material = Material(diffuseTexture, specularTexture, diffuseColour, specularColour, shininess)
            mesh.setMaterial(material)
            
            //
            //   Mesh Loading complete
            //
            
            // Add mesh to new mesh array
            meshes.append(mesh)
        }

        return meshes
    }
    
    /**
     Extracts a animation array from the assimp loader class.
     
     - parameters:
        - loader: An unsafe pointer to the C++ AssimpModelLoader object.
     
     - returns:
     A Animation array.
     */
    static private func extractAnimationsFromLoader(_ loader:UnsafeRawPointer) -> Array<Animation>
    {
        // Instantiate animations array to fill
        var animations: Array<Animation> = Array()
        
        // Get number of animations loaded
        let numAnimations: UInt32 = mlGetNumAnimations(loader)
        
        // Loop over all animations
        for i in 0..<numAnimations
        {
            //
            // Load animation duration
            //
            let duration: Double = mlGetAnimationDuration(loader, i)
            
            //
            // Load animation ticks per second
            //
            let ticksPerSecond: Double = mlGetAnimationTicksPerSecond(loader, i)
            
            // 
            // Load animation channels
            //
            var channels: Array<AnimationChannel> = Array()
            let numChannels: UInt32 = mlGetNumChannelsInAnimation(loader, i)
            
            for j in 0..<numChannels
            {
                // Load channel name
                let name: String = String(cString: mlGetAnimationChannelName(loader, i, j))
                
                // load channel positions
                var positions:Array<GLKVector3> = Array()
                let numPositions: Int = Int(mlGetNumPositionsInChannel(loader, i, j))
                var cPositions = Array(UnsafeBufferPointer(start: mlGetAnimationChannelPositions(loader, i, j), count: numPositions))
                
                for k in stride(from: 0, to: numPositions, by: 3)
                {
                    positions.append(GLKVector3Make(cPositions[k], cPositions[k+1], cPositions[k+2]))
                }
                
                // load channel positions
                var scales:Array<GLKVector3> = Array()
                let numScales: Int = Int(mlGetNumScalesInChannel(loader, i, j))
                var cScales = Array(UnsafeBufferPointer(start: mlGetAnimationChannelScales(loader, i, j), count: numScales))
                
                for k in stride(from: 0, to: numScales, by: 3)
                {
                    scales.append(GLKVector3Make(cScales[k], cScales[k+1], cScales[k+2]))
                }
                
                // load channel rotations
                var rotations:Array<GLKMatrix3> = Array()
                let numRotations: Int = Int(mlGetNumRotationsInChannel(loader, i, j))
                var cRotations = Array(UnsafeBufferPointer(start: mlGetAnimationChannelRotations(loader, i, j), count: numRotations))
                
                for k in stride(from: 0, to: numRotations, by: 9)
                {
                    rotations.append(GLKMatrix3Make(cRotations[k], cRotations[k+1], cRotations[k+2], cRotations[k+3], cRotations[k+4], cRotations[k+5], cRotations[k+6], cRotations[k+7], cRotations[k+8]))
                }
                
                // Insert channel into channels
                channels.append(AnimationChannel(name, positions, scales, rotations))
            }
            
            // Insert animation into animations
            animations.append(Animation(duration, ticksPerSecond, channels))
        }
        
        return animations
    }
}
