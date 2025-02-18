import SwiftUI
import Charts

// MARK: - JobStats View
struct JobStats: View {
    var jobs: [Job]
    
    init(jobs: [Job]) {
        self.jobs = jobs
        // Set the current (selected) dot color.
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.blue
        // Set the color for the unselected dots.
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
    }
    
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
        let debug = dictionary.map { ($0.key, $0.value) }
        print(debug)
        return dictionary.map { ($0.key, $0.value) }
        
    }
    private let allLevelOrder = ["Internship", "Entry level","Junior", "Mid level", "Senior level", "Expert/Leader", "N/A"]
    
    var computedLevelOrder: [String] {
        // Filter the desired order to include only those levels that are present in your data with a count > 0.
        allLevelOrder.filter { level in
            levelCount(jobs).contains { $0.0 == level && $0.1 > 0 }
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
        return dictionary.map { ($0.key, $0.value) }
    }
    
    private var jobsPostedThisWeek: ([Job], Int) {
        let filtered = JobFilterView.filteredJobs(from: jobs, title: "", company: "", location: "", level: "", salaryMin: 0, salaryMax: 500000, postDate: "7 Days")
        return (filtered, filtered.count)
    }
    
    var body: some View {
        VStack {
            Text("Job Statistics")
                .font(.title)
                .bold()
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
                    LevelBarChart(levelCount: levelCount(jobs),levelOrder: computedLevelOrder)
                        .padding(.bottom, 20)
                }
                .tag(1)
                
                VStack {
                    LocationBarChart(locationCount: locationCount(jobs))
                        .padding(.bottom, 20)
                }
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            //.tint(.blue)
            .padding(.bottom)

            Text("Total Jobs: \(jobCountFilter(jobs))")
                .bold()
            Text("Average Salary: \(averageSalary(jobs))")
        }
        .padding()
    }
}

// MARK: - LocationBarChart (Bar Chart)
struct LocationBarChart: View {
    private let locationOrder = ["Local", "Hybrid", "Remote"]
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
        .chartXScale(domain: locationOrder)
        .padding()
        
        // Sort the levelCount array based on the levelOrder
        let sortedLocationCount = locationCount.sorted { lhs, rhs in
            guard let lhsIndex = locationOrder.firstIndex(of: lhs.0),
                  let rhsIndex = locationOrder.firstIndex(of: rhs.0) else { return false }
            return lhsIndex < rhsIndex
        }
        
        VStack(alignment: .leading) {
            ForEach(sortedLocationCount, id: \.0) { location, count in
                HStack {
                    Text("\(location):")
                        .bold()
                    Spacer()
                    Text("\(count)")
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 20)
    }
}

// MARK: - LevelBarChart (Bar Chart)
struct LevelBarChart: View {
    var levelCount: [(String, Int)]
    var levelOrder: [String]

    var body: some View {
        VStack {
            Chart {
                ForEach(levelCount, id: \.0) { level, count in
                    BarMark(
                        x: .value("Job Level", level),
                        y: .value("Count", count)
                    )
                    .foregroundStyle(by: .value("Job Level", level))
                }
            }
            .chartXScale(domain: levelOrder)
            .padding()
            
            // Sort the levelCount array based on the levelOrder
            let sortedLevelCount = levelCount.sorted { lhs, rhs in
                guard let lhsIndex = levelOrder.firstIndex(of: lhs.0),
                      let rhsIndex = levelOrder.firstIndex(of: rhs.0) else { return false }
                return lhsIndex < rhsIndex
            }
            
            VStack(alignment: .leading) {
                ForEach(sortedLevelCount, id: \.0) { level, count in
                    HStack {
                        Text("\(level):")
                            .bold()
                        Spacer()
                        Text("\(count)")
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
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
