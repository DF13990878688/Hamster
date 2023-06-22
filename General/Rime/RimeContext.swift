import Foundation
import LibrimeKit
import ProgressHUD
import SwiftUI

public class RimeContext: ObservableObject {
  static let shared = RimeContext()

  private init() {}
  /// switcher hotkeys 键值映射
  static let hotKeyCodeMapping = [
    "f4": XK_F4,
    "control+grave": Int32("`".utf8.first!),
    "control+shift+grave": Int32("`".utf8.first!),
  ]

  static let hotKeyCodeModifiersMapping = [
    "f4": Int32(0),
    "control+grave": RimeModifier.kControlMask,
    "control+shift+grave": RimeModifier.kControlMask | RimeModifier.kShiftMask,
  ]

  /// 候选字上限
  var maxCandidateCount: Int = 100

  /// switcher hotkeys
  var hotKeys = ["f4"]

  /// 用户输入键值
  @Published
  var userInputKey: String = ""

  /// 字母模式
  @Published
  var asciiMode: Bool = false

  /// 候选字
  @Published
  var suggestions: [HamsterSuggestion] = []
}

extension RimeContext {
  func reset() {
    userInputKey = ""
    suggestions = []
    Rime.shared.cleanComposition()
  }

  func candidateListLimit() -> [HamsterSuggestion] {
    let candidates = Rime.shared.getCandidate(index: 0, count: maxCandidateCount)
    var result: [HamsterSuggestion] = []
    for (index, candidate) in candidates.enumerated() {
      var suggestion = HamsterSuggestion(
        text: candidate.text
      )
      suggestion.index = index
      suggestion.comment = candidate.comment
      suggestion.isAutocomplete = index == 0
      result.append(suggestion)
    }
    return result
  }

  // 拷贝 AppGroup 下词库文件
  func copyAppGroupUserDict(_ regex: [String] = ["^.*[.]userdb.*$"]) throws {
    // TODO: 将AppGroup下词库文件copy至应用目录
    // 只copy用户词库文件
    // let regex = ["^.*[.]userdb.*$", "^.*[.]txt$"]
    // let regex = ["^.*[.]userdb.*$"]
    try RimeContext.copyAppGroupSharedSupportDirectoryToSandbox(regex, filterMatchBreak: false)
    try RimeContext.copyAppGroupUserDirectoryToSandbox(regex, filterMatchBreak: false)
  }

  /// 重新部署
  func redeployment(_ appSettings: HamsterAppSettings) throws {
    // 如果开启 iCloud，则先将 iCloud 下文件增量复制到 Sandbox
    if appSettings.enableAppleCloud {
      do {
        let regexList = appSettings.copyToCloudFilterRegex.split(separator: ",").map { String($0) }
        try RimeContext.copyAppleCloudSharedSupportDirectoryToSandbox(regexList)
        try RimeContext.copyAppleCloudUserDataDirectoryToSandbox(regexList)
      } catch {
        Logger.shared.log.error("RIME redeploy error \(error.localizedDescription)")
        throw error
      }
    }

    // 判断是否需要覆盖键盘词库文件，如果为否，则先copy键盘词库文件至应用目录
    if !appSettings.enableOverrideKeyboardUserDictFileOnRimeDeploy {
      try copyAppGroupUserDict(["^.*[.]userdb.*$", "^.*[.]txt$"])
    }

    // 重新部署
    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
      userDataDir: RimeContext.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)
//    Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

    // 将 Sandbox 目录下方案复制到AppGroup下
    try RimeContext.syncSandboxSharedSupportDirectoryToApGroup(override: true)
    try RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)
  }

  /// RIME同步
  func syncRime() throws -> Bool {
    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
      userDataDir: RimeContext.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)
    let handled = Rime.shared.API().syncUserData()
    Rime.shared.shutdown()

    // 将 Sandbox 目录下方案复制到AppGroup下
    try RimeContext.syncSandboxSharedSupportDirectoryToApGroup(override: true)
    try RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)

    return handled
  }
}
