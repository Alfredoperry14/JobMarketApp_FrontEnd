//
//  JobFilter.swift
//  JobMarketApp
//
//  Created by Alfredo Perry on 2/12/25.
//

import SwiftUI

struct JobFilterView: View {
    var jobs: [Job]
    @State private var filteredJobs: [Job] = []
    
    @State private var title: String = ""
    @State private var company: String = ""
    @State private var location: String = ""
    @State private var level: String = ""
    @State private var salaryMin: Double = 0
    @State private var salaryMax: Double = 200000
    @State private var postDate: String = ""
    @Environment(\.dismiss) var dismiss
    
    let levels = ["Internship", "Junior", "Mid", "Senior", "Expert"]
    let postDateOptions = ["1 Day", "7 Days", "14 Days", "30 Days"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Job Title").font(.headline)) {
                    TextField("Enter job title", text: $title)
                }
                
                Section(header: Text("Company").font(.headline)) {
                    TextField("Enter company name", text: $company)
                }
                
                Section(header: Text("Location").font(.headline)) {
                    TextField("Enter location", text: $location)
                }
                
                Section(header: Text("Job Level").font(.headline)) {
                    Picker("Select level", selection: $level) {
                        Text("Any").tag("")
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Salary Range").font(.headline)) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Minimum Salary: \(Int(salaryMin))")
                            Slider(value: $salaryMin, in: 0...salaryMax, step: 1000)
                        }
                        HStack {
                            Text("Maximum Salary: \(Int(salaryMax))")
                            Slider(value: $salaryMax, in: salaryMin...500000, step: 1000)
                        }
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("Posted Within").font(.headline)) {
                    Picker("Post Date", selection: $postDate) {
                        Text("Any").tag("")
                        ForEach(postDateOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    HStack(spacing: 16) {
                        Button(action: {
                            resetFilters()
                        }) {
                            Text("Reset Filters")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Button(action: {
                            filteredJobs = applyFilters()
                            dismiss()
                        }) {
                            Text("Apply Filters")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
    }
    
    private func applyFilters() -> [Job] {
        return jobs.filter { job in
            (title.isEmpty || job.title.lowercased().contains(title.lowercased())) &&
            (company.isEmpty || job.company.lowercased().contains(company.lowercased())) &&
            (location.isEmpty || job.location.lowercased().contains(location.lowercased())) &&
            (level.isEmpty || job.level == level) &&
            (job.salary ?? 0 >= Int(salaryMin) && job.salary ?? 0 <= Int(salaryMax)) &&
            (postDate.isEmpty || JobFilterView.filterByPostDate(job.postDate, postDate))
        }
    }
    
    static func filterByPostDate(_ jobPostDate: String, _ selectedTimeFrame: String) -> Bool {
        // Convert the job's post date to a Date.
        guard let jobDate = getJobPostDate(jobPostDate) else { return false }
        
        // Extract the number of days from the selected time frame.
        let daysAgo = Int(selectedTimeFrame.components(separatedBy: " ").first ?? "0") ?? 0
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate the threshold date.
        guard let thresholdDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
            return false
        }
        
        // Return true if the job was posted on or after the threshold date.
        return jobDate >= thresholdDate
    }
    
    static private func getJobPostDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    private func resetFilters() {
        title = ""
        company = ""
        location = ""
        level = ""
        salaryMin = 0
        salaryMax = 200000
        postDate = ""
        filteredJobs = jobs
    }
    
    static func filteredJobs(from jobs: [Job],
                             title: String = "",
                             company: String = "",
                             location: String = "",
                             level: String = "",
                             salaryMin: Int = 0,
                             salaryMax: Int = 200000,
                             postDate: String = "") -> [Job] {
        return jobs.filter { job in
            (title.isEmpty || job.title.lowercased().contains(title.lowercased())) &&
            (company.isEmpty || job.company.lowercased().contains(company.lowercased())) &&
            (location.isEmpty || job.location.lowercased().contains(location.lowercased())) &&
            (level.isEmpty || job.level == level) &&
            (job.salary ?? 0 >= salaryMin && job.salary ?? 0 <= salaryMax) &&
            (postDate.isEmpty || filterByPostDate(job.postDate, postDate))
        }
    }
}

#Preview {
    JobFilterView(jobs: [
        Job(id: 1, title: "Software Engineer", level: "Mid", company: "TechCorp", location: "New York", postDate: "02-10", salary: 120000, url: URL(string: "https://example.com")!),
        Job(id: 2, title: "Data Scientist", level: "Senior", company: "DataCorp", location: "San Francisco", postDate: "02-08", salary: 150000, url: URL(string: "https://example.com")!)
    ])
}
