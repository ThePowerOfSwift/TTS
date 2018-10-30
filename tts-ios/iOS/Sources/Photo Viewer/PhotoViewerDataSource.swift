//
//  PhotoViewerDataSource.swift
//  tts
//
//  Created by Dmitry Nesterenko on 27/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import Foundation
import NYTPhotoViewer
import AlamofireImage
import Alamofire

final class PhotoViewerDataSource: NYTPhotoViewerDataSource {
    
    var numberOfPhotos: NSNumber?
    
    let photos: [PhotoViewerItem]
    private var requests = [RequestReceipt]()
    private let downloader: ImageDownloader
    private let completion: (PhotoViewerItem) -> Void
    
    deinit {
        stopDownloading()
    }
    
    init(urls: [URL], downloader: ImageDownloader, completion: @escaping (PhotoViewerItem) -> Void) {
        self.photos = urls.map { PhotoViewerItem(url: $0) }
        self.downloader = downloader
        self.completion = completion
        numberOfPhotos = urls.count as NSNumber
        startDownloading()
    }
    
    func index(of photo: NYTPhoto) -> Int {
        guard let item = photo as? PhotoViewerItem else { return 0 }
        return photos.index(of: item)!
    }
    
    func photo(at photoIndex: Int) -> NYTPhoto? {
        guard (0..<photos.count).contains(photoIndex) else { return nil }
        return photos[photoIndex]
    }
    
    // MARK: - Downloading
    
    private func startDownloading() {
        for photo in photos {
            let request = downloader.download(URLRequest(url: photo.url)) { [weak self] response in
                photo.image = response.result.value
                self?.completion(photo)
            }
            if let request = request {
                requests.append(request)
            }
        }
    }
    
    private func stopDownloading() {
        requests.forEach { downloader.cancelRequest(with: $0) }
    }
    
}
