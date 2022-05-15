//
//  StatisticCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/1/22.
//

import UIKit

/// A structure which stores the title and value of a statistic
/// NOTE: The value of the statistic is a string, not a number
struct Statistic {
    let title: String
    let value: String
}

class StatisticCell: UITableViewCell {
    
    func configure(statisticsCalculator: StatisticsCalculator, habit: Habit, index: Int) {
        var content = self.defaultContentConfiguration()
        let statistic = statisticsCalculator.getStatistic(habit: habit, index: index)
        content.text = statistic.title
        content.secondaryText = "\(statistic.value)"
        self.contentConfiguration = content
    }
}
