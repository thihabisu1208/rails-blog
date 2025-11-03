# Week 2, Day 5: Markdown & Syntax Highlighting

**What you're learning:** Markdown rendering, syntax highlighting with Rouge, asset pipeline integration

**Why this matters:** Blog posts should support proper markdown formatting and code blocks with color-coded syntax. This makes technical content readable and professional.

---

## Core Concept: Markdown to HTML

Right now, posts are rendered as plain text (`simple_format` just converts line breaks).

**What we want:**

```markdown
# Heading

**bold text**
`inline code`
\`\`\`javascript
// Code block
const x = 1;
\`\`\`
```

**What we need:**

1. A markdown parser (Redcarpet)
2. A syntax highlighter (Rouge)
3. CSS to style the highlighted code

---

## Step 1: Add Gems

Edit `Gemfile`:

```ruby
gem 'redcarpet'  # Markdown parser
gem 'rouge'      # Syntax highlighter
```

Install:

```bash
bundle install
```

---

## Step 2: Create Markdown Renderer

Create `app/helpers/markdown_helper.rb`:

````ruby
module MarkdownHelper
  def render_markdown(content)
    return "" if content.blank?

    # Configure Redcarpet with markdown extensions
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML,
      extensions = {
        fenced_code_blocks: true,     # Allows ``` code blocks
        strikethrough: true,           # Allows ~~strikethrough~~
        tables: true,                  # Allows markdown tables
        highlight: true,               # Highlights code blocks
        autolink: true                 # Automatically linkifies URLs
      }
    )

    # Render markdown to HTML
    html = markdown.render(content)

    # Syntax highlight code blocks
    highlighted_html = Rouge::Formatters::HTML.new.format(
      Rouge::Lexers::HTML.lex(html)
    )

    highlighted_html.html_safe
  end
end
````

Wait, that's not quite right. Let me give you the better version:

```ruby
module MarkdownHelper
  def render_markdown(content)
    return "" if content.blank?

    renderer = MarkdownRenderer.new
    markdown = Redcarpet::Markdown.new(
      renderer,
      fenced_code_blocks: true,
      strikethrough: true,
      tables: true,
      autolink: true
    )

    markdown.render(content).html_safe
  end

  class MarkdownRenderer < Redcarpet::Render::HTML
    def block_code(code, language)
      # Syntax highlight the code block
      lexer = Rouge::Lexer.find_by_name(language) || Rouge::Lexers::PlainText
      formatter = Rouge::Formatters::HTML.new
      highlighted = formatter.format(lexer.lex(code))

      %(<pre><code class="language-#{language}">#{highlighted}</code></pre>)
    end
  end
end
```

**What's happening:**

```ruby
fenced_code_blocks: true
```

- Allows writing code blocks like this in markdown:

```
\`\`\`javascript
const x = 1;
\`\`\`
```

```ruby
class MarkdownRenderer < Redcarpet::Render::HTML
  def block_code(code, language)
```

- Intercepts code blocks
- Uses Rouge to highlight them based on language
- Wraps them in `<pre><code>` tags

```ruby
lexer = Rouge::Lexer.find_by_name(language)
```

- Finds the right lexer for the language (JavaScript, Python, Ruby, etc.)

---

## Step 3: Update Posts Helper

Edit `app/helpers/posts_helper.rb`:

```ruby
module PostsHelper
  include MarkdownHelper
end
```

This includes the markdown helper into the posts context.

---

## Step 4: Update Post Show View

Edit `app/views/posts/show.html.erb`:

```erb
<article class="container mx-auto py-12 max-w-2xl">
  <header class="mb-8">
    <h1 class="text-4xl font-bold mb-4"><%= @post.title %></h1>

    <div class="flex items-center justify-between text-gray-600 text-sm mb-4">
      <span><%= @post.created_at.strftime("%B %d, %Y") %></span>
      <span><%= @post.views_count %> views</span>
    </div>

    <% if @post.categories.any? %>
      <div class="flex gap-2 flex-wrap">
        <% @post.categories.each do |category| %>
          <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded text-sm">
            <%= category.name %>
          </span>
        <% end %>
      </div>
    <% end %>
  </header>

  <% if @post.featured_image_url.present? %>
    <img src="<%= @post.featured_image_url %>" alt="<%= @post.title %>" class="w-full rounded-lg mb-8 max-h-96 object-cover">
  <% end %>

  <!-- Render markdown with syntax highlighting -->
  <div class="prose prose-lg max-w-none">
    <%= render_markdown(@post.content) %>
  </div>

  <!-- Share buttons -->
  <div class="mt-8 pt-8 border-t">
    <p class="text-sm text-gray-600 mb-4">Share this post:</p>

    <div class="flex gap-4">
      <a
        href="https://twitter.com/intent/tweet?url=<%= request.url %>&text=<%= @post.title %>"
        target="_blank"
        rel="noopener noreferrer"
        class="text-blue-400 hover:text-blue-600"
      >
        Twitter
      </a>

      <a
        href="https://www.facebook.com/sharer/sharer.php?u=<%= request.url %>"
        target="_blank"
        rel="noopener noreferrer"
        class="text-blue-600 hover:text-blue-800"
      >
        Facebook
      </a>
    </div>
  </div>

  <div class="mt-8 text-center">
    <%= link_to "← Back to posts", root_path, class: "text-blue-600 hover:underline" %>
  </div>
</article>
```

**What changed:**

```erb
<%= render_markdown(@post.content) %>
```

- Instead of `simple_format`, we're using the markdown helper

---

## Step 5: Add Code Block Styling

Edit `app/assets/stylesheets/application.tailwind.css`:

```css
/* Markdown content styling */
.prose {
	@apply max-w-none;
}

.prose h2 {
	@apply text-2xl font-bold mt-8 mb-4;
}

.prose h3 {
	@apply text-xl font-bold mt-6 mb-3;
}

.prose p {
	@apply mb-4 leading-relaxed;
}

.prose ul,
.prose ol {
	@apply mb-4 ml-6;
}

.prose li {
	@apply mb-2;
}

.prose a {
	@apply text-blue-600 hover:text-blue-800 underline;
}

/* Code block styling */
.prose pre {
	@apply bg-gray-900 text-gray-100 p-4 rounded-lg overflow-x-auto my-4 border border-gray-800;
}

.prose code {
	@apply font-mono text-sm;
}

.prose code.language-javascript,
.prose code.language-ruby,
.prose code.language-python,
.prose code.language-html,
.prose code.language-css {
	@apply bg-gray-100 px-2 py-1 rounded text-red-600 font-mono text-sm;
}

/* Rouge syntax highlighting classes */
.highlight .n {
	@apply text-gray-300;
} /* Name */
.highlight .s {
	@apply text-green-300;
} /* String */
.highlight .nb {
	@apply text-blue-300;
} /* Built-in */
.highlight .k {
	@apply text-pink-300;
} /* Keyword */
.highlight .kd {
	@apply text-pink-300;
} /* Keyword Declaration */
.highlight .c {
	@apply text-gray-500;
} /* Comment */
.highlight .m {
	@apply text-yellow-300;
} /* Number */
.highlight .o {
	@apply text-gray-400;
} /* Operator */
```

---

## Step 6: Test Markdown Rendering

Create a test post with markdown:

**Title:** "Testing Markdown"

**Content:**

```
# This is a Heading

This is a paragraph with **bold text** and *italic text*.

You can also use `inline code` like this.

## Code Example

Here's some JavaScript:

\`\`\`javascript
const greeting = "Hello, DevLog!";
console.log(greeting);
\`\`\`

And here's some Ruby:

\`\`\`ruby
def greet(name)
  puts "Hello, #{name}!"
end

greet("DevLog")
\`\`\`

## Lists

- Item one
- Item two
- Item three

1. First
2. Second
3. Third

> This is a blockquote
```

**Publish and view the post.** You should see:

- Proper heading styling
- Bold and italic text
- Inline code with background
- Code blocks with syntax highlighting (colors!)
- Lists formatted properly

---

## Step 7: Try Different Languages

Test code blocks in different languages:

```html
\`\`\`html
<div class="container">
	<h1>Hello</h1>
</div>
\`\`\`
```

```css
\`\`\`css
.container {
  display: flex;
  justify-content: center;
}
\`\`\`
```

```python
\`\`\`python
def hello_world():
    print("Hello, World!")

hello_world()
\`\`\`
```

All should highlight with language-appropriate colors!

---

## Optional: Add Copy Button to Code Blocks

If you want a "copy to clipboard" button, add to `app/assets/stylesheets/application.tailwind.css`:

```css
.prose pre {
	@apply relative;
}

.prose pre::before {
	content: "Copy";
	@apply absolute top-2 right-2 bg-gray-700 text-gray-200 px-2 py-1 rounded text-xs cursor-pointer hover:bg-gray-600;
}
```

---

## Recap: What You Learned

- ✅ Markdown parsing with Redcarpet
- ✅ Syntax highlighting with Rouge
- ✅ Custom Redcarpet renderer
- ✅ CSS for code block styling
- ✅ Lexer selection by language

---

## Common Pitfalls

1. **"Code blocks not highlighting"** — Make sure `bundle install` ran successfully
2. **"Language-specific colors not showing"** — Did you add the Rouge CSS classes?
3. **"Markdown not rendering"** — Check helper is included and method is called
4. **"Strange characters in output"** — Make sure to use `.html_safe` at the end

---

## Next: Day 6-7 - Testing & Deployment

Move on to `day6-7_testing_deployment.md` for the final push!
