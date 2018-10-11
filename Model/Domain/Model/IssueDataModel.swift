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

final class IssueDataModel {
    /// Issue登録成功通知用RX
    let rx_issueDataModelDidRegisterSuccess = PublishSubject<()>()

    /// Issue登録失敗通知用RX
    let rx_issueDataModelDidRegisterFailure = PublishSubject<Error?>()

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
                self.rx_issueDataModelDidRegisterSuccess.onNext(())
            } else {
                log.error("issue register failed. error: \(String(describing: error?.localizedDescription))")
                self.rx_issueDataModelDidRegisterFailure.onNext(error)
            }
        }
    }
}
