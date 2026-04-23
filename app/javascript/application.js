// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const BAR_COLORS = [
	"#d64545",
	"#ef7c34",
	"#f4b400",
	"#50a14f",
	"#2d7dd2",
	"#6d5bd0",
	"#b56576"
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
		ctx.fillStyle = "#486581"
		ctx.font = "16px Space Grotesk"
		ctx.fillText("No matching data", 16, 36)
		return
	}

	const values = categories.map((category) => totals[category])
	const maxValue = Math.max(...values)
	const barWidth = Math.max(48, Math.floor((width - 32) / categories.length) - 16)

	categories.forEach((category, index) => {
		const value = totals[category]
		const barHeight = Math.max(6, (value / maxValue) * (height - 78))
		const x = 18 + index * (barWidth + 16)
		const y = height - barHeight - 36

		ctx.fillStyle = BAR_COLORS[index % BAR_COLORS.length]
		ctx.fillRect(x, y, barWidth, barHeight)

		ctx.fillStyle = "#102a43"
		ctx.font = "12px Space Grotesk"
		ctx.fillText(`$${value.toFixed(2)}`, x, y - 8)

		const shortLabel = category.length > 12 ? `${category.slice(0, 10)}..` : category
		ctx.fillText(shortLabel, x, height - 12)
	})
}

document.addEventListener("turbo:load", initializeExpenseFilters)
