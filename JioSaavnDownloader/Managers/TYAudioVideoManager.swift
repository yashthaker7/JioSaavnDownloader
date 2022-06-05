//
//  TYAudioVideoManager.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import AVFoundation
import UIKit

enum SpeedMode {
    case faster
    case slower
}

class TYAudioVideoManager: NSObject {
    
    static let shared = TYAudioVideoManager()
    
    typealias Completion = (URL?, Error?) -> Void
    
    typealias Progress = (Float) -> Void
    
    private override init() {
        
    }
    
    func createAudioComposition(_ audioUrl: URL, startTime: CMTime, endTime: CMTime) -> AVMutableComposition? {
        let audioAsset = AVAsset(url: audioUrl)
        
        // Init composition
        let mixComposition = AVMutableComposition.init()
        
        // Get audio track
        guard let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            print("[Error]: Audio not found.")
            return  nil
        }
        
        // Init audio composition track
        let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: .audio,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        do {
            // Add audio track to audio composition at specific time
            try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: .zero, duration: audioAsset.duration), of: audioTrack, at: .zero)
        } catch {
            print(error.localizedDescription)
        }
        return mixComposition
    }
    
    deinit { print("TYAudioVideoManager deinit.") }
}

// MARK:- Private methods
extension TYAudioVideoManager {
    
    fileprivate func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    fileprivate func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset, standardSize: CGSize, atTime: CMTime) -> AVMutableVideoCompositionLayerInstruction {
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var aspectFillRatio:CGFloat = 1
        if assetTrack.naturalSize.height < assetTrack.naturalSize.width {
            aspectFillRatio = standardSize.height / assetTrack.naturalSize.height
        } else {
            aspectFillRatio = standardSize.width / assetTrack.naturalSize.width
        }
        
        if assetInfo.isPortrait {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
            let posY = standardSize.height/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: atTime)
            
        } else {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
            let posY = standardSize.height/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
            
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
            }
            
            instruction.setTransform(concat, at: atTime)
        }
        return instruction
    }
    
    fileprivate func setOrientation(image: UIImage?, onLayer: CALayer, outputSize: CGSize) -> Void {
        guard let image = image else { return }
        
        if image.imageOrientation == UIImage.Orientation.up {
            // Do nothing
        } else if image.imageOrientation == UIImage.Orientation.left {
            let rotate = CGAffineTransform(rotationAngle: .pi/2)
            onLayer.setAffineTransform(rotate)
        } else if image.imageOrientation == UIImage.Orientation.down {
            let rotate = CGAffineTransform(rotationAngle: .pi)
            onLayer.setAffineTransform(rotate)
        } else if image.imageOrientation == UIImage.Orientation.right {
            let rotate = CGAffineTransform(rotationAngle: -.pi/2)
            onLayer.setAffineTransform(rotate)
        }
    }
    
    fileprivate func startExport(_ mixComposition: AVAsset, _ videoComposition: AVMutableVideoComposition? = nil,  _ exportUrl: URL, preset: String? = nil, timeRange: CMTimeRange? = nil, outputFileType: AVFileType = .mp4, progress: @escaping Progress, completion: @escaping Completion) {
        
        // Init exporter
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: (preset ?? AVAssetExportPresetPassthrough))
        exporter?.outputURL = exportUrl
        exporter?.outputFileType = outputFileType
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = videoComposition
        if let timeRange = timeRange {
            exporter?.timeRange = timeRange
        }
        
        let progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            let exportProgress: Float = exporter?.progress ?? 0.0
            DispatchQueue.main.async {
                progress(exportProgress)
            }
        })
        
        //        let exportQueue = DispatchQueue(label: "VideoExportProgressQueue")
        //        exportQueue.async(execute: {
        //            while exporter != nil {
        //                let exportProgress: Float = exporter?.progress ?? 0.0
        //                DispatchQueue.main.async {
        //                    progress(exportProgress)
        //                }
        //                if exportProgress == 1.0 {
        //                    break
        //                }
        //            }
        //        })
        
        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            progressTimer.invalidate()
            if exporter?.status == AVAssetExportSession.Status.completed {
                print("Exported file: \(exportUrl.absoluteString)")
                DispatchQueue.main.async {
                    completion(exportUrl, nil)
                }
            } else if exporter?.status == AVAssetExportSession.Status.failed {
                DispatchQueue.main.async {
                    completion(exportUrl, exporter?.error)
                }
            }
        })
    }
}

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension CMTime {
    
    var msS: (Int, Int, Int) {
        let duration = CMTimeGetSeconds(self)
        let minutes = Int(floor(duration / 60))
        let seconds = Int(floor(duration - Double(minutes) * 60))
        let milliseconds = Int((duration - floor(duration)) * 100)
        return (minutes, seconds, milliseconds)
    }
    
    var stringInsSS: String {
        let (minutes, seconds, milliseconds) = msS
        return String(format: "%d.%02d", minutes * 60 + seconds, milliseconds)
    }
    
    var stringInmmssSS: String {
        let (minutes, seconds, milliseconds) = msS
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
    
    var stringInmmmsssSS: String {
        let (minutes, seconds, milliseconds) = msS
        return String(format: "%02dm%02ds%02d", minutes, seconds, milliseconds)
    }
}
