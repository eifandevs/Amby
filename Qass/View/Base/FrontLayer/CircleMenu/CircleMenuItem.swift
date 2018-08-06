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

        switch operation {
        case .menu:
            setImage(image: R.image.circlemenuMenu(), color: UIColor.darkGray)
        case .close:
            setImage(image: R.image.circlemenuClose(), color: UIColor.darkGray)
        case .historyBack:
            setImage(image: R.image.circlemenuHistoryback(), color: UIColor.darkGray)
        case .copy:
            setImage(image: R.image.circlemenuCopy(), color: UIColor.darkGray)
        case .search:
            setImage(image: R.image.circlemenuSearch(), color: UIColor.darkGray)
        case .add:
            setImage(image: R.image.circlemenuAdd(), color: UIColor.darkGray)
        case .scrollUp:
            setImage(image: R.image.circlemenuScrollup(), color: UIColor.darkGray)
        case .autoScroll:
            setImage(image: R.image.circlemenuAutoscroll(), color: UIColor.darkGray)
        case .historyForward:
            setImage(image: R.image.circlemenuHistoryforward(), color: UIColor.darkGray)
        case .form:
            setImage(image: R.image.circlemenuForm(), color: UIColor.darkGray)
        case .favorite:
            setImage(image: R.image.circlemenuFavorite(), color: UIColor.darkGray)
        case .grep:
            setImage(image: R.image.circlemenuHome(), color: UIColor.darkGray)
        default:
            break
        }

        #if UT
        switch operation {
        case .menu:
            accessibilityIdentifier = R.image.circlemenuMenu.name
            log.debug("set accessibility. name: \(R.image.circlemenuMenu.name)")
        case .close:
            accessibilityIdentifier = R.image.circlemenuClose.name
            log.debug("set accessibility. name: \(R.image.circlemenuClose.name)")
        case .historyBack:
            accessibilityIdentifier = R.image.circlemenuHistoryback.name
            log.debug("set accessibility. name: \(R.image.circlemenuHistoryback.name)")
        case .copy:
            accessibilityIdentifier = R.image.circlemenuCopy.name
            log.debug("set accessibility. name: \(R.image.circlemenuCopy.name)")
        case .search:
            accessibilityIdentifier = R.image.circlemenuSearch.name
            log.debug("set accessibility. name: \(R.image.circlemenuSearch.name)")
        case .add:
            accessibilityIdentifier = R.image.circlemenuAdd.name
            log.debug("set accessibility. name: \(R.image.circlemenuAdd.name)")
        case .scrollUp:
            accessibilityIdentifier = R.image.circlemenuScrollup.name
            log.debug("set accessibility. name: \(R.image.circlemenuScrollup.name)")
        case .autoScroll:
            accessibilityIdentifier = R.image.circlemenuAutoscroll.name
            log.debug("set accessibility. name: \(R.image.circlemenuAutoscroll.name)")
        case .historyForward:
            accessibilityIdentifier = R.image.circlemenuHistoryforward.name
            log.debug("set accessibility. name: \(R.image.circlemenuHistoryforward.name)")
        case .form:
            accessibilityIdentifier = R.image.circlemenuForm.name
            log.debug("set accessibility. name: \(R.image.circlemenuForm.name)")
        case .favorite:
            accessibilityIdentifier = R.image.circlemenuFavorite.name
            log.debug("set accessibility. name: \(R.image.circlemenuFavorite.name)")
        case .home:
            accessibilityIdentifier = R.image.circlemenuHome.name
            log.debug("set accessibility. name: \(R.image.circlemenuHome.name)")
        default:
            break
        }
        #endif
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }
}
