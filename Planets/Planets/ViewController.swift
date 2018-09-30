//
//  ViewController.swift
//  Planets
//
//  Created by Daryl Annen on 11/2/17.
//  Copyright © 2017 Daryl Annen. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        self.sceneView.autoenablesDefaultLighting = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        let sun = SCNNode(geometry: SCNSphere(radius: 0.35))
        let mercuryParent = SCNNode()
        let venusParent = SCNNode()
        let earthParent = SCNNode()
        
        sun.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Sun")
        sun.position = SCNVector3(0,0,-1)
        
        mercuryParent.position = SCNVector3(0,0,-1)
        venusParent.position = SCNVector3(0,0,-1)
        earthParent.position = SCNVector3(0,0,-1)
        
        self.sceneView.scene.rootNode.addChildNode(sun)
        self.sceneView.scene.rootNode.addChildNode(venusParent)
        self.sceneView.scene.rootNode.addChildNode(earthParent)
        
        let mercury =  SCNNode()
        mercury.geometry = SCNSphere(radius: 0.005)
        mercury.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Mercury")
        mercury.position = SCNVector3(0.5,0, 0)
        sun.addChildNode(mercury)
        
        mercury.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)))
        
        let venus = planet(geometry: SCNSphere(radius: 0.04), diffuse: #imageLiteral(resourceName: "Venus"), specular: nil, emission: #imageLiteral(resourceName: "Venus atmosphere"), normal: nil, position: SCNVector3(0.7,0, 0))
        
        venus.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)))
        
        let earth = planet(geometry: SCNSphere(radius: 0.06), diffuse: #imageLiteral(resourceName: "Earth night"), specular: #imageLiteral(resourceName: "Earth spec"), emission: #imageLiteral(resourceName: "Earth clouds"), normal: #imageLiteral(resourceName: "Earth normal"), position: SCNVector3(1.2,0,0))
        
        let moon = planet(geometry: SCNSphere(radius: 0.01), diffuse: #imageLiteral(resourceName: "Moon"), specular: nil, emission: nil, normal: nil, position: SCNVector3(0,0,-0.1))
        
        let venusMoon = planet(geometry: SCNSphere(radius: 0.01), diffuse: #imageLiteral(resourceName: "Moon"), specular: nil, emission: nil, normal: nil, position: SCNVector3(0,0,-0.15))
        
        mercuryParent.addChildNode(mercury)
        venusParent.addChildNode(venus)
        earthParent.addChildNode(earth)
        earth.addChildNode(moon)
        venus.addChildNode(venusMoon)
        
        
        let earthParentRotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 14)
        let venusParentRotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 10)
        let mercuryParentRotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)
        
        mercuryParent.runAction(SCNAction.repeatForever(mercuryParentRotation))
        venusParent.runAction(SCNAction.repeatForever(venusParentRotation))
        earthParent.runAction(SCNAction.repeatForever(earthParentRotation))
        
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
        let forev = SCNAction.repeatForever(rotation)
        earth.runAction(forev)
        
        let mars =  SCNNode()
        mars.geometry = SCNSphere(radius: 0.02)
        mars.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Mars")
        mars.position = SCNVector3(2.4,0, 0)
        sun.addChildNode(mars)
        
        mars.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)))
        
        let jupiter =  SCNNode()
        jupiter.geometry = SCNSphere(radius: 0.12)
        jupiter.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Jupiter")
        jupiter.position = SCNVector3(4,0, 0)
        sun.addChildNode(jupiter)
        
        jupiter.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 2)))
        
        let saturn =  SCNNode()
        saturn.geometry = SCNSphere(radius: 0.08)
        saturn.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Saturn")
        saturn.position = SCNVector3(6,0, 0)
        sun.addChildNode(saturn)
        
        saturn.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)))
        
        let uranus =  SCNNode()
        uranus.geometry = SCNSphere(radius: 0.06)
        uranus.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Uranus")
        uranus.position = SCNVector3(9,0, -1)
        sun.addChildNode(uranus)
        
        uranus.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)))
        
        let neptune =  SCNNode()
        neptune.geometry = SCNSphere(radius: 0.02)
        neptune.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Neptune")
        neptune.position = SCNVector3(14,0, -1)
        sun.addChildNode(neptune)
        
        neptune.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 6)))
        
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: 8)
        let forever = SCNAction.repeatForever(action)
        sun.runAction(forever)
    }
    
    
    
    func planet(geometry: SCNGeometry, diffuse: UIImage, specular: UIImage?, emission: UIImage?, normal: UIImage?, position: SCNVector3) -> SCNNode {
        let planet = SCNNode(geometry: geometry)
        planet.geometry?.firstMaterial?.diffuse.contents = diffuse
        planet.geometry?.firstMaterial?.specular.contents = specular
        planet.geometry?.firstMaterial?.emission.contents = emission
        planet.geometry?.firstMaterial?.normal.contents = normal
        planet.position = position
        return planet
    }
    
    func rotation(time: TimeInterval) -> SCNAction {
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat(360.degreesToRadians), z: 0, duration: time)
        let foreverRotation = SCNAction.repeatForever(rotate)
        return foreverRotation
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

