import SwiftUI
struct JobListView: View {
    @Binding var jobs: [Job]
    @State private var currentPage = 0
    @State private var showFilterModal = false
    @State private var showTodaysPostings = false
    @State private var cachedFilteredIndices: [Int] = []
    private let pageSize = 25

    // Filter criteria state variables.
    @State private var filterTitle: String = ""
    @State private var filterCompany: String = ""
    @State private var filterLocation: String = ""
    @State private var filterLevel: String = ""
    @State private var filterSalaryMin: Int = 0
    @State private var filterSalaryMax: Int = 500000
    @State private var filterPostDate: String = ""
    
    // MARK: - Helper: Compute Filtered Indices
    private func computeFilteredIndices() -> [Int] {
        // 1. Filter jobs based on criteria.
        var filteredJobs: [Job] = JobFilterView.filteredJobs(
            from: jobs,
            title: filterTitle,
            company: filterCompany,
            location: filterLocation,
            level: filterLevel,
            salaryMin: filterSalaryMin,
            salaryMax: filterSalaryMax,
            postDate: filterPostDate
        )
        //Only show jobs that haven't been applied to
        filteredJobs = filteredJobs.filter { !$0.appliedTo }
        
        // 2. If "Today's Postings" is active, filter further.
        if showTodaysPostings {
            filteredJobs = filteredJobs.filter { (job: Job) -> Bool in
                guard let jobDate = JobFilterView.getJobPostDate(job.postDate) else { return false }
                let calendar = Calendar.current
                let todayStart = calendar.startOfDay(for: Date())
                let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart)!
                return jobDate >= todayStart && jobDate < tomorrowStart
            }
        }
        
        // 3. Sorting logic.
        let noFiltersActive: Bool = filterTitle.isEmpty &&
            filterCompany.isEmpty &&
            filterLocation.isEmpty &&
            filterLevel.isEmpty &&
            filterSalaryMin == 0 &&
            filterSalaryMax == 500000 &&
            filterPostDate.isEmpty &&
            !showTodaysPostings
        
        let sortedJobs: [Job]
        if noFiltersActive {
            let oneWeekAgo: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            sortedJobs = filteredJobs.sorted(by: { (job1: Job, job2: Job) -> Bool in
                guard let date1 = JobFilterView.getJobPostDate(job1.postDate),
                      let date2 = JobFilterView.getJobPostDate(job2.postDate) else { return false }
                let job1Recent: Bool = date1 >= oneWeekAgo
                let job2Recent: Bool = date2 >= oneWeekAgo
                if job1Recent && !job2Recent {
                    return true
                } else if !job1Recent && job2Recent {
                    return false
                } else {
                    return date1 > date2
                }
            })
            //Start sorting based on active filters
        } else {
            sortedJobs = filteredJobs.sorted { job1, job2 in
                // First, prioritize jobs with a non-nil salary.
                switch (job1.salary, job2.salary) {
                case let (s1?, s2?):
                    // Both have salaries: sort by salary in ascending order.
                    if s1 != s2 {
                        return s1 < s2
                    }
                case (nil, _):
                    // job1 has no salary while job2 does: job2 comes first.
                    return false
                case (_, nil):
                    // job1 has a salary and job2 doesn't: job1 comes first.
                    return true
                default:
                    break
                }
                // Next, if filterLevel is active, sort by job level.
                if !filterLevel.isEmpty {
                    let level1 = job1.level ?? ""
                    let level2 = job2.level ?? ""
                    if level1 != level2 {
                        return level1 < level2
                    }
                }
                // Finally, sort by post date (more recent first).
                guard let date1 = JobFilterView.getJobPostDate(job1.postDate),
                      let date2 = JobFilterView.getJobPostDate(job2.postDate) else {
                    return false
                }
                return date1 > date2
            }
        }
        
        // 4. Map sorted jobs back to their indices in the original jobs array.
        let jobIDs: [Int] = sortedJobs.map { (job: Job) -> Int in
            return job.id
        }
        let sortedJobIDs: Set<Int> = Set(jobIDs)
        let indices: [Int] = jobs.indices.filter { (index: Int) -> Bool in
            return sortedJobIDs.contains(jobs[index].id)
        }
        
        return indices
    }
    
    // Update the cachedFilteredIndices asynchronously.
    func updateFilteredIndices() {
        DispatchQueue.global(qos: .userInitiated).async {
            let indices = computeFilteredIndices()
            DispatchQueue.main.async {
                self.cachedFilteredIndices = indices
                self.currentPage = 0
            }
        }
    }
    
    // Use cached results for pagination.
    var paginatedIndices: [Int] {
        let start = currentPage * pageSize
        let end = min(start + pageSize, cachedFilteredIndices.count)
        return Array(cachedFilteredIndices[start..<end])
    }
    
    var totalPages: Int {
        let totalJobs = Double(cachedFilteredIndices.count)
        return Int(ceil(totalJobs / Double(pageSize)))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView(showFilterModal: $showFilterModal, showTodaysPostings: $showTodaysPostings)
                    .onChange(of: showTodaysPostings) { updateFilteredIndices() }
                
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Color.clear.frame(height: 1).id("top")
                            
                            ForEach(paginatedIndices, id: \.self) { index in
                                NavigationLink(destination: JobPageView(job: $jobs[index])) {
                                    JobRowView(job: jobs[index])
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top)
                        .padding(.bottom)
                        
                        PaginationControlView(
                            currentPage: currentPage,
                            totalPages: totalPages,
                            onPrevious: {
                                if currentPage > 0 {
                                    currentPage -= 1
                                    withAnimation {
                                        scrollProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            },
                            onNext: {
                                if (currentPage + 1) * pageSize < cachedFilteredIndices.count {
                                    currentPage += 1
                                    withAnimation {
                                        scrollProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            }
                        )
                    }
                }
            }
            .sheet(isPresented: $showFilterModal) {
                JobFilterView(
                    jobs: jobs,
                    filterTitle: $filterTitle,
                    filterCompany: $filterCompany,
                    filterLocation: $filterLocation,
                    filterLevel: $filterLevel,
                    filterSalaryMin: $filterSalaryMin,
                    filterSalaryMax: $filterSalaryMax,
                    filterPostDate: $filterPostDate
                )
                .onDisappear {
                    updateFilteredIndices()
                }
            }
            .onAppear {
                updateFilteredIndices()
            }
            .onChange(of: jobs) { updateFilteredIndices() }
            .onChange(of: filterTitle) { updateFilteredIndices() }
            .onChange(of: filterCompany) { updateFilteredIndices() }
            .onChange(of: filterLocation) { updateFilteredIndices() }
            .onChange(of: filterLevel) { updateFilteredIndices() }
            .onChange(of: filterSalaryMin) { updateFilteredIndices() }
            .onChange(of: filterSalaryMax) { updateFilteredIndices() }
            .onChange(of: filterPostDate) { updateFilteredIndices() }
        }
    }
}
struct HeaderView: View {
    @Binding var showFilterModal: Bool
    @Binding var showTodaysPostings : Bool
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName: "text.rectangle.page")
                    .frame(width: 30, height: 30)
                    .foregroundStyle(showTodaysPostings ? .green : .gray)
                    .onTapGesture {
                        withAnimation {
                            showTodaysPostings.toggle()
                        }
                    }
                Spacer()
                Text("Job Listings")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.blue)
                    .onTapGesture {
                        withAnimation {
                            showFilterModal = true
                        }
                    }
                Spacer()
            }
            .font(.title)
            .padding(.bottom)
        }
        if showTodaysPostings {
            Text("Today's Postings!")
        }
    }
}

struct PaginationControlView: View {
    let currentPage: Int
    let totalPages: Int
    let onPrevious: () -> Void
    let onNext: () -> Void

    var body: some View {
        HStack {
            Spacer()
            Button(action: onPrevious) {
                Image(systemName: "arrowshape.backward.fill")
                    .foregroundColor(currentPage > 0 ? .blue : .gray)
            }
            .disabled(currentPage == 0)
            
            Spacer()
            Text("Page \(currentPage + 1) of \(totalPages)")
            
            Spacer()
            Button(action: onNext) {
                Image(systemName: "arrowshape.right.fill")
                    .foregroundColor(currentPage < totalPages - 1 ? .blue : .gray)
            }
            .disabled(currentPage >= totalPages - 1)
            Spacer()
        }
        .padding()
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
                .foregroundColor(.black)
            Text(job.level ?? "N/A")
                .font(.subheadline)
                .foregroundColor(.black)
            HStack {
                Text(job.location == "N/A" ? "Local" : job.location)
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                VStack {
                    Text(Job.getDatePostedDisplayString(job.postDate) ?? "N/A")
                    Text(Job.convertSalaryToCurrency(job.salary))
                        .bold()
                        .font(.footnote)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }
}
