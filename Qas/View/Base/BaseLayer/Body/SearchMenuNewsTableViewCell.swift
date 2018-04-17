//
//  SearchMenuNewsTableViewCell.swift
//  Qas
//
//  Created by tenma on 2018/04/17.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import UIKit

class SearchMenuNewsTableViewCell: UITableViewCell {
    var titleLabel = UILabel()
    var urlLabel = UILabel()
    var thumbnail = UIImageView()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(titleLabel)
        addSubview(urlLabel)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder: ) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setArticle(article: Article) {
        titleLabel.frame = CGRect(x: 20, y: 0, width: frame.size.width - 20, height: frame.size.height / 2)
        urlLabel.frame = CGRect(x: 20, y: frame.size.height / 2, width: frame.size.width - 20, height: frame.size.height / 2)
        titleLabel.text = article.title
        urlLabel.text = article.author
        titleLabel.font = UIFont(name: AppConst.APP_FONT, size: 13.5)
        urlLabel.font = UIFont(name: AppConst.APP_FONT, size: 11)
    }
}
