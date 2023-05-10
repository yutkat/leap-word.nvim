# leap-word

Go to any word in the current buffer.

![screenshot](https://github.com/yutkat/img/assets/8683947/9363e2da-62a2-457b-b1dc-545ea0d8a960)

## Usage

```lua
vim.keymap.set({ "n", "x" }, "SS", function()
	require("leap").leap({
		targets = get_backward_words(1), -- 1 means search word from one line up
	})
end)

vim.keymap.set({ "n", "x" }, "Ss", function()
	require("leap").leap({
		targets = get_forward_words(1), -- 1 means search word from one line down
	})
end)
```
