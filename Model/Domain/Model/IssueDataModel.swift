//
//  IssueDataModel.swift
//  Model
//
//  Created by tenma on 2018/10/08.
//  Copyright © 2018年 eifandevs. All rights reserved.
//

import Foundation
import GithubAPI
import RxCocoa
import RxSwift

enum IssueDataModelAction {
    case registered
}

enum IssueDataModelError {
    case post
}

extension IssueDataModelError: ModelError {
    var message: String {
        switch self {
        case .post:
            return MessageConst.NOTIFICATION.POST_ISSUE_ERROR
        }
    }
}

final class IssueDataModel {
    /// RXアクション通知用RX
    let rx_action = PublishSubject<IssueDataModelAction>()

    /// エラー通知用RX
    let rx_error = PublishSubject<IssueDataModelError>()

    static let s = IssueDataModel()
    private let disposeBag = DisposeBag()

    private init() {}

    /// 登録
    func post(title: String, body: String) {
        var issue = Issue(title: title)
        issue.body = body
        let owner = ModelConst.KEY.OWNER
        let repo = ModelConst.KEY.REPOSITORY
        let accessToken = ModelConst.KEY.GITHUB_ACCESS_TOKEN

        IssuesAPI(authentication: AccessTokenAuthentication(access_token: accessToken)).createIssue(owner: owner, repository: repo, issue: issue) { [weak self] response, error in
            guard let `self` = self else { return }

            if let response = response {
                log.debug("issue register success. response: \(response)")
                self.rx_action.onNext(.registered)
            } else {
                log.error("issue register failed. error: \(String(describing: error?.localizedDescription))")
                self.rx_error.onNext(.post)
            }
        }
    }
}
