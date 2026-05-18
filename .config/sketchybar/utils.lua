local M = {}

-- Replaces the alpha channel of a 0xAARRGGBB color value.
-- Masks out the existing AA byte with `& 0x00ffffff`, then shifts
-- the new alpha byte into the top 8 bits with `<< 24` and ORs it in,
-- leaving the RGB channels untouched.
function M.with_alpha(color, alpha)
	return (alpha << 24) | (color & 0x00ffffff)
end

return M
