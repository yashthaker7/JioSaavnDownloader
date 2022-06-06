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
    
    func createM4A(_ audioUrl: URL, exportUrl: URL, progress: @escaping Progress, completion: @escaping Completion) {
        let audioAsset = AVAsset(url: audioUrl)
        
        // Init composition
        let mixComposition = AVMutableComposition.init()
        
        // Get audio track
        guard let audioTrack = audioAsset.tracks(withMediaType: .audio).first else {
            print("[Error]: Audio not found.")
            return
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
        startExport(mixComposition, nil, exportUrl, outputFileType: .m4a, progress: progress, completion: completion)
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
    
    deinit { print("TYAudioVideoManager deinit.") }
}
