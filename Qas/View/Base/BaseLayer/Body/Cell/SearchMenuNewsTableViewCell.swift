//
//  SearchMenuNewsTableViewCell.swift
//  Qas
//
//  Created by tenma on 2018/04/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Kingfisher
import UIKit

class SearchMenuNewsTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    /// 表示内容
    var article: Article?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setArticle(article: Article?) {
        self.article = article

        if let urlToImage = article?.urlToImage, !urlToImage.isEmpty {
            thumbnailImageView.kf.indicatorType = .activity
            thumbnailImageView.kf.setImage(with: URL(string: urlToImage))
        } else {
            // サムネイルがない場合は、NO IMAGEで表示する
            thumbnailImageView.image = R.image.searchmenuNoimage()
        }
        titleLabel.text = article?.title ?? ""
        authorLabel.text = article?.author ?? ""
        descriptionLabel.text = article?.description ?? ""
    }
}
