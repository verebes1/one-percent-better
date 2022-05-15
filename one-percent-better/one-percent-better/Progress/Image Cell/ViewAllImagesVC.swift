//
//  ViewAllImagesVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/28/21.
//

import UIKit


class ViewAllImagesVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var tracker: ImageTracker!
    
    func configure(habit: Habit, tracker: ImageTracker) {
        self.tracker = tracker
        navigationBar.title = habit.name
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracker.dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCollectionCell.self), for: indexPath) as! ImageCollectionCell
        cell.cellImageView.image = tracker.getValue(date: tracker.dates[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 4
        let numItemsPerRow: CGFloat = 5
        let viewWidth = collectionView.frame.width - spacing * (numItemsPerRow + 1)
        let itemWidth = viewWidth / numItemsPerRow
        let itemSize = CGSize(width: itemWidth, height: itemWidth)
        return itemSize
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 4
//    }
    

}
