# Week 2, Day 6-7: Testing & Deployment

**What you're learning:** Testing with RSpec, environment configuration, Render deployment, production considerations

**Why this matters:** This is where your app becomes real. Testing ensures it works. Deployment makes it available to the world.

---

## Part 1: Basic Testing

### Core Concept: Why Test?

Testing is your safety net. When you add features later, tests verify you didn't break existing functionality.

**Types of tests:**

- **Unit tests** — Test individual models/methods
- **Integration tests** — Test how parts work together
- **Feature tests** — Test user interactions (usually overkill for small projects)

For a blog, we'll do simple unit tests on models.

---

## Step 1: Add RSpec

Edit `Gemfile`:

```ruby
group :development, :test do
  gem 'rspec-rails'
end
```

Install:

```bash
bundle install
rails generate rspec:install
```

This creates:

- `spec/` directory for tests
- `.rspec` configuration file

---

## Step 2: Write Model Tests

Create `spec/models/post_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  # Create a user and post for testing
  let(:user) { User.create!(email: "test@example.com", password: "password") }
  let(:post) { Post.create!(title: "Test Post", content: "Content", user: user) }

  describe "associations" do
    it "belongs to a user" do
      expect(post.user).to eq(user)
    end

    it "has many categories" do
      category = Category.create!(name: "Test")
      post.categories << category
      expect(post.categories).to include(category)
    end
  end

  describe "validations" do
    it "requires a title" do
      post.title = nil
      expect(post).not_to be_valid
    end

    it "requires content" do
      post.content = nil
      expect(post).not_to be_valid
    end
  end

  describe "slug generation" do
    it "generates a slug from the title" do
      post = Post.create!(title: "My First Post", content: "Content", user: user)
      expect(post.slug).to eq("my-first-post")
    end

    it "handles multi-word titles" do
      post = Post.create!(title: "Rails is Awesome", content: "Content", user: user)
      expect(post.slug).to eq("rails-is-awesome")
    end
  end

  describe "view tracking" do
    it "increments view count" do
      expect { post.increment!(:views_count) }.to change { post.views_count }.by(1)
    end
  end

  describe "scopes" do
    it "filters published posts" do
      published_post = Post.create!(title: "Published", content: "Content", user: user, is_published: true)
      draft_post = Post.create!(title: "Draft", content: "Content", user: user, is_published: false)

      expect(Post.published).to include(published_post)
      expect(Post.published).not_to include(draft_post)
    end

    it "orders by views descending" do
      post1 = Post.create!(title: "Post 1", content: "Content", user: user, views_count: 10)
      post2 = Post.create!(title: "Post 2", content: "Content", user: user, views_count: 50)
      post3 = Post.create!(title: "Post 3", content: "Content", user: user, views_count: 30)

      expect(Post.by_views.first).to eq(post2)
      expect(Post.by_views.last).to eq(post1)
    end
  end
end
```

Create `spec/models/user_spec.rb`:

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "requires an email" do
      user = User.new(password: "password")
      expect(user).not_to be_valid
    end

    it "requires unique emails" do
      User.create!(email: "test@example.com", password: "password")
      user2 = User.new(email: "test@example.com", password: "password")
      expect(user2).not_to be_valid
    end
  end

  describe "password" do
    it "authenticates with correct password" do
      user = User.create!(email: "test@example.com", password: "secret123")
      expect(user.authenticate("secret123")).to eq(user)
    end

    it "rejects incorrect password" do
      user = User.create!(email: "test@example.com", password: "secret123")
      expect(user.authenticate("wrongpassword")).to be_falsey
    end
  end

  describe "associations" do
    it "has many posts" do
      user = User.create!(email: "test@example.com", password: "password")
      post = user.posts.create!(title: "Test", content: "Content")

      expect(user.posts).to include(post)
    end
  end
end
```

---

## Step 3: Run Tests

```bash
bundle exec rspec
```

You should see:

```
Post
  associations
    ✓ belongs to a user
    ✓ has many categories
  validations
    ✓ requires a title
    ✓ requires content
  slug generation
    ✓ generates a slug from the title
    ✓ handles multi-word titles
  view tracking
    ✓ increments view count
  scopes
    ✓ filters published posts
    ✓ orders by views descending

User
  validations
    ...
```

All tests passing? Great! Move to deployment.

---

## Part 2: Deployment to Render

### Why Render?

- Free tier for testing
- Simple Rails integration
- PostgreSQL included
- ~$7/month for production

---

## Step 1: Prepare for Deployment

### Set Up Environment Variables

Create `.env.production` (don't commit this):

```
DATABASE_URL=postgresql://...  # Render provides this
SECRET_KEY_BASE=your_secret_here
RAILS_ENV=production
```

Generate a secret:

```bash
rails secret
```

Copy the output to `SECRET_KEY_BASE` in `.env.production`.

### Update Gemfile for Production

Rails needs some extra gems in production:

```ruby
# At the end of Gemfile
group :production do
  gem 'pg'  # PostgreSQL
end
```

Run:

```bash
bundle install
```

---

## Step 2: Prepare Git Repository

Initialize if you haven't:

```bash
cd /Users/thihahn/Work/rails/blog
git init
git add .
git commit -m "Initial commit"
```

Create `.gitignore` (if not exists) to exclude sensitive files:

```
.env.production
.env.local
.env.*.local
```

---

## Step 3: Push to GitHub

1. Go to https://github.com/new
2. Create a new repository (name it `devlog`)
3. Don't initialize with README (you have files)
4. Follow the "push an existing repository" instructions:

```bash
git remote add origin https://github.com/YOUR_USERNAME/devlog.git
git branch -M main
git push -u origin main
```

---

## Step 4: Deploy to Render

1. Go to https://render.com
2. Sign up (use GitHub account)
3. Click "New +" → "Web Service"
4. Connect GitHub repo (`devlog`)
5. Configure:

| Setting           | Value                                |
| ----------------- | ------------------------------------ |
| **Name**          | devlog                               |
| **Environment**   | Ruby                                 |
| **Region**        | Choose closest to you                |
| **Build Command** | `bundle install && rails db:migrate` |
| **Start Command** | `bundle exec rails s -b 0.0.0.0`     |

6. Click "Create Web Service"

Render will:

- Pull your code
- Install gems
- Run migrations
- Start the server

---

## Step 5: Add Environment Variables

After service is created:

1. Go to the service settings
2. Click "Environment"
3. Add these variables:

```
SECRET_KEY_BASE=<value from rails secret>
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
```

Render automatically provides `DATABASE_URL`.

---

## Step 6: View Logs

Click "Logs" to watch deployment:

```
$ bundle install
...
$ rails db:migrate
...
$ bundle exec rails s -b 0.0.0.0
* Puma starting in cluster mode...
* Listening on tcp://0.0.0.0:3000
```

Once you see "Listening on", your app is live!

---

## Step 7: Test the Live Site

1. Note your Render URL (like `devlog-xyz.onrender.com`)
2. Visit it in browser
3. Should see your landing page with 3D hero!

---

## Step 8: Add a Custom Domain (Optional)

1. Buy domain from Namecheap (~$10/year)
2. In Render, go to "Custom Domains"
3. Add your domain
4. Update nameservers in Namecheap to Render's

---

## Step 9: Deploy Updates

Whenever you make changes:

```bash
git add .
git commit -m "Add feature X"
git push origin main
```

Render automatically redeploys! (takes ~2 min)

---

## Troubleshooting Deployment

### "Build failed"

- Check logs in Render dashboard
- Common issues: missing gems, database migrations

### "Application Error"

- Check logs: `tail -f app.log`
- Often: missing environment variables

### "500 Error"

- Check Render logs
- Might be database connection issue

---

## Security Checklist Before Going Public

- [ ] Set strong `SECRET_KEY_BASE`
- [ ] Use HTTPS (Render provides free SSL)
- [ ] Never commit `.env` files
- [ ] Disable Rails error pages in production (`config/environments/production.rb`: `config.consider_all_requests_local = false`)
- [ ] Set secure cookies (`config.secure_cookies = true`)
- [ ] Add rate limiting for login attempts (optional, but good practice)

---

## What's Next After Deployment?

1. **Monitor** — Check logs occasionally
2. **Backup** — Export database regularly
3. **Scale** — If traffic grows, upgrade Render plan
4. **Add features** — Comments, email newsletters, etc.
5. **Learn AWS** — Render is great for starting; AWS for serious projects

---

## Recap: What You Learned

- ✅ Writing RSpec tests
- ✅ Test-driven thinking
- ✅ Environment configuration
- ✅ Git & GitHub workflow
- ✅ Render deployment
- ✅ Production considerations

---

## Congratulations! 🎉

You've built and deployed a full Rails blog from scratch!

**Your blog now has:**

- ✅ Secure authentication
- ✅ Admin dashboard
- ✅ Post management
- ✅ Multiple categories
- ✅ View tracking
- ✅ Social sharing
- ✅ Interactive 3D landing page
- ✅ Markdown support
- ✅ Syntax highlighting
- ✅ Live on the internet!

---

## What's Next?

Now that you understand Rails basics:

1. **Add Comments** — A next feature to build
2. **Learn OAuth** — Implement the learning module you created
3. **Explore AWS** — Real-world hosting (EC2, RDS, Amplify)
4. **Study Background Jobs** — Sidekiq for async tasks
5. **Master Testing** — Unit, integration, system tests
6. **Learn APIs** — Build JSON APIs with Rails

Come back to Claude Web when you're ready for any of these!

---

## Resources

- [Rails Guides](https://guides.rubyonrails.org)
- [RSpec Documentation](https://rspec.info)
- [Render Docs](https://render.com/docs)
- [Deploy Rails with Render](https://render.com/docs/deploy-rails)

---

**Enjoy your deployed DevLog! 🚀**
