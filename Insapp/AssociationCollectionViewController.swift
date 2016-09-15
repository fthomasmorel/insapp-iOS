//
//  AssociationCollectionViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let kAssociationCollectionCellView = "kAssociationCollectionCellView"
    let kMarginBubble = 30
    
    var associations:[Association] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kAssociationCollectionCellView)
        
        APIManager.fetchAssociations { (associations) in
            self.associations = associations
            self.collectionView.reloadData()
        }
    }
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return associations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let association = self.associations[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAssociationCollectionCellView, for: indexPath as IndexPath)
        cell.frame = self.frameForCollectionViewCell(indexPath.row)
        cell.backgroundColor = UIColor.white
        
        let size = cell.frame.size.width-CGFloat(kMarginBubble)
        let origin = CGFloat(kMarginBubble/2)
        
        let imageView = UIImageView(frame: CGRect(x: origin, y: 5, width: size, height: size))
        imageView.backgroundColor = kLightGreyColor
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = size/2
        
        let photo_url = kCDNHostname + association.profilePhotoURL!
        imageView.downloadedFrom(link: photo_url)
        
        let label = UILabel(frame: CGRect(x: 0, y: cell.frame.size.width-CGFloat(kMarginBubble), width: cell.frame.size.width, height: CGFloat(kMarginBubble)))
        label.text = association.name
        label.font = UIFont(name: "Helvetica", size: 12)
        label.textColor = .black
        label.textAlignment = .center
        
        cell.addSubview(label)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let association = self.associations[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController 
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func frameForCollectionViewCell(_ index:Int) -> CGRect {
        var quotient = 18/7,
        remainder = quotient % 1;
        
        quotient -= remainder;
        let size = self.collectionView.frame.size.width/3
        let xPosition = size * CGFloat(index % 3)
        let yPosition = size * CGFloat(index/3 - ((index/3) % 1))
        return CGRect(x: xPosition, y: yPosition, width: size, height: size)
    }
    
    
}
