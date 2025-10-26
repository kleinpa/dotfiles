-- Core UI Settings
vim.opt.number = true     -- Show line numbers
vim.opt.history = 50      -- Keep command history
vim.opt.ruler = true      -- Show cursor position
vim.opt.showcmd = true    -- Display incomplete commands
-- vim.opt.bs = 2            -- Backspace behavior
-- vim.opt.nomodeline = true -- Security setting

-- Tabs and Indentation
vim.opt.tabstop = 4       -- Tabs are 4 spaces
vim.opt.shiftwidth = 4    -- Indent is 4 spaces
vim.opt.softtabstop = 4   -- Soft tabs are 4 spaces
vim.opt.expandtab = true  -- Use spaces instead of tabs
vim.opt.autoindent = true -- Copy indent from previous line

-- Search Settings
vim.opt.ignorecase = true -- Case-insensitive search
vim.opt.smartcase = true  -- ...unless it contains an uppercase letter

-- GUI Font (only applies when running nvim-qt or similar)
if vim.fn.has("gui_running") == 1 then
  vim.opt.guifont = "Consolas:h11"
end

---
--- Keymaps
---

local opts = { noremap = true, silent = true }

-- Tab navigation (works in Normal and Insert mode)
vim.keymap.set({ "n", "i" }, "<C-S-Tab>", ":tabprevious<CR>", opts)
vim.keymap.set({ "n", "i" }, "<C-Tab>", ":tabnext<CR>", opts)
vim.keymap.set({ "n", "i" }, "<C-t>", ":tabnew<CR>", opts)

-- HJKL navigation remapping (Normal mode)
vim.keymap.set("n", ";", "<Right>")
vim.keymap.set("n", "l", "<Up>")
vim.keymap.set("n", "k", "<Down>")
vim.keymap.set("n", "j", "<Left>")
vim.keymap.set("n", "h", ";", { noremap = true })

-- HJKL navigation remapping (Visual mode)
vim.keymap.set("v", ";", "<Right>")
vim.keymap.set("v", "l", "<Up>")
vim.keymap.set("v", "k", "<Down>")
vim.keymap.set("v", "j", "<Left>")
vim.keymap.set("v", "h", ";", { noremap = true })

-- Window-switching remapping
local w_opts = { noremap = true }
vim.keymap.set("n", "<C-w>;", "<C-w>l", w_opts)
vim.keymap.set("n", "<C-w>l", "<C-w>k", w_opts)
vim.keymap.set("n", "<C-w>k", "<C-w>j", w_opts)
vim.keymap.set("n", "<C-w>j", "<C-w>h", w_opts)
vim.keymap.set("n", "<C-w>h", "<C-w>;", w_opts)
