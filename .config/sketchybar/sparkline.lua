local colors = require("colors")
local font = require("font")

local M = {}

local blocks = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }
local length = 8

-- SketchyBar trims surrounding whitespace and sizes text by its ink, so the
-- meter keeps a constant width through label.width instead of space padding.
M.label = { width = font.label_width(length + 5), align = "right" }

---Text meter drawn with the font's block glyphs, replacing vector graphs.
---@return fun(percent: number): string, integer push Records a sample; returns label text and color.
function M.new()
	local samples = {}
	return function(percent)
		samples[#samples + 1] = math.max(0, math.min(100, percent))
		if #samples > length then
			table.remove(samples, 1)
		end
		local cells = {}
		for _, sample in ipairs(samples) do
			cells[#cells + 1] = blocks[math.min(#blocks, math.floor(sample / 100 * #blocks) + 1)]
		end

		local color = colors.red
		if percent <= 50 then
			color = colors.green
		elseif percent <= 75 then
			color = colors.yellow
		end
		return string.format("%s %3d%%", table.concat(cells), math.floor(percent + 0.5)), color
	end
end

return M
