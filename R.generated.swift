//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap(Locale.init) ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)
  
  static func validate() throws {
    try intern.validate()
  }
  
  /// This `R.color` struct is generated, and contains static references to 0 color palettes.
  struct color {
    fileprivate init() {}
  }
  
  /// This `R.file` struct is generated, and contains static references to 7 files.
  struct file {
    /// Resource file `article_stub.json`.
    static let article_stubJson = Rswift.FileResource(bundle: R.hostingBundle, name: "article_stub", pathExtension: "json")
    /// Resource file `authorize.html`.
    static let authorizeHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "authorize", pathExtension: "html")
    /// Resource file `dns.html`.
    static let dnsHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "dns", pathExtension: "html")
    /// Resource file `invalid.html`.
    static let invalidHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "invalid", pathExtension: "html")
    /// Resource file `offline.html`.
    static let offlineHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "offline", pathExtension: "html")
    /// Resource file `suggest_stub.json`.
    static let suggest_stubJson = Rswift.FileResource(bundle: R.hostingBundle, name: "suggest_stub", pathExtension: "json")
    /// Resource file `timeout.html`.
    static let timeoutHtml = Rswift.FileResource(bundle: R.hostingBundle, name: "timeout", pathExtension: "html")
    
    /// `bundle.url(forResource: "article_stub", withExtension: "json")`
    static func article_stubJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.article_stubJson
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "authorize", withExtension: "html")`
    static func authorizeHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.authorizeHtml
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "dns", withExtension: "html")`
    static func dnsHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.dnsHtml
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "invalid", withExtension: "html")`
    static func invalidHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.invalidHtml
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "offline", withExtension: "html")`
    static func offlineHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.offlineHtml
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "suggest_stub", withExtension: "json")`
    static func suggest_stubJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.suggest_stubJson
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    /// `bundle.url(forResource: "timeout", withExtension: "html")`
    static func timeoutHtml(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.timeoutHtml
      return fileResource.bundle.url(forResource: fileResource)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.font` struct is generated, and contains static references to 0 fonts.
  struct font {
    fileprivate init() {}
  }
  
  /// This `R.image` struct is generated, and contains static references to 24 images.
  struct image {
    /// Image `circlemenu-add`.
    static let circlemenuAdd = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-add")
    /// Image `circlemenu-autoscroll`.
    static let circlemenuAutoscroll = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-autoscroll")
    /// Image `circlemenu-close`.
    static let circlemenuClose = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-close")
    /// Image `circlemenu-copy`.
    static let circlemenuCopy = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-copy")
    /// Image `circlemenu-form`.
    static let circlemenuForm = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-form")
    /// Image `circlemenu-historyback`.
    static let circlemenuHistoryback = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-historyback")
    /// Image `circlemenu-historyforward`.
    static let circlemenuHistoryforward = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-historyforward")
    /// Image `circlemenu-home`.
    static let circlemenuHome = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-home")
    /// Image `circlemenu-menu`.
    static let circlemenuMenu = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-menu")
    /// Image `circlemenu-scrollup`.
    static let circlemenuScrollup = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-scrollup")
    /// Image `circlemenu-search`.
    static let circlemenuSearch = Rswift.ImageResource(bundle: R.hostingBundle, name: "circlemenu-search")
    /// Image `footer-thumbnail-back`.
    static let footerThumbnailBack = Rswift.ImageResource(bundle: R.hostingBundle, name: "footer-thumbnail-back")
    /// Image `header-close`.
    static let headerClose = Rswift.ImageResource(bundle: R.hostingBundle, name: "header-close")
    /// Image `header-favorite-selected`.
    static let headerFavoriteSelected = Rswift.ImageResource(bundle: R.hostingBundle, name: "header-favorite-selected")
    /// Image `header-favorite`.
    static let headerFavorite = Rswift.ImageResource(bundle: R.hostingBundle, name: "header-favorite")
    /// Image `header-key`.
    static let headerKey = Rswift.ImageResource(bundle: R.hostingBundle, name: "header-key")
    /// Image `logo`.
    static let logo = Rswift.ImageResource(bundle: R.hostingBundle, name: "logo")
    /// Image `optionmenu-form`.
    static let optionmenuForm = Rswift.ImageResource(bundle: R.hostingBundle, name: "optionmenu-form")
    /// Image `optionmenu-help`.
    static let optionmenuHelp = Rswift.ImageResource(bundle: R.hostingBundle, name: "optionmenu-help")
    /// Image `optionmenu-history`.
    static let optionmenuHistory = Rswift.ImageResource(bundle: R.hostingBundle, name: "optionmenu-history")
    /// Image `optionmenu-setting`.
    static let optionmenuSetting = Rswift.ImageResource(bundle: R.hostingBundle, name: "optionmenu-setting")
    /// Image `optionmenu_app`.
    static let optionmenu_app = Rswift.ImageResource(bundle: R.hostingBundle, name: "optionmenu_app")
    /// Image `optionmenu_favorite`.
    static let optionmenu_favorite = Rswift.ImageResource(bundle: R.hostingBundle, name: "optionmenu_favorite")
    /// Image `searchmenu-noimage`.
    static let searchmenuNoimage = Rswift.ImageResource(bundle: R.hostingBundle, name: "searchmenu-noimage")
    
    /// `UIImage(named: "circlemenu-add", bundle: ..., traitCollection: ...)`
    static func circlemenuAdd(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuAdd, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-autoscroll", bundle: ..., traitCollection: ...)`
    static func circlemenuAutoscroll(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuAutoscroll, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-close", bundle: ..., traitCollection: ...)`
    static func circlemenuClose(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuClose, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-copy", bundle: ..., traitCollection: ...)`
    static func circlemenuCopy(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuCopy, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-form", bundle: ..., traitCollection: ...)`
    static func circlemenuForm(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuForm, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-historyback", bundle: ..., traitCollection: ...)`
    static func circlemenuHistoryback(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuHistoryback, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-historyforward", bundle: ..., traitCollection: ...)`
    static func circlemenuHistoryforward(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuHistoryforward, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-home", bundle: ..., traitCollection: ...)`
    static func circlemenuHome(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuHome, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-menu", bundle: ..., traitCollection: ...)`
    static func circlemenuMenu(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuMenu, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-scrollup", bundle: ..., traitCollection: ...)`
    static func circlemenuScrollup(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuScrollup, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "circlemenu-search", bundle: ..., traitCollection: ...)`
    static func circlemenuSearch(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.circlemenuSearch, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "footer-thumbnail-back", bundle: ..., traitCollection: ...)`
    static func footerThumbnailBack(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.footerThumbnailBack, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "header-close", bundle: ..., traitCollection: ...)`
    static func headerClose(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.headerClose, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "header-favorite", bundle: ..., traitCollection: ...)`
    static func headerFavorite(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.headerFavorite, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "header-favorite-selected", bundle: ..., traitCollection: ...)`
    static func headerFavoriteSelected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.headerFavoriteSelected, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "header-key", bundle: ..., traitCollection: ...)`
    static func headerKey(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.headerKey, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "logo", bundle: ..., traitCollection: ...)`
    static func logo(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.logo, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "optionmenu-form", bundle: ..., traitCollection: ...)`
    static func optionmenuForm(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.optionmenuForm, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "optionmenu-help", bundle: ..., traitCollection: ...)`
    static func optionmenuHelp(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.optionmenuHelp, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "optionmenu-history", bundle: ..., traitCollection: ...)`
    static func optionmenuHistory(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.optionmenuHistory, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "optionmenu-setting", bundle: ..., traitCollection: ...)`
    static func optionmenuSetting(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.optionmenuSetting, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "optionmenu_app", bundle: ..., traitCollection: ...)`
    static func optionmenu_app(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.optionmenu_app, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "optionmenu_favorite", bundle: ..., traitCollection: ...)`
    static func optionmenu_favorite(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.optionmenu_favorite, compatibleWith: traitCollection)
    }
    
    /// `UIImage(named: "searchmenu-noimage", bundle: ..., traitCollection: ...)`
    static func searchmenuNoimage(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.searchmenuNoimage, compatibleWith: traitCollection)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.nib` struct is generated, and contains static references to 21 nibs.
  struct nib {
    /// Nib `HelpViewController`.
    static let helpViewController = _R.nib._HelpViewController()
    /// Nib `OptionMenuAppTableViewCell`.
    static let optionMenuAppTableViewCell = _R.nib._OptionMenuAppTableViewCell()
    /// Nib `OptionMenuAppTableView`.
    static let optionMenuAppTableView = _R.nib._OptionMenuAppTableView()
    /// Nib `OptionMenuFavoriteTableViewCell`.
    static let optionMenuFavoriteTableViewCell = _R.nib._OptionMenuFavoriteTableViewCell()
    /// Nib `OptionMenuFavoriteTableView`.
    static let optionMenuFavoriteTableView = _R.nib._OptionMenuFavoriteTableView()
    /// Nib `OptionMenuFormTableViewCell`.
    static let optionMenuFormTableViewCell = _R.nib._OptionMenuFormTableViewCell()
    /// Nib `OptionMenuFormTableView`.
    static let optionMenuFormTableView = _R.nib._OptionMenuFormTableView()
    /// Nib `OptionMenuHelpTableViewCell`.
    static let optionMenuHelpTableViewCell = _R.nib._OptionMenuHelpTableViewCell()
    /// Nib `OptionMenuHelpTableView`.
    static let optionMenuHelpTableView = _R.nib._OptionMenuHelpTableView()
    /// Nib `OptionMenuHistoryTableViewCell`.
    static let optionMenuHistoryTableViewCell = _R.nib._OptionMenuHistoryTableViewCell()
    /// Nib `OptionMenuHistoryTableView`.
    static let optionMenuHistoryTableView = _R.nib._OptionMenuHistoryTableView()
    /// Nib `OptionMenuSettingSliderTableViewCell`.
    static let optionMenuSettingSliderTableViewCell = _R.nib._OptionMenuSettingSliderTableViewCell()
    /// Nib `OptionMenuSettingTableViewCell`.
    static let optionMenuSettingTableViewCell = _R.nib._OptionMenuSettingTableViewCell()
    /// Nib `OptionMenuSettingTableView`.
    static let optionMenuSettingTableView = _R.nib._OptionMenuSettingTableView()
    /// Nib `OptionMenuTableViewCell`.
    static let optionMenuTableViewCell = _R.nib._OptionMenuTableViewCell()
    /// Nib `OptionMenuTableView`.
    static let optionMenuTableView = _R.nib._OptionMenuTableView()
    /// Nib `SearchMenuCommonHistoryTableViewCell`.
    static let searchMenuCommonHistoryTableViewCell = _R.nib._SearchMenuCommonHistoryTableViewCell()
    /// Nib `SearchMenuNewsTableViewCell`.
    static let searchMenuNewsTableViewCell = _R.nib._SearchMenuNewsTableViewCell()
    /// Nib `SearchMenuSearchHistoryTableViewCell`.
    static let searchMenuSearchHistoryTableViewCell = _R.nib._SearchMenuSearchHistoryTableViewCell()
    /// Nib `SearchMenuSuggestTableViewCell`.
    static let searchMenuSuggestTableViewCell = _R.nib._SearchMenuSuggestTableViewCell()
    /// Nib `SplashViewController`.
    static let splashViewController = _R.nib._SplashViewController()
    
    /// `UINib(name: "HelpViewController", in: bundle)`
    static func helpViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.helpViewController)
    }
    
    /// `UINib(name: "OptionMenuAppTableView", in: bundle)`
    static func optionMenuAppTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuAppTableView)
    }
    
    /// `UINib(name: "OptionMenuAppTableViewCell", in: bundle)`
    static func optionMenuAppTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuAppTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuFavoriteTableView", in: bundle)`
    static func optionMenuFavoriteTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuFavoriteTableView)
    }
    
    /// `UINib(name: "OptionMenuFavoriteTableViewCell", in: bundle)`
    static func optionMenuFavoriteTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuFavoriteTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuFormTableView", in: bundle)`
    static func optionMenuFormTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuFormTableView)
    }
    
    /// `UINib(name: "OptionMenuFormTableViewCell", in: bundle)`
    static func optionMenuFormTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuFormTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuHelpTableView", in: bundle)`
    static func optionMenuHelpTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuHelpTableView)
    }
    
    /// `UINib(name: "OptionMenuHelpTableViewCell", in: bundle)`
    static func optionMenuHelpTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuHelpTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuHistoryTableView", in: bundle)`
    static func optionMenuHistoryTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuHistoryTableView)
    }
    
    /// `UINib(name: "OptionMenuHistoryTableViewCell", in: bundle)`
    static func optionMenuHistoryTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuHistoryTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuSettingSliderTableViewCell", in: bundle)`
    static func optionMenuSettingSliderTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuSettingSliderTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuSettingTableView", in: bundle)`
    static func optionMenuSettingTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuSettingTableView)
    }
    
    /// `UINib(name: "OptionMenuSettingTableViewCell", in: bundle)`
    static func optionMenuSettingTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuSettingTableViewCell)
    }
    
    /// `UINib(name: "OptionMenuTableView", in: bundle)`
    static func optionMenuTableView(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuTableView)
    }
    
    /// `UINib(name: "OptionMenuTableViewCell", in: bundle)`
    static func optionMenuTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.optionMenuTableViewCell)
    }
    
    /// `UINib(name: "SearchMenuCommonHistoryTableViewCell", in: bundle)`
    static func searchMenuCommonHistoryTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.searchMenuCommonHistoryTableViewCell)
    }
    
    /// `UINib(name: "SearchMenuNewsTableViewCell", in: bundle)`
    static func searchMenuNewsTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.searchMenuNewsTableViewCell)
    }
    
    /// `UINib(name: "SearchMenuSearchHistoryTableViewCell", in: bundle)`
    static func searchMenuSearchHistoryTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.searchMenuSearchHistoryTableViewCell)
    }
    
    /// `UINib(name: "SearchMenuSuggestTableViewCell", in: bundle)`
    static func searchMenuSuggestTableViewCell(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.searchMenuSuggestTableViewCell)
    }
    
    /// `UINib(name: "SplashViewController", in: bundle)`
    static func splashViewController(_: Void = ()) -> UIKit.UINib {
      return UIKit.UINib(resource: R.nib.splashViewController)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.reuseIdentifier` struct is generated, and contains static references to 12 reuse identifiers.
  struct reuseIdentifier {
    /// Reuse identifier `OptionMenuAppCell`.
    static let optionMenuAppCell: Rswift.ReuseIdentifier<OptionMenuAppTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuAppCell")
    /// Reuse identifier `OptionMenuCell`.
    static let optionMenuCell: Rswift.ReuseIdentifier<OptionMenuTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuCell")
    /// Reuse identifier `OptionMenuFavoriteCell`.
    static let optionMenuFavoriteCell: Rswift.ReuseIdentifier<OptionMenuFavoriteTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuFavoriteCell")
    /// Reuse identifier `OptionMenuFormCell`.
    static let optionMenuFormCell: Rswift.ReuseIdentifier<OptionMenuFormTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuFormCell")
    /// Reuse identifier `OptionMenuHelpCell`.
    static let optionMenuHelpCell: Rswift.ReuseIdentifier<OptionMenuHelpTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuHelpCell")
    /// Reuse identifier `OptionMenuHistoryCell`.
    static let optionMenuHistoryCell: Rswift.ReuseIdentifier<OptionMenuHistoryTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuHistoryCell")
    /// Reuse identifier `OptionMenuSettingCell`.
    static let optionMenuSettingCell: Rswift.ReuseIdentifier<OptionMenuSettingTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuSettingCell")
    /// Reuse identifier `OptionMenuSettingSliderCell`.
    static let optionMenuSettingSliderCell: Rswift.ReuseIdentifier<OptionMenuSettingSliderTableViewCell> = Rswift.ReuseIdentifier(identifier: "OptionMenuSettingSliderCell")
    /// Reuse identifier `SearchMenuCommonHistoryCell`.
    static let searchMenuCommonHistoryCell: Rswift.ReuseIdentifier<SearchMenuCommonHistoryTableViewCell> = Rswift.ReuseIdentifier(identifier: "SearchMenuCommonHistoryCell")
    /// Reuse identifier `SearchMenuNewsCell`.
    static let searchMenuNewsCell: Rswift.ReuseIdentifier<SearchMenuNewsTableViewCell> = Rswift.ReuseIdentifier(identifier: "SearchMenuNewsCell")
    /// Reuse identifier `SearchMenuSearchHistoryCell`.
    static let searchMenuSearchHistoryCell: Rswift.ReuseIdentifier<SearchMenuSearchHistoryTableViewCell> = Rswift.ReuseIdentifier(identifier: "SearchMenuSearchHistoryCell")
    /// Reuse identifier `SearchMenuSuggestCell`.
    static let searchMenuSuggestCell: Rswift.ReuseIdentifier<SearchMenuSuggestTableViewCell> = Rswift.ReuseIdentifier(identifier: "SearchMenuSuggestCell")
    
    fileprivate init() {}
  }
  
  /// This `R.segue` struct is generated, and contains static references to 0 view controllers.
  struct segue {
    fileprivate init() {}
  }
  
  /// This `R.storyboard` struct is generated, and contains static references to 1 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    
    fileprivate init() {}
  }
  
  /// This `R.string` struct is generated, and contains static references to 0 localization tables.
  struct string {
    fileprivate init() {}
  }
  
  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }
    
    fileprivate init() {}
  }
  
  fileprivate class Class {}
  
  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    try storyboard.validate()
    try nib.validate()
  }
  
  struct nib: Rswift.Validatable {
    static func validate() throws {
      try _SplashViewController.validate()
    }
    
    struct _HelpViewController: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "HelpViewController"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuAppTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuAppTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuAppTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuAppTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuAppCell"
      let name = "OptionMenuAppTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuAppTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuAppTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuFavoriteTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuFavoriteTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuFavoriteTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuFavoriteTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuFavoriteCell"
      let name = "OptionMenuFavoriteTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuFavoriteTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuFavoriteTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuFormTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuFormTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuFormTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuFormTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuFormCell"
      let name = "OptionMenuFormTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuFormTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuFormTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuHelpTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuHelpTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuHelpTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuHelpTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuHelpCell"
      let name = "OptionMenuHelpTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuHelpTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuHelpTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuHistoryTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuHistoryTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuHistoryTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuHistoryTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuHistoryCell"
      let name = "OptionMenuHistoryTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuHistoryTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuHistoryTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuSettingSliderTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuSettingSliderTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuSettingSliderCell"
      let name = "OptionMenuSettingSliderTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuSettingSliderTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuSettingSliderTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuSettingTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuSettingTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuSettingTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuSettingTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuSettingCell"
      let name = "OptionMenuSettingTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuSettingTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuSettingTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuTableView: Rswift.NibResourceType {
      let bundle = R.hostingBundle
      let name = "OptionMenuTableView"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      fileprivate init() {}
    }
    
    struct _OptionMenuTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = OptionMenuTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "OptionMenuCell"
      let name = "OptionMenuTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> OptionMenuTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? OptionMenuTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _SearchMenuCommonHistoryTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = SearchMenuCommonHistoryTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "SearchMenuCommonHistoryCell"
      let name = "SearchMenuCommonHistoryTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> SearchMenuCommonHistoryTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? SearchMenuCommonHistoryTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _SearchMenuNewsTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = SearchMenuNewsTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "SearchMenuNewsCell"
      let name = "SearchMenuNewsTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> SearchMenuNewsTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? SearchMenuNewsTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _SearchMenuSearchHistoryTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = SearchMenuSearchHistoryTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "SearchMenuSearchHistoryCell"
      let name = "SearchMenuSearchHistoryTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> SearchMenuSearchHistoryTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? SearchMenuSearchHistoryTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _SearchMenuSuggestTableViewCell: Rswift.NibResourceType, Rswift.ReuseIdentifierType {
      typealias ReusableType = SearchMenuSuggestTableViewCell
      
      let bundle = R.hostingBundle
      let identifier = "SearchMenuSuggestCell"
      let name = "SearchMenuSuggestTableViewCell"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> SearchMenuSuggestTableViewCell? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? SearchMenuSuggestTableViewCell
      }
      
      fileprivate init() {}
    }
    
    struct _SplashViewController: Rswift.NibResourceType, Rswift.Validatable {
      let bundle = R.hostingBundle
      let name = "SplashViewController"
      
      func firstView(owner ownerOrNil: AnyObject?, options optionsOrNil: [NSObject : AnyObject]? = nil) -> UIKit.UIView? {
        return instantiate(withOwner: ownerOrNil, options: optionsOrNil)[0] as? UIKit.UIView
      }
      
      static func validate() throws {
        if UIKit.UIImage(named: "logo", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'logo' is used in nib 'SplashViewController', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      try launchScreen.validate()
    }
    
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController
      
      let bundle = R.hostingBundle
      let name = "LaunchScreen"
      
      static func validate() throws {
        if UIKit.UIImage(named: "logo") == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'logo' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
      }
      
      fileprivate init() {}
    }
    
    fileprivate init() {}
  }
  
  fileprivate init() {}
}
