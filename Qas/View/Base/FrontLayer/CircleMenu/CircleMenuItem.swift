//
//  CircleMenuItem.swift
//  Eiger
//
//  Created by User on 2017/06/08.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import UIKit

class CircleMenuItem: UIButton, ShadowView, CircleView {
    var action: ((CGPoint) -> Void)?
    var scheduledAction: Bool = false
    var isValid: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
    }

    override func didMoveToSuperview() {
        addCircleShadow()
        addCircle()
    }

    convenience init(image: UIImage? = nil, tapAction: ((CGPoint) -> Void)?) {
        self.init(frame: CGRect.zero)
        if let image = image {
            imageEdgeInsets = UIEdgeInsetsMake(6.5, 6.5, 6.5, 6.5)
            setImage(image: image, color: UIColor.darkGray)
        }
        action = tapAction
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }
}
