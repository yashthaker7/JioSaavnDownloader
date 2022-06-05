//
//  EditingController.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit
import AVFoundation
import AVKit

class EditingController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var trimmerContainerView: UIView!
    @IBOutlet weak var duationLabel: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    
    var downloadedSongUrlInDD: URL?
    
    var isPlaying = false
    var player: AVPlayer?
    
    private lazy var colorPicker: UIColorPickerViewController = {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = playerContainerView.backgroundColor ?? .black
        colorPicker.delegate = self
        return colorPicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationView.addShadow(ofColor: .white, radius: 2)
        
//        let videoUrl = Bundle.main.url(forResource: "blank_video", withExtension: "mp4")!
//        let exportUrl = FileManager.default.createURLInDD("video.mp4")
//        FileManager.default.removeFileIfExists(exportUrl)
//        TYAudioVideoManager.shared.mergeAudioTo(videoUrl: videoUrl, audioUrl: downloadedSongUrlInDD!, exportUrl: exportUrl) { progress in
//            print(progress)
//        } completion: { destinationUrl, error in
//            print(destinationUrl)
//        }
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnAction(_ sender: UIButton) {
        shareFile(downloadedSongUrlInDD!, sourceView: sender, parentController: self)
    }
    
    @IBAction func changeBGColorBtnAction(_ sender: UIButton) {
        present(colorPicker, animated: true, completion: nil)
    }
    
    @IBAction func playPauseBtnAction(_ sender: UIButton) {
        if !isPlaying {
            guard let downloadedSongUrlInDD = downloadedSongUrlInDD,
                  let composition = TYAudioVideoManager.shared.createAudioComposition(downloadedSongUrlInDD, startTime: .zero, endTime: .zero) else { return }
            let item = AVPlayerItem(asset: composition)
            player = AVPlayer(playerItem: item)
            player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { (currentTime) in
                self.duationLabel.text = currentTime.formatedSeconds()
            }
            player?.play()
        } else {
            player?.pause()
        }
        isPlaying.toggle()
        playPauseBtn.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
        playPauseBtn.setTitle(nil, for: .normal)
    }
    
    private func shareFile(_ fileUrl: URL, sourceView: UIView, parentController: UIViewController) {
        let activityVC = UIActivityViewController(activityItems: [fileUrl], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityVC.popoverPresentationController?.sourceView = sourceView
            activityVC.popoverPresentationController?.sourceRect = CGRect(x: 150, y: sourceView.frame.height/2, width: 0, height: 0)
            activityVC.popoverPresentationController?.permittedArrowDirections = [.left, .right]
        }
        activityVC.completionWithItemsHandler = { (_, _, _, _) in
            FileManager.default.removeFileIfExists(fileUrl)
        }
        parentController.present(activityVC, animated: true, completion: nil)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
}

extension EditingController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        playerContainerView.backgroundColor = viewController.selectedColor
        
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        playerContainerView.backgroundColor = viewController.selectedColor
    }
}
