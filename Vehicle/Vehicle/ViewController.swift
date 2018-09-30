//
//  ViewController.swift
//  Floor is Lava
//
//  Created by Daryl Annen on 11/7/17.
//  Copyright © 2017 Daryl Annen. All rights reserved.
//

import UIKit
import ARKit
import CoreMotion

class ViewController: UIViewController, ARSCNViewDelegate {
    
    let configuration = ARWorldTrackingConfiguration()
    let motionManager = CMMotionManager()
    var vehicle = SCNPhysicsVehicle()
    var orientation: CGFloat = 0
    var accelerationValues = [UIAccelerationValue(0), UIAccelerationValue(0)]
    var touched: Int = 0
    
    @IBOutlet weak var sceneView: ARSCNView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(configuration)
        self.sceneView.delegate = self
        self.setupAccelerometer()
        self.sceneView.showsStatistics = true
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else {return}
        self.touched += touches.count
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touched = 0
    }
    
    func createConcrete(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let concreteNode = SCNNode(geometry: SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z)))
        concreteNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "Concrete")
        concreteNode.geometry?.firstMaterial?.isDoubleSided = true
        concreteNode.position = SCNVector3(planeAnchor.center.x, planeAnchor.center.y, planeAnchor.center.z)
        concreteNode.eulerAngles = SCNVector3(90.degreesToRadians, 0, 0)
        let staticBody = SCNPhysicsBody.static()
        concreteNode.physicsBody = staticBody
        return concreteNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
        print("new flat surface detected")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        print("flat surface updated")
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        let concreteNode = createConcrete(planeAnchor: planeAnchor)
        node.addChildNode(concreteNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let _ = anchor as? ARPlaneAnchor else { return }
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
    @IBAction func addCar(_ sender: Any) {
        guard let pointOfView = sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        
        let scene = SCNScene(named: "car-scene.scn")
        let chassis = (scene?.rootNode.childNode(withName: "chassis", recursively: false))!
        let frontDriverWheel = chassis.childNode(withName: "frontDriverWheelParent", recursively: false)!
        let frontPassengerWheel = chassis.childNode(withName: "frontPassengerWheelParent", recursively: false)!
        let rearDriverWheel = chassis.childNode(withName: "rearDriverWheelParent", recursively: false)!
        let rearPassengerWheel = chassis.childNode(withName: "rearPassengerWheelParent", recursively: false)!
        
        let v_frontDriverWheel = SCNPhysicsVehicleWheel(node: frontDriverWheel)
        let v_frontPassengerWheel = SCNPhysicsVehicleWheel(node: frontPassengerWheel)
        let v_rearDriverWheel = SCNPhysicsVehicleWheel(node: rearDriverWheel)
        let v_rearPassengerWheel = SCNPhysicsVehicleWheel(node: rearPassengerWheel)
        
        chassis.position = currentPositionOfCamera
        let body = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(node: chassis, options: [SCNPhysicsShape.Option.keepAsCompound: true]))
        body.mass = 5
        chassis.physicsBody = body
        self.vehicle = SCNPhysicsVehicle(chassisBody: chassis.physicsBody!, wheels: [v_rearDriverWheel, v_rearPassengerWheel, v_frontDriverWheel, v_frontPassengerWheel])
        self.sceneView.scene.physicsWorld.addBehavior(self.vehicle)
        
        self.sceneView.scene.rootNode.addChildNode(chassis)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        var engineForce: CGFloat = 0
        var brakingForce: CGFloat = 0
        self.vehicle.setSteeringAngle(-orientation, forWheelAt: 2)
        self.vehicle.setSteeringAngle(-orientation, forWheelAt: 3)
        if self.touched == 1 {
            engineForce = 50
        } else if self.touched == 2 {
            engineForce = -50
        } else if self.touched == 3 {
            brakingForce = 100
        }
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 0)
        self.vehicle.applyEngineForce(engineForce, forWheelAt: 1)   
        self.vehicle.applyBrakingForce(brakingForce, forWheelAt: 0)
        self.vehicle.applyBrakingForce(brakingForce, forWheelAt: 1)
    }
    
    func setupAccelerometer() {
        
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 1/60
            motionManager.startAccelerometerUpdates(to: .main, withHandler: { (accelerometerData, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                self.accelerometerDidChange(acceleration: accelerometerData!.acceleration)

            })
            
        } else {
            print("accelerometer not availible")
        }
    }
    
    func accelerometerDidChange(acceleration: CMAcceleration) {
        accelerationValues[1] = filtered(currentAcceleration: accelerationValues[1], UpdatedAcceleration: acceleration.y)
        accelerationValues[0] = filtered(currentAcceleration: accelerationValues[0], UpdatedAcceleration: acceleration.x)
        
        if accelerationValues[0] > 0  {
            self.orientation = -CGFloat(accelerationValues[1])
        } else {
            self.orientation = CGFloat(accelerationValues[1])
        }
    }
    
    func filtered(currentAcceleration: Double, UpdatedAcceleration: Double) -> Double {
        let kfilteringFactor = 0.5
        return UpdatedAcceleration * kfilteringFactor + currentAcceleration * (1 - kfilteringFactor)
    }
    


}

extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180}
}

func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + left.z)
}

