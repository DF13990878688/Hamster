//
//  RIMEView.swift
//  Hamster
//
//  Created by morse on 8/5/2023.
//

import Combine
import Foundation
import ProgressHUD
import SwiftUI

let _rimeSyncDemo = """
installation_id: "hamster"
# App内同步位置无需设置，保存在 Rime/sync 下
# iCloud前缀路径固定为：/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents
# 后面的地址可自定义，如
sync_dir: "/private/var/mobile/Library/Mobile Documents/iCloud~dev~fuxiao~app~hamsterapp/Documents/sync"
"""

let _rimeSyncRemark = """
注意：
1. RIME同步配置需要手工添加参数至Rime目录下的`installation.yaml`文件中(如果没有，需要则自行创建)；
2. 示例中的`installation_id`与`sync_dir`可自行修改，注意：如果路径错误会导致应用Crash；
3. 同步配置示例：(点击可复制)
```
\(_rimeSyncDemo)
```
"""

struct RIMEView: View {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self._appSettings = ObservedObject(wrappedValue: appSettings)
    self._rimeContext = ObservedObject(wrappedValue: rimeContext)
    self.rimeViewModel = RIMEViewModel(rimeContext: rimeContext, appSettings: appSettings)
  }

  @ObservedObject var appSettings: HamsterAppSettings
  @ObservedObject var rimeContext: RimeContext
  let rimeViewModel: RIMEViewModel

  @State var cancellables = Set<AnyCancellable>()
  @State var rimeError: Error?
  @State var showDeploymentAlert: Bool = false
  @State var showSyncAlert: Bool = false
  @State var showResetAlert = false
  @State var showAlert = false
  @State var alertTitle = ""
  @State var alertMessage = ""

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        VStack {
          VStack {
            HStack {
              Text("RIME设置")
                .subViewTitleFont()
              Spacer()
            }
            .padding(.horizontal)
          }
          .alert(isPresented: $showAlert) { Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .cancel(Text("关闭"))) }

          ScrollView {
            Group {
              VStack {
                HStack {
                  Toggle(isOn: $appSettings.enableOverrideKeyboardUserDictFileOnRimeDeploy) {
                    Text("部署时覆盖键盘词库文件")
                      .font(.system(size: 16, weight: .bold, design: .rounded))
                  }
                }
                HStack {
                  Text("如果您未使用自造词功能，保持默认开启状态。")
                    .font(.system(size: 12, weight: .light, design: .rounded))
                  Spacer()
                }
              }
              .functionCell()

              LongButton(
                buttonText: "重新部署"
              ) {
                DispatchQueue.global().async {
                  let handled = rimeViewModel.deployment()
                  DispatchQueue.main.async {
                    if !handled {
                      showAlert = true
                      alertTitle = "重新部署"
                      alertMessage = "重新部署失败"
                    }
                  }
                }
              }
              .padding(.top, 5)

              LongButton(
                buttonText: "RIME同步"
              ) {
                DispatchQueue.global().async {
                  rimeViewModel.rimeSync()
                }
              }

              LongButton(
                buttonText: "RIME重置"
              ) {
                showResetAlert = true
              }
              .alert(isPresented: $showResetAlert) { resetAlert }
            }
            .padding(.horizontal)

            VStack {
              HStack {
                Text(_rimeSyncRemark)
                  .font(.system(size: 14))
              }
            }
            .contentShape(Rectangle())
            .onTapGesture {
              UIPasteboard.general.string = _rimeSyncDemo
              ProgressHUD.showSuccess("复制成功", interaction: false, delay: 1.5)
            }
            .functionCell()
            .listRowBackground(Color.HamsterBackgroundColor)
            .padding(.horizontal)
          }
        }
      }
    }
  }

  var resetAlert: Alert {
    Alert(
      title: Text("确定重置？"),
      message: Text("重置会恢复至安装的初始状态，并关闭iCloud功能（不会删除iCloud内保存内容）"),
      primaryButton: .destructive(Text("确定")) {
        DispatchQueue.global().async {
          let handled = rimeViewModel.rimeRest()
          DispatchQueue.main.async {
            if !handled {
              showAlert = true
              alertTitle = "重置"
              alertMessage = "重置失败"
            }
          }
        }
      },
      secondaryButton: .cancel(Text("取消"))
    )
  }
}

struct RIMEView_Previews: PreviewProvider {
  static var previews: some View {
    RIMEView(appSettings: HamsterAppSettings.shared, rimeContext: RimeContext.shared)
  }
}
