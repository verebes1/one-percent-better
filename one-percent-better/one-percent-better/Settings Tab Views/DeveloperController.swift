//
//  DeveloperController.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 10/31/23.
//

import UIKit

class DeveloperController {
    static let shared = DeveloperController()
    
    private var allowList: Set<String> = ["D8BDA928-DD89-4A26-84FB-B2770C0D4B52"]
    
    public var isDeveloper: Bool {
        guard let udid = UIDevice.current.identifierForVendor?.uuidString else {
            return false
        }
        return allowList.contains(udid)
    }
}
