import SwiftUI

struct JobApplicationsView: View {
    @Binding var jobs: [Job]
    @State private var isExpanded: Bool = false

    // Applied jobs that are less than 14 days old.
    private var recentJobs: [Job] {
        jobs.filter { job in
            job.appliedTo && !isJobOlderThan14Days(job)
        }
    }
    
    // Applied jobs that are 14 days or older.
    private var olderJobs: [Job] {
        jobs.filter { job in
            job.appliedTo && isJobOlderThan14Days(job)
        }
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 16) {
                // Recent applications list view.
                if !recentJobs.isEmpty {
                    Text("Recent Applications (\(recentJobs.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    ForEach(recentJobs) { job in
                        NavigationLink(destination: JobPageView(job: bindingForJob(job))) {
                            JobRowView(job: job)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                    }
                } else {
                    Text("No recent applications.")
                        .padding(.horizontal)
                }
                
                // DisclosureGroup for applications 14+ days old.
                DisclosureGroup(
                    "Applications 14+ Days Old (\(olderJobs.count))",
                    isExpanded: $isExpanded
                ) {
                    ForEach(olderJobs) { job in
                        NavigationLink(destination: JobPageView(job: bindingForJob(job))) {
                            JobRowView(job: job)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("My Job Applications")
        }
    }
    
    /// Returns true if the job's post date is at least 14 days ago.
    private func isJobOlderThan14Days(_ job: Job) -> Bool {
        guard let jobDate = JobFilterView.getJobPostDate(job.postDate) else { return false }
        guard let thresholdDate = Calendar.current.date(byAdding: .day, value: 14, to: jobDate) else { return false }
        return Date() >= thresholdDate
    }
    
    /// Returns a binding for a given job in the jobs array.
    private func bindingForJob(_ job: Job) -> Binding<Job> {
        guard let index = jobs.firstIndex(where: { $0.id == job.id }) else {
            fatalError("Job not found")
        }
        return $jobs[index]
    }
}

#Preview {
    NavigationView {
        JobApplicationsView(jobs: .constant([
            // 5 Jobs 14+ days old (assuming current date is around Feb 14, 2025)
            Job(
                id: 1,
                title: "Software Engineer",
                level: "Mid",
                company: "TechCorp",
                location: "New York",
                postDate: "2025-01-20", // Older than 14 days.
                salary: 120000,
                url: URL(string: "https://example.com/job1")!,
                appliedTo: true
            ),
            Job(
                id: 2,
                title: "Data Scientist",
                level: "Senior",
                company: "DataCorp",
                location: "San Francisco",
                postDate: "2025-01-22", // Older than 14 days.
                salary: 150000,
                url: URL(string: "https://example.com/job2")!,
                appliedTo: true
            ),
            Job(
                id: 3,
                title: "DevOps Engineer",
                level: "Senior",
                company: "CloudCorp",
                location: "Remote",
                postDate: "2025-01-25", // Older than 14 days.
                salary: 130000,
                url: URL(string: "https://example.com/job3")!,
                appliedTo: true
            ),
            Job(
                id: 4,
                title: "Backend Developer",
                level: "Mid",
                company: "AppSolutions",
                location: "Boston",
                postDate: "2025-01-28", // Older than 14 days.
                salary: 115000,
                url: URL(string: "https://example.com/job4")!,
                appliedTo: true
            ),
            Job(
                id: 5,
                title: "Frontend Developer",
                level: "Junior",
                company: "WebWorks",
                location: "Austin",
                postDate: "2025-01-30", // Older than 14 days.
                salary: 95000,
                url: URL(string: "https://example.com/job5")!,
                appliedTo: true
            ),
            // 5 Jobs under 14 days old.
            Job(
                id: 6,
                title: "Mobile Developer",
                level: "Mid",
                company: "TechMobile",
                location: "Los Angeles",
                postDate: "2025-02-01", // Less than 14 days old.
                salary: 110000,
                url: URL(string: "https://example.com/job6")!,
                appliedTo: true
            ),
            Job(
                id: 7,
                title: "QA Engineer",
                level: "Junior",
                company: "QualitySoft",
                location: "Seattle",
                postDate: "2025-02-05", // Less than 14 days old.
                salary: 85000,
                url: URL(string: "https://example.com/job7")!,
                appliedTo: true
            ),
            Job(
                id: 8,
                title: "Project Manager",
                level: "Senior",
                company: "ManageIt",
                location: "Chicago",
                postDate: "2025-02-07", // Less than 14 days old.
                salary: 140000,
                url: URL(string: "https://example.com/job8")!,
                appliedTo: true
            ),
            Job(
                id: 9,
                title: "UX Designer",
                level: "Mid",
                company: "DesignHub",
                location: "San Diego",
                postDate: "2025-02-10", // Less than 14 days old.
                salary: 105000,
                url: URL(string: "https://example.com/job9")!,
                appliedTo: true
            ),
            Job(
                id: 10,
                title: "System Analyst",
                level: "Senior",
                company: "SysTech",
                location: "Denver",
                postDate: "2025-02-12", // Less than 14 days old.
                salary: 125000,
                url: URL(string: "https://example.com/job10")!,
                appliedTo: true
            )
        ]))
    }
}
