//
//  UIImage.swift
//  one-percent-better
//
//  Created by Jeremy Cook on 6/22/22.
//

import Foundation
import UIKit

extension UIImage {
    func png(isOpaque: Bool = true) -> Data? { flattened(isOpaque: isOpaque)?.pngData() }
    func flattened(isOpaque: Bool = true) -> UIImage? {
        if imageOrientation == .up { return self }
        UIGraphicsBeginImageContextWithOptions(size, isOpaque, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
