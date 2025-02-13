import Foundation

struct Job: Identifiable, Codable {
    var id: Int
    var title: String
    var level: String?
    var company: String
    var location: String
    var postDate: String
    var salary: Int?
    let url: URL
    var appliedTo: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case company
        case location
        case salary
        case level = "job_type"
        case postDate = "post_date"
        case url = "job_link"

    }
    
    static private func getJobPostDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
    
    static func getDatePostedDisplayString(_ dateString: String) -> String? {
        guard let jobDate = getJobPostDate(dateString) else { return nil }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(jobDate) {
            return "Posted Today"
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return "Posted: " + formatter.string(from: jobDate)
    }
    
    static func convertSalaryToCurrency(_ salary: Int?) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return salary != nil ? currencyFormatter.string(from: NSNumber(value: salary!)) ?? "N/A" : "Not listed"
    }
    
}
