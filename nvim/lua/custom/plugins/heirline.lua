return {
    'rebelot/heirline.nvim',
    dependencies = { 'lewis6991/gitsigns.nvim' },
    config = function()
      local conditions = require 'heirline.conditions'
  
      -- Colors
      local utils = require 'heirline.utils'
      local colors = {
        bright_bg = utils.get_highlight('Folded').bg,
        bright_fg = utils.get_highlight('Folded').fg,
        red = utils.get_highlight('DiagnosticError').fg,
        dark_red = utils.get_highlight('DiffDelete').bg,
        green = utils.get_highlight('String').fg,
        blue = utils.get_highlight('Function').fg,
        gray = utils.get_highlight('NonText').fg,
        orange = utils.get_highlight('Constant').fg,
        purple = utils.get_highlight('Statement').fg,
        cyan = utils.get_highlight('Special').fg,
        diag_warn = utils.get_highlight('DiagnosticWarn').fg,
        diag_error = utils.get_highlight('DiagnosticError').fg,
        diag_hint = utils.get_highlight('DiagnosticHint').fg,
        diag_info = utils.get_highlight('DiagnosticInfo').fg,
        git_del = utils.get_highlight('diffDeleted').fg,
        git_add = utils.get_highlight('diffAdded').fg,
        git_change = utils.get_highlight('diffChanged').fg,
      }
  
      local Align = { provider = '%=' }
      local Space = { provider = ' ' }
  
      -- Statusline
      local ViMode = {
        -- get vim current mode, this information will be required by the provider
        -- and the highlight functions, so we compute it only once per component
        -- evaluation and store it as a component attribute
        init = function(self)
          self.mode = vim.fn.mode(1) -- :h mode()
        end,
        -- Now we define some dictionaries to map the output of mode() to the
        -- corresponding string and color. We can put these into `static` to compute
        -- them at initialisation time.
        static = {
          mode_names = { -- change the strings if you like it vvvvverbose!
            n = 'Normal',
            no = 'Operator',
            nov = 'Operator',
            noV = 'Operator',
            ['no\22'] = 'Operator',
            niI = 'NormalI',
            niR = 'NormalR',
            niV = 'NormalV',
            nt = 'NormalTerm',
            v = 'Visual',
            vs = 'Visual',
            V = 'VisualLine',
            Vs = 'VisualLine',
            ['\22'] = '^V',
            ['\22s'] = '^V',
            s = 'Select',
            S = 'Select',
            ['\19'] = 'Select',
            i = 'Insert',
            ic = 'Insert',
            ix = 'Insert',
            R = 'Replace',
            Rc = 'Replace',
            Rx = 'Replace',
            Rv = 'Replace',
            Rvc = 'Replace',
            Rvx = 'Replace',
            c = 'Command',
            cv = 'Ex',
            r = '...',
            rm = 'M',
            ['r?'] = '?',
            ['!'] = '!',
            t = 'T',
          },
          mode_colors = {
            n = { bg = 'bright_bg', fg = 'bright_fg' },
            i = { bg = 'green', fg = 'bright_bg' },
            v = { bg = 'cyan', fg = 'bright_bg' },
            V = { bg = 'cyan', fg = 'bright_bg' },
            ['\22'] = { bg = 'cyan', fg = 'bright_bg' },
            c = { bg = 'orange', fg = 'bright_bg' },
            s = { bg = 'purple', fg = 'bright_bg' },
            S = { bg = 'purple', fg = 'bright_bg' },
            ['\19'] = { bg = 'purple', fg = 'bright_bg' },
            R = { bg = 'orange', fg = 'bright_bg' },
            r = { bg = 'orange', fg = 'bright_bg' },
            ['!'] = { bg = 'red', fg = 'bright_bg' },
            t = { bg = 'red', fg = 'bright_bg' },
          },
        },
        -- We can now access the value of mode() that, by now, would have been
        -- computed by `init()` and use it to index our strings dictionary.
        -- note how `static` fields become just regular attributes once the
        -- component is instantiated.
        -- To be extra meticulous, we can also add some vim statusline syntax to
        -- control the padding and make sure our string is always at least 2
        -- characters long. Plus a nice Icon.
        provider = function(self)
          if self.mode == 'n' then
            return ' '
          else
            return '  ' .. self.mode_names[self.mode] .. ' '
          end
        end,
        -- Same goes for the highlight. Now the foreground will change according to the current mode.
        hl = function(self)
          local mode = self.mode:sub(1, 1) -- get only the first mode character
          return { bg = self.mode_colors[mode].bg, fg = self.mode_colors[mode].fg, bold = true }
        end,
        -- Re-evaluate the component only on ModeChanged event!
        -- Also allows the statusline to be re-evaluated when entering operator-pending mode
        update = {
          'ModeChanged',
          pattern = '*:*',
          callback = vim.schedule_wrap(function()
            vim.cmd 'redrawstatus'
          end),
        },
      }
  
      local WorkDir = {
        init = function(self)
          self.icon = (vim.fn.haslocaldir(0) == 1 and '1' or 'g') .. ' ' .. ' '
          local cwd = vim.fn.getcwd(0)
          self.cwd = vim.fn.fnamemodify(cwd, ':~')
        end,
  
        hl = { fg = colors.blue },
  
        flexible = 1,
  
        {
          -- evaluates to the full path
          provider = function(self)
            local trail = self.cwd:sub(-1) == '/' and '' or '/'
            return self.icon .. self.cwd .. trail .. ' '
          end,
        },
        {
          -- evaluates to the shortened path
          provider = function(self)
            local cwd = vim.fn.pathshorten(self.cwd)
            local trail = self.cwd:sub(-1) == '/' and '' or '/'
            return self.icon .. cwd .. trail .. ' '
          end,
        },
        {
          -- evaluates to '', hiding the component
          provider = '',
        },
      }
  
      local FileNameBlock = {
        init = function(self)
          self.filename = vim.api.nvim_buf_get_name(0)
        end,
      }
  
      local FileIcon = {
        init = function(self)
          local filename = self.filename
          local extension = vim.fn.fnamemodify(filename, ':e')
          self.icon, self.icon_color = require('nvim-web-devicons').get_icon_color(filename, extension, { default = true })
        end,
  
        hl = function(self)
          return { fg = self.icon_color }
        end,
  
        provider = function(self)
          return self.icon and (self.icon .. ' ')
        end,
      }
  
      local FileName = {
        hl = { fg = utils.get_highlight('Directory').fg },
        provider = function(self)
          local filename = vim.fn.fnamemodify(self.filename, ':.')
          if filename == '' then
            return '[No Name]'
          end
  
          if not conditions.width_percent_below(#filename, 0.25) then
            filename = vim.fn.pathshorten(filename)
          end
          return filename
        end,
      }
  
      local FileFlags = {
        {
          condition = function()
            return vim.bo.modified
          end,
          hl = { fg = colors.green },
          provider = '[+]',
        },
        {
          condition = function()
            return not vim.bo.modifiable or vim.bo.readonly
          end,
          hl = { fg = colors.orange },
          provider = '',
        },
      }
  
      local FileNameModifier = {
        hl = function()
          if vim.bo.modified then
            return { fg = colors.cyan, bold = true, force = true }
          end
        end,
      }
  
      FileNameBlock = utils.insert(FileNameBlock, FileIcon, utils.insert(FileNameModifier, FileName), FileFlags, { provider = '%<' })
  
      local GitBranch = {
        condition = conditions.is_git_repo,
  
        init = function(self)
          self.status_dict = vim.b.gitsigns_status_dict
          self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
        end,
  
        hl = { fg = colors.orange, bg = colors.bright_bg, bold = true },
  
        provider = function(self)
          local branch = self.status_dict.head
          if branch == nil or branch == '' then
            branch = 'master'
          end
          return ' ' .. branch
        end,
      }
  
      local StatusLine = { ViMode, Space, FileNameBlock, Align, GitBranch }
  
      -- Winbar
      local WinBar = {}
  
      -- Tabline
      local TabLine = {}
  
      -- Statuscolumn
      local StatusColumn = {}
      require('heirline').setup {
        statusline = StatusLine,
        winbar = WinBar,
        tabline = TabLine,
        statuscolumn = StatusColumn,
        opts = { colors = colors },
      }
    end,
  }
  