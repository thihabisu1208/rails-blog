# DevLog: 2-Week Rails Learning Sprint

**Your Goal:** Build a production-ready tech blog with session auth, multiple categories, view tracking, and an interactive 3D landing page.

**Stack:** Rails 8 + Stimulus + Three.js + PostgreSQL

**Timeline:** 2 weeks part-time (30 mins - 1 hour daily)

**Deployment:** Render (~$7/month after free tier)

---

## Quick Start

### 1. Setup Your Machine

```bash
# Check you have the right versions
ruby --version        # Should be 3.2+
rails --version       # Should be 8.0+
psql --version        # PostgreSQL (for local dev)
node --version        # Should be 18+
```

If Rails isn't installed:

```bash
gem install rails
```

### 2. Create Your Rails App

```bash
# Navigate to your project directory
cd /Users/thihahn/Work/rails/blog

# Create a new Rails 8 app
rails new . --database=postgresql --css=tailwind --skip-bundle

# Install dependencies
bundle install

# Create the database
rails db:create
```

### 3. You're Ready to Start!

Pick a day below and start coding. Each day has its own markdown file in `docs/`.

---

## 📋 Daily Checklist

### Week 1: Core Functionality

- [ ] **Day 1-2:** Session Auth Setup (`docs/week1/day1-2_auth.md`)
- [ ] **Day 3-4:** Posts & Categories Models (`docs/week1/day3-4_models.md`)
- [ ] **Day 5:** Post CRUD Operations (`docs/week1/day5_crud.md`)
- [ ] **Day 6-7:** Public Pages & Landing (`docs/week1/day6-7_public_pages.md`)

### Week 2: Polish & Features

- [ ] **Day 1-2:** Social Sharing Meta Tags (`docs/week2/day1-2_social_sharing.md`)
- [ ] **Day 3-4:** Three.js Landing Hero (`docs/week2/day3-4_threejs.md`)
- [ ] **Day 5:** Markdown & Syntax Highlighting (`docs/week2/day5_markdown.md`)
- [ ] **Day 6-7:** Testing & Deployment (`docs/week2/day6-7_testing_deployment.md`)

---

## 🛠️ Key Commands

```bash
# Start the server
rails s

# Generate scaffolding
rails generate model Post title:string

# Run migrations
rails db:migrate

# Seed data
rails db:seed

# Console
rails console

# Tests
bundle exec rspec
```

---

## Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [Stimulus Handbook](https://stimulus.hotwired.dev)
- [Three.js Docs](https://threejs.org/docs)
- [Render Deployment](https://render.com)
