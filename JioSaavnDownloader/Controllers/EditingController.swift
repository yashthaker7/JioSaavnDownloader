//
//  EditingController.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit
import AVFoundation
import AVKit
import SoundWave

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
    
    var currentTime = CMTime.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationView.addShadow(ofColor: .white, radius: 2)
        setupSoundWaveView()
        playPauseBtn.setTitle("", for: .normal)
    }
    
    private func setupSoundWaveView() {
        let audioVisualizationView = AudioVisualizationView(frame: CGRect(x: 0, y: 0, width: 5000, height: 200))
        trimmerContainerView.addSubview(audioVisualizationView)
        audioVisualizationView.meteringLevelBarWidth = 5
        audioVisualizationView.meteringLevelBarInterItem = 1
        audioVisualizationView.meteringLevelBarCornerRadius = 0
        // audioVisualizationView.meteringLevelBarSingleStick = true
        audioVisualizationView.gradientStartColor = .white
        audioVisualizationView.gradientEndColor = .black
        audioVisualizationView.audioVisualizationMode = .read
        audioVisualizationView.meteringLevels = [0.1, 0.67, 0.13, 0.78, 0.31]
        // audioVisualizationView.play(for: 5.0)
        
        guard let downloadedSongUrlInDD = downloadedSongUrlInDD else { return }
        var outputArray = [Float]()
        TYAudioContext.load(fromAudioURL: downloadedSongUrlInDD, completionHandler: { audioContext in
            guard let audioContext = audioContext else {
                fatalError("Couldn't create the audioContext")
            }
            outputArray = render(audioContext: audioContext, targetSamples: 300)
            outputArray = outputArray.map({ abs($0)/80 })
            print(outputArray)
            print(outputArray.count)
            DispatchQueue.main.async {
                audioVisualizationView.reset()
                audioVisualizationView.meteringLevels = outputArray
            }
        })
    }
    
    @IBAction func backBtnAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func shareBtnAction(_ sender: UIButton) {
        guard let downloadedSongUrlInDD = downloadedSongUrlInDD else { return }
        shareFile(downloadedSongUrlInDD, sourceView: sender, parentController: self)
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
                self.duationLabel.text = currentTime.stringInmmssSS
            }
            player?.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { success in
                self.player?.play()
            })
        } else {
            player?.pause()
            currentTime = player?.currentTime() ?? .zero
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
