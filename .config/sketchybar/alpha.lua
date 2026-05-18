-- Alpha constants indexed by integer percentage (0–100).
-- Each value is the corresponding 0x00–0xFF byte for use as the AA
-- channel in a 0xAARRGGBB color, e.g. `alpha\[25\] → 0x40 (25% opacity)`.
local alpha = {}

for i = 0, 100 do
	alpha[i] = math.floor(i / 100 * 0xff + 0.5)
end

return alpha
