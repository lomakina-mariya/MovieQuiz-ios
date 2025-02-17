//
//  QuestionFactoryProtocol.swift
//  MovieQuiz

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? {get set}
    func requestNextQuestion(_ index: Int)
}
