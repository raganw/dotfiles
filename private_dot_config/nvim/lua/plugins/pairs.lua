return {
  -- Keep bracket auto-pairing, but don't auto-insert matching quotes/backticks.
  {
    "nvim-mini/mini.pairs",
    opts = {
      mappings = {
        ['"'] = false,
        ["'"] = false,
        ["`"] = false,
      },
    },
  },
}
