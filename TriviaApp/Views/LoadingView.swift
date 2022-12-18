//
//  LoadingView.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
            Text("Loading questions...")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .bodyStyle()
        .background(Color.background)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
