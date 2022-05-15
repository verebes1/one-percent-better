//
//  SettingsCell.swift
//  mo-ikai
//
//  Created by Jeremy Cook on 1/6/22.
//

import UIKit

class SettingsCell: UITableViewCell {
    
//    @IBOutlet weak var iconButton: UIButton!
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var settingsLabel: UILabel!
    
    static let cellHeight: CGFloat = 44
    
    func configure(setting: Setting) {
        settingsLabel.text = setting.name
        backGroundView.backgroundColor = setting.backgroundColor
        backGroundView.layer.cornerRadius = 7
        
        if let image = setting.iconImage {
            iconImageView.image = image
        } else {
            fatalError("Unable to get image for setting: \(setting.name)")
        }
    }
}
