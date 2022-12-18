//
//  ErrorView.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

struct ErrorView<Content: View>: View {
    let title: String
    var detail: String?
    var actions: (() -> Content)
    
    init(title: String, detail: String? = nil, @ViewBuilder actions: @escaping (() -> Content)) {
        self.title = title
        self.detail = detail
        self.actions = actions
    }
    
    var body: some View {
        VStack {
            Image(systemName: "xmark.circle")
                .foregroundColor(.red)
                .font(.title)
            
            Text(title)
            
            if let detail {
                Divider()
                Text(detail)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            actions()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .bodyStyle()
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(
            title: "Something went wrong.",
            detail: "this is the detail message"
        ) {
            VStack {
                Button("one") {
                    
                }
                Button("two") {
                    
                }
            }
        }
    }
}
