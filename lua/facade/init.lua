require("earthshine.string")
local nvimw, type_error, table_vim_type
do
  local _with_0 = { }
  _with_0.g_get = function(key, default)
    do
      local var = vim.api.nvim_get_var(key)
      if var then
        return var
      else
        return default
      end
    end
  end
  _with_0.g_set = function(key, val)
    return vim.api.nvim_set_var(key, val)
  end
  _with_0.g_exists = function(key)
    if pcall(vim.api.nvim_get_var, key) then
      return true
    else
      return false
    end
  end
  _with_0.g_default = function(key, default)
    local val, _ = pcall(vim.api.nvim_get_var, key)
    if not (val) then
      return vim.api.nvim_set_var(key, default)
    end
  end
  _with_0.g_defaults = function(tbl)
    for key, default in pairs(tbl) do
      _with_0.g_default(key, default)
    end
  end
  _with_0.b_set = function(buffer_handle, key, val)
    return vim.api.nvim_buf_set_var(buffer_handle, key, val)
  end
  _with_0.b_get = function(buffer_handle, key, default)
    do
      local var = vim.api.nvim_buf_get_var(buffer_handle, key)
      if var then
        return var
      else
        return default
      end
    end
  end
  _with_0.exec = function(str)
    local str_by_lines = str:split("\n")
    for _i, line in ipairs(str_by_lines) do
      vim.api.nvim_command("exec '" .. tostring(line) .. "'")
    end
  end
  _with_0.option_get = function(key, default)
    do
      local var = vim.api.nvim_get_option(key)
      if var then
        return var
      else
        return default
      end
    end
  end
  _with_0.option_set = function(key, value)
    return vim.api.nvim_set_option(key, value)
  end
  _with_0.b_option_get = function(buffer_handle, key, default)
    do
      local var = vim.api.nvim_buf_get_option(buffer_handle, key)
      if var then
        return var
      else
        return default
      end
    end
  end
  _with_0.fn = function(fn_str, args)
    if args == nil then
      args = { }
    end
    return vim.api.nvim_call_function(fn_str, args)
  end
  _with_0.empty_dict = function()
    return {
      [vim.type_idx] = vim.types.dictionary
    }
  end
  _with_0.to_vim_expression = function(item)
    local _exp_0 = type(item)
    if "nil" == _exp_0 then
      return "v:null"
    elseif "boolean" == _exp_0 then
      return "v:" .. tostring(item)
    elseif "number" == _exp_0 then
      return tostring(item)
    elseif "string" == _exp_0 then
      return "'" .. tostring(item) .. "'"
    elseif "userdata" == _exp_0 then
      return error("userdata", item)
    elseif "function" == _exp_0 then
      return error("function", item)
    elseif "thread" == _exp_0 then
      return error("thread", item)
    elseif "table" == _exp_0 then
      local ok, table_type
      do
        local _obj_0 = table_vim_type(item)
        ok, table_type = _obj_0[1], _obj_0[2]
      end
      if not ok then
        error("Item of table-type is not a valid VimL List or Dict, Lua value is:\n" .. tostring(item))
      end
      if table_type == 'list' then
        local sub_exprs
        do
          local _accum_0 = { }
          local _len_0 = 1
          for _index_0 = 1, #item do
            local sub_item = item[_index_0]
            _accum_0[_len_0] = _with_0.to_vim_expression(sub_item)
            _len_0 = _len_0 + 1
          end
          sub_exprs = _accum_0
        end
        return "[ " .. tostring((", "):join_list(sub_exprs)) .. " ]"
      elseif table_type == 'dict' then
        local sub_exprs
        do
          local _tbl_0 = { }
          for key, sub_item in pairs(item) do
            _tbl_0[key] = _with_0.to_vim_expression(sub_item)
          end
          sub_exprs = _tbl_0
        end
        do
          local _accum_0 = { }
          local _len_0 = 1
          for key, expr in pairs(sub_exprs) do
            _accum_0[_len_0] = "'" .. tostring(key) .. "': " .. tostring(expr)
            _len_0 = _len_0 + 1
          end
          sub_exprs = _accum_0
        end
        return "{ " .. tostring((", "):join_list(sub_exprs)) .. " }"
      end
    end
  end
  nvimw = _with_0
end
type_error = function(_type, val)
  return error("Cannot convert item of " .. tostring(_type) .. "-type (value " .. tostring(val) .. ") to a VimL value!")
end
table_vim_type = function(tbl)
  local i = 0
  local maybe_list = true
  local maybe_dict = true
  for key, val in pairs(tbl) do
    i = i + 1
    local _type = type(key)
    if _type == 'string' then
      maybe_dict = true
      maybe_list = false
    elseif _type ~= 'number' then
      maybe_list = false
    end
    if i ~= key then
      maybe_list = false
    end
    if not (maybe_dict or maybe_list) then
      return {
        false,
        nil
      }
    end
  end
  if maybe_list then
    return {
      true,
      'list'
    }
  else
    return {
      true,
      'dict'
    }
  end
end
return nvimw
