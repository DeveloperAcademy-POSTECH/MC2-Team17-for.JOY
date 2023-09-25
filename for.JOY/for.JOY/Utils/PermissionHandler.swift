//
//  PermissionHandler.swift
//  for.JOY
//
//  Created by hyebin on 2023/09/24.
//

import AVFoundation
import Photos

class PermissionHandler: ObservableObject {
    @Published var areAllPermissionsGranted: Bool = false

    func requestPermissions() {
        var allPermissionsGranted = true

        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                allPermissionsGranted = allPermissionsGranted && granted
                self.checkPermissionsCompleted()
            }
        }

        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                allPermissionsGranted = allPermissionsGranted && (status == .authorized)
                self.checkPermissionsCompleted()
            }
        }

        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                allPermissionsGranted = allPermissionsGranted && granted
                self.checkPermissionsCompleted()
            }
        }

        self.areAllPermissionsGranted = allPermissionsGranted
    }

    private func checkPermissionsCompleted() {
    }

    func checkCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            completion(granted)
        }
    }

    func checkPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            completion(status == .authorized)
        }
    }

    func checkAudioPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            completion(granted)
        }
    }
}
