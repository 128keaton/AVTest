//
//  GeneratedJSONViewController.swift
//  AVTest
//
//  Created by Keaton Burleson on 6/3/19.
//  Copyright © 2019 Keaton Burleson. All rights reserved.
//

import Foundation
import Cocoa
import WebKit

class GeneratedJSONViewController: NSViewController {
    @IBOutlet weak private var outputWebView: WebView!

    private var outputString: String = ""

    override func viewDidAppear() {
        super.viewDidAppear()

        self.outputWebView.enclosingScrollView?.hasHorizontalScroller = true
        self.addParsingJavascript()
        self.addStylesheet()
        self.loadData()
    }

    private func addParsingJavascript() {
        if let javascriptFilePath = Bundle.main.path(forResource: "json", ofType: "js") {
            do {
                let javascriptContents = try String(contentsOfFile: javascriptFilePath)
                self.outputWebView.stringByEvaluatingJavaScript(from: javascriptContents)
            } catch {
                print("Unable to parse 'json.js' in bundle")
            }
        } else {
            print("Unable to find 'json.js' in bundle")
        }
    }

    private func addStylesheet() {
        if let stylesheetFilePath = Bundle.main.path(forResource: "highlight", ofType: "css") {
            do {
                let stylesheetContents = try String(contentsOfFile: stylesheetFilePath).condenseWhitespace()
                self.outputWebView.stringByEvaluatingJavaScript(from: "loadStyle('\(stylesheetContents)');")
            } catch {
                print("Unable to parse 'highlight.css' in bundle")
            }
        } else {
            print("Unable to find 'highlight.css' in bundle")
        }
    }

    private func loadData() {
        let condensedData = SystemProfiler.condense()

        do {
            let rawJSON = try JSONEncoder().encode(condensedData)

            if let rawJSONString = String(data: rawJSON, encoding: .utf8) {
                self.outputString = rawJSONString
                self.loadWebView(content: rawJSONString)
            }
        } catch {
            print("Unable to show JSON: \(error)")
        }
    }

    private func loadWebView(content: String) {
        let script = "convertAndDisplay(\(content));"
        self.outputWebView.stringByEvaluatingJavaScript(from: script)
    }

    @IBAction private func copyToClipboard(_ sender: NSButton) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputString, forType: .string)
    }

    @IBAction private func reloadData(_ sender: NSButton) {
        self.loadData()
    }
}
