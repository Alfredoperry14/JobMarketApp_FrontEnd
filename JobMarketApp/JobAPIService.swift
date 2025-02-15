import Foundation

class JobAPIService {
    static let shared = JobAPIService()
    private let baseURL = "https://myfirstapi.website" // Replace with your EC2 public IP or domain

    func fetchJobs(completion: @escaping (Result<[Job], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/jobs") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        // Add the token header
        request.setValue(Config.apiToken, forHTTPHeaderField: "x_token")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            
            do {
                let jobs = try JSONDecoder().decode([Job].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(jobs))
                }
            } catch {
                print("Decoding error:", error)
                completion(.failure(error))
            }
        }.resume()
    }
}
