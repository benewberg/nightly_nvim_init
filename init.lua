-- helpers -----------------------------------------------------------------------------------------
local cmd = vim.cmd  -- to execute Vim commands e.g. cmd('pwd')
local fn = vim.fn    -- to call Vim functions e.g. fn.bufnr()
local g = vim.g      -- a table to access global variables
local opt = vim.opt  -- to set options

local function map(mode, lhs, rhs, opts)
    local options = {noremap = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- plugins -----------------------------------------------------------------------------------------
local Plug = fn['plug#']
vim.call('plug#begin', '~/.config/nvim/plugged')
Plug('nvim-treesitter/nvim-treesitter', {branch = '0.5-compat'})
Plug 'neovim/nvim-lspconfig'
Plug('junegunn/fzf', {['do'] = fn['fzf#install']})
Plug 'junegunn/fzf.vim'
Plug 'ojroques/nvim-lspfuzzy'
Plug 'luxed/ayu-vim'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'tpope/vim-commentary'
Plug 'machakann/vim-sandwich'
Plug 'justinmk/vim-sneak'
Plug 'voldikss/vim-floaterm'
Plug 'liuchengxu/vim-which-key'
Plug 'windwp/nvim-autopairs'
Plug 'Vimjas/vim-python-pep8-indent'
vim.call('plug#end')    -- automatically calls `filetype plugin indent on` and `syntax enable`

-- options -----------------------------------------------------------------------------------------
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.textwidth = 100
opt.completeopt = {'menuone,noinsert,noselect'}  -- completion options (for deoplete)
opt.clipboard = 'unnamedplus'
opt.hidden = true  -- enable modified buffers in background
opt.ignorecase = true
opt.inccommand = 'nosplit'  -- visually show live substitutions
opt.lazyredraw = true
opt.mouse = 'a'
vim.o.shortmess = vim.o.shortmess .. 'c'  -- don't pass messages to completions menu
opt.showmode = false  -- not necessary with a statusline set
opt.startofline = false
opt.termguicolors = true
opt.ttimeoutlen = 10
opt.updatetime = 100
opt.colorcolumn = '100'
opt.cursorline = true
opt.number = true
opt.wrap = false

g.python3_host_prog = vim.env.HOME .. "/.virtualenvs/nvim/bin/python3"

cmd 'au TextYankPost * lua vim.highlight.on_yank {timeout=400}'  -- yank highlights
-- cmd('autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()')  -- show diagnostic on cursor hover

-- plugin settings ---------------------------------------------------------------------------------
-- autopairs
require('nvim-autopairs').setup()

-- ayu
g.ayucolor = 'mirage'
function custom_ayu_colors()
    cmd 'call ayu#hi("LineNr", "comment", "")'
    cmd 'call ayu#hi("TabLineFill", "", "bg")'
    cmd 'call ayu#hi("TabLineSel", "bg", "accent", "bold")'
    cmd 'call ayu#hi("NormalMode", "string", "bg", "reverse,bold")'
    cmd 'call ayu#hi("InsertMode", "tag", "bg", "reverse,bold")'
    cmd 'call ayu#hi("VisualMode", "keyword", "bg", "reverse,bold")'
    cmd 'call ayu#hi("ReplaceMode", "markup", "bg", "reverse,bold")'
    cmd 'call ayu#hi("OtherMode", "constant", "bg", "reverse,bold")'
    cmd 'call ayu#hi("ScrollBar", "accent", "selection_inactive")'
    cmd 'call ayu#hi("Sneak", "bg", "error", "bold")'
    cmd 'call ayu#hi("FloatermBorder", "comment", "bg")'
end
cmd('autocmd ColorScheme ayu lua custom_ayu_colors()')
cmd [[colorscheme ayu]]

-- floaterm
g.floaterm_autoclose = 1
g.floaterm_width = 0.9
g.floaterm_height = 0.7
g.floaterm_title = 0

-- fzf
g.fzf_colors = {
    fg = {'fg', 'Normal'},
    hl = {'fg', 'Underlined'},
    ['fg+'] = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
    ['bg+'] = {'bg', 'CursorLine', 'CursorColumn'},
    ['hl+'] = {'fg', 'Statement'},
    info = {'fg', 'PreProc'},
    prompt = {'fg', 'Conditional'},
    pointer = {'fg', 'Exception'},
    marker = {'fg', 'Keyword'},
    spinner = {'fg', 'Label'},
    header = {'fg', 'Comment'}
}

function fzf_cd()
    local spec = {
        source = "find . -type d -follow 2>/dev/null",
        options = {
            "--prompt", "Cd> "
        },
        sink = function(line)
            cmd('cd ./' .. line)
        end,
    }
    local wrapped = fn["fzf#wrap"]("fzf_cd", spec)
    wrapped["sink*"] = spec["sink*"]
    wrapped.sink = spec.sink
    fn['fzf#run'](wrapped)
end
cmd [[command! Cd lua fzf_cd{}]]

function fzf_sessions()
    local spec = {
        source = "find ~/.local/share/nvim/sessions -type f",
        options = {
            "--prompt", "Sessions> "
        },
        sink = function(line)
            cmd('source ' .. line)
        end,
    }
    local wrapped = fn["fzf#wrap"]("fzf_sessions", spec)
    wrapped["sink*"] = spec["sink*"]
    wrapped.sink = spec.sink
    fn['fzf#run'](wrapped)
end
cmd [[command! Sessions lua fzf_sessions{}]]

-- gitgutter
g.gitgutter_map_keys = 0

-- indent_blankline
require("indent_blankline").setup()
g.indent_blankline_use_treesitter = true
g.indent_blankline_show_current_context = true
g.indent_blankline_context_patterns = {'class', 'function', '^if', '^elif', '^for'}
cmd('autocmd CursorMoved * IndentBlanklineRefresh')

-- lsp
local lsp = require 'lspconfig'
-- lsp.ccls.setup {}  -- default settings; use this for cpp
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    -- vim.api.nvim_buf_set_keymap(bufnr, 'i', '.', '.<C-x><C-o>', {noremap=true, silent=true})  -- trigger completion when period entered
    -- cmd('autocmd CursorHoldI <buffer> lua vim.lsp.omnifunc()')  -- pseudo autocompletion
end
lsp.pylsp.setup {
    on_attach = on_attach,
    root_dir = lsp.util.root_pattern('.git', fn.getcwd()),  -- start LSP server at project root or cwd
    cmd = {vim.env.HOME .. '/.virtualenvs/nvim/bin/pylsp'},
    settings = {
        pylsp = {
            configurationSources = {'flake8'},
            plugins = {
                flake8 = {enabled = true, executable = vim.env.HOME .. '/.virtualenvs/nvim/bin/flake8'},
                pycodestyle = {enabled = false},
            }
        }
    }
}

-- lsp fuzzy
local lspfuzzy = require 'lspfuzzy'
lspfuzzy.setup {}  -- Make the LSP client use FZF instead of the quickfix list

-- sandwich
cmd 'runtime macros/sandwich/keymap/surround.vim'  -- use tpope's surround.vim mapping so sneak works

-- sneak
g['sneak#label'] = 1

-- treesitter
local ts = require 'nvim-treesitter.configs'
ts.setup {ensure_installed = 'python', highlight = {enable = true}}

-- disable unused builtin plugins ------------------------------------------------------------------
local disabled_builtins = {'gzip', 'zip', 'zipPlugin', 'tar', 'tarPlugin', 'getscript',
                           'getscriptPlugin', 'vimball', 'vimballPlugin', '2html_plugin', 'logipat',
                           'rrhelper', 'spellfile_plugin', 'matchit'}
for _, plugin in pairs(disabled_builtins) do
    g["loaded_" .. plugin] = 1
end

-- status line -------------------------------------------------------------------------------------
function git()
    if not g.loaded_fugitive then
        return ""
    end
    local branch_sign = '???'
    local out = fn.FugitiveHead()
    if out ~= "" then
        out = "  " .. branch_sign .. " " .. out .. " "
    end
    return out
end

function get_mode_color(mode)
    local mode_color = '%#OtherMode#'
    local mode_color_table = {
        n = '%#NormalMode#',
        i = '%#InsertMode#',
        R = '%#ReplaceMode#',
        v = '%#VisualMode#',
        V = '%#VisualMode#',
        [''] = '%#VisualMode#',
    }
    if mode_color_table[mode] then
        mode_color = mode_color_table[mode]
    end
    return mode_color
end

function get_readonly_char()
    local ro_char = ''
    if vim.bo.readonly or vim.bo.modifiable == false then ro_char = '???' end
    return ro_char
end

function get_cwd()
    local dir = vim.api.nvim_call_function('getcwd', {})
    dir = vim.api.nvim_call_function('pathshorten', {dir})
    return dir
end

function scroll_bar()  -- from github.com/drzel/vim-line-no-indicator
    local chars = {
        '   ', '???  ', '???  ', '???  ', '???  ', '???  ', '???  ', '???  ', '???  ', '?????? ', '?????? ', '?????? ', '?????? ',
        '?????? ', '?????? ', '?????? ', '?????? ', '?????????', '?????????', '?????????', '?????????', '?????????', '?????????', '?????????', '?????????'
    }
    local current_line = fn.line('.')
    local total_lines = fn.line('$')
    local index = current_line
    if current_line == 1 then
      index = 1
    elseif current_line == total_lines then
      index = #chars
    else
      local line_no_fraction = math.floor(current_line) / math.floor(total_lines)
      index = math.ceil(line_no_fraction * #chars)
    end
    return chars[index]
end

function git_summary(idx)
   local summary = fn.GitGutterGetHunkSummary()
   local prefix = {'+', '~', '-'}
   return summary[idx] > 0 and string.format(" %s%d ", prefix[idx], summary[idx]) or ''
end

function StatusLine()
    local status = ''
    status = status .. get_mode_color(fn.mode())
    status = status .. [[ %-"]]
    status = status .. '%#DiffAdd#'
    status = status .. [[%-{luaeval("git()")}]]
    status = status .. '%#Directory# '
    status = status .. '%#DiffAdd#'
    status = status .. [[%-{luaeval("git_summary(1)")}]]
    status = status .. '%#DiffChange#'
    status = status .. [[%-{luaeval("git_summary(2)")}]]
    status = status .. '%#DiffDelete#'
    status = status .. [[%-{luaeval("git_summary(3)")}]]
    status = status .. '%#Directory#'
    status = status .. [[ %-m %-{luaeval("get_readonly_char()")}]]
    status = status .. '%='
    status = status .. [[%-{luaeval("get_cwd()")} ]]
    status = status .. [[%#ScrollBar#%-{luaeval("scroll_bar()")}]]
    status = status .. [[%#TabLine# %-"col:%2c]]
    return status
end

opt.laststatus = 2
opt.statusline = '%!luaeval("StatusLine()")'
opt.showtabline = 2

-- mappings ----------------------------------------------------------------------------------------
g.mapleader = ' '  -- make sure this is before all other leader mappings
-- single key mappings
map('n', '<leader>', ':WhichKey " "<CR>', { silent = true })
map('n', '<leader>/', ':BLines<CR>')
map('n', '<leader>:', ':e ~/dotfiles/nvim_nightly/init.lua<CR>')
map('n', '<leader>;', ':luafile ~/dotfiles/nvim_nightly/init.lua<CR>')
map('n', '<leader>b', ':Buffers<CR>')
map('n', '<leader>h', ':Helptags<CR>')
map('n', '<leader>q', ':bd<CR>')
map('n', '<leader>r', ':Rg<CR>')
map('n', '<leader>s', ':lua SaveSession()<CR>')

-- change dir
map('n', '<leader>cc', ':cd %:p:h<CR>')
map('n', '<leader>cd', ':Cd<CR>')
map('n', '<leader>ch', ':cd ~<CR>')
map('n', '<leader>c..', ':cd ..<CR>')
map('n', '<leader>c-', ':cd -<CR>')

-- git
map('n', '<leader>gb', ':Git blame<CR>')
map('n', '<leader>gc', ':Git commit<CR>')
map('n', '<leader>gg', ':Git<CR>')
map('n', '<leader>gj', ':GitGutterNextHunk<CR>')
map('n', '<leader>gk', ':GitGutterPrevHunk<CR>')
map('n', '<leader>gl', ':BCommits<CR>')
map('n', '<leader>gp', ':GitGutterPreviewHunk<CR>')
map('n', '<leader>gr', ':Git reset -p<CR>')
map('n', '<leader>gs', ':GitGutterStageHunk<CR>')
map('n', '<leader>gu', ':GitGutterUndoHunk<CR>')

-- insert text
map('n', '<leader>ib', ':lua Abbrev("break")<CR>')
map('n', '<leader>il', ':lua Abbrev("lbreak")<CR>')
map('n', '<leader>ip', ':lua Abbrev("pdb")<CR>')
map('n', '<leader>it', ':lua Abbrev("this")<CR>')

-- lsp
map('n', '<leader>ld', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', '<leader>lh', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<leader>lr', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<leader>ls', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>')
map('n', '<leader>lt', ':lua ToggleDiagnostics()<CR>')

-- open
map('n', '<leader>of', ':Files<CR>')
map('n', '<leader>oh', ':History<CR>')
map('n', '<leader>os', ':Sessions<CR>')
map('n', '<leader>ot', ':FloatermNew<CR>')

-- tests
map('n', '<leader>tc', ':lua NtCov()<CR>')  -- file coverage (ONLY WORKS ON py3!!)
map('n', '<leader>tf', ':FloatermNew --wintype=floating --title=test-file --autoclose=0 nosetests -sv --nologcapture --with-id %:p<CR>')
map('n', '<leader>tt', ':FloatermNew --wintype=floating --title=test-these --autoclose=0 nosetests -sv -a this --nologcapture %:p<CR>')
map('n', '<leader>tx', ':FloatermNew --wintype=floating --title=test-file-stop --autoclose=0 nosetests -sv --nologcapture --with-id -x %:p<CR>')

-- general
map('n', '<F1>', ':w<CR>')
map('i', '<F1>', '<ESC>:w<CR>i')
map('n', '<F2>', '<cmd>noh<CR>')
map('n', '<TAB>', '<C-^>')
map('n', '<S-TAB>', ':bn<CR>')
map('n', 'Y', 'y$')  -- now included in default neovim > 0.5
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- <Tab> to navigate the completion menu
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})

-- functions ---------------------------------------------------------------------------------------
function SaveSession()
  local name = fn.input("Session name: ")
  if name ~= "" then fn.execute('mksession! ~/.local/share/nvim/sessions/' .. fn.fnameescape(name)) end
end

function Abbrev(_text)
    local abbrev_text_table = {
        sbreak = '# ' .. string.rep('-', 94),
        lbreak = '# ' .. string.rep('-', 98),
        pdb = 'from pdb import set_trace; set_trace()',
        this = 'from nose.plugins.attrib import attr<CR>@attr("this")',
    }
    local cmd = abbrev_text_table[_text]
    vim.api.nvim_command(vim.api.nvim_replace_termcodes('normal! O' .. cmd .. '<ESC><CR>', true, false, true))
end

function NtCov()
    local prevPwd = fn.getcwd()
    cmd(":cd " .. fn.expand('%:p:h'))
    local cov = fn.split(fn.substitute(fn.split(fn.expand('%:p'), "python/")[2], "/", ".", "g"), ".tests.")[1] .. "." .. fn.substitute(fn.substitute(fn.expand('%'), "test_", "", ""), ".py", "", "")
    cmd(":FloatermNew --wintype=floating --title=test-file-coverage --autoclose=0 nosetests --with-cov --cov=" .. cov .. " --cov-report=term-missing " .. fn.expand('%') .. " --verbose")
    cmd(":cd " .. prevPwd)
end

g.diagnostics_active = true
function ToggleDiagnostics()
    if g.diagnostics_active then
        g.diagnostics_active = false
        vim.lsp.diagnostic.clear(0)
    else
        g.diagnostics_active = true
    end
    vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
            virtual_text = g.diagnostics_active,
            signs = g.diagnostics_active,
            underline = g.diagnostics_active,
            update_in_insert = not g.diagnostics_active,
        }
    )
end
