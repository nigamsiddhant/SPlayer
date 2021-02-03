//
//  SPlayerUtilities.swift
//  SPlayer
//
//  Created by mac  on 28/11/20.
//

import Foundation
import UIKit

public class SPlayerUtilities {
    
    static let shared = SPlayerUtilities()
    
    var play: UIImage? {
        get{
            let bundle = Bundle(for: Self.self)
            return UIImage(named: "play", in: bundle, compatibleWith: nil)
        }
    }
    
    var expand: UIImage? {
        get{
            let bundle = Bundle(for: Self.self)
            return UIImage(named: "expand", in: bundle, compatibleWith: nil)
        }
    }
    
    var collapse: UIImage? {
        get{
            let bundle = Bundle(for: Self.self)
            return UIImage(named: "collapse", in: bundle, compatibleWith: nil)
        }
    }
    
    var mute: UIImage? {
        get{
            let bundle = Bundle(for: Self.self)
            return UIImage(named: "mute", in: bundle, compatibleWith: nil)
        }
    }
    
    var unmute: UIImage? {
        get{
            let bundle = Bundle(for: Self.self)
            return UIImage(named: "unmute", in: bundle, compatibleWith: nil)
        }
    }
}
