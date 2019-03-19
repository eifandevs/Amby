//
//  GrepOperationView.swift
//  Amby
//
//  Created by tenma on 2019/03/15.
//  Copyright © 2019 eifandevs. All rights reserved.
//

import UIKit

class GrepOperationView: UIView {
    @IBOutlet var upButton: UIButton!
    @IBOutlet var downButton: UIButton!
    @IBOutlet var countLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    func loadNib() {
        // swiftlint:disable force_cast
        let view = Bundle.main.loadNibNamed(R.nib.grepOperationView.name, owner: self, options: nil)?.first as! UIView
        // swiftlint:enable force_cast
        view.frame = bounds
        addSubview(view)
    }
}
