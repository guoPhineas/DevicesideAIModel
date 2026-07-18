//
//  QwenAI.swift
//  DevicesideAIModel
//
//  Created by Phineas Guo on 2026/7/16.
//

import FoundationModels
import Playgrounds
import Foundation
import CoreAILanguageModels
import CoreAI

@Observable
class AIM{
    @ObservationIgnored var model: CoreAILanguageModel?
    @ObservationIgnored var session: LanguageModelSession?
    var finfishedLoading=false
    var isProcessing=false
    init() {
        Task {
            
            let folderPath = Bundle.main.path(forResource: "QwenAI", ofType: nil)!
            let folderURL = URL(fileURLWithPath: folderPath)
                
            do{
                model = try await CoreAILanguageModel(resourcesAt: folderURL)
                try await model?.load()
            }catch{
                print(error)
            }
            
            guard let model=model else {return}
            session = LanguageModelSession(model: model, instructions: "You can use Markdown")
            finfishedLoading=true
        }
    }
    
    deinit {
        model?.unload()
    }
    
    func streamRequest(msg: String) -> LanguageModelSession.ResponseStream<String>? {
        
        return session?.streamResponse(to: msg)
    }
    
    func request(msg: String) async -> String? {
        do{
            return try await session?.respond(to: msg).content
        }catch{
            print(error.localizedDescription)
            return nil
        }
    }
}

#Playground {
    let modelURL = Bundle.main.url(forResource: "qwen3_5_2b_decode_int8hu_block32_sym", withExtension: "aimodel")!
}
