//
//  LoadingView.swift
//  DevicesideAIModel
//
//  Created by Phineas Guo on 2026/7/18.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack{
            ProgressView()
            Text("Model is loading. Maybe 3-5 min for the frist time.")
        }
    }
}

#Preview {
    LoadingView()
}
