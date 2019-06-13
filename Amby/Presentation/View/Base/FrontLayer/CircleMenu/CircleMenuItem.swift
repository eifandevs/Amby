//
//  CircleMenuItem.swift
//  Eiger
//
//  Created by User on 2017/06/08.
//  Copyright © 2017年 eifandevs. All rights reserved.
//

import Foundation
import Model
import UIKit

class CircleMenuItem: UIButton, ShadowView, CircleView {
    var scheduledAction: Bool = false
    var isValid: Bool = false
    var operation: UserOperation!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }

    override func didMoveToSuperview() {
        addCircleShadow()
        addCircle()
    }

    convenience init(operation: UserOperation) {
        self.init(frame: CGRect.zero)

        self.operation = operation
        imageEdgeInsets = UIEdgeInsets(top: 6.5, left: 6.5, bottom: 6.5, right: 6.5)

        setImage(image: operation.image(), color: operation.imageColor())

        #if UT
            accessibilityIdentifier = operation.accesibilityIdentify()
        #endif
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }
}
