//
//  DeveloperController.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/31/23.
//

import UIKit

class DeveloperController {
    static let shared = DeveloperController()
    
    private var allowList: Set<String> = ["84B9DA5C-F47E-4D2F-AFAB-5EDDD8122270"]
    
    public var isDeveloper: Bool {
        guard let udid = UIDevice.current.identifierForVendor?.uuidString else {
            return false
        }
        return allowList.contains(udid)
    }
}
