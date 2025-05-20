# SaurzCode Blog

A personal blog focused on Big Data, Spark, ML, and Data Engineering, built with Jekyll and deployed via Firebase Hosting.

## Prerequisites

- **macOS**
- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (2.5 or higher recommended)
- [Bundler](https://bundler.io/) (`gem install bundler`)
- [Jekyll](https://jekyllrb.com/docs/installation/) (`gem install jekyll`)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`)

## Setup

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd <repo-directory>
   ```
2. **Install Ruby dependencies:**
   ```sh
   bundle install
   ```

## Building the Site

To build the static site (output will be in the `_site` directory):

```sh
bundle exec jekyll build
```

## Local Development / Testing

To serve the site locally and preview changes:

```sh
bundle exec jekyll serve
```

- The site will be available at `http://localhost:4000` by default.
- Any changes you make will be auto-reloaded.

## Deployment (Firebase Hosting)

1. **Build the site:**
   ```sh
   bundle exec jekyll build
   ```
2. **Login to Firebase (first time only):**
   ```sh
   firebase login
   ```
3. **Deploy to Firebase Hosting:**
   ```sh
   firebase deploy
   ```

The `firebase.json` is already configured to serve the contents of the `_site` directory.

## Useful Commands

- `bundle exec jekyll build` — Build the site for production
- `bundle exec jekyll serve` — Serve locally with live reload
- `firebase deploy` — Deploy the built site to Firebase Hosting

---

For more details, see the [Jekyll documentation](https://jekyllrb.com/docs/) and [Firebase Hosting documentation](https://firebase.google.com/docs/hosting). 