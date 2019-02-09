//
//  FooterView.swift
//  Eiger
//
//  Created by temma on 2017/03/05.
//  Copyright © 2017年 eifaniori. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import RxCocoa
import RxSwift
import UIKit

class FooterView: UIView, ShadowView {
    private var viewModel = FooterViewModel()
    private var collectionView: UICollectionView!
    private var isDragging = false
    private var cell: FooterCollectionViewCell!

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup(frame: frame)
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        log.debug("deinit called.")
    }

    private func setup(frame: CGRect) {
        // layout
        addAreaShadow()
        backgroundColor = UIColor.lightGray

        // cell layout
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: AppConst.BASE_LAYER.THUMBNAIL_SIZE.width, height: frame.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        collectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: frame.size), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = layout
        collectionView.backgroundColor = UIColor.lightGray
        collectionView.isScrollEnabled = true
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(R.nib.footerCollectionViewCell(), forCellWithReuseIdentifier: R.nib.footerCollectionViewCell.identifier)
        // タイトル用に、スクロールビューの領域外に配置できるようにする
        collectionView.clipsToBounds = false

        // ロングプレスで移動
        let longPressRecognizer = UILongPressGestureRecognizer()

        longPressRecognizer.rx.event
            .subscribe { [weak self] sender in
                guard let `self` = self else { return }
                if let sender = sender.element {
                    switch sender.state {
                    case .began:
                        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: sender.location(in: self.collectionView)), let cell = self.collectionView.cellForItem(at: selectedIndexPath) as? FooterCollectionViewCell else {
                            break
                        }
                        self.cell = cell
                        self.cell.startDrag()
                        self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
                    case .changed:
                        self.collectionView.updateInteractiveMovementTargetPosition(sender.location(in: sender.view!))
                    case .ended:
                        self.cell.endDrag()
                        self.collectionView.endInteractiveMovement()
                    default:
                        self.collectionView.cancelInteractiveMovement()
                    }
                }
            }
            .disposed(by: rx.disposeBag)

        collectionView.addGestureRecognizer(longPressRecognizer)

        addSubview(collectionView)

        setupRx()
    }

    private func setupRx() {
        // サムネイル監視
        viewModel.rx_action
            .subscribe { [weak self] action in
                guard let `self` = self, let action = action.element else { return }
                log.eventIn(chain: "FooterViewModel.rx_action. action: \(action)")
                switch action {
                case let .update(indexPath, animated): self.update(indexPath: indexPath, animated: animated)
                case let .append(indexPath): self.append(indexPath: indexPath)
                case let .insert(indexPath): self.insert(indexPath: indexPath)
                case let .delete(indexPath): self.delete(indexPath: indexPath)
                default: break
                }
                log.eventOut(chain: "FooterViewModel.rx_action. action: \(action)")
            }
            .disposed(by: rx.disposeBag)
    }

    /// アペンド
    private func append(indexPath: IndexPath) {
        DispatchQueue.mainSyncSafe {
            self.collectionView.insertItems(at: [indexPath])
            self.viewModel.updateFrontBar()
        }
    }

    /// 挿入
    private func insert(indexPath: IndexPath) {
        DispatchQueue.mainSyncSafe {
            self.collectionView.insertItems(at: [indexPath])
            self.viewModel.updateFrontBar()
        }
    }

    /// 削除
    private func delete(indexPath: IndexPath) {
        DispatchQueue.mainSyncSafe {
            self.collectionView.deleteItems(at: [indexPath])
            self.viewModel.updateFrontBar()
        }
    }

    /// 画面更新
    private func update(indexPath: [IndexPath]?, animated: Bool) {
        if let indexPath = indexPath {
            // 部分更新
            DispatchQueue.mainSyncSafe {
                if animated {
                    collectionView.reloadItems(at: indexPath)
                } else {
                    UIView.performWithoutAnimation {
                        collectionView.reloadItems(at: indexPath)
                    }
                }
            }
        } else {
            // 全更新
            DispatchQueue.mainSyncSafe {
                if animated {
                    collectionView.reloadData()
                } else {
                    UIView.performWithoutAnimation {
                        collectionView.reloadData()
                    }
                }
            }
        }
    }
}

extension FooterView: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return viewModel.cellCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = R.nib.footerCollectionViewCell.identifier
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! FooterCollectionViewCell
        // swiftlint:enable force_cast
        cell.setRow(row: viewModel.getRow(indexPath: indexPath))
        return cell
    }
}

extension FooterView: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, canMoveItemAt _: IndexPath) -> Bool {
        return true
    }

    func collectionView(_: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.swap(start: sourceIndexPath.item, end: destinationIndexPath.item)
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.change(indexPath: indexPath)
    }
}

// cellのサイズの設定
extension FooterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt _: Int) -> UIEdgeInsets {
        let isRequireLeftMargin = (AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * CGFloat(viewModel.cellCount)) < bounds.size.width
        if isRequireLeftMargin {
            let leftMargin = (bounds.size.width - (AppConst.BASE_LAYER.THUMBNAIL_SIZE.width * CGFloat(viewModel.cellCount))) / 2
            return UIEdgeInsets(top: 0, left: leftMargin, bottom: 0, right: 0)
        } else {
            return .zero
        }
    }

    func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt _: IndexPath) -> CGSize {
        return CGSize(width: AppConst.BASE_LAYER.THUMBNAIL_SIZE.width, height: frame.height)
    }
}

// MARK: ScrollView Delegate

extension FooterView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_: UIScrollView) {
        viewModel.startDragging()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }

    func scrollViewDidEndDragging(_: UIScrollView, willDecelerate _: Bool) {
        viewModel.endDragging()
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
    }
}
