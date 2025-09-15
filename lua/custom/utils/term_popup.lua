local M = {}

function M.open()
  -- Get the directory of the current buffer
  local buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(buf)
  local current_dir

  if current_file ~= '' and vim.fn.filereadable(current_file) == 1 then
    current_dir = vim.fn.fnamemodify(current_file, ':h')
  else
    current_dir = vim.fn.getcwd()
  end

  -- Ensure the directory exists
  if vim.fn.isdirectory(current_dir) == 0 then
    current_dir = vim.fn.getcwd()
  end

  -- Calculate popup dimensions (80% of screen)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Create a new buffer for the terminal
  local popup_buf = vim.api.nvim_create_buf(false, true)

  -- Set buffer options
  vim.api.nvim_buf_set_option(popup_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(popup_buf, 'buflisted', false)

  -- Create the popup window
  local popup_win = vim.api.nvim_open_win(popup_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Terminal: ' .. vim.fn.fnamemodify(current_dir, ':t') .. ' ',
    title_pos = 'center',
  })

  -- Set window options
  vim.api.nvim_win_set_option(popup_win, 'winhl', 'Normal:Normal,FloatBorder:FloatBorder')

  -- Start the terminal in the target directory
  local shell = vim.o.shell or 'zsh'
  vim.fn.termopen(shell, {
    cwd = current_dir,
    on_exit = function()
      if vim.api.nvim_win_is_valid(popup_win) then
        vim.api.nvim_win_close(popup_win, true)
      end
    end
  })

  -- Start in insert mode
  vim.cmd('startinsert')

  -- Set up keymaps for the terminal buffer
  local opts = { buffer = popup_buf, noremap = true, silent = true }

  -- Exit terminal mode and close
  vim.keymap.set('t', '<Esc>', '<C-\\><C-n>:q<CR>', opts)
  vim.keymap.set('t', '<C-q>', '<C-\\><C-n>:q<CR>', opts)

  -- Close from normal mode
  vim.keymap.set('n', 'q', ':q<CR>', opts)
  vim.keymap.set('n', '<Esc>', ':q<CR>', opts)
end

return M