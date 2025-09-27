# SaurzCode Blog

A personal blog focused on Big Data, Spark, ML, and Data Engineering, built with Jekyll and deployed to both GitHub Pages and Firebase Hosting.

## Prerequisites

- **macOS**
- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (2.5 or higher recommended)
- [Bundler](https://bundler.io/) (`gem install bundler`)
- [Jekyll](https://jekyllrb.com/docs/installation/) (`gem install jekyll`)
- [Git](https://git-scm.com/downloads) (for version control and deployment)
- [Firebase CLI](https://firebase.google.com/docs/cli) (`npm install -g firebase-tools`) - for Firebase deployment

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

## Deployment

This blog is deployed to **both GitHub Pages and Firebase Hosting** using automated GitHub Actions workflows.

### GitHub Pages Deployment

#### Automatic Deployment via GitHub Actions
This repository includes a GitHub Actions workflow (`.github/workflows/jekyll.yml`) that automatically builds and deploys your Jekyll site to GitHub Pages.

**How it works:**
1. **Push to the `main` branch:**
   ```sh
   git add .
   git commit -m "Update blog"
   git push origin main
   ```
2. **GitHub Actions automatically:**
   - Sets up Ruby 3.1 environment
   - Installs dependencies with Bundler
   - Builds the Jekyll site
   - Deploys to GitHub Pages

**Workflow triggers:**
- Push to `main` branch
- Manual trigger from GitHub Actions tab

**View deployment status:**
- Go to the "Actions" tab in your GitHub repository
- Monitor the "Deploy Jekyll site to Pages" workflow

### Firebase Hosting Deployment

#### Automatic Deployment via Firebase Actions
The repository also includes Firebase Hosting workflows that deploy to [https://saurzcode-blog-428f1.web.app/](https://saurzcode-blog-428f1.web.app/):

- **`.github/workflows/firebase-hosting-merge.yml`** - Deploys to Firebase on merge to main
- **`.github/workflows/firebase-hosting-pull-request.yml`** - Creates preview deployments for pull requests

**How it works:**
1. **Push to the `main` branch:**
   ```sh
   git add .
   git commit -m "Update blog"
   git push origin main
   ```
2. **Firebase Actions automatically:**
   - Sets up Ruby 3.1 environment
   - Installs dependencies with Bundler
   - Builds the Jekyll site
   - Deploys to Firebase Hosting

**Manual Firebase deployment:**
```sh
bundle exec jekyll build
firebase deploy
```

### Manual Deployment (Alternative)
1. **Build the site:**
   ```sh
   bundle exec jekyll build
   ```
2. **Deploy to GitHub Pages:**
   ```sh
   git subtree push --prefix _site origin gh-pages
   ```
3. **Deploy to Firebase:**
   ```sh
   firebase deploy
   ```

**Live sites:**
- GitHub Pages: `https://saurzcode.github.io` (or your custom domain if configured)
- Firebase Hosting: [https://saurzcode-blog-428f1.web.app/](https://saurzcode-blog-428f1.web.app/)

## Useful Commands

- `bundle exec jekyll build` — Build the site for production
- `bundle exec jekyll serve` — Serve locally with live reload
- `git push origin main` — Deploy to both GitHub Pages and Firebase (automatic)
- `firebase deploy` — Manual deployment to Firebase Hosting
- `git subtree push --prefix _site origin gh-pages` — Manual deployment to GitHub Pages

---

For more details, see the [Jekyll documentation](https://jekyllrb.com/docs/), [GitHub Pages documentation](https://docs.github.com/en/pages), and [Firebase Hosting documentation](https://firebase.google.com/docs/hosting). 