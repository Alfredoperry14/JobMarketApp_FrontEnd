
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
                JobStats(jobs: jobs)
            }
            
            Tab("Current Applications", systemImage: "tray.and.arrow.up.fill") {
                JobApplicationsView()
            }
        }
        .onAppear(perform: fetchJobs)
    }
    
    func fetchJobs() {
        print("Fetching jobs...")
        JobAPIService.shared.fetchJobs { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedJobs):
                    print("Jobs fetched: \(fetchedJobs.count)")
                    
                    if let firstJob = fetchedJobs.first {
                        print("First Job: \(firstJob.title), \(firstJob.company), \(firstJob.location)")
                    } else {
                        print("⚠️ API returned an empty array!")
                    }
                    withAnimation{
                        self.jobs = fetchedJobs
                    }
                case .failure(let error):
                    print("❌ Error fetching jobs: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    JobHomeView()
}
