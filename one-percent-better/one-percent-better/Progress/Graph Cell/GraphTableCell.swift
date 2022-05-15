//
//  GraphControlCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 12/7/21.
//

import UIKit

class GraphTableCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var numberTrackerNameLabel: UILabel!
    @IBOutlet weak var numberTrackerValueLabel: UILabel!
    
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var oneWButton: UIButton!
    @IBOutlet weak var twoWButton: UIButton!
    @IBOutlet weak var oneMButton: UIButton!
    @IBOutlet weak var threeMButton: UIButton!
    @IBOutlet weak var sixMButton: UIButton!
    @IBOutlet weak var oneYButton: UIButton!
    
    // MARK: - Variables
    
    static let cellHeight: CGFloat = 350
    var graphData: GraphData!
    
    var buttons: [UIButton] = []
    let buttonLabels = ["1W", "2W", "1M", "3M", "6M", "1Y"]
    let buttonDict = ["1W": 7, "2W": 14, "1M": 30, "3M": 91, "6M": 183, "1Y": 365]
    
    func configure(habit: Habit, graphTracker: GraphTracker) {
        
        numberTrackerNameLabel.text = graphTracker.name
        numberTrackerValueLabel.text = ""
        
        if let it = graphTracker as? ImprovementTracker {
            it.updateImprovementTracker(habit: habit)
        }
        
        // Set up graph
        graphView.delegate = self
        self.graphData = GraphData(graphTracker: graphTracker)
        graphData.updateRange(endDate: Date(), numDaysBefore: 7)
        graphView.configure(graphData: graphData)
        
        // Set up buttons
        setupButtons()
    }
    
    override func prepareForReuse() {
        for button in buttons {
            button.alpha = 1
        }
    }
    
    func markButtonAs(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = graphView.graphColor.withAlphaComponent(1)
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = graphView.graphColor.withAlphaComponent(0.1)
            button.setTitleColor(graphView.graphColor, for: .normal)
        }
    }
    
    func setupButtons() {
        buttons = [oneWButton, twoWButton, oneMButton, threeMButton, sixMButton, oneYButton]
        
        for (i, button) in buttons.enumerated() {
            // Set first button as selected and others as not selected
            if i == 0 {
                markButtonAs(button, selected: true)
            } else {
                markButtonAs(button, selected: false)
            }
            
            // Set up tags to differentiate buttons and send all to one target
            button.tag = i
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        }
    }
    
    @objc func buttonAction(sender: UIButton!) {
        for (i, button) in buttons.enumerated() {
            if i == sender.tag {
                markButtonAs(button, selected: true)
            } else {
                markButtonAs(button, selected: false)
            }
        }
        let label = buttonLabels[sender.tag]
        let numDays = buttonDict[label]!
        graphView.updateRange(endDate: Date(), numDaysBefore: numDays)
    }
    
}

// MARK: - Update Graph Value Delegate

protocol UpdateGraphValueDelegate {
    func update(to: String)
}

extension GraphTableCell: UpdateGraphValueDelegate {
    func update(to value: String) {
        numberTrackerValueLabel.text = value
    }
}
