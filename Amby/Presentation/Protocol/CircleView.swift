//
//  CircleView.swift
//  Eiger
//
//  Created by User on 2017/06/08.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

protocol CircleView {
    func addCircle()
}

extension CircleView where Self: UIView {
    func addCircle() {
        layer.cornerRadius = frame.size.width / 2
    }
}
