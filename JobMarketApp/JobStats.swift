import SwiftUI
import Charts

// MARK: - JobStats View
struct JobStats: View {
    var jobs: [Job]
    
    // For level ordering, adjust to match sample job levels.
    // In our sample, we have "Entry Level", "Mid Level", and "Senior Level".
    private let levelOrder = ["Entry Level", "Mid Level", "Senior Level"]
    
    private func jobCountFilter(_ jobs: [Job]) -> Int {
        jobs.count
    }
    
    private func averageSalary(_ jobs: [Job]) -> String {
        let totalSalary = jobs.reduce(0) { $0 + ($1.salary ?? 0) }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalSalary / max(jobCountFilter(jobs), 1))) ?? ""
    }
    
    private func levelCount(_ jobs: [Job]) -> [(String, Int)] {
        let dictionary = jobs.reduce(into: [String: Int]()) { result, job in
            result[job.level ?? "Unknown", default: 0] += 1
        }
        
        return dictionary
            .map { ($0.key, $0.value) }
            .sorted { lhs, rhs in
                let lhsIndex = levelOrder.firstIndex(of: lhs.0) ?? levelOrder.count
                let rhsIndex = levelOrder.firstIndex(of: rhs.0) ?? levelOrder.count
                return lhsIndex < rhsIndex
            }
    }
    
    private func locationCount(_ jobs: [Job]) -> [(String, Int)] {
        let dictionary = jobs.reduce(into: [String: Int]()) { result, job in
            // Map "N/A" to "Local", otherwise use job.location.
            if job.location == "N/A" {
                result["Local", default: 0] += 1
            } else {
                result[job.location, default: 0] += 1
            }
        }
        
        // Sort alphabetically.
        return dictionary
            .sorted { $0.key < $1.key }
            .map { ($0.key, $0.value) }
    }
    
    private var jobsPostedThisWeek: ([Job], Int) {
        let filtered = JobFilterView.filteredJobs(from: jobs, title: "", company: "", location: "", level: "", salaryMin: 0, salaryMax: 500000, postDate: "7 Days")
        return (filtered, filtered.count)
    }
    
    var body: some View {
        VStack {
            TabView {
                VStack {
                    JobsPostedThisWeekTable(
                        thisWeeksJobs: jobsPostedThisWeek,
                        jobLocations: locationCount(jobsPostedThisWeek.0),
                        jobLevels: levelCount(jobsPostedThisWeek.0),
                        averageSalary: averageSalary(jobsPostedThisWeek.0)
                    )
                }
                .tag(0)
                
                VStack {
                    LevelBarChart(levelCount: levelCount(jobs))
                }
                .tag(1)
                
                VStack {
                    LocationBarChart(locationCount: locationCount(jobs))
                }
                .tag(2)
            }
            .padding(.bottom)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .tint(.blue)
            
            Text("Total Jobs: \(jobCountFilter(jobs))")
                .bold()
            Text("Average Salary: \(averageSalary(jobs))")
        }
        .padding()
    }
}

// MARK: - LocationBarChart (Bar Chart)
struct LocationBarChart: View {
    var locationCount: [(String, Int)]
    var body: some View {
        Chart {
            ForEach(locationCount, id: \.0) { location, count in
                BarMark(
                    x: .value("Job Location", location),
                    y: .value("Count", count)
                )
                .foregroundStyle(by: .value("Job Location", location))
            }
        }
        .padding()
    }
}

// MARK: - LevelBarChart (Bar Chart)
struct LevelBarChart: View {
    var levelCount: [(String, Int)]
    var body: some View {
        Chart {
            ForEach(levelCount, id: \.0) { level, count in
                BarMark(
                    x: .value("Job Level", level),
                    y: .value("Count", count)
                )
                .foregroundStyle(by: .value("Job Level", level))
            }
        }
        .padding()
    }
}

// MARK: - JobsPostedThisWeekTable
struct JobsPostedThisWeekTable: View {
    var thisWeeksJobs: ([Job], Int)
    var jobLocations: [(String, Int)]
    var jobLevels: [(String, Int)]
    var averageSalary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Total jobs posted in the last 7 days
            Text("\(thisWeeksJobs.1) Jobs Posted in the Last 7 Days")
                .font(.headline)
            
            Divider()
            
            // Levels Section
            Text("Levels")
                .font(.subheadline)
                .bold()
            ForEach(jobLevels, id: \.0) { level, count in
                HStack {
                    Text("\(level):")
                    Spacer()
                    Text("\(count)")
                }
            }
            
            Divider()
            
            // Locations Section
            Text("Locations")
                .font(.subheadline)
                .bold()
            ForEach(jobLocations, id: \.0) { location, count in
                HStack {
                    Text("\(location):")
                    Spacer()
                    Text("\(count)")
                }
            }
            
            Divider()
            
            // Salary Section
            HStack {
                Text("Salary:")
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text(averageSalary)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

// MARK: - JobFilterView Stub
// This stub simulates filtering jobs for the "last 7 days".
// Adjust the logic as needed.
struct JobFilterView2 {
    static func filteredJobs(from jobs: [Job], title: String, company: String, location: String, level: String, salaryMin: Int, salaryMax: Int, postDate: String) -> [Job] {
        // For preview purposes, assume all jobs are in the last 7 days.
        return jobs
    }
}

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
