//
//  UIView+.swift
//  uipip
//
//  Created by Akihiro Urushihara on 2021/11/27.
//  @see https://iganin.hatenablog.com/entry/2020/05/11/070950
//

import UIKit
import WebKit

extension UIView {

  var uiImage: UIImage {
    let imageRenderer = UIGraphicsImageRenderer.init(size: bounds.size)
    return imageRenderer.image { context in
      layer.render(in: context.cgContext)
    }
  }
}

extension WKWebView {
    var image: UIImage? {
        get async {
            let snapshotWidth = UIScreen.main.bounds.width
            let config = WKSnapshotConfiguration()
            config.snapshotWidth = NSNumber(value: snapshotWidth)
            do {
                let image = try await Task { @MainActor in
                    try await takeSnapshot(configuration: config)
                }.value
                return image
            } catch {
                print(error)
                return nil
            }
        }
    }
}
