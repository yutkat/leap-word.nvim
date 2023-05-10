local M = {}

local function regex_by_word_start(s, start_pos)
	local sub = string.sub(s, start_pos)
	local regex = vim.regex("\\k\\+")
	if regex == nil then
		return nil
	end
	return regex:match_str(sub)
end

local function get_match_positions(targets, line_number)
	local line = vim.api.nvim_buf_get_lines(0, line_number - 1, line_number, false)[1]
	local start_pos = 1

	while true do
		local s, e = regex_by_word_start(line, start_pos)
		if not s then
			break
		end
		s = s + start_pos
		e = e + start_pos
		if s ~= e then
			table.insert(targets, { pos = { line_number, s } })
		end
		start_pos = e + 1
	end

	return targets
end

local function get_words(start_line, end_line)
	local winid = vim.api.nvim_get_current_win()
	local cur_line = vim.fn.line(".")

	-- Get targets.
	local targets = {}
	local lnum = start_line
	while lnum <= end_line do
		targets = get_match_positions(targets, lnum)
		lnum = lnum + 1
	end
	-- Sort them by vertical screen distance from cursor.
	local cur_screen_row = vim.fn.screenpos(winid, cur_line, 1)["row"]
	local function screen_rows_from_cur(t)
		local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])["row"]
		return math.abs(cur_screen_row - t_screen_row)
	end
	table.sort(targets, function(t1, t2)
		return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
	end)

	if #targets >= 1 then
		return targets
	end
end

function M.get_backward_words(offset)
	local winid = vim.api.nvim_get_current_win()
	local wininfo = vim.fn.getwininfo(winid)[1]
	local cur_line = vim.fn.line(".")
	local offset_value = offset or 0
	local start_line = wininfo.topline
	local end_line = cur_line - offset_value

	return get_words(start_line, end_line)
end

function M.get_forward_words(offset)
	local winid = vim.api.nvim_get_current_win()
	local wininfo = vim.fn.getwininfo(winid)[1]
	local cur_line = vim.fn.line(".")
	local offset_value = offset or 0
	local start_line = cur_line + offset_value
	local end_line = wininfo.botline

	return get_words(start_line, end_line)
end

return M
