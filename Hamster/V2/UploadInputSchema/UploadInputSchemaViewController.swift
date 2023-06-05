//
//  UploadInputSchemaViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import ProgressHUD
import UIKit

class UploadInputSchemaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  let viewModel = UploadInputSchemaViewModel()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    return tableView
  }()
}

// MARK: override UIViewController

extension UploadInputSchemaViewController {
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "输入方案上传"
    // 保持屏幕长亮, 防止wifi无法使用
    UIApplication.shared.isIdleTimerDisabled = true

    let tableView = tableView
    tableView.dataSource = self
    tableView.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    viewModel.startMonitor()
    tableView.reloadData()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
    viewModel.stopFileServer()
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension UploadInputSchemaViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return localIPCell()
    }
    return buttonCell()
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "局域网访问地址(点击复制)"
    }
    return nil
  }

  static let remark = """
  1. 请保持手机与浏览器处于同一局域网；
  2. 请将个人方案上传至“Rime”文件夹内，可先删除原“Rime”文件夹内文件在上传;
  3. 上传完毕后，需要点击"重新部署"，否则方案不会生效；
  4. 浏览器内支持全选/拖拽等动作。
  """

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if section == 0 {
      return TableFooterView(footer: Self.remark)
    }

    return nil
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0, indexPath.row == 0 {
      if let ip = UIDevice.current.localIP() {
        UIPasteboard.general.string = "http://\(ip)"
        ProgressHUD.showSuccess("复制成功", delay: 1.5)
      }
    } else if indexPath.section == 1, indexPath.row == 0 {
      if viewModel.fileServerRunning {
        viewModel.stopFileServer()
      } else {
        viewModel.startFileServer()
      }
      tableView.reloadData()
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }

  func localIPCell() -> UITableViewCell {
    var valueCellConfig = UIListContentConfiguration.cell()
    if let ip = UIDevice.current.localIP() {
      valueCellConfig.text = "http://\(ip)"
    } else {
      valueCellConfig.text = "无法获取IP地址"
    }

    let cell = UITableViewCell()
    cell.contentConfiguration = valueCellConfig
    return cell
  }

  func buttonCell() -> UITableViewCell {
    let cell = UITableViewCell()

    let button = UIButton(type: .system)
    button.setTitle(viewModel.fileServerRunning ? "停止服务" : "启动服务", for: .normal)
//    button.addTarget(
//      self,
//      action: viewModel.fileServerRunning ? #selector(viewModel.stopFileServer) : #selector(viewModel.startFileServer),
//      for: .touchUpInside)

    button.translatesAutoresizingMaskIntoConstraints = false
    cell.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
      button.topAnchor.constraint(equalTo: cell.layoutMarginsGuide.topAnchor),
      button.bottomAnchor.constraint(equalTo: cell.layoutMarginsGuide.bottomAnchor),
    ])

    return cell
  }
}
