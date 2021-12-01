//
//  VideoProvider.swift
//  uipip
//
//  Created by Akihiro Urushihara on 2021/11/27.
//

import UIKit
import AVKit
import WebKit
import AVFoundation

class VideoProvider: NSObject {

    private var timer: Timer?
    var bufferDisplayLayer = AVSampleBufferDisplayLayer()

    private let webView: WKWebView = {
        let width = UIScreen.main.bounds.width * 0.4
        let height = UIScreen.main.bounds.height * 0.4
        let view = WKWebView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        let initialURL = URLRequest(url: URL(string: "https://qiita.com/fummicc1_dev/items/bf57dbd203d78933bf0f")!)
        view.load(initialURL)
        return view
    }()

    private var previousURL: URL?

    // 現在時刻を表示
    func nextBuffer() async -> UIImage? {
        let contentOffsetY = await webView.scrollView.contentOffset.y
        let contentSizeY = await webView.scrollView.contentSize.height
        let isOver = contentOffsetY == contentSizeY
        if isOver {
            let url = URL(string: "https://qiita.com/fummicc1_dev/items/bf57dbd203d78933bf0f")!
            let request = URLRequest(url: url)
            await webView.load(request)
        }
        await Task { @MainActor in
            webView.scrollView.contentOffset.y += 10
        }.value
        return await webView.image
    }

    func startIfNeeded() {
        if timer?.isValid ?? false {
            return
        }
        let timerBlock: ((Timer) -> Void) = { [weak self] timer in
            guard let self = self else {
                return
            }
            Task {
                guard let buffer = await self.nextBuffer()?.cmSampleBuffer else { return }
                self.bufferDisplayLayer.enqueue(buffer)
            }
        }

        let timer = Timer(timeInterval: 0.3, repeats: true, block: timerBlock)
        RunLoop.main.add(timer, forMode: .default)
        self.timer = timer
    }

    func stop() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
        }
    }

    func handlePipAction() {
        let isValid = timer?.isValid ?? false
        if isValid {
            stop()
        } else {
            startIfNeeded()
        }
    }

    func isRunning() -> Bool {
        return timer != nil
    }
}
