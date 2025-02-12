
import SwiftUI

struct JobHomeView: View {
    @State private var jobs: [Job] = []
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        TabView {
            Tab("Home", systemImage: "house") {
                JobListView()

            }

            Tab("Stats", systemImage: "chart.line.text.clipboard") {
                JobStats()
            }

            Tab("Current Applications", systemImage: "tray.and.arrow.up.fill") {
                JobApplicationsView()
            }
        }
    }
    func fetchJobs() {
        JobAPIService.shared.fetchJobs { result in
            switch result {
            case .success(let jobs):
                self.jobs = jobs
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    JobHomeView()
}
