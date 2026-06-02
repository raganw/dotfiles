-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- chezmoi plist fragments: literal {{ }} inside <string> values must be escaped
-- or the Go-template engine consumes them. Prefer the backtick form:
--   {{width}}x{{height}}  ->  {{ `{{width}}x{{height}}` }}
-- Both mappings edit text programmatically so mini.pairs does not auto-close the
-- braces/backticks we insert.
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*.plist.tmpl",
  desc = "chezmoi plist template escape helpers",
  callback = function(ev)
    local function opts(desc)
      return { buffer = ev.buf, desc = desc }
    end

    -- Visual: wrap the selection in {{ `…` }}
    vim.keymap.set("x", "<leader>ce", function()
      vim.cmd('noautocmd normal! "zd') -- cut selection into register z, exit visual
      vim.api.nvim_put({ "{{ `" .. vim.fn.getreg("z") .. "` }}" }, "c", false, true)
    end, opts("chezmoi: wrap selection in {{ `…` }}"))

    -- Normal: escape the <string>…</string> value on the current line (idempotent).
    vim.keymap.set("n", "<leader>ce", function()
      local changed = false
      local new = vim.api.nvim_get_current_line():gsub("(<string>)(.-)(</string>)", function(open, val, close)
        local needs = val:find("{{", 1, true) or val:find("}}", 1, true)
        local done = val:find("`", 1, true) or val:find('{{ "', 1, true)
        if needs and not done then
          changed = true
          return open .. "{{ `" .. val .. "` }}" .. close
        end
        return open .. val .. close
      end)
      if changed then
        vim.api.nvim_set_current_line(new)
      end
    end, opts("chezmoi: escape <string> value on this line"))
  end,
})
