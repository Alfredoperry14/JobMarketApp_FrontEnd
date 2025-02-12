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
    
    static func convertSalaryToCurrency(_ salary: Int?) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        return salary != nil ? currencyFormatter.string(from: NSNumber(value: salary!)) ?? "N/A" : "N/A"
    }
    
}
