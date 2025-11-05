Stimulus is a lightweight JavaScript framework designed to enhance server-rendered HTML with dynamic behavior. It's a key part of the Hotwire stack, which favors sending HTML over the wire instead of JSON, allowing you to build modern, interactive applications with less custom JavaScript.

### Key Concepts

Stimulus is built around three core concepts:

1.  **Controllers:** JavaScript classes that act as the "brain" for a section of your HTML. You connect a controller to an HTML element using the
    `data-controller="controller-name"` attribute. The element and all its children become the scope of the controller.

2.  **Actions:** Methods within a controller that are triggered by DOM events (like clicks, form submissions, etc.). You define an action with
    `data-action="event->controller-name#methodName"`. For example, `data-action="click->clipboard#copy"` will call the `copy` method on the `clipboard`
    controller when the element is clicked.

3.  **Targets:** Specific elements within a controller's scope that the controller needs to interact with. You define a target with
    `data-controller-name-target="targetName"`. For instance, in a `clipboard` controller, you might have `<input data-clipboard-target="source">`. The
    controller can then access this element via `this.sourceTarget`.

### How to Use Stimulus with Ruby on Rails

In modern Rails applications (7+), Stimulus is the default and is seamlessly integrated using **Importmaps**.

1.  **Installation:** New Rails 7 apps include `stimulus-rails` by default. If you're adding it to an existing app, add `gem "stimulus-rails"` to your
    `Gemfile` and run `bundle install`, followed by `bin/rails stimulus:install`.

2.  **Generating Controllers:** You can create a new Stimulus controller using a Rails generator:

    ```shell
    bin/rails generate stimulus clipboard
    ```

    This will create `app/javascript/controllers/clipboard_controller.js` and automatically register it.

3.  **Controller Structure:** A typical controller looks like this:

    ```javascript
    // app/javascript/controllers/clipboard_controller.js
    import { Controller } from "@hotwired/stimulus";

    export default class extends Controller {
    	// ... controller logic ...
    }
    ```

### Practical Examples

#### Example 1: Simple Toggle

This example shows how to toggle a CSS class to show/hide an element.

**HTML (e.g., in a `*.html.erb` file):**

```html
<div data-controller="toggle">
	<button data-action="toggle#toggle">Menu</button>

	<div data-toggle-target="togglableElement" class="hidden">
		<p>Content to be shown or hidden.</p>
	</div>
</div>
```

**JavaScript (`app/javascript/controllers/toggle_controller.js`):**

```javascript
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["togglableElement"];

	toggle() {
		this.togglableElement.classList.toggle("hidden");
	}
}
```

_(You would need a CSS class named `hidden` like `.hidden { display: none; }`)_

#### Example 2: Clipboard Copy

This example copies text from an input field to the clipboard.

**HTML:**

```html
<div data-controller="clipboard">
	<input data-clipboard-target="source" type="text" value="Hello, Stimulus!" />
	<button data-action="clipboard#copy">Copy</button>
</div>
```

**JavaScript (`app/javascript/controllers/clipboard_controller.js`):**

```javascript
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
	static targets = ["source"];

	copy() {
		navigator.clipboard.writeText(this.sourceTarget.value);
		alert("Copied to clipboard!");
	}
}
```

### Best Practices for 2025

1.  **Embrace Importmaps:** For most Rails projects, stick with the default importmap setup. It simplifies dependency management and avoids the
    complexity of JavaScript bundling tools like Webpack or esbuild.

2.  **Keep Controllers Focused:** Design controllers to handle a single responsibility (e.g., a `clipboard-controller`, a `slideshow-controller`, a
    `search-form-controller`). This makes them more reusable and easier to maintain.

3.  **Use Values for Configuration:** Pass data from your Rails views (ERB) to your controllers using Stimulus Values. This is the idiomatic way to
    make your controllers configurable.

        **HTML with a Value:**
        ```html
        <div data-controller="slideshow" data-slideshow-index-value="1">
          ...
        </div>
        ```

        **Controller with a Value:**
        ```javascript
        import { Controller } from "@hotwired/stimulus"

        export default class extends Controller {
          static values = { index: Number }

          connect() {
            // Access the value with this.indexValue
            console.log(this.indexValue); // Outputs: 1
          }
        }
        ```

4.  **Leverage Lifecycle Callbacks:** Use the `connect()` and `disconnect()` lifecycle methods to set up and tear down state. `connect()` runs when
    the controller is attached to the DOM, and `disconnect()` runs when it's removed.

5.  **Combine with Turbo:** Stimulus is designed to work with Turbo. Use Turbo for page navigation and form submissions, and use Stimulus to add
    small, client-side interactions that Turbo doesn't cover (like dropdowns, modals, or real-time input validation).

### Key findings:

- Stimulus = lightweight JS framework for server-rendered HTML
- Part of Hotwire stack (HTML over the wire)
- 3 core concepts: Controllers, Actions, Targets
- Default in Rails 7+, uses Importmaps
- Generate with: bin/rails generate stimulus <name>

### 2025 Best Practices:

1. Use Importmaps (default Rails setup)
2. Keep controllers focused (single responsibility)
3. Use Stimulus Values for configuration
4. Leverage lifecycle callbacks (connect/disconnect)
5. Combine with Turbo for navigation
