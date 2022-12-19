//
//  CreditsView.swift
//  TriviaApp
//
//  Created by Tino on 17/12/2022.
//

import SwiftUI

struct CreditsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
            }
            
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Acknowledgements")
                        .modifier(TextStyle(font: .sfCompactRoundedMedium, fontSize: 35, color: .text))
                        .minimumScaleFactor(0.7)
                    
                    creditRow(url: URL(string: "https://opentdb.com")!)
                    creditRow(url: URL(string: "https://opengameart.org")!)
                    creditRow(url: URL(string: "https://pixabay.com")!)
                }
            }
        }
        .bodyStyle()
        .padding()
        .background(Color.background)
    }
}

private extension CreditsView {
    /// Shows a view with the host of the URL as the name.
    /// - Parameter url: The URL to list.
    /// - Returns: A link view.
    func creditRow(url: URL) -> some View {
        Link(linkName(url: url), destination: url)
            .foregroundColor(.blue)
    }
    
    /// The host name of a given URL.
    /// - Parameter url: The URL to get the data from.
    /// - Returns: The host name of the URL or "Error"
    func linkName(url: URL) -> String {
        url.host() ?? "Error"
    }
}

struct CreditsView_Previews: PreviewProvider {
    static var previews: some View {
        CreditsView()
    }
}
