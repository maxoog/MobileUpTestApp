//
//  VkPhotoProvider.swift
//  MobileUpTestProject
//
//  Created by Максим on 04.04.2022.
//

import Foundation
import UIKit

struct AlbumResponse: Decodable {
    let response: VkAlbum
}

struct VkAlbum: Decodable {
    let count: Int
    let items: [VkPhoto]
}

struct VkPhoto: Decodable {
    let id: Int
    let album_id: Int
    let user_id: Int
    let text: String
    let date: Int
    let sizes: [VkPhotoSize]
}

struct VkPhotoSize: Decodable {
    let url: String
    let width: Int
    let height: Int
    let type: String
}

class PhotoProvider {
    var album: VkAlbum?
    var session: VkApiSession
    let albumID = "266276915"
    let ownerID = "-128666765"
    
    // queue for barrier task "fetch album" realization
    private let taskQueue = OperationQueue()
    
    static let unknownImage = UIImage(systemName: "camera.metering.unknown")

    init(session: VkApiSession) {
        self.session = session
        
        let url = getUrlForAlbumFetching(id: albumID, ownerID: ownerID)
        
        taskQueue.addOperation {
            session.dataTask(with: URLRequest(url: url)) { [weak self] result in
                switch result {
                case .success(let (_, data)):
                    self?.album = (try? JSONDecoder().decode(AlbumResponse.self, from: data))?.response
                case .failure(let error):
                    print(error)
                    ()
                }
                self?.taskQueue.isSuspended = false
            }
        }
        taskQueue.isSuspended = true
    }

    typealias PhotoFetchResult = Result<UIImage?, Error>
    
    func fetchPhoto(index: Int, completion: ((PhotoFetchResult) -> Void)?) {
        taskQueue.addOperation {
            let photo: VkPhoto? = self.album?.items[index]
            let urlString: String? = photo?.sizes.last?.url
            
            let url: URL? = urlString.flatMap { URL(string: $0) }
            
            if let url = url {
                let request = URLRequest(url: url)
                self.session.dataTask(with: request) { result in
                    completion?(result.map { success in
                        return UIImage(data: success.1)
                    })
                }
            } else {
                completion?(.success(Self.unknownImage))
            }
        }
            
    }
    
    private func getUrlForAlbumFetching(id: String, ownerID: String) -> URL {
        var components = URLComponents(string: "https://api.vk.com/method/photos.get")!
        components.queryItems = [
            URLQueryItem(name: "owner_id", value: ownerID),
            URLQueryItem(name: "album_id", value: id),
            URLQueryItem(name: "access_token", value: VkApiSession.accessToken),
            URLQueryItem(name: "v", value: "5.131")
        ]
        guard let url = components.url else {
            fatalError("internal inconsistency")
        }
        return url
    }
    
    private func convertDate(_ date: Double) -> String {
        let date = Date(timeIntervalSince1970: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd LLLL yyyy"
        return formatter.string(from: date)
    }
}
