//
//  ViewController.swift
//  attitude3
//
//  Created by Michael Weitzman on 1/12/16.
//  Copyright © 2016 World Source Tech. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation
class ViewController: UIViewController {
    
    @IBOutlet weak var altimiterView: UIImageView!
    var altimiter = UIImage(named:"attitudeIndicator1")
    var captureSession: AVCaptureSession?
    // used to display a preview of the data that is coming in from captureSession's input device
    var previewLayer: AVCaptureVideoPreviewLayer!
    func newVideoCaptureSession() throws -> AVCaptureSession? {
        // Identify the device that we will be capturing from
        let videoCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // try to create an input capturer
        do {
            let videoInput: AVCaptureDeviceInput? = try AVCaptureDeviceInput.init(device: videoCamera)
            let captureSession = AVCaptureSession()
            // we are going to ask for it to handle the data that comes in from the videoInput
            captureSession.addInput(videoInput)
            return captureSession
        } catch let error as NSError { // catch an error if we couldn't capture input
            throw error
        }
    }
    func addPreviewLayerForSession(session: AVCaptureSession) {
        // all views are backed by a layer
        // we only use the layer for special circumstances like using it to create a preview layer
        let rootLayer = self.view.layer
        // create a preview layer that can display the video stream coming in from captureSession
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        // set its frame to be the same as rootLayer's frame to take up the whole screen
        previewLayer.frame = rootLayer.frame
        // add this previewLayer as a sub layer of rootLayer to display video stream
        rootLayer.addSublayer(previewLayer)
    }
    override func viewDidLoad() {
        indicatorLineHorizontal.image = line
        altimiterView.image = altimiter
        super.viewDidLoad()
        do {
            try captureSession = newVideoCaptureSession()
            // create a preview layer that will display the data that this captureSession gets
            addPreviewLayerForSession(captureSession!)
            // start camera
            captureSession!.startRunning()
        } catch let error as NSError {
            fatalError("Error capturing video \(error)")
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // after the view appears then start camera
        captureSession?.startRunning()
    }
    override func viewDidDisappear(animated: Bool) {
        // stop camera then have the view disappear
        captureSession?.stopRunning()
        super.viewDidDisappear(animated)
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        // change the previewLayer's frame to match the frame of the new size after orientation change
        previewLayer.frame = CGRectMake(0, 0, size.width, size.height);
        // figure out the current orientation of the device
        let currentOrientation = UIDevice.currentDevice().orientation
        // create an instance of AVCaptureVideoOrientation
        let videoOrientation = AVCaptureVideoOrientation(rawValue: currentOrientation.rawValue)!
        // then tell the previewLayer how it should change itself
        self.previewLayer.connection.videoOrientation = videoOrientation
    }
    
    
    @IBOutlet weak var indicatorLineHorizontal: UIImageView!
    var line = UIImage(named:"line_indicator")
    
    
    @IBOutlet weak var attitudeLabel: UILabel!
    @IBOutlet weak var rollLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    @IBOutlet weak var yawLabel: UILabel!
    @IBAction func startButtonPressed(sender: UIButton) {
        
        
        motionManager.startDeviceMotionUpdatesToQueue(
            NSOperationQueue.currentQueue()!, withHandler: {
                (deviceMotion, error) -> Void in
                
                if(error == nil) {
                    self.handleDeviceMotionUpdate(deviceMotion!)
                } else {
                    //handle the error
                }
        })

        
        
    }
    let motionManager = CMMotionManager()
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        indicatorLineHorizontal.image = line
//
//        
//        
//    }
//    

    
    func handleDeviceMotionUpdate(deviceMotion:CMDeviceMotion) {
        
        
        
        var attitude = deviceMotion.attitude
        var roll = degrees(attitude.roll)
        rollLabel.text = "\(roll)"
        var pitch = degrees(attitude.pitch)
        pitchLabel.text = "\(pitch)"
        var yaw = degrees(attitude.yaw)
        yawLabel.text = "\(yaw)"
//        print("Roll: \(roll), Pitch: \(pitch), Yaw: \(yaw)")
//        print(indicatorLineHorizontal.frame.origin.x)
        
        var pitchFloat: CGFloat = CGFloat(pitch)
        var rollFloat: CGFloat = CGFloat(roll)
//        
        
        if rollFloat > 0  {
            rollFloat -= 90
        } else if rollFloat < 0 {
            rollFloat += 90
        }
     
      
        
        
        print(rollFloat)
        
       dispatch_async(dispatch_get_main_queue()) {


//        self.indicatorLineHorizontal.frame.offsetInPlace(dx:0, dy: pitchFloat)
        
        UIView.animateWithDuration(0.5, delay: 0.4, options: [], animations: {
            self.indicatorLineHorizontal.frame.origin.y += rollFloat / 40
            }, completion: nil)
        
      
        
        let theAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        theAnimation.fromValue = (CGfloat: 0)
        theAnimation.toValue = (CGfloat: pitchFloat / 12 )
        
//        theAnimation.duration = 0.2
        
        UIView.animateWithDuration(0.5, delay: 0.4, options: [], animations: {
            self.indicatorLineHorizontal!.layer.addAnimation(theAnimation, forKey: "animateMyRotation")
            }, completion: nil)

        
        
        
//        self.indicatorLineHorizontal!.transform = CGAffineTransformMakeRotation(CGFloat(pitchFloat / 90 ))
        
        
        }
    }
    
    
    func degrees(radians:Double) -> Double {
        return  180 / M_PI * radians
    }
    
}

