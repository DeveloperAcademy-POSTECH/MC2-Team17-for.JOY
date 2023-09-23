//
//  ImagePickerView.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/23.
//

import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
     @Binding var selectedImage: UIImage?
     var sourceType: UIImagePickerController.SourceType = .photoLibrary

     func makeCoordinator() -> Coordinator {
         Coordinator(parent: self)
     }

     func makeUIViewController(context: Context) -> UIImagePickerController {
         let imagePickerController = UIImagePickerController()
         imagePickerController.delegate = context.coordinator
         imagePickerController.sourceType = sourceType
         return imagePickerController
     }

     func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

     class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
         let parent: ImagePickerView

         init(parent: ImagePickerView) {
             self.parent = parent
         }

         func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo
            info: [UIImagePickerController.InfoKey: Any]
         ) {
             if let selectedImage = info[.originalImage] as? UIImage {
                 parent.selectedImage = selectedImage
             }
             picker.dismiss(animated: true, completion: nil)
         }
     }
 }

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(selectedImage: .constant(UIImage(named: "test")))
    }
}
