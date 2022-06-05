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
        setPasteboardText()
    }
    
    private func setPasteboardText() {
        if let pasteboardText = UIPasteboard.general.string {
            textView.text = pasteboardText
        }
        textView.text = "https://www.jiosaavn.com/song/soniye/AxgychBKXHY"
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
                self.navigateToEditingVC(downloadUrl)
                self.downloadAnimation(.remove)
            case .failure(let serviceError):
                self.downloadAnimation(.remove)
                AlertManager.showServiceErrorAlert(serviceError)
            }
        }
    }
    
    func navigateToEditingVC(_ downloadedSongUrlInDD: URL?) {
        let editingVC: EditingController = UIStoryboard(.main).instantiateVC()
        editingVC.downloadedSongUrlInDD = downloadedSongUrlInDD
        navigationController?.pushViewController(editingVC, animated: true)
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
