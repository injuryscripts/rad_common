const OFF = 0, WARN = 1, ERROR = 2;

module.exports = exports = {
  "env": {
    "es6": true
  },
  "ecmaFeatures": {
    "modules": true
  },
  "extends": "eslint:recommended",
  "rules": {
    'block-spacing': ERROR,
    'brace-style': ERROR,
    'camelcase': ERROR,
    'comma-spacing': ERROR,
    'comma-style': ERROR,
    'implicit-arrow-linebreak': ERROR,
    'indent': [ERROR, 2],
    'key-spacing': ERROR,
    'keyword-spacing': ERROR,
    'lines-between-class-members': [
      ERROR,
      'always',
      { 'exceptAfterSingleLine': true }
    ],
    'max-depth': ERROR,
    'max-len': [
      ERROR,
      {
        'ignorePattern': '^import|^export|function|class'
      }
    ],
    'max-lines': ERROR,
    'max-statements': ERROR,
    'max-statements-per-line': ERROR,
    'multiline-ternary': [ERROR, 'always-multiline'],
    'new-cap': [ ERROR, { 'capIsNewExceptions': [ 'A' ] } ],
    'new-parens': ERROR,
    'no-multiple-empty-lines': ERROR,
    'no-tabs': ERROR,
    'no-trailing-spaces': ERROR,
    'no-unneeded-ternary': ERROR,
    'no-whitespace-before-property': ERROR,
    'object-curly-spacing': [ERROR, 'always'],
    'object-property-newline': [
      ERROR,
      { 'allowAllPropertiesOnSameLine': true }
    ],
    'quotes': [ERROR, 'single', { avoidEscape: true }],
    'semi': WARN,
    'semi-spacing': ERROR,
    'semi-style': ERROR,
    'space-before-blocks': ERROR,
    'space-before-function-paren': [ERROR, 'never'],
    'space-in-parens': ERROR,
    'space-infix-ops': ERROR,
    'space-unary-ops': ERROR,
    'switch-colon-spacing': ERROR,

    'arrow-body-style': ERROR,
    'arrow-parens': [ERROR, 'as-needed'],
    'arrow-spacing': ERROR,
    'generator-star-spacing': OFF,
    'no-confusing-arrow': OFF,
    'no-useless-computed-key': ERROR,
    'no-useless-constructor': ERROR,
    'no-useless-rename': ERROR,
    'no-var': ERROR,
    'object-shorthand': ERROR,
    'prefer-arrow-callback': ERROR,
    'prefer-const': [ERROR, { destructuring: 'all' }],
    'prefer-destructuring': ERROR,
    'prefer-rest-params': OFF,
    'prefer-spread': ERROR,
    'prefer-template': ERROR,
    'rest-spread-spacing': ERROR,
    'template-curly-spacing': ERROR,
    'yield-star-spacing': ERROR,

    'accessor-pairs': ERROR,
    'array-callback-return': ERROR,
    'block-scoped-var': ERROR,
    'class-methods-use-this': OFF,
    'complexity': ERROR,
    'consistent-return': ERROR,
    'curly': ERROR,
    'default-case': ERROR,
    'dot-notation': ERROR,
    'no-caller': ERROR,
    'no-else-return': ERROR,
    'no-eval': ERROR,
    'no-extra-bind': ERROR,
    'no-floating-decimal': ERROR,
    'no-implied-eval': ERROR,
    'no-iterator': ERROR,
    'no-lone-blocks': ERROR,
    'no-multi-spaces': ERROR,
    'no-new-func': ERROR,
    'no-param-reassign': OFF,
    'no-proto': ERROR,
    'no-return-assign': ERROR,
    'no-return-await': ERROR,
    'no-script-url': ERROR,
    'no-self-compare': ERROR,
    'no-sequences': ERROR,
    'no-throw-literal': ERROR,
    'no-unused-expressions': ERROR,
    'no-unused-vars': [
      ERROR,
      {
        'varsIgnorePattern': '^_'
      }
    ],
    'no-useless-call': ERROR,
    'no-useless-concat': ERROR,
    'no-useless-return': ERROR,
    'require-await': WARN,
    'wrap-iife': ERROR,
    'vars-on-top': ERROR,
  },
  "parserOptions": {
    "sourceType": "module"
  }
};