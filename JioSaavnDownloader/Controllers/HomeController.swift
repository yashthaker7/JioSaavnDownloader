//
//  HomeController.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit
import Alamofire

class HomeController: UIViewController {
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var downloadSongBtn: UIButton!
    @IBOutlet weak var progressContainerView: ProgressContainerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationView.addShadow(radius: 2)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setUrl), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @objc func setUrl() {
        if let incomingURL = UserDefaults(suiteName: "group.JioSaavnDownloaderShareExtension")?.value(forKey: "incomingURL") as? String {
            textView.text = incomingURL
            UserDefaults(suiteName: "group.JioSaavnDownloaderShareExtension")?.removeObject(forKey: "incomingURL")
        } else {
            setPasteboardText()
        }
    }
    
    @objc func appEnterForeground() {
        setPasteboardText()
    }
    
    private func setPasteboardText() {
        guard let pasteboardText = UIPasteboard.general.string else { return }
        textView.text = pasteboardText
    }
    
    @IBAction func downloadSongBtnAction(_ sender: UIButton) {
        downloadAnimation(.add)
        let urlStr = textView.text.trimmingWhiteSpaces
        Service.shared.getDownloadSongURL(urlStr: urlStr) { result in
            switch result {
            case .success(let song):
                self.startDownloading(song: song)
            case .failure(let serviceError):
                self.downloadAnimation(.remove)
                AlertManager.showServiceErrorAlert(serviceError)
            }
        }
    }
    
    private func startDownloading(song: Song) {
        Service.shared.downloadSong(song) { progress in
            self.progressContainerView.progress = progress
        } completion: { result in
            switch result {
            case .success(let downloadUrl):
                self.convertMP4ToM4A(downloadUrl) { exportUrl in
                    self.shareFile(exportUrl, sourceView: self.downloadSongBtn, parentController: self)
                    self.downloadAnimation(.remove)
                }
            case .failure(let serviceError):
                self.downloadAnimation(.remove)
                AlertManager.showServiceErrorAlert(serviceError)
            }
        }
    }
    
    private func convertMP4ToM4A(_ audioUrl: URL, completion: @escaping (URL) -> ()) {
        let exportUrl = FileManager.default.createURLInDD(audioUrl.nameWithoutExtension()+".m4a")
        TYAudioVideoManager.shared.createM4A(audioUrl, exportUrl: exportUrl) { progress in
            print(progress)
        } completion: { destinationUrl, error in
            guard let destinationUrl = destinationUrl else { return }
            completion(destinationUrl)
        }
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
    
    enum DownloadAnimationType {
        case add, remove
    }
    
    private func downloadAnimation(_ animationType: DownloadAnimationType) {
        progressContainerView.progress = 0
        if animationType == .add {
            progressContainerView.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        } else {
            downloadSongBtn.transform = CGAffineTransform.init(scaleX: 0, y: 0)
        }
        UIView.animate(withDuration: 0.3) {
            self.downloadSongBtn.alpha = animationType == .add ? 0 : 1
            let scale: CGFloat = animationType == .add ? 0 : 1
            self.downloadSongBtn.transform = CGAffineTransform.init(scaleX: scale, y: scale)
            let scale2: CGFloat = animationType == .add ? 1 : 0
            self.progressContainerView.transform = CGAffineTransform.init(scaleX: scale2, y: scale2)
            self.progressContainerView.alpha = animationType == .add ? 1 : 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
