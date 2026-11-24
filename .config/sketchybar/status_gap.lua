-- Bracket backgrounds include their members' padding, so reserve the outer gap separately.
return function(name)
	SBAR.add("item", name, {
		position = "right",
		width = 3,
		padding_left = 0,
		padding_right = 0,
		icon = { drawing = false },
		label = { drawing = false },
		background = { drawing = false },
	})
end
