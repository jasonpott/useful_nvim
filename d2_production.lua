-- Useful watcher that compiles d2 files to svg and png output in the working directory on file save
-- watches d2 files
-- saves output with same file name as d2 file with svg and png suffix
-- handles the notifications of success and errors elegantly with snack notifications in lazyvime


vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.d2",
  callback = function(args)
    local input = args.file
    local base = input:gsub("%.d2$", "")

    vim.notify("Generating SVG and PNG from " .. input, vim.log.levels.INFO, { title = "D2 Export" })

    local function run_d2(output_format)
      local output_file = base .. "." .. output_format
      vim.fn.jobstart({ "d2", "--layout", "elk", input, output_file }, {
        stderr_buffered = true,
        on_stderr = function(_, data)
          if data then
            vim.schedule(function()
              vim.notify(
                "D2 error (" .. output_format .. "):\n" .. table.concat(data, "\n"),
                vim.log.levels.ERROR,
                { title = "D2 Export" }
              )
            end)
          end
        end,
        on_exit = function(_, code)
          vim.schedule(function()
            if code == 0 then
              vim.notify(
                output_format:upper() .. " generated: " .. output_file,
                vim.log.levels.INFO,
                { title = "D2 Export" }
              )
            else
              vim.notify("Failed to generate " .. output_format:upper(), vim.log.levels.ERROR, { title = "D2 Export" })
            end
          end)
        end,
      })
    end

    run_d2("svg")
    run_d2("png")
  end,
})
