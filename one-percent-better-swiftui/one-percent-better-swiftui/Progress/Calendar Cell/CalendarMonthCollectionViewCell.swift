//
//  CalendarTableCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/5/21.
//

import UIKit

class CalendarMonthCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    
    /// Height of the cell
    static let cellHeight: CGFloat = 322
    
    /// Object used to calculate an array of days for each month
    lazy var calendarCalculator = CalendarCalculator()
    
    /// The habit we are presenting
    private var habit: Habit!
    
    // MARK: Methods
    
    
    /// Configure the collection view
    /// - Parameters:
    ///   - habit: The habit we are presenting
    ///   - index: How many months backward from the present month to offset
    func configure(habit: Habit, monthOffset: Int) {
        self.habit = habit
        collectionView.delegate = self
        collectionView.dataSource = self
        calendarCalculator.backXMonths(x: monthOffset)
        collectionView.reloadData()
    }
    
    /// Reset base date of calendar for reuse
    override func prepareForReuse() {
        calendarCalculator.resetBaseDate()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return calendarCalculator.days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarCollectionCell.self), for: indexPath) as! CalendarCollectionCell
        cell.configure(day: calendarCalculator.days[indexPath.row], habit: habit)
        return cell
    }
    
    // Spacing between items in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        // Want spacing for 7 items per row
        let totalWidth = self.frame.width
        let inset = CGFloat(20) // Defined in storyboard
        let usableWidth = totalWidth - 2*inset
        let itemWidth = CGFloat(25) // Defined in storyboard
        let removeItems = usableWidth - 7*itemWidth
        let divideBySeven = removeItems / 7
        return CGFloat(divideBySeven)
    }
    
    // Spacing between rows in collection view
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let usableHeight = self.frame.height
        let numRows = calendarCalculator.days.count / 7
        let itemHeight = CGFloat(25) // Defined in storyboard
        let removeItems = usableHeight - CGFloat(numRows) * itemHeight
        let spacing = removeItems / CGFloat(numRows - 1)
        return spacing
    }
}
