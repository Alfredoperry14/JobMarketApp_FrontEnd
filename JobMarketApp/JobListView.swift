import SwiftUI


struct JobListView: View {
    @Binding var jobs: [Job]
    @State private var currentPage = 0
    private let pageSize = 25
    
    var paginatedJobs: [Job] {
        let start = currentPage * pageSize
        let end = min(start + pageSize, jobs.count)
        return Array(jobs[start..<end])
    }
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Job Listings")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center) // Ensures centering
                    
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .padding(.trailing, 10)
                        .frame(width: 30, height: 30, alignment: .trailing)
                        .foregroundStyle(.blue)
                }
                .font(.title)
                .padding(.bottom)
                
                
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            Color.clear.frame(height: 1).id("top") // Invisible anchor at top
                            
                            ForEach(jobs.indices, id: \.self) { index in
                                if jobs[index].id >= currentPage * pageSize && jobs[index].id < (currentPage + 1) * pageSize {
                                    NavigationLink(destination: JobPageView(job: .constant(jobs[index]))) {
                                        JobRowView(job: jobs[index])
                                            .padding(.horizontal)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
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
                                    withAnimation{
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
            
            HStack {
                Text(job.location)
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
                Text(Job.convertSalaryToCurrency(job.salary))
                    .font(.footnote)
                    .bold()
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)).shadow(radius: 3))
        .padding(.horizontal)
    }
}
