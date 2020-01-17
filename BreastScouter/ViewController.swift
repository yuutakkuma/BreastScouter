//
//  ViewController.swift
//  BreastScouter
//
//  Created by 渡辺雄太 on 2020/01/18.
//  Copyright © 2020 Yuta Watanabe. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // デリゲートを設定
        imagePicker.delegate = self

        // 撮影した画像を編集不可にする
        imagePicker.allowsEditing = false
        
    }

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        // カメラを利用できるようにする
        imagePicker.sourceType = .camera

        // カメラを起動
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func photoPressed(_ sender: UIBarButtonItem) {
        // 写真を利用できるようにする
        imagePicker.sourceType = .photoLibrary
        // 写真を起動
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickerImage = info[.originalImage] as? UIImage {
            // 撮影した写真をimageViewに反映させる
            imageView.image = userPickerImage
            // CIImageに変換
            guard let ciimage = CIImage(image: userPickerImage) else {
                fatalError("UIImageをCIImageに変換出来ませんでした。")
            }
            // 変換したCIImageを分析
            detect(image: ciimage)
            
        }
        // カメラを閉じる
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    // 撮影した画像を分析するメソッド
    private func detect(image: CIImage) {
        // 画像を分析するモデル
        guard let model = try? VNCoreMLModel(for: MyBreastImageClassifier_1().model ) else {
            fatalError("バストモデルをロード出来ませんでした。")
        }
        // モデルに画像の分析をリクエストする
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation] else {
                fatalError("バストモデルは画像の分析に失敗しました。")
            }
            
            if let result = results.first {
                // 識別子を使用し、画像が何カップか分析する
                if result.identifier.contains("Aカップ") {
                    self.navigationItem.title = "これはAカップです"
                } else if result.identifier.contains("Bカップ") {
                    self.navigationItem.title = "これはBカップです"
                } else if result.identifier.contains("Cカップ") {
                    self.navigationItem.title = "これはCカップです"
                } else {
                    self.navigationItem.title = "測定不可"
                }
            }
        }
        // Imageハンドラーを使用して、画像を分析するリクエストを実行する
        let handler = VNImageRequestHandler(ciImage: image)
        // リクエストを実行
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
    }
    
}

