
import SwiftUI

struct JobHomeView: View {
    @State private var jobs: [Job] = []
    @State private var errorMessage: String?
    
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                JobListView(jobs: $jobs)

            }

            Tab("Stats", systemImage: "chart.line.text.clipboard") {
                JobStats()
            }

            Tab("Current Applications", systemImage: "tray.and.arrow.up.fill") {
                JobApplicationsView()
            }
        }
        .onAppear(perform: fetchJobs)
    }
    
    func fetchJobs() {
        JobAPIService.shared.fetchJobs { result in
            switch result {
            case .success(let jobs):
                self.jobs = jobs
                print("Jobs fetched: \(jobs.count)")
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    JobHomeView()
}
