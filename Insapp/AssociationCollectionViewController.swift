//
//  AssociationCollectionViewController.swift
//  Insapp
//
//  Created by Florent THOMAS-MOREL on 9/13/16.
//  Copyright © 2016 Florent THOMAS-MOREL. All rights reserved.
//

import Foundation
import UIKit

class AssociationCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    var refreshControl:UIRefreshControl!
    var associations:[Association] = []
    var filteredAssociations:[Association] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noAssociationLabel: UILabel!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.keyboardDismissMode = .interactive
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor.white.withAlphaComponent(0)
        self.refreshControl.addTarget(self, action: #selector(AssociationCollectionViewController.fetchAssociations), for: UIControlEvents.valueChanged)
        self.collectionView.addSubview(refreshControl)
        self.collectionView.alwaysBounceVertical = true
        
        self.searchBar.backgroundImage = UIImage()
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        (textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel)?.textColor = kDarkGreyColor
        if let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            glassIconView.tintColor = kDarkGreyColor
        }
        self.searchBar.delegate = self
        self.fetchAssociations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.hideNavBar()
        self.notifyGoogleAnalytics()
        self.lightStatusBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AssociationCollectionViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AssociationCollectionViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let layout: UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        self.refreshUI(reload: true)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = UIColor.white
    }
    
    func fetchAssociations(){
        self.searchBar.text = ""
        APIManager.fetchAssociations(controller: self) { (associations) in
            self.associations = associations
            self.filteredAssociations = associations
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.refreshUI()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: self.view.window)
    }
    
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredAssociations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (self.collectionView.frame.width-41)/3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let association = self.filteredAssociations[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kAssociationCell, for: indexPath as IndexPath) as! AssociationCell
        cell.load(association: association)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let association = self.filteredAssociations[indexPath.row]
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AssociationViewController") as! AssociationViewController 
        vc.association = association
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func keyboardWillShow(_ notification: NSNotification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame = (userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue
        DispatchQueue.main.async {
            self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.height - (kCommentEmptyTextViewHeight + kCommentViewEmptyHeight), 0)
            self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset
            self.searchBar.showsCancelButton = true
            self.refreshControl.removeFromSuperview()
        }
        
    }
    
    func keyboardWillHide(_ notification: NSNotification) {
        self.collectionView.contentInset = .zero
        self.collectionView.scrollIndicatorInsets = .zero
        self.refreshControl.isHidden = false
        self.searchBar.showsCancelButton = false
        if self.associations.count == self.filteredAssociations.count {
            self.collectionView.addSubview(self.refreshControl)   
        }
    }
    
    func refreshUI(reload:Bool = false){
        if self.associations.count == 0 {
            if reload {
                self.collectionView.isHidden = true
                self.noAssociationLabel.isHidden = true
                self.reloadButton.isHidden = true
                self.loader.isHidden = false
            }else{
                self.collectionView.isHidden = true
                self.noAssociationLabel.isHidden = false
                self.reloadButton.isHidden = false
                self.loader.isHidden = true
            }
        }else{
            self.collectionView.isHidden = false
            self.noAssociationLabel.isHidden = true
            self.reloadButton.isHidden = true
            self.loader.isHidden = false
            self.collectionView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            self.filteredAssociations = self.associations
            self.collectionView.reloadData()
        }else{
            self.filteredAssociations = self.associations.filter({ (association) -> Bool in
                return association.name!.lowercased().contains(searchText.lowercased()) ||
                        association.email!.lowercased().contains(searchText.lowercased()) ||
                        association.desc!.lowercased().contains(searchText.lowercased())
            })
            self.collectionView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = false
        DispatchQueue.main.async {
            self.searchBar.resignFirstResponder()
            self.fetchAssociations()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func scrollToTop(){
        self.collectionView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    @IBAction func reloadAction(_ sender: AnyObject) {
        self.refreshUI(reload: true)
        self.fetchAssociations()
    }
}
