return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").install({
                "lua",
                "vim",
                "vimdoc",
                "bash",
                "json",
                "nix",
                "qml",
                "python",
                "javascript",
                "typescript",
                "html",
                "css",
            })
        end,
    },
}
