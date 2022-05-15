//
//  ProgressVC.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/5/21.
//

import UIKit

class ProgressVC: UIViewController {

    // MARK: - IBOutlets
    
    @IBOutlet weak var navigationBar: UINavigationItem!
    @IBOutlet weak var tableView: DelayedTouchesTableView!
    
    // MARK: Storyboard Segues
    
    @IBAction func unwindToProgressVC(segue: UIStoryboardSegue) {
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
    }
    
    @IBAction func unwindFromHabitEntryVC(unwindSegue: UIStoryboardSegue) {
        CoreDataManager.shared.saveContext()
        tableView.reloadData()
    }
    
    // MARK: - Variables
    
    var habit: Habit!
    var numberTrackers: [NumberTracker] = []
    var imageTrackers: [ImageTracker] = []
    
    lazy var statisticsCalculator = StatisticsCalculator()
    var viewAllImagesTracker: ImageTracker!
    
    let calendarSection = 0
    let statisticSection = 1
    lazy var trackerSections: [Int:Tracker] = {
        var sections: [Int:Tracker] = [:]
        var sectionCounter = statisticSection
        for tracker in habit.trackers {
            if let tracker = tracker as? Tracker {
                sectionCounter += 1
                sections[sectionCounter] = tracker
            }
        }
        return sections
    }()

    // MARK: - Configure
    
    func configure(habit: Habit) {
        self.habit = habit
        
        for tracker in habit.trackers {
            if let t = tracker as? NumberTracker {
                numberTrackers.append(t)
            } else if let t = tracker as? ImageTracker {
                imageTrackers.append(t)
            }
        }
    }
    
    // MARK: - View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.title = habit.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEntrySegue",
           let destination = segue.destination as? HabitEntryVC {
            destination.configure(habit: habit)
        } else if segue.identifier == "ViewAllImages",
                  let destination = segue.destination as? ViewAllImagesVC {
            destination.configure(habit: habit, tracker: viewAllImagesTracker)
        }
    }
}

// MARK: - Table View Methods

extension ProgressVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Sections:
        //  Calendar
        //  Statistics Table
        //  Trackers
        return 2 + trackerSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == calendarSection {
            return 2
        } else if section == statisticSection {
            return statisticsCalculator.numStatistics
        } else if trackerSections.keys.contains(section) {
            return 1
        } else {
            fatalError("wrong number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == calendarSection {
            // Calendar
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CalendarTableCell.self), for: indexPath) as! CalendarTableCell
                cell.configure(habit: habit)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "EditEntryCell", for: indexPath)
                return cell
            }
        } else if section == statisticSection {
            // Statistics
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: StatisticCell.self), for: indexPath) as! StatisticCell
            cell.configure(statisticsCalculator: statisticsCalculator, habit: habit, index: indexPath.row)
            return cell
        } else if trackerSections.keys.contains(section) {
            if let tracker = trackerSections[section] as? GraphTracker {
                // Graph Trackers (NumberTracker, ImprovementTracker)
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GraphTableCell.self), for: indexPath) as! GraphTableCell
                cell.configure(habit: habit, graphTracker: tracker)
                return cell
            } else if let tracker = trackerSections[section] as? ImageTracker {
                // Image Trackers
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ImageTableCell.self), for: indexPath) as! ImageTableCell
                cell.configure(tracker: tracker, viewAllImagesDelegate: self)
                return cell
            } else {
                fatalError("Unknown tracker")
            }
        } else {
            fatalError("Wrong number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        if section == calendarSection {
            if indexPath.row == 0 {
                return CalendarTableCell.cellHeight
            } else {
                return 44
            }
        } else if section == statisticSection {
            return 44
        } else if trackerSections.keys.contains(section) {
            if let _ = trackerSections[section] as? GraphTracker {
                return GraphTableCell.cellHeight
            } else if let _ = trackerSections[section] as? ImageTracker {
                return ImageTableCell.cellHeight
            } else {
                fatalError("unknown tracker")
            }
        } else {
            fatalError("wrong number of sections")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        default:
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - View All Images Protocol

protocol ViewAllImages {
    func viewAllImages(for: ImageTracker)
}

extension ProgressVC: ViewAllImages {
    func viewAllImages(for tracker: ImageTracker) {
        viewAllImagesTracker = tracker
        performSegue(withIdentifier: "ViewAllImages", sender: self)
    }
}

class DelayedTouchesTableView: UITableView {
    
    override func touchesShouldBegin(_ touches: Set<UITouch>, with event: UIEvent?, in view: UIView) -> Bool {
        if let graphView = view as? GraphView {
            graphView.beginTouches(touches, with: event)
        }
        return super.touchesShouldBegin(touches, with: event, in: view)
    }
}
