module.exports = {
  root: true,
  env: {
    node: true,
  },
  extends: [
    'plugin:vue/vue3-recommended',  // 👈 key part!
    'eslint:recommended',
  ],
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'module'
  },
  rules: {
    'vue/no-undef-components': 'off',
    'no-undef': 'off', // 👈 stops yelling about defineProps/defineEmits
  }
}
