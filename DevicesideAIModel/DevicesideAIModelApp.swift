//
//  DevicesideAIModelApp.swift
//  DevicesideAIModel
//
//  Created by Phineas Guo on 2026/7/16.
//

import SwiftUI
import Foundation
import CoreAI

@main
struct DevicesideAIModelApp: App {
    @State var ai=AIM()
    var body: some Scene {
        WindowGroup {
            if ai.finfishedLoading{
                ContentView()
            }else{
                LoadingView()
            }
                
        }
        .environment(ai)
    }
}
