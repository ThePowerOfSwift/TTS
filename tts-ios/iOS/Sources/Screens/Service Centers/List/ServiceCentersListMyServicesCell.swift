//
//  ServiceCentersListMyServicesCell.swift
//  tts
//
//  Created by Dmitry Nesterenko on 15/04/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import TTSKit

// Горизонтальный список моих сервисов на экране "Сервис центры/Список"
final class ServiceCentersListMyServicesCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet private var pageControl: UIPageControl!
    private var behavior: PaginatedScrollViewBehavior!
    
    var didSelect: ((ServiceCenterUserAutoLightPair) -> Void)?
    
    var pairs: [ServiceCenterUserAutoLightPair]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Collection View
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(ServiceCentersListMyCell.nib, forCellWithReuseIdentifier: "cell")
        behavior = PaginatedScrollViewBehavior(pageControl: pageControl, scrollView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pairs?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ServiceCentersListMyCell {
            cell.pair = pairs?[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let pair = pairs?[indexPath.row] else { return }
        didSelect?(pair)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let sectionInsetHorizontalPadding: CGFloat = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: sectionInsetHorizontalPadding, bottom: 0, right: sectionInsetHorizontalPadding)
        layout.itemSize = CGSize(width: contentView.bounds.insetBy(dx: sectionInsetHorizontalPadding, dy: 0).width, height: contentView.bounds.height)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = sectionInsetHorizontalPadding * 2
    }
    
}
