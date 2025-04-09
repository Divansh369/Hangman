<template>
  <div class="container">
    <h1 class="title">🪓 Hangman Game</h1>

    <div v-if="!gameStarted" class="menu">
      <label>
        <span>Mode:</span>
        <select v-model="mode">
          <option>1-Player</option>
          <option>2-Player</option>
        </select>
      </label>

      <div v-if="mode === '1-Player'">
        <label>
          <span>Choose Category:</span>
          <select v-model="category">
            <option>Months</option>
            <option>Weekdays</option>
            <option>Zodiac Signs</option>
          </select>
        </label>
      </div>

      <div v-else>
        <label>
          <span>Player 1: Enter Secret Word</span>
          <input v-model="customWord" type="password" placeholder="Secret word" />
        </label>
      </div>

      <button @click="startGame">Start Game</button>
    </div>

    <div v-else class="game-area">
      <HangmanVisual :wrong-guesses="wrongGuesses" />

      <p class="word-display">
        Word: <span>{{ displayWord }}</span>
      </p>

      <div v-if="!gameOver" class="guess-input">
        <input
          v-model="guess"
          maxlength="1"
          :disabled="gameOver"
          @keyup.enter="makeGuess"
        />
        <button :disabled="gameOver" @click="makeGuess">Guess</button>
      </div>

      <div class="keyboard" v-if="!gameOver">
        <button
          v-for="letter in alphabet"
          :key="letter"
          :disabled="guessedLetters.includes(letter)"
          @click="makeGuess(letter)"
        >
          {{ letter }}
        </button>
      </div>

      <p v-if="gameOver" class="game-result">
        <span v-if="didWin">🎉 You Won!</span>
        <span v-else>☠️ Game Over! The word was: <strong>{{ secretWord }}</strong></span>
      </p>

      <button class="restart-btn" @click="resetGame">Restart</button>
      <canvas v-show="showConfetti" ref="confettiCanvas" class="confetti"></canvas>
    </div>
  </div>
</template>

<script setup>
import HangmanVisual from './HangmanVisual.vue';
import confetti from 'canvas-confetti';
import { ref, computed, nextTick } from 'vue';

const mode = ref('1-Player');
const category = ref('Months');
const customWord = ref('');
const guess = ref('');
const secretWord = ref('');
const revealed = ref([]);
const wrongGuesses = ref(0);
const guessedLetters = ref([]);
const maxTries = 6;
const gameStarted = ref(false);
const gameOver = ref(false);
const showConfetti = ref(false);
const didWin = ref(false);
const confettiCanvas = ref(null);

const categories = {
  Months: ['january', 'february', 'march', 'april', 'may', 'june', 'july', 'august', 'september', 'october', 'november', 'december'],
  Weekdays: ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'],
  'Zodiac Signs': ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
};

const alphabet = 'abcdefghijklmnopqrstuvwxyz'.split('');

const startGame = () => {
  const word = mode.value === '2-Player'
    ? customWord.value.trim().toLowerCase()
    : categories[category.value][Math.floor(Math.random() * categories[category.value].length)];

  if (!word || word.length < 1) return;

  secretWord.value = word;
  revealed.value = Array(word.length).fill('');
  wrongGuesses.value = 0;
  gameStarted.value = true;
  gameOver.value = false;
  guessedLetters.value = [];
  showConfetti.value = false;
  guess.value = '';
  didWin.value = false;
};

const makeGuess = (letter = guess.value.toLowerCase()) => {
  if (!letter || guessedLetters.value.includes(letter) || gameOver.value) return;

  guessedLetters.value.push(letter);
  guess.value = '';

  let found = false;
  for (let i = 0; i < secretWord.value.length; i++) {
    if (secretWord.value[i] === letter && revealed.value[i] === '') {
      revealed.value[i] = letter;
      found = true;
    }
  }

  if (!found) wrongGuesses.value++;

  const won = !revealed.value.includes('');
  const lost = wrongGuesses.value >= maxTries;

  if (won || lost) {
    gameOver.value = true;
    revealed.value = secretWord.value.split('');
    didWin.value = won;
    if (won) triggerConfetti();
  }
};

const resetGame = () => {
  gameStarted.value = false;
  gameOver.value = false;
  customWord.value = '';
  revealed.value = [];
  showConfetti.value = false;
  didWin.value = false;
};

const triggerConfetti = async () => {
  showConfetti.value = true;
  await nextTick(); // Ensures the canvas is rendered
  const canvasEl = confettiCanvas.value;

  if (!canvasEl || !canvasEl.getContext) {
    console.error("❌ Canvas not ready or unsupported.");
    return;
  }

  const myConfetti = confetti.create(canvasEl, {
    resize: true,
    useWorker: true
  });

  myConfetti({
    particleCount: 200,
    spread: 120,
    origin: { x: 0.5, y: 0.5 }
  });
};

const displayWord = computed(() =>
  revealed.value.map(letter => (letter ? letter : '_')).join(' ')
);
</script>

<style scoped>
.container {
  min-height: 100vh;
  padding: 2rem;
  background-color: #f9fafb;
  color: #111827;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.title {
  font-size: 2rem;
  margin-bottom: 1rem;
}

.menu label, .menu select, .menu input {
  width: 100%;
  margin-bottom: 1rem;
  display: block;
  font-size: 1rem;
}

.menu select, .menu input {
  padding: 0.5rem;
  border-radius: 5px;
  border: 1px solid #ccc;
}

.menu button, .restart-btn {
  padding: 0.5rem 1rem;
  font-size: 1rem;
  background-color: #2563eb;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.game-area {
  text-align: center;
  max-width: 600px;
  margin-top: 2rem;
}

.word-display {
  font-size: 1.5rem;
  margin: 1rem 0;
  letter-spacing: 0.2em;
}

.guess-input input {
  width: 50px;
  text-align: center;
  font-size: 1.5rem;
  padding: 0.3rem;
}

.guess-input button {
  margin-left: 1rem;
  padding: 0.5rem 1rem;
  font-size: 1rem;
  background-color: #10b981;
  color: white;
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.keyboard {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(32px, 1fr));
  gap: 0.5rem;
  margin-top: 1rem;
}

.keyboard button {
  padding: 0.5rem;
  font-size: 1rem;
  border: 1px solid #ccc;
  border-radius: 4px;
  background-color: #e5e7eb;
  cursor: pointer;
}

.keyboard button:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.game-result {
  font-size: 1.5rem;
  margin-top: 1rem;
}

.confetti {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  pointer-events: none;
  z-index: 9999;
}
</style>