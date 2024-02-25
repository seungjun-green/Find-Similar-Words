//
//  ModelManager.swift
//  SW
//
//  Created by SeungJun Lee on 2/12/24.
//

import Foundation
import CoreML


class AppViewModel: ObservableObject {
    @Published var isInitializing = true
    var modelManager: ModelManager?
    
    func initializeModelManager() {
        DispatchQueue.global(qos: .background).async {
            self.modelManager = ModelManager()
            DispatchQueue.main.async {
                self.isInitializing = false
            }
        }
    }
}



class ModelManager {
    let brain: iOS_find_wordV2
    let word2Index: [String: Int]
    let index2Word: [Int: String]
    
    init() {
        
        let config = MLModelConfiguration()
        
        brain = try! iOS_find_wordV2(configuration: config)
        word2Index = ModelManager.loadWord2IndexDictionary() ?? [:]
        index2Word = ModelManager.loadIndex2Word() ?? [:]
    
    }
    
    
    func convertSingleIntToMLMultiArray(_ intValue: Int) -> MLMultiArray? {
        do {
            let shape = [1] as [NSNumber]
            let array = try MLMultiArray(shape: shape, dataType: .int32)
            array[0] = NSNumber(value: intValue)
            return array
        } catch {
            print("Error creating MLMultiArray: \(error)")
            return nil
        }
    }
    
    func convertMLMultiArrayToIntArray(_ mlArray: MLMultiArray) -> [Float] {
        var outputArray: [Float] = []
        
        let totalCount = mlArray.count
        for i in 0..<totalCount {
            outputArray.append( Float(truncating: mlArray[i]))
        }
        
        return outputArray
    }
    
    
    
    func predict(input: String) -> [String] {
        do {
            
            
            guard let indexOfWord = word2Index[input] else {
                return ["Input Word Not Found"]
            }
            
            let mlarray = convertSingleIntToMLMultiArray(indexOfWord)
            let pred = try brain.prediction(input_62: mlarray!).Identity
            let ff = convertMLMultiArrayToIntArray(pred)
            
            let answerWords = indicesOfTopTenElements(in: ff)
            
            
            var answerArray = [String]()
            for currWordIndex in answerWords {
                answerArray.append(index2Word[currWordIndex] ?? ".")
            }
            
            return answerArray
        } catch {
            print("Something have gone wrong")
        }
        
        return ["Not Found"]
    }
    
    
    func subtractOneFromElements(of array: [Float]) -> [Float] {
        let newArray = array.map { 1 - $0 }
        return newArray
    }
    
    func indicesOfTopTenElements(in array: [Float]) -> [Int] {
        let count = min(array.count, 100)
        let sortedIndices = array.enumerated().sorted { $0.element > $1.element }.map { $0.offset }
        return Array(sortedIndices.prefix(count))
    }
    
    private static func loadWord2IndexDictionary() -> [String: Int]? {
        
        guard let url = Bundle.main.url(forResource: "word2index", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        return try? JSONDecoder().decode([String: Int].self, from: data)
    }
    
    private static func loadIndex2Word() -> [Int: String]? {
        
        guard let url = Bundle.main.url(forResource: "index2word", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        return try? JSONDecoder().decode([Int: String].self, from: data)
    }
    
    
}
