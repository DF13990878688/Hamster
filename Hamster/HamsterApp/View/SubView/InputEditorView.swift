//
//  InputkeyFuctionView.swift
//  HamsterApp
//
//  Created by morse on 2023/3/20.
//

import SwiftUI

struct InputEditorView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      ScrollView {
        VStack {
          HStack {
            Text("输入功能调整")
              .subViewTitleFont()
            Spacer()
          }
          .padding(.horizontal)

          HStack {
            Text("可根据个人爱好修改两个按键对应的键值.")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
            Spacer()
          }
          .padding(.top)
          .padding(.horizontal)

          BothSidesOfTheSpaceView()

          ShiftExtensionsView()

          CandidateBarShowModeSettingView()

          RimeUseSquirrelSettingsView()

          Spacer()
        }
        .padding(.horizontal)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

/// 空格两侧区域功能设置
struct BothSidesOfTheSpaceView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    VStack {
      HStack {
        Toggle(isOn: $appSettings.showSemicolonButton) {
          Text("启用分号键")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
    }
    .functionCell()

    VStack {
      HStack {
        Toggle(isOn: $appSettings.enableSymbolKeyboard) {
          Text("启用符号键盘")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      HStack {
        Text("启用后，常规符号键盘将被替换为符号键盘。常规符号键盘布局类似系统自带键盘符号布局。")
          .font(.system(size: 12, weight: .light, design: .rounded))
        Spacer()
      }
    }
    .functionCell()

    VStack {
      HStack {
        Text("简繁切换：")
          .font(.system(size: 16, weight: .bold, design: .rounded))

        TextField("", text: $appSettings.rimeSimplifiedAndTraditionalSwitcherKey)
          .textFieldStyle(.roundedBorder)
      }
      HStack {
        Text("输入方案中 switches 对应简繁转换的名称，用于中文简体与繁体之间切换。")
          .font(.system(size: 12, weight: .light, design: .rounded))

        Spacer()
      }
    }
    .functionCell()

    VStack {
      HStack {
        Toggle(isOn: $appSettings.showSpaceLeftButton) {
          Text("空格左边按键")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      if appSettings.showSpaceLeftButton {
        HStack {
          TextField("空格左边按键", text: $appSettings.spaceLeftButtonValue)
            .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
            .padding(.vertical, 5)
            .foregroundColor(.secondary)
          Spacer()
        }
      }
    }
    .functionCell()

    VStack {
      HStack {
        Toggle(isOn: $appSettings.showSpaceRightButton) {
          Text("空格右边按键")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      if appSettings.showSpaceRightButton {
        HStack {
          TextField("空格左边按键", text: $appSettings.spaceRightButtonValue)
            .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
            .padding(.vertical, 5)
            .foregroundColor(.secondary)
          Spacer()
        }
      }
    }
    .functionCell()

    VStack {
      HStack {
        Toggle(isOn: $appSettings.showSpaceRightSwitchLanguageButton) {
          Text("中英切换键")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      if appSettings.showSpaceRightSwitchLanguageButton {
        HStack {
          Toggle(isOn: $appSettings.switchLanguageButtonInSpaceLeft) {
            Text("空格左侧:(默认位于右侧)")
              .font(.system(size: 16, weight: .bold, design: .rounded))
          }
        }
      }
    }
    .functionCell()
  }
}

/// Shift扩展功能
struct ShiftExtensionsView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  var body: some View {
    VStack {
      HStack {
        Toggle(isOn: $appSettings.enableKeyboardAutomaticallyLowercase) {
          Text("Shift自动转小写")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      HStack {
        Text("默认键盘大小写会保持自身状态. 开启此选项后, 当在大写状态在下输入一个字母后会自动转为小写状态. 注意: 双击Shift会保持锁定")
          .font(.system(size: 14))
      }
    }
    .functionCell()
  }
}

/// 候选栏显示模式设置
struct CandidateBarShowModeSettingView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    VStack {
      HStack {
        Toggle(isOn: $appSettings.enableInputEmbeddedMode) {
          Text("候选栏内嵌模式")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
    }
    .functionCell()

    VStack {
      HStack {
        Toggle(isOn: $appSettings.enableCandidateBar) {
          Text("候选栏显示")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
    }
    .functionCell()

    VStack {
      HStack {
        Stepper(value: $appSettings.rimeMaxCandidateSize, in: 50 ... 500, step: 50) {
          Text("候选文字最大数量: \(appSettings.rimeMaxCandidateSize)")
        }
        Spacer()
      }
    }
    .functionCell()

    VStack {
      HStack {
        Stepper(value: $appSettings.rimeCandidateTitleFontSize, in: 10 ... 30, step: 1) {
          Text("候选文字体大小: \(appSettings.rimeCandidateTitleFontSize)")
        }
        Spacer()
      }
    }
    .functionCell()

    VStack {
      HStack {
        Stepper(value: $appSettings.candidateBarHeight, in: 30 ... 60, step: 1) {
          Text("候选栏高度: \(Int(appSettings.candidateBarHeight))")
        }
        Spacer()
      }
    }
    .functionCell()

    VStack {
      HStack {
        Toggle(isOn: $appSettings.enableShowCandidateIndex) {
          Text("显示候选项索引")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
    }
    .functionCell()

    VStack {
      HStack {
        Stepper(value: $appSettings.xSwipeSensitivity, in: 1 ... 50, step: 1) {
          Text("横向滑动灵敏度（值越小越灵敏）: \(appSettings.xSwipeSensitivity)")
        }
        Spacer()
      }
    }
    .functionCell()

    VStack {
      HStack {
        TextField("点我呼出键盘（重新呼出键盘才能生效）", text: .constant(""))
      }
    }
    .functionCell()
  }
}

/// 使用鼠须管配置的设置
struct RimeUseSquirrelSettingsView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  var body: some View {
    VStack {
      HStack {
        Toggle(isOn: $appSettings.rimeUseSquirrelSettings) {
          Text("使用鼠须管配置")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }
      HStack {
        Text("重新部署后生效. 默认使用鼠须管(squirrel)配置. 关闭此选项后, Rime引擎会使用仓(hamster)配置. 您必须保证hamster.yaml存在")
          .font(.system(size: 14))
      }
    }
    .functionCell()
  }
}

struct InputEditorView_Previews: PreviewProvider {
  static var previews: some View {
    InputEditorView()
      .environmentObject(HamsterAppSettings.shared)
  }
}
