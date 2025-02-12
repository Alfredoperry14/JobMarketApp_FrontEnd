import SwiftUI

import SwiftUI

struct JobListView: View {
    let jobs: [Job]
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            List(jobs) { job in
                JobRowView(job: job) 
            }
            .navigationTitle("Job Listings")
            .alert(isPresented: Binding<Bool>(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Alert(title: Text("Error"), message: Text(errorMessage ?? "Unknown error"), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct JobRowView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(job.title)
                .font(.headline)
                .foregroundColor(.primary)

            Text(job.company)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Text(job.location)
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                Text(Job.convertSalaryToCurrency(job.salary))
                    .font(.footnote)
                    .bold()
            }

            if let url = URL(string: job.url.absoluteString) {
                Link("View Job", destination: url)
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 3))
        .padding(.horizontal)
    }
}
