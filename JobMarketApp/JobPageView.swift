//
//  JobPageView.swift
//  JobMarketApp
//
//  Created by Alfredo Perry on 2/12/25.
//

import SwiftUI
import WebKit

struct JobPageView: View {
    @Binding var job: Job
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(job.title)
                    .font(.title)
                    .fontWeight(.bold)

                Text(job.company)
                    .font(.headline)
                    .foregroundColor(.secondary)

                HStack {
                    Text("Location: \(job.location)")
                        .font(.subheadline)
                    Spacer()
                    Text("Salary: \(Job.convertSalaryToCurrency(job.salary))")
                        .font(.subheadline)
                        .bold()
                }

                Divider()

                // Inline web view displaying the job URL
                if let url = URL(string: job.url.absoluteString) {
                    WebView(url: url)
                        .frame(height: 500)
                }
                Spacer()
                
                Button(action: {
                    withAnimation{
                        job.appliedTo.toggle()
                        dismiss()
                    }
                }) {
                    Text("I Applied")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.green)
                        .cornerRadius(10) // Rounds corners
                        .padding() // Adds spacing around the button
                }
                
                
            }
            .padding()
        }
        .navigationTitle(job.title)
    }
}


struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

#Preview {
    JobPageView(job: .constant(Job(id: 1, title: "iOS Developer", level: "Senior", company: "Apple", location: "Cupertino, CA", postDate: "Today", salary: 120000, url: URL(string: "https://apple.com")!, appliedTo: false)))
}
