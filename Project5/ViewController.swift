//
//  ViewController.swift
//  Project5
//
//  Created by Христина Мізинюк on 10/22/22.
//

import UIKit


class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    //    var scoreLabel = UILabel()
    //    var score: Int = 0 {
    //        didSet {
    //            scoreLabel.text = "Score: \(score)"
    //
    //        }
    enum ValidationError: String {
        case notPossible
        case notOriginal
        case notReal
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //       scoreLabel = UILabel()
        //        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        //       scoreLabel.textAlignment = .natural
        //        scoreLabel.text = "Score: 0"
        //        view.addSubview(scoreLabel)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector (startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
            
        }
        
        startGame()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    func restartGame(action: UIAlertAction) {
        
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc  func startGame () {
        
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
            
        }
        
        ac.addTextField()
        ac.addAction(submitAction)
        
        present(ac, animated: true)
        enum ValidationError: String {
            case notPossible
            case notOriginal
            case notReal
        }
        
    }
    
    func submit(_ answer: String) {
        var type: ValidationError
        let lowerAnswer = answer.lowercased()
        
        if (usedWords.count == 4)
        {
            let ac = UIAlertController(title: "Well done!", message: "Let's guess the next word", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: restartGame))
            present(ac, animated: true)
        }
        
        if isPossible(word: lowerAnswer) {
            if isOriginal(word: lowerAnswer) {
                if isReal(word: lowerAnswer) {
                    usedWords.insert(answer, at: 0)
                    
                    let indexPath = IndexPath(row: 0, section: 0)
                    tableView.insertRows(at: [indexPath], with: .automatic)
                    
                    return
                    
                } else {
                    type = .notPossible
                }
                
            } else {
                type = .notOriginal
            }
            
        } else {
            type = .notReal
        }
        
        showError(type: type)
    }
    func createAlertController(title: String, message: String, actionTitle: String, handler: ((UIAlertAction) -> Void)? ) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }
    
    func showError (type: ValidationError) {
        var errorTitle: String
        var errorMessage: String
        guard let title = title else { return }
        
        switch type {
        case .notPossible:
            errorTitle = "Word not recognized!"
            errorMessage = " You can't just make them up, you know!"
        case .notOriginal:
            errorTitle = "Word already used!"
            errorMessage = "Be more original!"
        case .notReal:
            errorTitle = "Word is not possible!"
            errorMessage = "You can't spell that word from \(title.lowercased())!"
            
        }
        
        createAlertController(title: errorTitle, message: errorMessage, actionTitle: "OK", handler: nil)
    }
    
    func isPossible(word:String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
                
            } else {
                
                return false
            }
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
}
