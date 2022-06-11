module.exports = {
    "env": {
        "browser": true,
        "commonjs": true,
        "es2021": true
    },
    "extends": [
        "eslint:recommended",
        "plugin:@typescript-eslint/recommended"
    ],
    "parser": "@typescript-eslint/parser",
    "parserOptions": {
        "ecmaVersion": 13
    },
    "plugins": [
        "@typescript-eslint"
    ],
    "rules": {
        'no-await-in-loop': 'off',
        '@typescript-eslint/no-var-requires': 'off',
        'max-len': [
            'error',
            {
                code: 120,
                ignoreUrls: true,
                ignoreStrings: true,
                // ignore single line return shorthands: //(x) => {id: x}
                ignorePattern: '^.*?(.*?).=>.(.*?).*$', // eslint-disable-line
            },
        ],
    }
};
