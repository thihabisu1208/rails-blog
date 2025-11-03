# Week 2, Day 3-4: Three.js Landing Hero with Stimulus

**What you're learning:** Three.js fundamentals, Stimulus + Three.js integration, WebGL rendering, responsive canvas

**Why this matters:** This is where you combine your JavaScript + Rails knowledge. You'll build something visually impressive that also teaches you about integrating complex libraries into Rails.

---

## Core Concept: Three.js in a Rails App

Three.js is a 3D graphics library. It abstracts WebGL (low-level 3D graphics) into something manageable.

**The flow:**

1. HTML has a `<canvas>` element
2. Stimulus controller initializes on page load
3. Three.js takes over the canvas
4. Renders a 3D scene (particles, cubes, etc.)
5. Animation loop updates every frame (60fps)

**Why use Stimulus?** Because Stimulus is already in Rails and handles lifecycle cleanly (connect = initialize, disconnect = cleanup).

---

## Step 1: Add Three.js to Importmap

Rails 8 uses Importmap for JavaScript modules (no build step needed).

Edit `config/importmap.rb`:

```ruby
pin "three", to: "https://cdn.jsdelivr.net/npm/three@r128/build/three.min.js"
```

This imports Three.js from a CDN. `r128` is a specific version—stick with this.

---

## Step 2: Create Stimulus Controller for 3D

Create `app/javascript/controllers/three_hero_controller.js`:

```javascript
import { Controller } from "@hotwired/stimulus";
import * as THREE from "three";

export default class extends Controller {
	connect() {
		// Called when the controller connects to an element in the DOM
		console.log("Three.js hero initializing...");

		this.initScene();
		this.createGeometry();
		this.startAnimation();

		// Handle window resize
		window.addEventListener("resize", () => this.handleResize());
	}

	disconnect() {
		// Called when the controller element is removed from DOM
		window.removeEventListener("resize", () => this.handleResize());
		this.renderer.dispose();
		// Clean up Three.js resources to prevent memory leaks
	}

	initScene() {
		// Get canvas dimensions
		const canvas = this.element.querySelector("canvas");
		const width = this.element.clientWidth;
		const height = this.element.clientHeight;

		// Create scene (container for all 3D objects)
		this.scene = new THREE.Scene();
		this.scene.background = new THREE.Color(0x111827); // Dark gray

		// Create camera (viewer perspective)
		this.camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
		this.camera.position.z = 5;

		// Create renderer (draws to canvas)
		this.renderer = new THREE.WebGLRenderer({
			canvas: canvas,
			antialias: true,
			alpha: false,
		});
		this.renderer.setSize(width, height);
		this.renderer.setPixelRatio(window.devicePixelRatio); // Sharp on retina displays

		// Store dimensions for later
		this.width = width;
		this.height = height;
	}

	createGeometry() {
		// Create 5 animated cubes
		this.objects = [];

		for (let i = 0; i < 5; i++) {
			// Create cube geometry and material
			const geometry = new THREE.BoxGeometry(1, 1, 1);
			const material = new THREE.MeshPhongMaterial({
				color: 0x3b82f6, // Blue
				emissive: 0x1e40af, // Darker blue glow
				shininess: 100,
			});

			// Create mesh (geometry + material)
			const mesh = new THREE.Mesh(geometry, material);

			// Random position
			mesh.position.set(
				(Math.random() - 0.5) * 10,
				(Math.random() - 0.5) * 10,
				(Math.random() - 0.5) * 10
			);

			// Random initial rotation
			mesh.rotation.set(Math.random(), Math.random(), Math.random());

			// Random rotation speeds
			const rotationSpeed = {
				x: (Math.random() - 0.5) * 0.01,
				y: (Math.random() - 0.5) * 0.01,
				z: (Math.random() - 0.5) * 0.01,
			};

			this.scene.add(mesh);
			this.objects.push({ mesh, rotationSpeed });
		}

		// Add lighting
		// PointLight: radiates from a point, like a lightbulb
		const pointLight = new THREE.PointLight(0xffffff, 1, 100);
		pointLight.position.set(5, 5, 5);
		this.scene.add(pointLight);

		// AmbientLight: illuminates everything equally, like daylight
		const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
		this.scene.add(ambientLight);
	}

	startAnimation() {
		// RequestAnimationFrame: calls this function every frame (~60fps)
		this.animate();
	}

	animate() {
		// Rotate each cube
		this.objects.forEach(({ mesh, rotationSpeed }) => {
			mesh.rotation.x += rotationSpeed.x;
			mesh.rotation.y += rotationSpeed.y;
			mesh.rotation.z += rotationSpeed.z;
		});

		// Render the scene
		this.renderer.render(this.scene, this.camera);

		// Request next frame
		requestAnimationFrame(() => this.animate());
	}

	handleResize() {
		// Adjust canvas when window resizes
		const width = this.element.clientWidth;
		const height = this.element.clientHeight;

		this.camera.aspect = width / height;
		this.camera.updateProjectionMatrix();
		this.renderer.setSize(width, height);
	}
}
```

**Breaking this down:**

```javascript
connect() {
  this.initScene()
  this.createGeometry()
  this.startAnimation()
}
```

- Stimulus calls `connect()` when the element appears in the DOM
- This is where we initialize everything

```javascript
this.scene = new THREE.Scene();
this.camera = new THREE.PerspectiveCamera(75, width / height, 0.1, 1000);
this.renderer = new THREE.WebGLRenderer({ canvas: canvas });
```

- Scene = 3D container
- Camera = virtual viewer (perspective camera = realistic depth)
- Renderer = draws to canvas

```javascript
requestAnimationFrame(() => this.animate());
```

- Calls `animate()` ~60 times per second
- Each time, rotates cubes and re-renders

```javascript
disconnect() {
  this.renderer.dispose()
}
```

- Cleanup when element leaves DOM
- Prevents memory leaks

---

## Step 3: Update Landing Page with Three.js

Edit `app/views/pages/landing.html.erb`:

```erb
<div class="min-h-screen bg-gradient-to-b from-gray-900 to-gray-800 text-white flex flex-col">
  <!-- Three.js Hero Section -->
  <section
    data-controller="three-hero"
    class="relative flex-1 overflow-hidden"
  >
    <!-- Canvas for Three.js -->
    <canvas id="three-canvas" class="absolute inset-0 w-full h-full"></canvas>

    <!-- Hero Content (overlay on top of canvas) -->
    <div class="relative z-10 h-full flex flex-col items-center justify-center text-center px-4">
      <h1 class="text-5xl md:text-7xl font-bold mb-4 animate-fade-in">
        DevLog
      </h1>
      <p class="text-xl md:text-2xl text-gray-300 mb-8 animate-fade-in-delay">
        Exploring tech, design, and interactive experiences
      </p>
      <a href="#posts" class="inline-block bg-blue-600 hover:bg-blue-700 transition px-8 py-3 rounded-lg font-medium animate-fade-in-delay-2">
        Read Articles
      </a>
    </div>
  </section>

  <!-- Featured Posts Section -->
  <section id="posts" class="bg-white text-gray-900 py-16">
    <div class="container mx-auto px-4">
      <h2 class="text-3xl md:text-4xl font-bold mb-12">Latest Articles</h2>

      <% if @featured_posts.any? %>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <% @featured_posts.each do |post| %>
            <%= render "post_card", post: post %>
          <% end %>
        </div>
      <% else %>
        <div class="text-center py-12 text-gray-500">
          <p class="text-lg">No posts yet. Check back soon!</p>
        </div>
      <% end %>
    </div>
  </section>
</div>
```

**Key points:**

```erb
data-controller="three-hero"
```

- Activates the Stimulus controller
- Stimulus finds the matching controller by naming convention: `ThreeHeroController`

```erb
<canvas id="three-canvas" class="absolute inset-0"></canvas>
```

- The canvas element that Three.js will use
- `absolute inset-0` makes it fill the parent container

```erb
<div class="relative z-10">
```

- `relative` positions it relative to the section
- `z-10` puts it on top of the canvas (z-index)

---

## Step 4: Add CSS Animations

Edit `app/assets/stylesheets/application.tailwind.css`:

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

/* Fade-in animations */
@keyframes fadeIn {
	from {
		opacity: 0;
		transform: translateY(20px);
	}
	to {
		opacity: 1;
		transform: translateY(0);
	}
}

@keyframes fadeInDelay {
	0% {
		opacity: 0;
		transform: translateY(20px);
	}
	50% {
		opacity: 0;
		transform: translateY(20px);
	}
	100% {
		opacity: 1;
		transform: translateY(0);
	}
}

@keyframes fadeInDelay2 {
	0% {
		opacity: 0;
		transform: translateY(20px);
	}
	70% {
		opacity: 0;
		transform: translateY(20px);
	}
	100% {
		opacity: 1;
		transform: translateY(0);
	}
}

.animate-fade-in {
	animation: fadeIn 0.8s ease-out;
}

.animate-fade-in-delay {
	animation: fadeInDelay 1.2s ease-out;
}

.animate-fade-in-delay-2 {
	animation: fadeInDelay2 1.6s ease-out;
}
```

---

## Step 5: Handle Canvas Sizing on Mobile

The controller already handles resize, but we should make sure the canvas element fills its container.

Add to `app/assets/stylesheets/application.tailwind.css`:

```css
canvas {
	display: block;
	/* Prevents inline-block spacing issue */
}
```

---

## Step 6: Test It

```bash
rails s
```

Visit `http://localhost:3000`

**What you should see:**

- Dark hero section with animated rotating cubes
- Hero text fades in
- Articles section below
- Smooth scrolling

**Test on mobile:**

- Canvas should be responsive
- Should work on iPhone/Android
- If it's laggy, reduce number of cubes (change `for (let i = 0; i < 5; i++)` to 3)

---

## Step 7: Optional Enhancements

### Make Cubes More Interesting

Change the cubes to spheres:

```javascript
// In createGeometry(), replace BoxGeometry with:
const geometry = new THREE.IcosahedronGeometry(0.5, 4);
// Creates a sphere-like shape

// Or use actual sphere:
const geometry = new THREE.SphereGeometry(0.5, 32, 32);
```

### Add Floating Animation

Instead of just rotating, make cubes float up and down:

```javascript
// In createGeometry(), add to object:
mesh.floatSpeed = Math.random() * 0.01;
mesh.floatAmount = Math.random() * 2;

// In animate():
this.objects.forEach(({ mesh, rotationSpeed }, i) => {
	mesh.rotation.x += rotationSpeed.x;
	mesh.rotation.y += rotationSpeed.y;

	// Float animation
	mesh.position.y += mesh.floatSpeed * Math.sin(Date.now() * 0.001 + i);
});
```

### Change Colors

Modify the material color:

```javascript
const material = new THREE.MeshPhongMaterial({
	color: 0xff6b6b, // Red instead of blue
	emissive: 0xcc5555,
	shininess: 100,
});
```

---

## Recap: What You Learned

- ✅ Three.js fundamentals (scene, camera, renderer)
- ✅ Creating 3D geometry (cubes, materials, lighting)
- ✅ Animation loop (requestAnimationFrame)
- ✅ Stimulus + Three.js integration
- ✅ Canvas resizing and responsive handling
- ✅ WebGL rendering
- ✅ Memory cleanup (dispose)

---

## Common Pitfalls

1. **"Canvas is black/blank"** — Check browser console for errors. Make sure Three.js loaded from CDN.
2. **"Cubes not visible"** — Check camera position (`camera.position.z = 5`) and lighting setup
3. **"Performance is laggy"** — Reduce number of objects or reduce `antialias: true` to `false`
4. **"Canvas doesn't resize"** — Make sure `handleResize()` is wired up
5. **"High memory usage"** — Check that `disconnect()` is cleaning up properly

---

## Next: Day 5 - Markdown & Syntax Highlighting

Ready to add proper markdown support? Move on to `day5_markdown.md`!
