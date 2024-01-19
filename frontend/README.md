# Nuxt 3 Minimal Starter

Look at the [Nuxt 3 documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.


## Install commands

Requires to have installed npm (nodejs package manager)

```bash
npm --version
npm install --global yarn
yarn install
yarn add vuetify@next sass
yarn add @pinia/nuxt
yarn add @mdi/font
yarn dev
```

From then on, just run on cmd/bash:
```bash
yarn dev
```


## Setup

Make sure to install the dependencies:

```bash
# yarn
yarn install

# npm
npm install

# pnpm
pnpm install --shamefully-hoist
```

## Development Server

Start the development server on http://localhost:3000

```bash
npm run dev
```

## Production

Build the application for production:

```bash
npm run build
```

Locally preview production build:

```bash
npm run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.

## Serverless

Change nuxt config with CDN url (repeat below steps 2 times in case you are using a tmp URL for development).



```bash
yarn
#NITRO_PRESET=aws-lambda npm run build
npx nuxt build

sam validate
sam validate --lint

sam deploy
aws s3 sync .output/public/ s3://adri-test2-s3-sam \
  --cache-control max-age=31536000 --delete
```

## Vuetify


Vuetify has been installed here. You can check Vuetify examples here:
- Pages: https://vuetifyjs.com/en/getting-started/wireframes/#examples (click on the wireframe, and then on the bottom right corner button)
- Elements: https://vuetifyjs.com/en/components/toolbars/#background
- Colors: https://vuetifyjs.com/en/styles/colors/#material-colors

