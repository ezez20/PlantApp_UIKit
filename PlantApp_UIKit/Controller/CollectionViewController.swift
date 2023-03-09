//
//  CollectionViewController.swift
//  PlantApp_UIKit
//
//  Created by Ezra Yeoh on 3/3/23.
//

import UIKit


class CollectionViewController: UIViewController {
    
    var plants = [Plant]()
    
    private var collectionView: UICollectionView?


    override func viewDidLoad() {
        super.viewDidLoad()
        
//        title = "Plants"
//        view.backgroundColor = .white
//
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
//        layout.minimumLineSpacing = 1
//        layout.minimumInteritemSpacing = 1
//        layout.itemSize = CGSize(width: (view.frame.size.width / 3) - 4, height: 150)
//        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        guard let collectionView = collectionView else { return }
//
//        view.addSubview(collectionView)
////        collectionView.frame = view.bounds
////        collectionView.frame = CGRect(x: 5, y: 150, width: view.frame.size.width - 10, height: view.frame.size.height - 150 - 60)
//        collectionView.frame = CGRect(x: 5, y: 150, width: view.frame.size.width - 10, height: view.frame.size.height - 150 - 60)
//        collectionView.backgroundColor = .secondarySystemBackground
//
//        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
//        collectionView.delegate = self
//        collectionView.dataSource = self
        

    }
    
   
}
//
//extension CollectionViewController: UICollectionViewDelegate {
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        collectionView.deselectItem(at: indexPath, animated: true)
//        print("User tapped collection view cell")
//    }
//
//}
//
//extension CollectionViewController : UICollectionViewDataSource{
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return plants.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
//        cell.plant = plants[indexPath.row]
//        return cell
//    }
//
//
//
//}

//extension CollectionViewController : UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 120, height: 150)
//    }
//}
