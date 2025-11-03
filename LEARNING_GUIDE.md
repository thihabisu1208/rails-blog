# DevLog Learning Guide Index

**Welcome!** This is your complete learning resource for building a Rails blog in 2 weeks.

---

## 🚀 Getting Started

1. **First time?** Start here: [README.md](README.md)
2. **Read the full plan?** Continue below to understand the structure
3. **Ready to code?** Pick a day and jump in!

---

## 📚 Complete Learning Structure

### Week 1: Core Functionality

| Day     | Topic                                                  | What You'll Learn                                | Time      |
| ------- | ------------------------------------------------------ | ------------------------------------------------ | --------- |
| **1-2** | [Authentication Setup](week1/day1-2_auth.md)           | Sessions, password hashing, login flow           | 1-2 hours |
| **3-4** | [Models & Relationships](week1/day3-4_models.md)       | Many-to-many relationships, associations, scopes | 1-2 hours |
| **5**   | [Post CRUD](week1/day5_crud.md)                        | Rails controllers, forms, strong parameters      | 1-2 hours |
| **6-7** | [Public Pages & Landing](week1/day6-7_public_pages.md) | Query optimization, responsive design, security  | 1-2 hours |

**Week 1 Deliverable:** A working blog with auth, admin dashboard, and public-facing posts.

---

### Week 2: Polish & Features

| Day     | Topic                                                      | What You'll Learn                                 | Time      |
| ------- | ---------------------------------------------------------- | ------------------------------------------------- | --------- |
| **1-2** | [Social Sharing Meta Tags](week2/day1-2_social_sharing.md) | SEO, Open Graph, view helpers                     | 30 mins   |
| **3-4** | [Three.js Landing Hero](week2/day3-4_threejs.md)           | Three.js, Stimulus integration, WebGL, animations | 2-3 hours |
| **5**   | [Markdown & Syntax Highlighting](week2/day5_markdown.md)   | Redcarpet, Rouge, syntax highlighting             | 1 hour    |
| **6-7** | [Testing & Deployment](week2/day6-7_testing_deployment.md) | RSpec, Render deployment, production setup        | 1-2 hours |

**Week 2 Deliverable:** A fully featured, deployed blog with advanced features.

---

## 🎯 Learning Path by Topic

### If you want to understand...

**Authentication & Security**

- Start: [Day 1-2: Auth](week1/day1-2_auth.md)
- Then: [Day 6-7: Public vs. Admin](week1/day6-7_public_pages.md)

**Database Design**

- Start: [Day 3-4: Models](week1/day3-4_models.md)
- Then: Think about: "How would you add comments?"

**Rails Controller Patterns**

- Start: [Day 5: CRUD](week1/day5_crud.md)
- Then: [Day 1-2: Auth Controller](week1/day1-2_auth.md)

**JavaScript + Rails**

- Start: [Day 3-4: Three.js](week2/day3-4_threejs.md)
- Context: Uses Stimulus (already in Rails)

**Frontend Polish**

- Start: [Day 1-2: Meta Tags](week2/day1-2_social_sharing.md)
- Then: [Day 5: Markdown](week2/day5_markdown.md)

**Deployment & Production**

- Start: [Day 6-7: Testing & Deployment](week2/day6-7_testing_deployment.md)

---

## 💡 Key Concepts You'll Learn

### Rails Fundamentals

- ✅ MVC architecture (Models, Views, Controllers)
- ✅ RESTful routing
- ✅ Active Record (Rails ORM)
- ✅ Migrations and database design
- ✅ Associations (belongs_to, has_many, through)
- ✅ Validations and callbacks
- ✅ Scopes and query methods
- ✅ Strong parameters (security)
- ✅ View helpers

### Advanced Topics

- ✅ Session-based authentication
- ✅ Stimulus JS framework (already in Rails)
- ✅ Three.js integration
- ✅ Markdown rendering
- ✅ Syntax highlighting
- ✅ Testing with RSpec
- ✅ Production deployment

### Real-World Skills

- ✅ Security (password hashing, CSRF protection)
- ✅ SEO (meta tags, social sharing)
- ✅ Performance considerations (N+1 queries)
- ✅ Responsive design
- ✅ Error handling
- ✅ Environment configuration

---

## 📋 Daily Checklist

Copy this to track your progress:

```
Week 1:
- [ ] Day 1-2: Auth Setup
- [ ] Day 3-4: Models & Relationships
- [ ] Day 5: CRUD Operations
- [ ] Day 6-7: Public Pages

Week 2:
- [ ] Day 1-2: Social Sharing
- [ ] Day 3-4: Three.js Hero
- [ ] Day 5: Markdown & Highlighting
- [ ] Day 6-7: Testing & Deployment
```

---

## 🛠️ How to Use Each Day's Guide

**Before You Start:**

1. Read the "Core Concept" section (understand the "why")
2. Read through all the code (don't just copy-paste)
3. Make sure you understand each section before implementing

**While You Code:**

1. Follow steps in order
2. Test locally after each step (`rails s`)
3. If stuck, use Claude CLI to paste the error
4. Don't skip the "test your work" sections

**After You Finish:**

1. Check the "Recap" section
2. Verify all checkboxes pass
3. Reflect on what you learned
4. Move to the next day

---

## 🚨 Important Notes

### General

- **Always run tests** — After each day's major section, run `rails s` and verify locally
- **Read error messages** — Rails error messages are usually very helpful
- **Don't skip steps** — Each day builds on previous days
- **Ask Claude CLI** — When stuck, paste errors into Claude Code

### Security

- Never commit `.env` files with secrets
- Always use strong passwords
- Test authentication is working

### Performance

- Test locally before deploying
- Check browser console for JavaScript errors
- If slow, check Rails logs

---

## 📚 External Resources

While following this guide, you might want to reference:

- [Rails Guides](https://guides.rubyonrails.org) — Official documentation
- [Stimulus Handbook](https://stimulus.hotwired.dev) — Interactive JavaScript guide
- [Three.js Docs](https://threejs.org/docs) — 3D graphics reference
- [Redcarpet Docs](https://github.com/vmg/redcarpet) — Markdown parser
- [Rouge Docs](https://github.com/rouge-ruby/rouge) — Syntax highlighter

---

## 🤔 If You Get Stuck

**Common Solutions:**

1. **Reread the guide section** — You probably skipped something
2. **Check if `rails s` is running** — Start server in another terminal
3. **Verify migrations ran** — `rails db:migrate`
4. **Check database seeding** — `rails db:seed`
5. **Look at error in browser console** — Ctrl+Shift+J (Windows) or Cmd+Option+J (Mac)
6. **Paste error to Claude CLI** — Let Claude help debug

**If a test fails:**

- Reread the "Test Your Work" section
- Make sure you followed all steps
- Create user manually in `rails console`
- Check database is actually created: `ls db/`

---

## 🎉 Success Criteria

**After Week 1, you should have:**

- ✅ A working admin dashboard
- ✅ Ability to create, edit, delete posts
- ✅ Authentication system
- ✅ Multiple categories per post
- ✅ Public landing page showing featured posts
- ✅ View count tracking

**After Week 2, you should have:**

- ✅ Everything from Week 1
- ✅ Beautiful animated landing page (Three.js)
- ✅ Markdown-formatted blog posts
- ✅ Syntax highlighting for code
- ✅ Social sharing meta tags
- ✅ Live deployment on Render
- ✅ Basic test coverage

---

## 🚀 Next Steps After Week 2

Once you complete this guide:

1. **Build something new** — Apply what you learned
2. **Add features** — Comments, tags, search, email subscribers
3. **Study OAuth** — Use the learning module you created
4. **Explore AWS** — EC2, RDS, S3, Amplify
5. **Master testing** — Write more comprehensive tests
6. **Learn APIs** — Build JSON endpoints

Return to Claude Web when you're ready to learn any of these!

---

## 📞 Getting Help

**Use Claude Web for:**

- Conceptual questions
- Architecture decisions
- Reflection on what you learned
- Planning next steps

**Use Claude CLI for:**

- Debugging errors
- Code generation
- Code review
- Specific Rails syntax

---

## 👏 You're Ready!

Take a deep breath. You're about to learn Rails the right way—by building a real project.

**Start with [Day 1-2: Authentication Setup](week1/day1-2_auth.md)**

Good luck! 🚀

---

**Last updated:** 2024
**Target audience:** Experienced frontend engineers learning Rails
**Estimated time:** 14-20 hours total
