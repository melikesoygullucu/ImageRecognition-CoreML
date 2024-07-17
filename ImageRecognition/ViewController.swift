//
//  ViewController.swift
//  ImageRecognition
//
//  Created by Melike Soygüllücü on 16.07.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var chosenImage = CIImage()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }

    @IBAction func changeButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!){
            chosenImage = ciImage
        }
        
        recognizeImage(image: chosenImage)
    }
    
    func recognizeImage(image: CIImage) {
        // 1. Request
        // 2. Handler
        
        resultLabel.text = "Finding..."
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnRequest, error in
                
                if let results = vnRequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            // if you want to do something faster in background asynchronously
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }
}

