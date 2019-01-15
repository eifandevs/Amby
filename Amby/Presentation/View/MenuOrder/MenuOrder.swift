//
//  MenuOrder.swift
//  Amby
//
//  Created by tenma on 2018/11/18.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation

enum MenuOrder: Int, CaseIterable {
    case first = 0
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eighth
    case ninth
    case tenth
    case eleventh
    case twelfth
    case none

    init(order: Int?) {
        if let order = order {
            for menuOrder in MenuOrder.allCases where menuOrder.rawValue == order {
                self = menuOrder
                return
            }
        }
        self = .none
    }

    func color() -> UIColor {
        if self == .none {
            return UIColor.clear
        } else {
            return UIColor.black
        }
    }

    func image() -> UIImage? {
        let image = { () -> UIImage? in
            switch self {
            case .first:
                return R.image.optionmenuMenuOrderOne()
            case .second:
                return R.image.optionmenuMenuOrderTwo()
            case .third:
                return R.image.optionmenuMenuOrderThree()
            case .fourth:
                return R.image.optionmenuMenuOrderFour()
            case .fifth:
                return R.image.optionmenuMenuOrderFive()
            case .sixth:
                return R.image.optionmenuMenuOrderSix()
            case .seventh:
                return R.image.optionmenuMenuOrderSeven()
            case .eighth:
                return R.image.optionmenuMenuOrderEight()
            case .ninth:
                return R.image.optionmenuMenuOrderNine()
            case .tenth:
                return R.image.optionmenuMenuOrderTen()
            case .eleventh:
                return R.image.optionmenuMenuOrderEleven()
            case .twelfth:
                return R.image.optionmenuMenuOrderTwelve()
            case .none:
                return nil
            }
        }()

        if let image = image {
            return image.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        } else {
            return nil
        }
    }
}
