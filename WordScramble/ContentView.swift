//
//  ContentView.swift
//  WordScramble
//
//  Created by Dennis Dang on 10/26/19.
//  Copyright © 2019 Dennis Dang. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                
                List(usedWords, id:\.self) {
                    Image(systemName: "\($0.count).circle")
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
            .onAppear(perform: startGame)
            .alert(isPresented: $showingError) {
                Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarItems(leading:
                HStack {
                    Button(action: startGame) {
                        Text("Reset")
                        Image(systemName: "arrow.2.circlepath")
                    }
                }
            )
        }
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else {
            // If were are *here* then there was a problem – trigger a crash and report the error
            fatalError("Could not load start.txt from bundle.")
        }
        
        // 2. Load start.txt into a string
        guard let startWords = try? String(contentsOf: startWordsURL) else {
            fatalError("Could not load start.txt from bundle.")
        }
        
        // 3. Split the string up into an array of strings, splitting on line breaks
        let allWords = startWords.components(separatedBy: .newlines)
        
        // 4. Pick one random word, or use "silkworm"
        rootWord = allWords.randomElement() ?? "silkworm"
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        if word.count < 3 {
            return false
        }
        
        if word == rootWord {
            return false
        }
        
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
