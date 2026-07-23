//
//  ContentView.swift
//  DevicesideAIModel
//
//  Created by Phineas Guo on 2026/7/16.
//

import SwiftUI
import AIChatUI
import FoundationModels

struct ContentView: View {
    @Environment(AIM.self) var ai
    var body: some View {
        AIChatView(configuration: AIChatConfiguration(
            aiName: "Qwen 3-4B",
            submitMessage: { input, onUpdate in
                if ai.isProcessing == true{
                    onUpdate(#"""
> [!IMPORTANT]
>
> Is processing, please wait until the last request is finished.
"""#)
                    return
                }
                ai.isProcessing=true
                _ = Task{
                    guard let response = ai.streamRequest(msg: input.text ?? "") else {
                        onUpdate(#"""
> [!IMPORTANT]
>
> Cannot load model.
"""#)
                        return
                    }
                    for try await article in response {
                        onUpdate(article.content)
                    }
                    let all = try await response.collect()
                    onUpdate(all.content)
                    ai.isProcessing=false
                }
            }
        ))
    }
}

#Preview {
    ContentView()
}
