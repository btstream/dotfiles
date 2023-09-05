local platform = require("utils.wezterm").platform

local M = {}

function M.get_domain_info(pane)
    local domain_name = pcall(function()
        return pane:get_domain_name()
    end) and pane:get_domain_name() or pane.domain_name

    if domain_name == nil then
        return nil
    end

    if domain_name == "local" then
        return {
            domain = "local",
        }
    end

    local domain = domain_name:split(":")
    if domain[1]:lower() == "wsl" then
        return {
            domain = "wsl",
            dist = domain[2]:lower(),
        }
    end

    return {
        domain = domain[1]:lower(),
        extra = domain[2] ~= nil and domain[2]:lower() or nil,
    }
end

local function guess_app_from_title(pane)
    local title = pcall(function()
        return pane:get_title()
    end) and pane:get_title() or pane.title

    -- to eliminate if just a folder
    title = title:gsub("^%s*(.-)%s*$", "%1")
    if title then
        if platform() == "Windows" then
            if title:find("^%a?:") == 1 or title:find("^~/") == 1 then
                return
            end
        end
        if title:find("^[~/]") then
            return
        end
        if title:find("^%.%..*") then
            return
        end
    end

    -- very personal, for alias as on zsh
    if title == "v" or title == "e" then
        return "vim"
    end

    -- local sep = platform() == "Windows" and "\\" or "/"
    -- sep = M.get_domain_info(pane).domain == "wsl" and "/" or sep

    -- current title is a path, suitable for oh-my-zsh's termsupport
    -- if #title:split(sep) > 1 then
    -- return nil
    -- end

    for _, value in pairs(require("utils.wezterm.ui").get_supported_apps()) do
        if title:lower():find(value) then
            return value
        end
    end
end

local function get_app_from_user_var(pane)
    local user_vars = pcall(function()
        pane:get_user_vars()
    end) and pane:get_user_vars() or pane.user_vars

    local program = user_vars.WEZTERM_PROG
    if program then
        program = program:gsub("^%s*(.-)%s*$", "%1")

        if program == "v" or program == "e" then
            program = "vim"
        end

        return program:split(" ")[1]
    end
end

function M.get_current_app(pane)
    ----------------------------------------------------------------------
    --          get app from user_vars if shell_integration of          --
    --                        wezterm has set                           --
    ----------------------------------------------------------------------

    local app = get_app_from_user_var(pane)
    if app then
        return app
    end

    local domain = M.get_domain_info(pane)
    if domain == nil or domain.domain == "local" then
        app = pcall(function()
            return pane:foreground_process_name()
        end) and pane:get_foreground_process_name() or pane.foreground_process_name

        local sep = platform() == "Windows" and "\\" or "/"

        app = app and app:split(sep) or nil
        app = app and app[#app] or nil

        -- wezterm.log_info(string.format("detected app at running is %s", app))

        -- some of the program is writing with shell script,
        -- which may indicator foreground_process_name with a
        -- script interpreter
        if
            app == nil
            or app == "zsh"
            or app == "bash"
            or app == "cmd.exe"
            or app == "pwsh.exe"
            or app:find("^python")
            or app:find("^ruby")
        then
            return guess_app_from_title(pane)
        end

        if platform() == "Windows" then
            return app:split(".")[1]:lower()
        end

        return app:lower()
    else
        local title = pcall(function()
            return pane:get_title()
        end) and pane:get_title() or pane.title

        if (domain.domain == "wsl" or domain.domain == "ssh") and (title == "v" or title == "e") then
            return "nvim"
        end

        return guess_app_from_title(pane)
    end
end

return M
