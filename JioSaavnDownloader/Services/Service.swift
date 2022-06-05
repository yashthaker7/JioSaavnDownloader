//
//  Service.swift
//  JioSaavnDownloader
//
//  Created by Yash on 05/06/22.
//

import UIKit
import Alamofire

public class Service: NSObject {
    
    static let shared = Service()
    
    private override init() {
        AF.sessionConfiguration.timeoutIntervalForRequest = 60
    }
    
    func downloadSong(_ song: Song, downloadProgress: @escaping (Double) -> (), completion: @escaping (Result<URL, ServiceError>) -> ()) {
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = FileManager.default.createURLInDD(song.name+".m4a")
            return (fileURL, [.removePreviousFile])
        }
        AF.download(song.mediaURL, to: destination).downloadProgress { progress in
            downloadProgress(progress.fractionCompleted)
        }.response { downloadUrl in
            guard let downloadUrl = downloadUrl.fileURL else {
                completion(.failure(ServiceError(.errorWhileDownloading)))
                return
            }
            print(downloadUrl)
            completion(.success(downloadUrl))
        }
    }
    
    func getDownloadSongURL(urlStr: String, completion: @escaping (Result<Song, ServiceError>) -> ()) {
        guard let _ = URL(string: urlStr) else {
            completion(.failure(ServiceError(.invalidURL)))
            return
        }
        getSongId(urlStr: urlStr) { result in
            switch result {
            case .success(let songId):
                print(songId)
                AF.request(APIBaseURLStr.songDetails.urlStr+songId).responseData { response in
                    self.handleResponse(response) { result2 in
                        switch result2 {
                        case .success(let str):
                            guard let json = str.data(using: .utf8),
                                  let dict = try? JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String: AnyObject],
                                  let jsonData = dict[songId] as? [String: AnyObject] else {
                                completion(.failure(ServiceError(.somethingWentWrong)))
                                return
                            }
                            print(jsonData)
                            guard let mediaPreviewUrlStr = jsonData["media_preview_url"] as? String else {
                                completion(.failure(ServiceError(.somethingWentWrong)))
                                return
                            }
                            var mediaUrlStr = mediaPreviewUrlStr.replacingOccurrences(of: "preview", with: "aac")
                            if let isHigherRateAudioAvailable = jsonData["320kbps"] as? String, isHigherRateAudioAvailable == "true" {
                                mediaUrlStr = mediaPreviewUrlStr.replacingOccurrences(of: "_96_p.mp4", with: "_320.mp4")
                            } else {
                                mediaUrlStr = mediaPreviewUrlStr.replacingOccurrences(of: "_96_p.mp4", with: "_160.mp4")
                            }
                            guard let url = URL(string: mediaUrlStr) else {
                                completion(.failure(ServiceError(.invalidURL)))
                                return
                            }
                            let songName = jsonData["song"] as? String
                            let song = Song(name: songName ?? "song", mediaURL: url)
                            completion(.success(song))
                        case .failure(let serviceError):
                            completion(.failure(serviceError))
                        }
                    }
                }
            case .failure(let serviceError):
                completion(.failure(serviceError))
            }
        }
    }
    
    private func getSongId(urlStr: String, completion: @escaping (Result<String, ServiceError>) -> ()) {
        AF.request(urlStr).responseData { response in
            self.handleResponse(response) { result in
                switch result {
                case .success(let str):
                    guard let songId = str.components(separatedBy: "\"song\":{\"type\":\"")[safe: 1]?
                        .components(separatedBy: "\",\"image\":")[safe: 0]?
                        .components(separatedBy: "\"id\":\"").last else {
                        completion(.failure(ServiceError(.songIdNotFound)))
                        return
                    }
                    completion(.success(songId))
                case .failure(let serviceError):
                    completion(.failure(serviceError))
                }
            }
        }
    }
    
    private func handleResponse(_ response: AFDataResponse<Data>, completion: @escaping (Result<String, ServiceError>) -> ()) {
        if let error = response.error {
            completion(.failure(ServiceError(error)))
            return
        }
        guard let data = response.data else {
            completion(.failure(ServiceError(.noResponse)))
            return
        }
        let str = String(decoding: data, as: UTF8.self)
        completion(.success(str))
    }
}

