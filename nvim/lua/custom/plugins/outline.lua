return {
    'hedyhli/outline.nvim',
    lazy = true,
    cmd = { 'Outline', 'OutlineOpen' },
    keys = {
      { '<leader>so', '<cmd>Outline<cr>', desc = '[S]earch [O]utline' },
    },
    opts = {
      outline_window = {
        position = 'right',
      },
    },
  }
  