//
//  PresenterTests.swift
//  MovieQuizTests
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func showQuestion(quiz step: MovieQuiz.QuizStepViewModel) {
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    }
    
    func showFinalAlert(quiz result: MovieQuiz.QuizResultsViewModel) {
    }
    
    func showErrorAlert(alertModel: MovieQuiz.AlertModel) {
    }
    
    func showLoadingIndicator() {
    }
    
    func hideLoadingIndicator() {
    }
    
    func switchOfButtons() {
    }
}


final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() {
        let viewControllerMock = MovieQuizViewController()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
}
