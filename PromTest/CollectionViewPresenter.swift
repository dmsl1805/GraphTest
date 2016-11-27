//
//  CollectionViewPresenter.swift
//  PromTest
//
//  Created by Dmitriy Shulzhenko on 11/20/16.
//  Copyright © 2016 dmitriy.shulzhenko. All rights reserved.
//

import UIKit
import CollectionViewWaterfallLayout
import MBProgressHUD

class CollectionViewPresenter: NSObject, ViewControllerPresenterProtocol, UICollectionViewDelegate, UICollectionViewDataSource, CollectionViewWaterfallLayoutDelegate, ModelUpdaterDelegate, ModelUpdaterDataDelegate, ViewResponderProtocol {
    
    weak var viewController: UIViewController?
    var updatesManagerTemporary: TemporaryModelUpdaterManagerProtocol?
    var updatesManagerPersistent: PersistantModelUpdaterManagerProtocol?
    var updatesFinished: (() -> Void)?
    
    let pickerView = PickerView(frame: CGRect(origin: CGPoint.init(x: 0, y: 0),
                                              size: CGSize(width: 200, height: 200)))
    let pickerSourse = SortPickerDataSource()
    
    var pickerHidden = true
    
    var headerView: HeaderViewPresenter?
    
    func configure() {
        
        if let storedEntities = updatesManagerPersistent?.persistentContext.fetch(withPredicate: nil, name: PRMEntity.entityName()), storedEntities.count > 0  {
            for entity in storedEntities {
                let tempEntity = TemporaryEntity(entity: entity as? PRMEntity, template: nil)
                let _ = updatesManagerTemporary?.tempContext.insert(tempEntity, withName: tempEntity.dataName!)

                if let data = updatesManagerPersistent?.persistentDataManager.get(data: tempEntity.dataName!) {
                    tempEntity.image = UIImage(data: data)
                }
            }
        }
        updatesManagerTemporary?.updateTemporary()
        updatesManagerPersistent?.updatePersistent()
        
        let collectionViewController = viewController as! UICollectionViewController
        collectionViewController.collectionView?.delegate = self
        collectionViewController.collectionView?.dataSource = self
        collectionViewController.collectionView?.backgroundColor = UIColor.lightGray
        collectionViewController.collectionView?.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.cellIdentifier)
        collectionViewController.collectionView?.register(ProgressCollectionReusableView.self,
                                                          forSupplementaryViewOfKind: CollectionViewWaterfallElementKindSectionFooter,
                                                          withReuseIdentifier: "FOOTER")
        
        if let layout = collectionViewController.collectionViewLayout as? CollectionViewWaterfallLayout {
            layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
            layout.minimumColumnSpacing = 8;
            layout.minimumInteritemSpacing = 8;
            layout.footerHeight = 100;
        }
        
        (collectionViewController as! CollectionViewController).refresh = { [unowned self] (finished: @escaping (() -> Void)) in
            self.updatesFinished = finished
            self.updatesManagerTemporary?.updateTemporary()
            self.updatesManagerPersistent?.updatePersistent()
        }
        
        pickerView.pickerView.dataSource  = pickerSourse
        pickerView.pickerView.delegate = pickerSourse
        pickerView.titleItem.title = "Sort".localized
        pickerView.responder = self
        collectionViewController.view.addSubview(pickerView)
        
    }
    
    func didTouchedUpInside(_ sender: Any) {
        if let button = sender as? UIBarButtonItem {
            switch button {
            case pickerView.rightButton:
                (updatesManagerTemporary as? TemporaryModelUpdaterManager<TemporaryEntity, TemporaryEntity>)?.updateTemporary(sort: pickerSourse.selectedSort)
                headerView?.sortType = pickerSourse.selectedSort
                break
            default:
                break
            }
        }
        
        
        pickerHidden = !pickerHidden
        hidePicker(pickerHidden)
        
    }
    
    func layoutSubviews() {
        let collectionVC = viewController as! CollectionViewController
        pickerView.frame = CGRect(x: 0,
                                  y: collectionVC.view.frame.size.height,
                                  width: collectionVC.view.frame.size.width,
                                  height: 260)
    }
    
    
    func hidePicker( _ hide: Bool ) {
        let newY = hide ? viewController!.view.frame.size.height : viewController!.view.frame.size.height - (pickerView.frame.size.height)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: { [unowned self] in
            self.pickerView.frame = CGRect(origin: CGPoint.init(x: 0, y: newY), size: (self.pickerView.frame.size))
        })
    }
    func updater(_ updater: ModelUpdaterProtocol,
                 didWrite data: Data,
                 forEntity: PersistentEntityDataProtocol,
                 error: Error?) {
        var tempEntity: TemporaryEntity?
        if let image = UIImage(data: data) {
            if let entity = forEntity as? PRMEntity {
                tempEntity = self.updatesManagerTemporary?.tempContext.fetchForUpdate(withKey: entity.id!.description, name: entity.name!) as? TemporaryEntity
                tempEntity?.image = image
            } else if let entity = forEntity as? TemporaryEntity {
                entity.image = image
                tempEntity = entity
            }
            OperationQueue.main.addOperation { [unowned self] in
//                let contex = self.updatesManagerTemporary?.tempContext as! TemporaryContextStorage
//                let index = contex.indexOf(tempEntity!)!
                let collection = (self.viewController as! UICollectionViewController).collectionView
                collection?.reloadData()
                //TODO: NSInternalInconsistencyException
//                do {
//                    UIView.animate(withDuration: 0, animations: {
//                        collection?.performBatchUpdates({
//                            collection?.reloadItems(at: [IndexPath(row: index.intValue, section: 0)])
//                        })
//                    })
//                } catch {
//                    print("Error updating collection view: \(error)")
//                }
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.updatesManagerTemporary?.tempContext.entitiesCount ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionView = (viewController as! UICollectionViewController).collectionView
        let cell = collectionView?.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.cellIdentifier, for: indexPath) as! CollectionViewCell
        if ( cell.presenter == nil ) {
            let presenter = CollectionViewCellPresenter()
            presenter.view = cell
            cell.presenter = presenter
        }
        (cell.presenter as! CollectionViewCellPresenter).model = self.updatesManagerTemporary?.tempContext.getEntity!(forIndex: indexPath.row) as! TemporaryEntity?
        (cell.presenter as! CollectionViewCellPresenter).update()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return (self.updatesManagerTemporary?.tempContext.getEntity?(forIndex: indexPath.row) as? ViewRepresentableProtocol)?.size(forObject: layout) ?? CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        return (collectionView.dequeueReusableSupplementaryView(ofKind: CollectionViewWaterfallElementKindSectionFooter,
                                                                withReuseIdentifier: "FOOTER",
                                                                for: indexPath) as! ProgressCollectionReusableView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            updatesManagerTemporary?.updateTemporary()
        }
    }
    
    func updater(_ updater: ModelUpdaterProtocol, didFinishExecuting operation: ModelUpdaterOperation) {
        if operation == .writeInfo {
            OperationQueue.main.addOperation { [unowned self] in
                (self.viewController as! UICollectionViewController).collectionView?.reloadData()
                self.updatesFinished?()
            }
        }
    }
    
    func updater(_ updater: ModelUpdaterProtocol, didGet response: [Dictionary<String, Any>]?, error: Error?) {
        if error != nil {
            OperationQueue.main.addOperation { [unowned self] in
                let hud = MBProgressHUD.showAdded(to: self.viewController!.view, animated: true)
                hud.label.text = error?.localizedDescription
                hud.mode = .text
                hud.hide(animated: true, afterDelay: 3)
            }
        }
    }
}
