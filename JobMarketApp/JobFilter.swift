//
//  JobFilter.swift
//  JobMarketApp
//
//  Created by Alfredo Perry on 2/12/25.
//

import SwiftUI

struct JobFilterView: View {
    // The complete list of jobs for reference (if needed for filtering)
    var jobs: [Job]
    
    // Bindings for filter criteria from the parent view.
    @Binding var filterTitle: String
    @Binding var filterCompany: String
    @Binding var filterLocation: String
    @Binding var filterLevel: String
    @Binding var filterSalaryMin: Int
    @Binding var filterSalaryMax: Int
    @Binding var filterPostDate: String
    
    // Environment dismissal action for the modal.
    @Environment(\.dismiss) var dismiss
    
    // Local constants for Picker options.
    let levels = ["Internship", "Junior", "Mid", "Senior", "Expert"]
    let locations = ["Local", "Hybrid", "Remote"]
    let postDateOptions = ["1 Day", "7 Days", "14 Days", "30 Days"]
    
    var body: some View {
        NavigationView {
            Form {
                // Job Title Section
                Section(header: Text("Job Title").font(.headline)) {
                    TextField("Enter job title", text: $filterTitle)
                }
                
                // Company Section
                Section(header: Text("Company").font(.headline)) {
                    TextField("Enter company name", text: $filterCompany)
                }
                
                // Job Level Section
                Section(header: Text("Location").font(.headline)) {
                    Picker("Select location", selection: $filterLocation) {
                        Text("Any").tag("")
                        ForEach(locations, id: \.self) { location in
                            Text(location).tag(location)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Job Level Section
                Section(header: Text("Job Level").font(.headline)) {
                    Picker("Select level", selection: $filterLevel) {
                        Text("Any").tag("")
                        ForEach(levels, id: \.self) { level in
                            Text(level).tag(level)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Salary Range Section
                Section(header: Text("Salary Range").font(.headline)) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Minimum Salary: \(filterSalaryMin)")
                            Slider(
                                value: Binding(
                                    get: { Double(filterSalaryMin) },
                                    set: { filterSalaryMin = Int($0) }
                                ),
                                in: 0...Double(filterSalaryMax),
                                step: 5000
                            )
                        }
                        HStack {
                            Text("Maximum Salary: \(filterSalaryMax)")
                            Slider(
                                value: Binding(
                                    get: { Double(filterSalaryMax) },
                                    set: { filterSalaryMax = Int($0) }
                                ),
                                in: Double(filterSalaryMin)...500000,
                                step: 5000
                            )
                        }
                    }
                    .padding(.vertical)
                }
                
                // Posted Within Section
                Section(header: Text("Posted Within").font(.headline)) {
                    Picker("Post Date", selection: $filterPostDate) {
                        Text("Any").tag("")
                        ForEach(postDateOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // Action Buttons Section
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
                            // In this example, simply dismiss.
                            // The parent view is responsible for using the bound filter values.
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
            .navigationTitle("Job Filters")
        }
    }
    
    /// Resets all filter criteria to default values.
    private func resetFilters() {
        filterTitle = ""
        filterCompany = ""
        filterLocation = ""
        filterLevel = ""
        filterSalaryMin = 0
        filterSalaryMax = 50000
        filterPostDate = ""
    }
    
    // MARK: - Static Helper Functions
    
    static func filterByPostDate(_ jobPostDate: String, _ selectedTimeFrame: String) -> Bool {
        // Convert the job's post date to a Date.
        guard let jobDate = getJobPostDate(jobPostDate) else { return false }
        
        // Extract the number of days from the selected time frame (e.g., "7 Days" → 7).
        let daysAgo = Int(selectedTimeFrame.components(separatedBy: " ").first ?? "0") ?? 0
        let calendar = Calendar.current
        
        //Allows for jobs to be searched for at the start of day (1 Day Filter)
        let todayStart = calendar.startOfDay(for: Date())

        // Calculate the threshold date.
        guard let thresholdDate = calendar.date(byAdding: .day, value: -daysAgo, to: todayStart) else {
            return false
        }
        
        // Return true if the job was posted on or after the threshold date.
        return jobDate >= thresholdDate
    }
    
    /// Converts a date string (formatted as "yyyy-MM-dd") into a Date object.
    static func getJobPostDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    /// An static function to filter an array of jobs based on provided criteria.
    static func filteredJobs(from jobs: [Job],
                             title: String = "",
                             company: String = "",
                             location: String = "",
                             level: String = "",
                             salaryMin: Int = 0,
                             salaryMax: Int = 50000,
                             postDate: String = "") -> [Job] {
        return jobs.filter { job in
            let matchesTitle = title.isEmpty || job.title.lowercased().contains(title.lowercased())
            let matchesCompany = company.isEmpty || job.company.lowercased().contains(company.lowercased())
            
            let matchesLocation: Bool = {
                if location.isEmpty {
                    return true
                }
                else if (location == "Local"){
                    return job.location.lowercased() == "n/a"
                }

                return job.location.lowercased().contains(location.lowercased())
            }()
            
            let matchesLevel: Bool = {
                //If empty provide every job no matter the level
                if level.isEmpty { return true }
                //Filter out nil levels
                
                if let jobLevel = job.level {
                    return jobLevel.lowercased().contains(level.lowercased())
                } else {
                    return true
                }
            }()
            
            let jobSalary = job.salary ?? 0
            let matchesSalary = job.salary == nil || (jobSalary >= salaryMin && jobSalary <= salaryMax)
            
            let matchesPostDate = postDate.isEmpty || filterByPostDate(job.postDate, postDate)
            
            return matchesTitle && matchesCompany && matchesLocation && matchesLevel && matchesSalary && matchesPostDate
        }
    }
}

// MARK: - Preview

struct JobFilterView_Previews: PreviewProvider {
    static var previews: some View {
        JobFilterView(
            jobs: [
                Job(id: 1, title: "Software Engineer", level: "Mid", company: "TechCorp", location: "New York", postDate: "2025-02-10", salary: 120000, url: URL(string: "https://example.com")!),
                Job(id: 2, title: "Data Scientist", level: "Senior", company: "DataCorp", location: "San Francisco", postDate: "2025-02-08", salary: 150000, url: URL(string: "https://example.com")!)
            ],
            filterTitle: .constant(""),
            filterCompany: .constant(""),
            filterLocation: .constant(""),
            filterLevel: .constant(""),
            filterSalaryMin: .constant(0),
            filterSalaryMax: .constant(200000),
            filterPostDate: .constant("")
        )
    }
}
