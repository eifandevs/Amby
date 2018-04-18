//
//  SearchMenuNewsTableViewCell.swift
//  Qas
//
//  Created by tenma on 2018/04/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import UIKit

class SearchMenuNewsTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setArticle(article: Article?) {
        titleLabel.text = article?.title ?? ""
        authorLabel.text = article?.author ?? ""
        descriptionLabel.text = article?.description ?? ""
    }
}
