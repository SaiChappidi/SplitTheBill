// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const BAR_COLORS = [
	"#54776c",
	"#5a7a99",
	"#a97d55",
	"#7a6a8f",
	"#9c6b6b",
	"#6b8f86",
	"#62788c"
]

function initializeExpenseFilters() {
	const table = document.getElementById("expense-table")
	if (!table) return

	const rows = Array.from(table.querySelectorAll("tbody tr"))
	const searchInput = document.getElementById("expense-search")
	const categoryFilter = document.getElementById("expense-category-filter")
	const personFilter = document.getElementById("expense-person-filter")
	const visibleCount = document.getElementById("visible-expense-count")
	const visibleTotal = document.getElementById("visible-expense-total")
	const chartCanvas = document.getElementById("category-chart")

	const applyFilters = () => {
		const searchTerm = searchInput.value.trim().toLowerCase()
		const categoryTerm = categoryFilter.value
		const personTerm = personFilter.value

		let count = 0
		let total = 0
		const categoryTotals = {}

		rows.forEach((row) => {
			const description = row.dataset.description
			const category = row.dataset.category
			const payer = row.dataset.payer
			const amount = Number(row.dataset.amount)

			const matchesSearch = !searchTerm || description.includes(searchTerm)
			const matchesCategory = !categoryTerm || category === categoryTerm
			const matchesPerson = !personTerm || payer === personTerm
			const visible = matchesSearch && matchesCategory && matchesPerson

			row.style.display = visible ? "" : "none"

			if (visible) {
				count += 1
				total += amount
				categoryTotals[category] = (categoryTotals[category] || 0) + amount
			}
		})

		visibleCount.textContent = String(count)
		visibleTotal.textContent = total.toFixed(2)
		drawCategoryChart(chartCanvas, categoryTotals)
	}

	;[searchInput, categoryFilter, personFilter].forEach((input) => {
		input.addEventListener("input", applyFilters)
		input.addEventListener("change", applyFilters)
	})

	applyFilters()
}

function drawCategoryChart(canvas, totals) {
	if (!canvas) return

	const ctx = canvas.getContext("2d")
	const width = canvas.width
	const height = canvas.height
	ctx.clearRect(0, 0, width, height)

	const categories = Object.keys(totals)
	if (categories.length === 0) {
		ctx.fillStyle = "#5f685c"
		ctx.font = "13px 'IBM Plex Mono', monospace"
		ctx.fillText("NO MATCHING DATA", 16, 36)
		return
	}

	const values = categories.map((category) => totals[category])
	const maxValue = Math.max(...values)
	const barWidth = Math.max(48, Math.floor((width - 32) / categories.length) - 16)
	const radius = 6

	categories.forEach((category, index) => {
		const value = totals[category]
		const barHeight = Math.max(10, (value / maxValue) * (height - 78))
		const x = 18 + index * (barWidth + 16)
		const y = height - barHeight - 36

		ctx.fillStyle = BAR_COLORS[index % BAR_COLORS.length]
		ctx.beginPath()
		ctx.roundRect(x, y, barWidth, barHeight, [radius, radius, 0, 0])
		ctx.fill()

		ctx.fillStyle = "#232820"
		ctx.font = "600 11px 'IBM Plex Mono', monospace"
		ctx.fillText(`$${value.toFixed(2)}`, x, y - 8)

		ctx.fillStyle = "#5f685c"
		ctx.font = "11px 'IBM Plex Mono', monospace"
		const shortLabel = category.length > 12 ? `${category.slice(0, 10)}..` : category
		ctx.fillText(shortLabel, x, height - 12)
	})
}

// Landing page: elements with data-depth drift gently toward the cursor.
function initializeParallaxScene() {
	const scene = document.querySelector("[data-parallax-scene]")
	if (!scene) return
	if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

	const layers = Array.from(scene.querySelectorAll("[data-depth]"))
	if (layers.length === 0) return

	let targetX = 0
	let targetY = 0
	let currentX = 0
	let currentY = 0
	let rafId = null

	const render = () => {
		// Ease toward the target for a soft, weighty feel
		currentX += (targetX - currentX) * 0.08
		currentY += (targetY - currentY) * 0.08

		layers.forEach((layer) => {
			const depth = Number(layer.dataset.depth) || 10
			const x = currentX * depth
			const y = currentY * depth
			layer.style.transform = `translate3d(${x.toFixed(1)}px, ${y.toFixed(1)}px, 0)`
		})

		if (Math.abs(targetX - currentX) > 0.001 || Math.abs(targetY - currentY) > 0.001) {
			rafId = requestAnimationFrame(render)
		} else {
			rafId = null
		}
	}

	const queueRender = () => {
		if (rafId === null) rafId = requestAnimationFrame(render)
	}

	const onPointerMove = (event) => {
		const rect = scene.getBoundingClientRect()
		const centerX = rect.left + rect.width / 2
		const centerY = rect.top + rect.height / 2
		targetX = (event.clientX - centerX) / window.innerWidth
		targetY = (event.clientY - centerY) / window.innerHeight
		queueRender()
	}

	const onPointerLeave = () => {
		targetX = 0
		targetY = 0
		queueRender()
	}

	document.addEventListener("pointermove", onPointerMove, { passive: true })
	document.addEventListener("pointerleave", onPointerLeave, { passive: true })

	// Clean up when Turbo swaps the page
	document.addEventListener(
		"turbo:before-cache",
		() => {
			document.removeEventListener("pointermove", onPointerMove)
			document.removeEventListener("pointerleave", onPointerLeave)
			if (rafId !== null) cancelAnimationFrame(rafId)
		},
		{ once: true }
	)
}

document.addEventListener("turbo:load", () => {
	initializeExpenseFilters()
	initializeParallaxScene()
})
