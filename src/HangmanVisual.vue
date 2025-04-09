<template>
  <svg
    width="200"
    height="250"
    class="mx-auto my-4"
  >
    <!-- Gallows -->
    <line
      x1="10"
      y1="240"
      x2="190"
      y2="240"
      stroke="#444"
      stroke-width="4"
    />
    <line
      x1="50"
      y1="240"
      x2="50"
      y2="20"
      stroke="#444"
      stroke-width="4"
    />
    <line
      x1="50"
      y1="20"
      x2="140"
      y2="20"
      stroke="#444"
      stroke-width="4"
    />
    <line
      x1="140"
      y1="20"
      x2="140"
      y2="50"
      stroke="#444"
      stroke-width="4"
    />

    <!-- Head -->
    <circle
      v-if="wrongGuesses > 0"
      cx="140"
      cy="70"
      r="20"
      stroke="black"
      stroke-width="3"
      fill="none"
    />
    <!-- Body -->
    <line
      v-if="wrongGuesses > 1"
      x1="140"
      y1="90"
      x2="140"
      y2="150"
      stroke="black"
      stroke-width="3"
    />
    <!-- Arms -->
    <line
      v-if="wrongGuesses > 2"
      x1="140"
      y1="110"
      x2="120"
      y2="130"
      stroke="black"
      stroke-width="3"
    />
    <line
      v-if="wrongGuesses > 3"
      x1="140"
      y1="110"
      x2="160"
      y2="130"
      stroke="black"
      stroke-width="3"
    />
    <!-- Legs -->
    <line
      v-if="wrongGuesses > 4"
      x1="140"
      y1="150"
      x2="120"
      y2="180"
      stroke="black"
      stroke-width="3"
    />
    <line
      v-if="wrongGuesses > 5"
      x1="140"
      y1="150"
      x2="160"
      y2="180"
      stroke="black"
      stroke-width="3"
    />
  </svg>
</template>

<script setup>
defineProps({
  wrongGuesses: Number
});
</script>
