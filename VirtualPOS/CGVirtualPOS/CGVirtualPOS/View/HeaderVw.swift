//
//  HeaderVw.swift
//  CGVirtualPOS
//
//  Created by Krishna Srivastava on 24/12/19.
//  Copyright © 2019 Krishna Srivastava. All rights reserved.
//

import Foundation
import UIKit

class HeaderVw: UIView {
    
    @IBOutlet weak var lblHeader: UILabel!
    
    class func instansiateFromNib() -> HeaderVw{
        return MAIN_BUNDLE.loadNibNamed("HeaderVw", owner: self, options: nil)! [0] as! HeaderVw
    }
    
}
