//
//  ViewController.swift
//  Image_Classification_CoreML
//
//  Created by Amr Omran on 04/08/2018.
//  Copyright © 2018 Amr Omran. All rights reserved.
//

import UIKit
import Vision
import Speech

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var textView: UITextField!
    
    let speak = AVSpeechSynthesizer()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.isEnabled = false
        let tapImageView = UITapGestureRecognizer(target: self, action: #selector(openGallery))
        imageViewOutlet.isUserInteractionEnabled = true
        imageViewOutlet.addGestureRecognizer(tapImageView)
        imagePicker.delegate = self
    }

    @IBAction func checkImageClassificationBtn(_ sender: Any) {
        if (imageViewOutlet.image == nil){
            print("ImageView is empty")
        }else{
            let image = imageViewOutlet.image
            detectImage(image: image!)
        }
    }
    
    
    // detect the photo by using model, Vision and CoreML
    func detectImage(image: UIImage){
        let model = try! VNCoreMLModel(for: GoogLeNetPlaces().model)
        let visionRequest = VNCoreMLRequest(model: model){ request, error in
            
            let result = request.results as? [VNClassificationObservation]
            let finalResult = result?.first
            DispatchQueue.main.async {
                self.textView.text = "Detection: \(finalResult!.identifier), Confidence: \(Int(finalResult!.confidence * 100)) %"
                let input = "I guess this is \(finalResult!.identifier), and I am \(Int(finalResult!.confidence * 100)) percent sure"
                self.readTheText(input: input)
            }
        }
        let ciImage = CIImage(image: image)
        let handler = VNImageRequestHandler(ciImage: ciImage!, options: [:])
        do{
            try handler.perform([visionRequest])
        }catch{
            print("handler error")
        }
    }
    
    
    // Open the pickerView
    @objc func openGallery(){
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // delegate methode to get the picked Image and set it to the UIImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageViewOutlet.contentMode = .scaleAspectFit
            imageViewOutlet.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    // If the user cancel the picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // To read the text
    func readTheText(input: String){
        let read = AVSpeechUtterance(string: input)
        read.rate = 0.4
        read.pitchMultiplier = 1.2
        speak.speak(read)
    }
    
}







