//
//  SearchAssociationCell.swift
//  Insapp
//
//  Created by Guillaume Courtet on 27/11/2016.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import UIKit
import Foundation

class SearchAssociationCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var associationCollectionView: UICollectionView!
    
    var parent: UniversalSearchViewController!
    var associations: [Association] = []
    var searchText: String!
    var assoSelected: Association?
    var more = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.associationCollectionView.delegate = self
        self.associationCollectionView.dataSource = self
    }
    
    override func layoutSubviews() {
        if(more == 0) {
            let layout: UICollectionViewFlowLayout = self.associationCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
            layout.minimumInteritemSpacing = 1
            layout.minimumLineSpacing = 1
            self.associationCollectionView.showsHorizontalScrollIndicator = false
        } else {
            let layout: UICollectionViewFlowLayout = self.associationCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.scrollDirection = .vertical
        }
        self.associationCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kSearchAssociationCell)
        self.associationCollectionView.register(UINib(nibName: "AssociationSearchCell", bundle: nil), forCellWithReuseIdentifier: kAssociationSearchCell)
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(more == 1){
            return self.associations.count
        }
        else {
            return min(6,(associations.count))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(more == 0) {
            return CGSize(width: 80, height: 80)
        }
        else {
            let size = (self.associationCollectionView.frame.width-41)/3
            return CGSize(width: size, height: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(more == 0) {
        let cell = associationCollectionView.dequeueReusableCell(withReuseIdentifier: kAssociationSearchCell, for: indexPath as IndexPath) as! AssociationSearchCell
        if(indexPath.row == 5 && self.associations.count > 6 && more == 0) {
            cell.associationImageView.image = #imageLiteral(resourceName: "plus")
            cell.associationNameLabel.text = "\"\(self.searchText!)\""
        }
        else {
            let association = self.associations[indexPath.row]
            cell.load(association: association)
        }
        cell.associationImageView.layer.cornerRadius = 30
        cell.associationImageView.layer.masksToBounds = true
        cell.associationImageView.backgroundColor = kWhiteColor
        
        return cell
        }
        else {
            let association = self.associations[indexPath.row]
            let cell = associationCollectionView.dequeueReusableCell(withReuseIdentifier: kAssociationSearchCell, for: indexPath as IndexPath) as! AssociationSearchCell
            cell.more = 1
            cell.load(association: association)
            return cell
        }
    }
    
    
    func loadAssociations(_ associations: [Association]){
        self.associations = associations
        self.associationCollectionView.reloadData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(indexPath.row == 5 && self.associations.count > 6 && more == 0){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SeeMoreViewController") as! SeeMoreViewController
            vc.associations = self.associations
            vc.searchedText = self.searchText
            vc.type = 1
            vc.prt = self.parent
            self.parent.navigationController?.pushViewController(vc, animated: true)
        }
        else {
        let association = self.associations[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController
        vc.association = association
        self.parent.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
