package = "facade.nvim"
version = "scm-1"
source = {
  url = "git://github.com/Shados/facade.nvim",
  branch = "master",
}
description = {
  summary = "A MoonScript wrapper around Neovim's Lua API",
  homepage = "https://github.com/Shados/facade.nvim",
  license = "MIT",
}
dependencies = {
  "lua == 5.1",
}
build_dependencies = {
  "moonscript >= 0.5.0",
  "earthshine >= 0.0.1",
}
build = {
  type = "make",

  install_variables = {
    LUA_LIBDIR="$(LUADIR)",
    PREFIX="$(PREFIX)",
  },
}
rockspec_format = "3.0"
