//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Venus Nguyen on 3/26/25.
//

import Foundation

class TriviaQuestionService {
    func fetchQuestions(completion: @escaping ([TriviaQuestion]?) -> Void) {
        let urlString = "https://opentdb.com/api.php?amount=10&category=9"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(TriviaResponse.self, from: data)
                let questions = decodedResponse.results.map { result in
                    TriviaQuestion(
                        category: result.category,
                        type: result.type,
                        question: result.question.htmlDecoded(),
                        correctAnswer: result.correct_answer.htmlDecoded(),
                        incorrectAnswers: result.incorrect_answers.map { $0.htmlDecoded() }
                    )
                }
                completion(questions)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}

// API Response Models
struct TriviaResponse: Codable {
    let results: [TriviaAPIQuestion]
}

struct TriviaAPIQuestion: Codable {
    let category: String
    let type: String  // "multiple" or "boolean"
    let question: String
    let correct_answer: String
    let incorrect_answers: [String]
}

// Extension to decode HTML entities
extension String {
    func htmlDecoded() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return (try? NSAttributedString(data: data, options: options, documentAttributes: nil).string) ?? self
    }
}
