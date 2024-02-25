//
//  Helper.swift
//  SW
//
//  Created by SeungJun Lee on 2/12/24.
//


import Foundation

class Helper {
    func dotProduct(_ vec1: [Float], _ vec2: [Float]) -> Float {
        return zip(vec1, vec2).map(*).reduce(0, +)
    }

    func magnitude(_ vec: [Float]) -> Float {
        return sqrt(vec.map { $0 * $0 }.reduce(0, +))
    }

    func cosineSimilarity(_ vec1: [Float], _ vec2: [Float]) -> Float {
        let dotProd = dotProduct(vec1, vec2)
        let magVec1 = magnitude(vec1)
        let magVec2 = magnitude(vec2)
        return dotProd / (magVec1 * magVec2)
    }
}
