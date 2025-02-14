import SwiftUI
import Charts

// MARK: - JobStats View
struct JobStats: View {
    var jobs: [Job]
    
    private var jobCount: Int {
        jobs.count
    }
    
    private var averageSalary: String {
        let totalSalary = jobs.reduce(0) { $0 + ($1.salary ?? 0) }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalSalary / max(jobCount, 1))) ?? ""
    }
    
    private var levelCount: [String: Int] {
        jobs.reduce(into: [:]) { result, job in
            result[job.level ?? "N/A", default: 0] += 1
        }
    }
        
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text("Job Statistics")
                .font(.headline)
            
            TabView {
                
                
            }
            
            
            Text("Total Jobs: \(jobCount)")
            Text("Average Salary: \(averageSalary)")
            
            // Job Level Pie Chart
            //JobLevelPieChart(dataDictionary: levelCount)
        }
        .padding()
    }
}
/*
struct LevelBarChart: View {
    var body: some View {
        
    }
}
*/

// MARK: - Preview
#Preview {
    JobStats(jobs: [
        Job(id: 1, title: "Software Engineer", level: "Mid Level", company: "Apple", location: "California", postDate: "2024-02-10", salary: 120000, url: URL(string: "https://apple.com")!),
        Job(id: 2, title: "Data Scientist", level: "Senior Level", company: "Google", location: "California", postDate: "2024-02-09", salary: 150000, url: URL(string: "https://google.com")!),
        Job(id: 3, title: "Backend Developer", level: "Entry Level", company: "Amazon", location: "Texas", postDate: "2024-02-08", salary: 90000, url: URL(string: "https://amazon.com")!),
        Job(id: 4, title: "Frontend Developer", level: "Mid Level", company: "Meta", location: "New York", postDate: "2024-02-07", salary: 110000, url: URL(string: "https://meta.com")!),
        Job(id: 5, title: "Project Manager", level: "Senior Level", company: "Tesla", location: "California", postDate: "2024-02-06", salary: 140000, url: URL(string: "https://tesla.com")!)
    ])
}
