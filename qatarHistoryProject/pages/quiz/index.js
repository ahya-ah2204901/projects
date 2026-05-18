/*
  Quiz Page
  Interactive multiple-choice quiz about Qatari heritage
*/

'use client';

import { useState } from 'react';
import Head from 'next/head';
import Link from 'next/link';
import { quizQuestions } from '@/data/quizQuestions';
import styles from '@/styles/Quiz.module.css';

export default function Quiz() {
  const [currentQuestion, setCurrentQuestion] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState(null);
  const [showExplanation, setShowExplanation] = useState(false);
  const [score, setScore] = useState(0);
  const [answeredQuestions, setAnsweredQuestions] = useState([]);
  const [quizCompleted, setQuizCompleted] = useState(false);

  const question = quizQuestions[currentQuestion];

  const handleAnswerSelect = (optionIndex) => {
    if (showExplanation) return; // Prevent changing answer after submission

    setSelectedAnswer(optionIndex);
  };

  const handleSubmitAnswer = () => {
    if (selectedAnswer === null) return;

    const isCorrect = selectedAnswer === question.correctAnswer;

    if (isCorrect) {
      setScore(score + 1);
    }

    setAnsweredQuestions([
      ...answeredQuestions,
      {
        questionId: question.id,
        correct: isCorrect
      }
    ]);

    setShowExplanation(true);
  };

  const handleNextQuestion = () => {
    if (currentQuestion < quizQuestions.length - 1) {
      setCurrentQuestion(currentQuestion + 1);
      setSelectedAnswer(null);
      setShowExplanation(false);
    } else {
      setQuizCompleted(true);
    }
  };

  const handleRestartQuiz = () => {
    setCurrentQuestion(0);
    setSelectedAnswer(null);
    setShowExplanation(false);
    setScore(0);
    setAnsweredQuestions([]);
    setQuizCompleted(false);
  };

  const getScoreMessage = () => {
    const percentage = (score / quizQuestions.length) * 100;

    if (percentage === 100) {
      return {
        title: 'Perfect Score!',
        message: 'Outstanding! You have excellent knowledge of Qatari heritage!',
        emoji: '🏆'
      };
    } else if (percentage >= 75) {
      return {
        title: 'Excellent Work!',
        message: 'Great job! You have strong knowledge of Qatar\'s history and culture.',
        emoji: '🌟'
      };
    } else if (percentage >= 50) {
      return {
        title: 'Good Effort!',
        message: 'Well done! You have a solid understanding of Qatari heritage.',
        emoji: '👍'
      };
    } else {
      return {
        title: 'Keep Learning!',
        message: 'Explore the historical sites to learn more about Qatar\'s rich heritage.',
        emoji: '📚'
      };
    }
  };

  if (quizCompleted) {
    const scoreMessage = getScoreMessage();

    return (
      <>
        <Head>
          <title>Quiz Results - Exploring Qatari Heritage</title>
        </Head>

        <section className="section">
          <div className="container">
            <div className={styles.results}>
              <div className={styles.resultsEmoji}>{scoreMessage.emoji}</div>
              <h1 className={styles.resultsTitle}>{scoreMessage.title}</h1>
              <div className={styles.scoreDisplay}>
                <div className={styles.scoreLarge}>
                  {score} / {quizQuestions.length}
                </div>
                <div className={styles.scorePercentage}>
                  {Math.round((score / quizQuestions.length) * 100)}%
                </div>
              </div>
              <p className={styles.resultsMessage}>{scoreMessage.message}</p>

              <div className={styles.resultsActions}>
                <button onClick={handleRestartQuiz} className="btn btn-primary">
                  Take Quiz Again
                </button>
                <Link href="/historical-sites/" className="btn btn-secondary">
                  Explore Historical Sites
                </Link>
              </div>
            </div>
          </div>
        </section>
      </>
    );
  }

  return (
    <>
      <Head>
        <title>Quiz - Test Your Knowledge of Qatari Heritage</title>
        <meta name="description" content="Test your knowledge about Qatar's history, culture, and heritage with our interactive quiz." />
      </Head>

      {/* Page Header */}
      <section className="hero">
        <div className="hero-content">
          <h1>Qatari Heritage Quiz</h1>
          <p>Test your knowledge about Qatar's rich history and cultural heritage</p>
        </div>
      </section>

      {/* Quiz Section */}
      <section className="section">
        <div className="container">
          <div className={styles.quizContainer}>
            {/* Progress Bar */}
            <div className={styles.progress}>
              <div className={styles.progressText}>
                Question {currentQuestion + 1} of {quizQuestions.length}
              </div>
              <div className={styles.progressBar}>
                <div
                  className={styles.progressFill}
                  style={{
                    width: `${((currentQuestion + 1) / quizQuestions.length) * 100}%`
                  }}
                />
              </div>
            </div>

            {/* Question */}
            <div className={styles.questionCard}>
              <h2 className={styles.question}>{question.question}</h2>

              {/* Options */}
              <div className={styles.options}>
                {question.options.map((option, index) => {
                  const isSelected = selectedAnswer === index;
                  const isCorrect = index === question.correctAnswer;

                  let optionClass = styles.option;

                  if (showExplanation) {
                    if (isCorrect) {
                      optionClass += ` ${styles.optionCorrect}`;
                    } else if (isSelected && !isCorrect) {
                      optionClass += ` ${styles.optionIncorrect}`;
                    }
                  } else if (isSelected) {
                    optionClass += ` ${styles.optionSelected}`;
                  }

                  return (
                    <button
                      key={index}
                      className={optionClass}
                      onClick={() => handleAnswerSelect(index)}
                      disabled={showExplanation}
                    >
                      <span className={styles.optionLabel}>
                        {String.fromCharCode(65 + index)}
                      </span>
                      <span className={styles.optionText}>{option}</span>
                      {showExplanation && isCorrect && (
                        <span className={styles.optionIcon}>✓</span>
                      )}
                      {showExplanation && isSelected && !isCorrect && (
                        <span className={styles.optionIcon}>✗</span>
                      )}
                    </button>
                  );
                })}
              </div>

              {/* Explanation */}
              {showExplanation && (
                <div className={styles.explanation}>
                  <h3>
                    {selectedAnswer === question.correctAnswer ? 'Correct!' : 'Not quite!'}
                  </h3>
                  <p>{question.explanation}</p>
                </div>
              )}

              {/* Action Buttons */}
              <div className={styles.actions}>
                {!showExplanation ? (
                  <button
                    className="btn btn-primary"
                    onClick={handleSubmitAnswer}
                    disabled={selectedAnswer === null}
                  >
                    Submit Answer
                  </button>
                ) : (
                  <button className="btn btn-primary" onClick={handleNextQuestion}>
                    {currentQuestion < quizQuestions.length - 1
                      ? 'Next Question'
                      : 'View Results'}
                  </button>
                )}
              </div>
            </div>

            {/* Score Tracker */}
            <div className={styles.scoreTracker}>
              <div className={styles.scoreLabel}>Current Score:</div>
              <div className={styles.scoreValue}>
                {score} / {currentQuestion + (showExplanation ? 1 : 0)}
              </div>
            </div>
          </div>
        </div>
      </section>
    </>
  );
}
