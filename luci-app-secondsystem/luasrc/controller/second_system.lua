module("luci.controller.second_system", package.seeall)

local sys = require "luci.sys"
local http = require "luci.http"
local disp = require "luci.dispatcher"

function index()
    entry({"admin", "system", "second_system"}, view("admin", "system", "second_system", "settings"),
        _("官方系统"), 50).dependent = true
    entry({"admin", "system", "second_system", "settings"}, template("settings"), _("Settings"), 10).leaf = true
    entry({"admin", "system", "second_system", "act_switch"}, call("action_switch"), nil).leaf = true
    entry({"admin", "system", "second_system", "act_reboot"}, call("action_reboots"), nil).leaf = true
end

function action_switch()
    local needReboot = http.formvalue("needReboot")

    if needReboot and needReboot == "yes" then
        sys.call("reboot_default_sys.sh")
        sys.call("reboot")
    else
        http.redirect(disp.build_url("admin", "system", "second_system", "settings"))
    end
end

function action_reboots()
    local needReboot = http.formvalue("needReboot")

    if needReboot and needReboot == "yes" then
        sys.call("reboot")
    else
        http.redirect(disp.build_url("admin", "system", "second_system", "settings"))
    end
end
