//
//  CalendarTableCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/5/21.
//

import UIKit

class CalendarTableCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var consistencyLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    
    /// The height of the cell
    static let cellHeight: CGFloat = 322
    
    /// Object used to calculate an array of days for each month
    var calendarCalculator: CalendarCalculator!
    
    /// Do not update page control page if it was tapped manually, otherwise you get a glitch
    /// where it goes to the next page, then scrollViewDidScroll updates it again
    var selectedPageManually = false
    
    /// The number of months since the startDate of this habit
    var numMonths: Int {
        let startMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: habit.startDate))!
        let endMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let component = Calendar.current.dateComponents([.month], from: startMonth, to: endMonth)
        let numMonths = component.month! + 1
        return numMonths
    }
    
    /// Date formatter for the month year label at the top of the calendar
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale.autoupdatingCurrent
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return dateFormatter
    }()
    
    
    /// The habit we are presenting
    private var habit: Habit!
    
    
    // MARK: - Methods
    
    /// Configure the cell's collectionView and pageControl
    /// - Parameter habit: The habit we are presenting
    func configure(habit: Habit) {
        self.habit = habit
        self.calendarCalculator = CalendarCalculator()
        
        // Layout so we get collectionView.frame.size correct
        collectionView.layoutIfNeeded()
        collectionView.isPagingEnabled = true
        // Scroll to present date
        collectionView.scrollToItem(at: IndexPath(row: numMonths - 1, section: 0), at: .centeredHorizontally, animated: false)
        
        updateHeader()
        updateFooter()
        
        pageControl.numberOfPages = numMonths
        pageControl.currentPage = numMonths - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numMonths
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarMonthCollectionViewCell.self), for: indexPath) as! CalendarMonthCollectionViewCell
        cell.configure(habit: habit, monthOffset: (numMonths - 1) - indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(collectionView.contentOffset.x / collectionView.frame.width))
        let goBack = (numMonths - 1) - page
        
        // Change calendar calculator to current month
        calendarCalculator.resetBaseDate()
        calendarCalculator.backXMonths(x: goBack)
        
        updateHeader()
        updateFooter()
        
        if !selectedPageManually {
            pageControl.currentPage = page
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        selectedPageManually = false
    }
    
    /// Update month year label
    func updateHeader() {
        let baseDate = calendarCalculator.getBaseDate()
        monthLabel.text = dateFormatter.string(from: baseDate)
    }
    
    /// Update consistency label
    func updateFooter() {
        let numberOfDaysInMonth = Calendar.current.range(
            of: .day,
            in: .month,
            for: calendarCalculator.getBaseDate())?.count
        
        var daysSoFar = 0
        var daysCompleted = 0
        for day in calendarCalculator.days {
            if !day.isWithinDisplayedMonth {
                continue
            }
            daysSoFar += 1
            if habit.wasCompleted(on: day.date) {
                daysCompleted += 1
            }
            if Calendar.current.isDateInToday(day.date) {
                break
            }
        }
        
        var text = "\(daysCompleted) of \(daysSoFar) days"
        if daysSoFar != numberOfDaysInMonth {
            text += " so far"
        }
        consistencyLabel.text = text
    }
    
    @IBAction func pageValueChanged(_ sender: UIPageControl) {
        let selectedPage = sender.currentPage
        
        if sender.interactionState == .continuous {
            collectionView.scrollToItem(at: IndexPath(row: selectedPage, section: 0), at: .centeredHorizontally, animated: false)
        } else {
            selectedPageManually = true
            collectionView.scrollToItem(at: IndexPath(row: selectedPage, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
}
