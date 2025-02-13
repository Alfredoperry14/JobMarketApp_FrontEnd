import SwiftUI

struct JobListView: View {
    @Binding var jobs: [Job]
    @State private var currentPage = 0
    @State private var showFilterModal = false
    private let pageSize = 25
    
    var filteredIndices: [Int] {
        let filteredJobs = JobFilterView.filteredJobs(from: jobs)
        return jobs.indices.filter { index in
            filteredJobs.contains { $0.id == jobs[index].id }
        }
    }
    
    // Pagination: Paginate over the filtered indices.
    var paginatedIndices: [Int] {
        // Calculate the start and end indices for the current page. The indices are each job
        let start = currentPage * pageSize
        let end = min(start + pageSize, filteredIndices.count)
        return Array(filteredIndices[start..<end])
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header
                HStack {
                    Text("Job Listings")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .padding(.trailing, 10)
                        .frame(width: 30, height: 30, alignment: .trailing)
                        .foregroundStyle(.blue)
                        .onTapGesture {
                            // Show the filter modal when tapped
                            showFilterModal = true
                        }
                }
                .font(.title)
                .padding(.bottom)

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Color.clear.frame(height: 1).id("top") //Invisible anchor for switching pages


                            let startIndex = currentPage * pageSize
                            let endIndex = min(startIndex + pageSize, jobs.count)
                            
                            // Use indices to pass a binding for each job.
                            ForEach(startIndex..<endIndex, id: \.self) { index in
                                NavigationLink(destination: JobPageView(job: $jobs[index])) {
                                    JobRowView(job: jobs[index])
                                        .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top)
                        .padding(.bottom)

                        // Pagination Controls
                        HStack {
                            Spacer()
                            Button(action: {
                                if currentPage > 0 {
                                    currentPage -= 1
                                    withAnimation {
                                        scrollProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            }) {
                                Image(systemName: "arrowshape.backward.fill")
                                    .foregroundColor(currentPage > 0 ? Color.blue : Color.gray)
                            }
                            .disabled(currentPage == 0)

                            Spacer()
                            Text("Page \(currentPage + 1) of \(Int(ceil(Double(jobs.count) / Double(pageSize))))")
                            Spacer()

                            Button(action: {
                                if (currentPage + 1) * pageSize < jobs.count {
                                    currentPage += 1
                                    withAnimation {
                                        scrollProxy.scrollTo("top", anchor: .top)
                                    }
                                }
                            }) {
                                Image(systemName: "arrowshape.right.fill")
                                    .foregroundColor((currentPage + 1) * pageSize < jobs.count ? Color.blue : Color.gray)
                            }
                            .disabled((currentPage + 1) * pageSize >= jobs.count)

                            Spacer()
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterModal) {
                // Present JobFilterView as a modal sheet.
                // Pass the filterText binding so the filter can be updated.
                JobFilterView(jobs: jobs)
            }
        }
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
                VStack{
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
