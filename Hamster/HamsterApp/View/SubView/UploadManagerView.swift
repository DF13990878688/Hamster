//
//  FileManagerView.swift
//  HamsterApp
//
//  Created by morse on 14/3/2023.
//

import iFilemanager
import Network
import SwiftUI
import UIKit

struct UploadManagerView: View {
  @State var fileServer: FileServer?
  @State var monitor: NWPathMonitor = .init(requiredInterfaceType: .wifi)
  @State var isBoot: Bool = false
  @State var localIP: String = ""
  @State var wifiEnable: Bool = true

  var remark: String { """
  1. 请在与您手机处与同一局域网内的PC浏览器上打开下面的IP地址.

     - http://\(self.localIP)

  2. 将您的个人输入方案上传至"Rime"文件夹内.
  3. 上传完毕请务必点击主菜单中的"重新部署", 否则方案不会生效.
  注意: SharedSupport目录是Rime的主目录, 无非必要不要修改.
  """
  }

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  var body: some View {
    GeometryReader { proxy in
      ZStack {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        VStack {
          HStack {
            Text("输入方案上传")
              .subViewTitleFont()

            Spacer()
          }
          .padding(.horizontal)

          VStack(alignment: .leading) {
            Text("注意: 此功能需要开启WiFi网络访问权限(只需Wifi即可, 无需移动网络权限).")
              .font(.system(size: 18, weight: .bold, design: .rounded))
            if self.wifiEnable {
              Text(self.remark)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 30)
            } else {
              Text("WiFi网络不可用, 请打开WiFi或开启Wifi网络访问权限")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.top, 30)
            }
          }
          .padding(.top, 30)
          .padding(.leading, 10)

          LongButton(buttonText: !self.isBoot ? "启动" : "停止") {
            self.isBoot.toggle()
            if self.isBoot {
              self.fileServer?.start()
            } else {
              self.fileServer?.shutdown()
            }
          }
          .frame(width: 200)
          .padding(.top, 30)
          .disabled(self.wifiEnable == false)

          Spacer()
        }
        .frame(width: proxy.size.width, height: proxy.size.height)
        .onAppear {
          Logger.shared.log.debug("FileManagerView appear")

          self.fileServer = .init(
            port: 80,
            publicDirectory: RimeContext.sandboxDirectory
          )

          // 保持屏幕长亮, 防止wifi无法使用
          UIApplication.shared.isIdleTimerDisabled = true

          if let localIP = UIDevice.current.localIP() {
            self.localIP = localIP
          }
          self.monitor = .init(requiredInterfaceType: .wifi)
          self.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
              self.wifiEnable = true
              return
            }
            self.wifiEnable = false
          }
          self.monitor.start(queue: .main)
        }
        .onDisappear {
          Logger.shared.log.debug("FileManagerView disppear")
          UIApplication.shared.isIdleTimerDisabled = false
          self.monitor.cancel()
          if self.isBoot {
            self.fileServer?.shutdown()
            self.isBoot = false
          }
          self.fileServer = nil
        }
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct FileManagerView_Previews: PreviewProvider {
  static var previews: some View {
    UploadManagerView()
  }
}
