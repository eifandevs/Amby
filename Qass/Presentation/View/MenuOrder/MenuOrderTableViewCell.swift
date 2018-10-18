//
//  MenuOrderTableViewCell.swift
//  Qass
//
//  Created by tenma on 2018/10/15.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class MenuOrderTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var orderImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setRow(row: MenuOrderViewControllerViewModel.Row, order: Int?) {
        titleLabel.text = row.operation.title()
        if let order = order {
            let image = { () -> UIImage? in
                switch order {
                case 0:
                    return R.image.optionmenuMenuOrderOne()
                case 1:
                    return R.image.optionmenuMenuOrderTwo()
                case 2:
                    return R.image.optionmenuMenuOrderThree()
                case 3:
                    return R.image.optionmenuMenuOrderFour()
                case 4:
                    return R.image.optionmenuMenuOrderFive()
                case 5:
                    return R.image.optionmenuMenuOrderSix()
                case 6:
                    return R.image.optionmenuMenuOrderSeven()
                case 7:
                    return R.image.optionmenuMenuOrderEight()
                case 8:
                    return R.image.optionmenuMenuOrderNine()
                case 9:
                    return R.image.optionmenuMenuOrderTen()
                case 10:
                    return R.image.optionmenuMenuOrderEleven()
                case 11:
                    return R.image.optionmenuMenuOrderTwelve()
                default:
                    return UIImage()
                }
            }()

            orderImageView.image = image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            orderImageView.tintColor = UIColor.black
        } else {
            orderImageView.tintColor = UIColor.clear
        }
    }
}
