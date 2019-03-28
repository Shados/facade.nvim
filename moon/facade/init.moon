require "earthshine.string"
local *

nvimw = with {}
  -- Get a g: variable, or a default value if unset
  .g_get = (key, default) ->
    if var = vim.api.nvim_get_var key
      var
    else
      default

  -- Set a g: variable
  .g_set = (key, val) ->
    vim.api.nvim_set_var key, val

  -- Return true if a g: variable exists; this exists mainly for clarity of intent
  .g_exists = (key) ->
    if pcall vim.api.nvim_get_var, key
      true
    else
      false

  -- Set a g: variable to a default if it is unset, otherwise leave it as-is
  .g_default = (key, default) ->
    val, _ = pcall vim.api.nvim_get_var, key
    unless val
      vim.api.nvim_set_var key, default

  -- Set g: dictionary defaults based on given table
  .g_defaults = (tbl) ->
    for key, default in pairs tbl
      .g_default key, default

  -- Set a b: variable
  .b_set = (buffer_handle, key, val) ->
    vim.api.nvim_buf_set_var buffer_handle, key, val

  -- Get a b: variable, or a default value if unset
  .b_get = (buffer_handle, key, default) ->
    if var = vim.api.nvim_buf_get_var buffer_handle, key
      var
    else
      default

  -- Executes a multi-line string containing Ex commands
  .exec = (str) ->
    str_by_lines = str\split("\n")
    for _i, line in ipairs str_by_lines
      -- TODO escape line properly
      vim.api.nvim_command("exec '#{line}'")

  -- Get an option, or a default value if unset
  .option_get = (key, default) ->
    if var = vim.api.nvim_get_option key
      var
    else
      default

  .option_set = (key, value) ->
    vim.api.nvim_set_option key, value

  -- Get a buffer option, or a default value if unset
  .b_option_get = (buffer_handle, key, default) ->
    if var = vim.api.nvim_buf_get_option buffer_handle, key
      var
    else
      default

  -- Call a VimL function with the given arguments, return the result
  .fn = (fn_str, args={}) ->
    vim.api.nvim_call_function(fn_str, args)

  -- Empty Lua table is considered a Vim list by default; this results in an
  -- empty Vim dictionary instead
  .empty_dict = () ->
    { [vim.type_idx]: vim.types.dictionary }

  -- Converts a Lua type to a string containing an eval()-able representation of
  -- a VimL item of the corresponding type
  .to_vim_expression = (item) ->
    return switch type(item)
      when "nil" then "v:null"
      when "boolean" then "v:#{item}"
      when "number" then "#{item}"
      when "string" then "'#{item}'"
      when "userdata"
        error "userdata", item
      when "function"
        error "function", item
      when "thread"
        error "thread", item
      when "table"
        {ok, table_type} = table_vim_type item
        if not ok
          error "Item of table-type is not a valid VimL List or Dict, Lua value is:\n#{item}"
        if table_type == 'list'
          sub_exprs = [.to_vim_expression(sub_item) for sub_item in *item]
          "[ #{", "\join_list sub_exprs} ]"
        elseif table_type == 'dict'
          sub_exprs = {key, .to_vim_expression(sub_item) for key, sub_item in pairs item}
          sub_exprs = for key, expr in pairs sub_exprs
            "'#{key}': #{expr}"
          "{ #{", "\join_list sub_exprs} }"

type_error = (_type, val) ->
  error "Cannot convert item of #{_type}-type (value #{val}) to a VimL value!"

table_vim_type = (tbl) ->
  i = 0
  maybe_list = true
  maybe_dict = true
  for key, val in pairs tbl
    i += 1
    _type = type(key)
    if _type == 'string' -- non-string keys aren't valid VimL Dicts
      maybe_dict = true
      maybe_list = false
    elseif _type != 'number'
      maybe_list = false
    if i != key -- non-sequential integer keys aren't valid VimL Lists
      maybe_list = false

    unless maybe_dict or maybe_list
      return {false, nil}

  if maybe_list
    return {true, 'list'}
  else
    return {true, 'dict'}

return nvimw
