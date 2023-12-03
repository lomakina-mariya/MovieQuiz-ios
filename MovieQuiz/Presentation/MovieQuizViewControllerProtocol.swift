//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func showQuestion(quiz step: QuizStepViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showFinalAlert(quiz result: QuizResultsViewModel)
    
    func showErrorAlert(alertModel: AlertModel)
    
    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    func switchOfButtons()
    
}
