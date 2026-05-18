/*
  Quiz Questions Data
  Edit this file to modify quiz questions and answers
  Each question should have: id, question, options (array), correctAnswer (index), and explanation
*/

export const quizQuestions = [
  {
    id: 1,
    question: 'When was Al Zubarah Fort built?',
    options: [
      '1868',
      '1905',
      '1938',
      '1950'
    ],
    correctAnswer: 2, // Index of correct option (1938)
    explanation: 'Al Zubarah Fort was built in 1938 and served as a coast guard station during the pearling season. The site became a UNESCO World Heritage Site in 2013.'
  },
  {
    id: 2,
    question: 'What does "Souq Waqif" translate to in English?',
    options: [
      'Old Market',
      'Standing Market',
      'Traditional Bazaar',
      'Heritage Square'
    ],
    correctAnswer: 1,
    explanation: 'Souq Waqif means "Standing Market" as Bedouins would come here to trade their goods while standing. It has been a commercial hub for over a century.'
  },
  {
    id: 3,
    question: 'Which famous architect designed the Museum of Islamic Art in Doha?',
    options: [
      'Frank Gehry',
      'Zaha Hadid',
      'I.M. Pei',
      'Norman Foster'
    ],
    correctAnswer: 2,
    explanation: 'I.M. Pei, the renowned Chinese-American architect, designed the Museum of Islamic Art, which opened in 2008. The museum is considered one of his masterpieces.'
  },
  {
    id: 4,
    question: 'What was the primary historical industry that made Qatar prosperous before the discovery of oil?',
    options: [
      'Agriculture',
      'Pearling',
      'Textile manufacturing',
      'Spice trade'
    ],
    correctAnswer: 1,
    explanation: 'Pearling was the backbone of Qatar\'s economy for centuries before oil was discovered. Qatar was renowned for producing some of the finest pearls in the Gulf region.'
  },
  {
    id: 5,
    question: 'In which year did Al Zubarah become a UNESCO World Heritage Site?',
    options: [
      '2008',
      '2010',
      '2013',
      '2015'
    ],
    correctAnswer: 2,
    explanation: 'Al Zubarah Archaeological Site was inscribed as a UNESCO World Heritage Site in 2013, recognizing its significance as one of the best-preserved examples of an 18th-19th century pearling and trading town in the Gulf region.'
  },
  {
    id: 6,
    question: 'What is the name of the cultural village that promotes Qatari heritage through arts and traditional architecture?',
    options: [
      'Souq Waqif',
      'Al Wakrah Village',
      'Katara Cultural Village',
      'Al Zubarah Village'
    ],
    correctAnswer: 2,
    explanation: 'Katara Cultural Village, opened in 2010, is Qatar\'s premier destination for cultural events, traditional architecture, and artistic performances. The name "Katara" was an ancient name for the Qatar Peninsula.'
  },
  {
    id: 7,
    question: 'How long is the Doha Corniche waterfront promenade?',
    options: [
      '3 kilometers',
      '5 kilometers',
      '7 kilometers',
      '10 kilometers'
    ],
    correctAnswer: 2,
    explanation: 'The Doha Corniche stretches for 7 kilometers along Doha Bay, offering spectacular views of the city\'s skyline and serving as a popular recreational area for residents and visitors.'
  },
  {
    id: 8,
    question: 'What were the Barzan Towers primarily used for?',
    options: [
      'Royal residence',
      'Watchtowers and moon sighting',
      'Trading post',
      'Religious ceremonies'
    ],
    correctAnswer: 1,
    explanation: 'The Barzan Towers, built in the late 19th century, were used as watchtowers to monitor the surrounding areas and for moon sighting to determine the beginning and end of Ramadan. They also protected nearby water sources.'
  }
];

// Helper function to shuffle quiz options (optional, for randomization)
export function shuffleOptions(question) {
  const options = [...question.options];
  const correctOption = options[question.correctAnswer];

  // Fisher-Yates shuffle
  for (let i = options.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [options[i], options[j]] = [options[j], options[i]];
  }

  // Find new index of correct answer
  const newCorrectAnswer = options.indexOf(correctOption);

  return {
    ...question,
    options,
    correctAnswer: newCorrectAnswer
  };
}

// Get a random subset of questions
export function getRandomQuestions(count = 5) {
  const shuffled = [...quizQuestions].sort(() => 0.5 - Math.random());
  return shuffled.slice(0, count);
}
