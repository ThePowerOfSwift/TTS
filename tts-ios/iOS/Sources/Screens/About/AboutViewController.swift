//
//  AboutViewController.swift
//  tts
//
//  Created by Dmitry Nesterenko on 18/02/2018.
//  Copyright © 2018 dz. All rights reserved.
//

import UIKit
import IGListKit
import TTSKit

final class AboutViewController: CollectionViewController {
    
    private let bundleVersion = Bundle.main.bundleVersion!
        
    // MARK: - Navigation Interface
    
    override var navigationItem: UINavigationItem {
        let navigationItem = super.navigationItem
        navigationItem.title = "О приложении"
        return navigationItem
    }
    
    // MARK: - Managing the View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(r: 19, g: 21, b: 25)
        
        collectionView.alwaysBounceVertical = true
        
        let footer = InfiniteScrollViewFooter()
        footer.backgroundColor = UIColor(r: 37, g: 42, b: 57)
        collectionView.addSubview(footer)
    }
    
    // MARK: - Managing the Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - List Adapter
    
    override func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        let backgroundColor = UIColor(r: 37, g: 42, b: 57)
        
        let items: [ListDiffable & HeightCalculatable] = [
            ListBasicItem(layout: .init(title: .init(title: "Перейти на сайт"), background: .init(fillColor: backgroundColor, corners: [.topLeft, .topRight], radius: 8)), selected: { [weak self] in
                let url = URL(string: "https://www.tts.ru/")!
                self?.openURL(url)
            }),
            ListBasicItem(layout: .init(title: .init(title: "Оценить приложение"), background: .init(fillColor: backgroundColor)), selected: { [weak self] in
                let url = URL(string: "https://itunes.apple.com/app/id1424528365?mt=8")!
                self?.openURL(url)
            }),
            AboutFooterItem()
        ]
        
        let headerItemHeight = collectionView.boundsSizeWithContentInsetExcluded.height - (items as [HeightCalculatable]).height(forWidth: collectionView.bounds.width)
        return [AboutHeaderItem(bundleVersion: bundleVersion, height: headerItemHeight)] + items
    }
    
    override func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if object is AboutHeaderItem {
            return AboutHeaderSectionController()
        } else if object is ListBasicItem {
            return ListBasicSectionController()
        } else if object is AboutFooterItem {
            return AboutFooterSectionController()
        } else {
            fatalError()
        }
    }
    
    private func openURL(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] _ in
            self?.collectionView.deselectAll(animated: IsAnimationAllowed())
        })
    }
    
}
