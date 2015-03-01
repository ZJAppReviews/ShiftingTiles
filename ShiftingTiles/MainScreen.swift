//
//  MainScreen.swift
//  ShiftingTiles
//
//  Created by Parker Lewis on 9/3/14.
//  Copyright (c) 2014 Parker Lewis. All rights reserved.
//



import Foundation
import UIKit
import AVFoundation
import CoreMedia
import CoreVideo
import ImageIO
import QuartzCore

class MainScreen: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Misc vars
    let colorPalette = ColorPalette()
    let userDefaults = NSUserDefaults.standardUserDefaults()
    var imageGallery = ImageGallery()
    var imagePackageArray : [ImagePackage]?
    var currentImagePackage : ImagePackage?
    var tilesPerRow = 3

    
    // MARK: AVFoundation vars
    var captureSession : AVCaptureSession?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var stillImageOutput : AVCaptureStillImageOutput?

    
    // MARK: VIEWS
    @IBOutlet weak var shiftingTilesLabel: UILabel!
    @IBOutlet weak var imageCollection: UICollectionView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tilesPerRowLabel: UILabel!
    @IBOutlet weak var imageCapturingButtonArea: UIView!
    @IBOutlet weak var imageCapturingButtonAreaFakeBorder: UIView!
    // Categories
    @IBOutlet weak var categoryArea: UIView!
    @IBOutlet weak var selectCategoryButton: UIButton!
    @IBOutlet weak var animalsCategoryButton: UIButton!
    @IBOutlet weak var natureCategoryButton: UIButton!
    @IBOutlet weak var placesCategoryButton: UIButton!
    // Other buttons
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var letsPlayButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var captureImageButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: Constraints
    @IBOutlet weak var imageCapturingAreaTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoriesHeightConstraint: NSLayoutConstraint!

    
    
    
    // MARK: Lifecycle methods
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set up and style the views
        self.view.sendSubviewToBack(self.imageCapturingButtonArea)
        self.imageCapturingButtonArea.alpha = 0

        self.mainImageView.layer.borderWidth = 2
        self.letsPlayButton.layer.cornerRadius = self.letsPlayButton.frame.width * 0.25
        self.letsPlayButton.layer.borderWidth = 2

        self.categoryArea.layer.borderWidth = 2
        self.natureCategoryButton.layer.borderWidth = 2
        self.animalsCategoryButton.userInteractionEnabled = false
        self.natureCategoryButton.userInteractionEnabled = false
        self.placesCategoryButton.userInteractionEnabled = false
        self.animalsCategoryButton.alpha = 0
        self.natureCategoryButton.alpha = 0
        self.placesCategoryButton.alpha = 0

        self.updateColorsAndFonts()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        self.imageCollection.delegate = self
        self.imageCollection.dataSource = self
        
        // Set user defaults upon the first launch
        if(!self.userDefaults.boolForKey("firstlaunch1.0")){
            self.userDefaults.setBool(true, forKey: "firstlaunch1.0")
            self.userDefaults.setBool(true, forKey: "congratsOn")
            self.userDefaults.setInteger(3, forKey: "colorPaletteInt")
            self.userDefaults.synchronize()
        }
        
        // Register the nib for the CollectionView cells
        let nib = UINib(nibName: "CollectionViewImageCell", bundle: NSBundle.mainBundle())
        self.imageCollection.registerNib(nib, forCellWithReuseIdentifier: "CELL")

        // Choose which size of images to use based on device
        self.imagePackageArray = self.imageGallery.animalImagePackages
        self.currentImagePackage = self.imagePackageArray![0]
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            self.currentImagePackage?.image = UIImage(named: self.currentImagePackage!.mediumFileName!)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.currentImagePackage?.image = UIImage(named: self.currentImagePackage!.largeFileName!)
        }
        self.mainImageView.image = self.currentImagePackage?.image!

        // Tiles per row label
        self.tilesPerRowLabel.adjustsFontSizeToFitWidth = true
        self.tilesPerRow = 3
        self.tilesPerRowLabel.text = "3 x 3"
    }
    
    
    
    // Segue to game screen
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if self.categoriesHeightConstraint.constant != 0 {
            self.shrinkCategories()
        }

        if segue.identifier == "playGame" {
            var gameScreen = segue.destinationViewController as GameScreen
            gameScreen.currentImagePackage = self.currentImagePackage
            gameScreen.tilesPerRow = self.tilesPerRow
        }
    }
    

    
    //MARK: CATEGORIES
    @IBAction func selectCategoryButtonPressed(sender: AnyObject) {
        if self.categoriesHeightConstraint.constant == 0 {
            self.expandCategories()
        } else {
            self.shrinkCategories()
        }
    }
    
    
    func expandCategories() {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            self.categoriesHeightConstraint.constant = 120
        }
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.categoriesHeightConstraint.constant = 180
        }
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.animalsCategoryButton.userInteractionEnabled = true
            self.natureCategoryButton.userInteractionEnabled = true
            self.placesCategoryButton.userInteractionEnabled = true
            self.animalsCategoryButton.alpha = 1
            self.natureCategoryButton.alpha = 1
            self.placesCategoryButton.alpha = 1
            
            self.view.layoutIfNeeded()
        })
    }
    
    
    func shrinkCategories() {
        self.categoriesHeightConstraint.constant = 0
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.animalsCategoryButton.userInteractionEnabled = false
            self.natureCategoryButton.userInteractionEnabled = false
            self.placesCategoryButton.userInteractionEnabled = false
            self.animalsCategoryButton.alpha = 0
            self.natureCategoryButton.alpha = 0
            self.placesCategoryButton.alpha = 0
            
            self.view.layoutIfNeeded()
        })
    }
    
    
    @IBAction func animalCategoryPressed(sender: AnyObject) {
        self.changeToCategory(1)
    }
    
    
    @IBAction func natureCategoryPressed(sender: AnyObject) {
        self.changeToCategory(2)
    }
    
    
    @IBAction func placesCategoryPressed(sender: AnyObject) {
        self.changeToCategory(3)
    }
    
    
    func changeToCategory(category: Int) {
        // Update the imagePackageArray
        if category == 1 {
            self.imagePackageArray = self.imageGallery.animalImagePackages
        } else if category == 2 {
            self.imagePackageArray = self.imageGallery.natureImagePackages
        } else if category == 3 {
            self.imagePackageArray = self.imageGallery.placesImagePackages
        }
        
        // Update the currentImagePackage
        self.currentImagePackage = self.imagePackageArray![0]
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            self.currentImagePackage?.image = UIImage(named: self.currentImagePackage!.mediumFileName)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.currentImagePackage?.image = UIImage(named: self.currentImagePackage!.largeFileName)
        }
        
        //Update the mainImageView and the CollectionView
        UIView.transitionWithView(self.mainImageView,
            duration: 0.5,
            options: .TransitionCrossDissolve,
            animations: { self.mainImageView.image = self.currentImagePackage?.image },
            completion: nil)
        self.imageCollection.reloadData()
        self.shrinkCategories()
    }
    

    
    //MARK: COLLECTION VIEW
    // Number of cells = number of images
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagePackageArray!.count
    }
    
    
    // Cells will be square sized
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        return CGSize(width: self.imageCollection.frame.height * 0.9, height: self.imageCollection.frame.height * 0.9)
    }

    
    // Create cell from nib and load the appropriate image
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = self.imageCollection.dequeueReusableCellWithReuseIdentifier("CELL", forIndexPath: indexPath) as CollectionViewImageCell
        cell.imageView.image = UIImage(named: self.imagePackageArray![indexPath.row].smallFileName)
        return cell
    }
    
    
    // Selecting a cell loads the image to the main image view
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if self.categoriesHeightConstraint.constant != 0 {
            self.shrinkCategories()
        }

        self.currentImagePackage = self.imagePackageArray![indexPath.row]
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            self.currentImagePackage?.image = UIImage(named: self.currentImagePackage!.mediumFileName)
        }
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.currentImagePackage?.image = UIImage(named: self.currentImagePackage!.largeFileName)
        }

        UIView.transitionWithView(self.mainImageView,
            duration: 0.5,
            options: .TransitionCrossDissolve,
            animations: { self.mainImageView.image = self.currentImagePackage?.image },
            completion: nil)

    }
    
    
    

    // MARK: Camera methods
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        self.selectCategoryButton.userInteractionEnabled = false
        if self.categoriesHeightConstraint.constant != 0 {
            self.shrinkCategories()
        }

        var pickPhotoMenu = UIAlertController(title: NSLocalizedString("CameraButtonAlert_Part1", comment: ""), message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let libraryAction = UIAlertAction(title: NSLocalizedString("CameraButtonAlert_Part2", comment: ""), style: UIAlertActionStyle.Default) { (handler) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
        let cameraAction = UIAlertAction(title: NSLocalizedString("CameraButtonAlert_Part3", comment: ""), style: UIAlertActionStyle.Default) { (handler) -> Void in
            
            // Check if device has a camera
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                
                // Check authorization status
                let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
                if status == AVAuthorizationStatus.Authorized {
                    if self.captureSession == nil {
                        self.setupAVFoundation()
                    } else {
                        self.view.layer.addSublayer(self.previewLayer)
                        self.captureSession!.startRunning()
                    }
                    
                    // Display the capture button and block out other controls
                    self.view.bringSubviewToFront(self.imageCapturingButtonArea)
                    self.imageCapturingButtonArea.alpha = 1
                    
                    self.imageCapturingAreaTopConstraint.constant = 5
                    UIView.animateWithDuration(0.8, animations: { () -> Void in
                        self.view.layoutIfNeeded()
                    })
                }
                if status == AVAuthorizationStatus.Denied {
                    var noAccessAlert = UIAlertController(title: NSLocalizedString("CameraAccessAlert_Part1", comment: ""), message: NSLocalizedString("CameraAccessAlert_Part2", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel) { (handler) -> Void in
                        self.selectCategoryButton.userInteractionEnabled = true
                    }
                    noAccessAlert.addAction(okAction)
                    self.presentViewController(noAccessAlert, animated: true, completion: nil)
                }
                if status == AVAuthorizationStatus.NotDetermined {
                    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
                        if granted {
                            println("Granted access to camera")
                        } else {
                            println("Access to camera denied")
                        }
                    })
                }
            } else { // No camera on device
                var noCameraAlert = UIAlertController(title: "", message: NSLocalizedString("NoCameraAlert", comment: ""), preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel) { (handler) -> Void in
                    self.selectCategoryButton.userInteractionEnabled = true
                }
                noCameraAlert.addAction(okAction)
                self.presentViewController(noCameraAlert, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: UIAlertActionStyle.Cancel) { (handler) -> Void in
            self.selectCategoryButton.userInteractionEnabled = true
        }

        pickPhotoMenu.addAction(libraryAction)
        pickPhotoMenu.addAction(cameraAction)
        pickPhotoMenu.addAction(cancelAction)
        self.presentViewController(pickPhotoMenu, animated: true, completion: nil)
    }
    
    
    
    func setupAVFoundation() {
        // Capture Session
        self.captureSession = AVCaptureSession()
        self.captureSession!.sessionPreset = AVCaptureSessionPresetPhoto
        
        // Preview layer
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        var bounds = self.mainImageView.bounds
        self.previewLayer!.bounds = CGRectMake(bounds.origin.x + 2, bounds.origin.y + 2, bounds.width - 4, bounds.height - 4)
        self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer!.position = CGPointMake(CGRectGetMidX(bounds) + self.mainImageView.frame.origin.x, CGRectGetMidY(bounds) + self.mainImageView.frame.origin.y)
        self.view.layer.addSublayer(self.previewLayer)
        
        // Capture Device
        self.captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        var err : NSError? = nil
        var input = AVCaptureDeviceInput.deviceInputWithDevice(self.captureDevice, error: &err) as AVCaptureDeviceInput!
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        self.captureSession!.addInput(input)

    
        var outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
        self.stillImageOutput = AVCaptureStillImageOutput()
        self.stillImageOutput!.outputSettings = outputSettings
        self.captureSession!.addOutput(self.stillImageOutput)
    
        self.captureSession!.startRunning()
    }
  
    
    @IBAction func cancelImageCaptureMode(sender: AnyObject) {
        self.captureSession!.stopRunning()
        self.previewLayer?.removeFromSuperlayer()

        self.imageCapturingAreaTopConstraint.constant = 300
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (closure) -> Void in
                self.imageCapturingButtonArea.alpha = 0
                self.view.sendSubviewToBack(self.imageCapturingButtonArea)
        }
        self.selectCategoryButton.userInteractionEnabled = true
    }
    
    @IBAction func captureImage(sender: AnyObject) {
        self.imageCapturingAreaTopConstraint.constant = 300
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (closure) -> Void in
            self.imageCapturingButtonArea.alpha = 0
            self.view.sendSubviewToBack(self.imageCapturingButtonArea)
        }

        var videoConnection : AVCaptureConnection?
        for connection in self.stillImageOutput!.connections {
            if let cameraConnection = connection as? AVCaptureConnection {
                for port in cameraConnection.inputPorts {
                    if let videoPort = port as? AVCaptureInputPort {
                        if videoPort.mediaType == AVMediaTypeVideo {
                            videoConnection = cameraConnection
                            break;
                        }
                    }
                }
            }
            if videoConnection != nil {
                break;
            }
        }
        

        // This might not be necessary
        var newOrientation: AVCaptureVideoOrientation
        switch UIDevice.currentDevice().orientation {
        case .PortraitUpsideDown:
            newOrientation = .PortraitUpsideDown;
            break;
        case .LandscapeLeft:
            newOrientation = .LandscapeRight;
            break;
        case .LandscapeRight:
            newOrientation = .LandscapeLeft;
            break;
        default:
            newOrientation = .Portrait;
        }
        videoConnection!.videoOrientation = newOrientation
        
        
        
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.stillImageOutput!.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(buffer : CMSampleBuffer!, error : NSError!) -> Void in
                var data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
                var capturedImage = UIImage(data: data)
                self.previewLayer?.removeFromSuperlayer()
                self.captureSession!.stopRunning()

                // Rotates the image if its imageOrientation property is not Up
                if !(capturedImage!.imageOrientation == UIImageOrientation.Up) {
                    UIGraphicsBeginImageContextWithOptions(capturedImage!.size, false, capturedImage!.scale)
                    capturedImage!.drawInRect(CGRect(origin: CGPointZero, size: capturedImage!.size))
                    var properImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
                    
                    // Now crop to square
                    var squareRect = CGRectMake(0, (properImage.size.height / 2) - (properImage.size.width / 2), properImage.size.width, properImage.size.width)
                    var croppedCGImage = CGImageCreateWithImageInRect(properImage.CGImage, squareRect)
                    var croppedUIImage = UIImage(CGImage: croppedCGImage)

                    capturedImage = croppedUIImage
                    UIGraphicsEndImageContext()
                }
                
                self.currentImagePackage = ImagePackage(baseFileName: "", caption: "", photographer: "")
                self.currentImagePackage?.image = capturedImage!
                self.mainImageView.image = capturedImage!

            })
        }
        self.selectCategoryButton.userInteractionEnabled = true
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var imagePicked = info[UIImagePickerControllerEditedImage] as? UIImage
        
        
        var imageWidth  = imagePicked!.size.width
        var imageHeight  = imagePicked!.size.height
        var rect = CGRect()
        if ( imageWidth < imageHeight) {
            // Potrait mode
            rect = CGRectMake (0, (imageHeight - imageWidth) / 2, imageWidth, imageWidth);
        } else {
            // Landscape mode
            rect = CGRectMake ((imageWidth - imageHeight) / 2, 0, imageHeight, imageHeight);
        }
        
        var croppedCGImage = CGImageCreateWithImageInRect(imagePicked?.CGImage, rect)
        var croppedUIImage = UIImage(CGImage: croppedCGImage)
        
        self.currentImagePackage = ImagePackage(baseFileName: "", caption: "", photographer: "")
        self.currentImagePackage?.image = croppedUIImage!
        self.mainImageView.image = croppedUIImage!

        
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.selectCategoryButton.userInteractionEnabled = true
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        //this gets fired when the users cancel out of the process
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.selectCategoryButton.userInteractionEnabled = true
    }

    
    
    
    // MARK: Other methods
    @IBAction func rightButtonPressed(sender: AnyObject) {
        if self.categoriesHeightConstraint.constant != 0 {
            self.shrinkCategories()
        }

        self.tilesPerRow++
        if self.tilesPerRow > 10 {
            self.tilesPerRow--
            return
        }
        self.tilesPerRowLabel.text = "\(self.tilesPerRow) x \(self.tilesPerRow)"
   }

    
    @IBAction func leftButtonPressed(sender: AnyObject) {
        if self.categoriesHeightConstraint.constant != 0 {
            self.shrinkCategories()
        }

        self.tilesPerRow--
        if self.tilesPerRow < 2 {
            self.tilesPerRow++
            return
        }
        self.tilesPerRowLabel.text = "\(self.tilesPerRow) x \(self.tilesPerRow)"
    }
    
    
    func updateColorsAndFonts() {
        // Colors
        self.view.backgroundColor = self.colorPalette.fetchLightColor()
        self.categoryArea.backgroundColor = self.colorPalette.fetchLightColor()
        self.categoryArea.layer.borderColor = self.colorPalette.fetchDarkColor().CGColor
        self.natureCategoryButton.layer.borderColor = self.colorPalette.fetchDarkColor().CGColor
        self.imageCapturingButtonArea.backgroundColor = self.colorPalette.fetchLightColor()
        self.shiftingTilesLabel.textColor = self.colorPalette.fetchDarkColor()
        self.tilesPerRowLabel.textColor = self.colorPalette.fetchDarkColor()
        self.mainImageView.layer.borderColor = self.colorPalette.fetchDarkColor().CGColor
        self.animalsCategoryButton.setTitleColor(self.colorPalette.fetchDarkColor(), forState: UIControlState.Normal)
        self.natureCategoryButton.setTitleColor(self.colorPalette.fetchDarkColor(), forState: UIControlState.Normal)
        self.placesCategoryButton.setTitleColor(self.colorPalette.fetchDarkColor(), forState: UIControlState.Normal)
        
        // Icons
        self.selectCategoryButton.setImage(UIImage(named: "menuIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.cameraButton.setImage(UIImage(named: "cameraIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.statsButton.setImage(UIImage(named: "statsIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.decreaseButton.setImage(UIImage(named: "decreaseIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.increaseButton.setImage(UIImage(named: "increaseIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.separatorView.backgroundColor = self.colorPalette.fetchDarkColor()
        self.infoButton.setImage(UIImage(named: "infoIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.letsPlayButton.setImage(UIImage(named: "goIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.letsPlayButton.layer.borderColor = self.colorPalette.fetchDarkColor().CGColor
        self.settingsButton.setImage(UIImage(named: "settingsIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.imageCapturingButtonAreaFakeBorder.backgroundColor = self.colorPalette.fetchDarkColor()
        self.captureImageButton.setImage(UIImage(named: "targetIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
        self.cancelButton.setImage(UIImage(named: "backIcon")?.imageWithColor(self.colorPalette.fetchDarkColor()), forState: UIControlState.Normal)
 
        // Fonts
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            self.shiftingTilesLabel.font = UIFont(name: "OpenSans-Bold", size: 40)
            self.tilesPerRowLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
            self.animalsCategoryButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 15)
            self.natureCategoryButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 15)
            self.placesCategoryButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 15)
        }
        
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
            self.shiftingTilesLabel.font = UIFont(name: "OpenSans-Bold", size: 70)
            self.tilesPerRowLabel.font = UIFont(name: "OpenSans-Bold", size: 30)
            self.animalsCategoryButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 30)
            self.natureCategoryButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 30)
            self.placesCategoryButton.titleLabel?.font = UIFont(name: "OpenSans-Bold", size: 30)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        println("MEMORY WARNING")
    }
}