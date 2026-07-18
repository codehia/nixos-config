-- =============================================================================
-- CUSTOM SNIPPETS
-- Loaded from the luasnip spec in plugins/coding.lua (after friendly-snippets).
-- Shown by blink.cmp as snippet entries; <Tab>/<S-Tab> jump between nodes.
-- Brace-heavy languages (nix, lua) use '<>' fmt delimiters to avoid {{}} noise.
-- =============================================================================

local ls = require('luasnip')
local s = ls.snippet
local i = ls.insert_node
local rep = require('luasnip.extras').rep
local fmt = require('luasnip.extras.fmt').fmt
local events = require('luasnip.util.events')

-- pre_expand callback table: inserts `import_line` at the top of the buffer
-- unless `pattern` already matches somewhere in it. ruff_organize_imports
-- sorts the line into the top import block on save.
local function auto_import(import_line, pattern)
  return {
    [-1] = {
      [events.pre_expand] = function(_, event_args)
        if vim.fn.search(pattern, 'nw') ~= 0 then
          return
        end
        local pos = event_args.expand_pos
        vim.api.nvim_buf_set_lines(0, 0, 0, false, { import_line })
        -- The expand-position extmark has left gravity, so it does NOT shift
        -- when the import is inserted exactly at it (trigger at buffer top =
        -- (0,0) after trigger clearing) — reposition it below the import
        -- unconditionally; row+1 is correct whether or not it auto-shifted.
        vim.api.nvim_buf_set_extmark(0, require('luasnip.session').ns_id, pos[1] + 1, pos[2], {
          id = event_args.expand_pos_mark_id,
          right_gravity = false,
        })
      end,
    },
  }
end

-- ---------------------------------------------------------------------------
-- Python
-- ---------------------------------------------------------------------------
ls.add_snippets('python', {
  s(
    { trig = 'singleton', desc = 'Singleton metaclass + class' },
    fmt(
      [[
class {}Meta(type):
    _instances = {{}}

    def __call__(cls, *args, **kwargs):
        if cls not in cls._instances:
            cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


class {}(metaclass={}Meta):
    {}
]],
      { i(1, 'Singleton'), i(2, 'MyClass'), rep(1), i(0, 'pass') }
    )
  ),

  s(
    { trig = 'singletont', desc = 'Thread-safe singleton metaclass + class (auto-imports threading)' },
    fmt(
      [[
class {}Meta(type):
    _instances = {{}}
    _lock: threading.Lock = threading.Lock()

    def __call__(cls, *args, **kwargs):
        with cls._lock:
            if cls not in cls._instances:
                cls._instances[cls] = super().__call__(*args, **kwargs)
        return cls._instances[cls]


class {}(metaclass={}Meta):
    {}
]],
      { i(1, 'Singleton'), i(2, 'MyClass'), rep(1), i(0, 'pass') }
    ),
    { callbacks = auto_import('import threading', [[^import threading\>]]) }
  ),

  s(
    { trig = 'synchronized', desc = 'synchronized method decorator (auto-imports functools.wraps)' },
    fmt(
      [[
def synchronized(method):
    @wraps(method)
    def wrapper(self, *args, **kwargs):
        with self.{}:
            return method(self, *args, **kwargs)
    return wrapper
]],
      { i(0, 'lock') }
    ),
    { callbacks = auto_import('from functools import wraps', [[^from functools import .*\<wraps\>]]) }
  ),

  s(
    { trig = 'logger', desc = 'Module-level logger (needs: import logging)' },
    fmt('logger = logging.getLogger(__name__)', {})
  ),

  s(
    { trig = 'ctxman', desc = '@contextmanager skeleton (needs: import contextlib)' },
    fmt(
      [[
@contextlib.contextmanager
def {}({}):
    {}
    try:
        yield {}
    finally:
        {}
]],
      { i(1, 'managed'), i(2), i(3, '# setup'), i(4, 'None'), i(0, '# teardown') }
    )
  ),

  s(
    { trig = 'param', desc = 'pytest parametrized test' },
    fmt(
      [[
@pytest.mark.parametrize('{}', [{}])
def test_{}({}):
    {}
]],
      { i(1, 'arg'), i(2), i(3, 'name'), rep(1), i(0, 'assert True') }
    )
  ),

  s(
    { trig = 'fixture', desc = 'pytest fixture' },
    fmt(
      [[
@pytest.fixture
def {}():
    {}
]],
      { i(1, 'name'), i(0, 'return None') }
    )
  ),

  s(
    { trig = 'proto', desc = 'typing.Protocol class' },
    fmt(
      [[
class {}(Protocol):
    def {}(self{}) -> {}: ...
]],
      { i(1, 'MyProtocol'), i(2, 'method'), i(3), i(0, 'None') }
    )
  ),

  s(
    { trig = 'amain', desc = 'async main + asyncio.run (needs: import asyncio)' },
    fmt(
      [[
async def main() -> None:
    {}


if __name__ == '__main__':
    asyncio.run(main())
]],
      { i(0, 'pass') }
    )
  ),
})

-- ---------------------------------------------------------------------------
-- Nix (den/dendritic skeletons for this repo)
-- ---------------------------------------------------------------------------
ls.add_snippets('nix', {
  s(
    { trig = 'aspect', desc = 'den aspect file (attrset form)' },
    fmt(
      [[
{ den, ... }:
{
  den.aspects.<> = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.<> ];
    };
  };
}
]],
      { i(1, 'myapp'), i(0, 'myapp') },
      { delimiters = '<>' }
    )
  ),

  s(
    { trig = 'paraminc', desc = 'named parametric include (let-binding)' },
    fmt(
      [[
let
  <> =
    { <>, ... }:
    {
      <>
    };
in
]],
      { i(1, 'name'), i(2, 'host'), i(0) },
      { delimiters = '<>' }
    )
  ),

  s(
    { trig = 'flakeinput', desc = 'flake-file input block (run `just write-flake` after)' },
    fmt(
      [[
flake-file.inputs.<> = {
  url = "github:<>";
  inputs.nixpkgs.follows = "nixpkgs-unstable";
};
]],
      { i(1, 'name'), i(0, 'owner/repo') },
      { delimiters = '<>' }
    )
  ),
})

-- ---------------------------------------------------------------------------
-- Lua (lze plugin spec for this repo's nvim config)
-- ---------------------------------------------------------------------------
ls.add_snippets('lua', {
  s(
    { trig = 'lzespec', desc = 'lze plugin spec' },
    fmt(
      [[
-- pname: <>
{
  '<>',
  event = 'VeryLazy',
  after = function()
    require('<>').setup({})
  end,
},
]],
      { i(1, 'plugin.nvim'), rep(1), i(0, 'plugin') },
      { delimiters = '<>' }
    )
  ),
})
