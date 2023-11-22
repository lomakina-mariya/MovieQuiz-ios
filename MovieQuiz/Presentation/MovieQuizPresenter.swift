//
//  MovieQuizPresenter.swift
//  MovieQuiz
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var correctAnswers: Int = 0
    private var currentQuestionIndex = 0
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private weak var viewController: MovieQuizViewController?
    private var statisticService: StatisticService?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
        viewController?.showLoadingIndicator()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.hideLoadingIndicator()
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showQuestion(quiz: viewModel)
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        viewController?.showLoadingIndicator()
    }
    
    func didFailToLoadData(with errorMessage: String) {
        viewController?.hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: errorMessage,
            buttonText: "Попробовать еще раз",
            completion: { [weak self] in
                guard let self = self else { return }
                self.questionFactory?.loadData()
                self.viewController?.showLoadingIndicator()
            }
        )
        viewController?.showErrorAlert(alertModel: alertModel)
    }
    
    func didFailToLoadImage() {
        viewController?.hideLoadingIndicator()
        let alertModel = AlertModel(
            title: "Ошибка",
            message: "Failed to load image",
            buttonText: "Загрузить другой вопрос",
            completion: { [weak self] in
                guard let self = self else { return }
                self.didLoadDataFromServer()
                self.viewController?.showLoadingIndicator()
            }
        )
        viewController?.showErrorAlert(alertModel: alertModel)
    }
    
    // MARK: - Internal functions
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func yesButtonClicked() {
      didAnswer(isCorrectAnswer: true)
    }
      
    func noButtonClicked() {
        didAnswer(isCorrectAnswer: false)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isCorrectAnswer
        if givenAnswer == currentQuestion.correctAnswer {
            proceedWithAnswer(isCorrect: true)
            correctAnswers += 1
        } else {
            proceedWithAnswer(isCorrect: false)
        }
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: makeResultMessage(),
                buttonText: "Сыграть еще раз"
                )
            viewController?.showFinalAlert(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
            self.viewController?.showLoadingIndicator()
        }
    }
    
    func makeResultMessage() -> String {
        guard let statisticService = statisticService else {
            assertionFailure("error message")
            return ""
        }
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/10 (\(statisticService.bestGame.date.dateTimeString))
        Cредняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        """
        return message
    }
    
    
}
