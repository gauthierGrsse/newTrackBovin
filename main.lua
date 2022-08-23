-- Create new track
-- Bovin show de base
-- Par Gauthier Guerisse

-- Variable :

-- Setup :
local haveFeedback = true

-- Shortcut
local cmd = gma.cmd
local setvar = gma.show.setvar
local getvar = gma.show.getvar
local sleep = gma.sleep
local confirm = gma.gui.confirm
local msgbox = gma.gui.msgbox
local textinput = gma.textinput
local progress = gma.gui.progress
local getobj = gma.show.getobj
local property = gma.show.property

local function feedback(text)
    if haveFeedback then
        gma.feedback("Plugin trackshow : " .. text)
    else
        echo(text)
    end
end

local function echo(text)
    gma.echo("Plugin trackshow : " .. text)
end

local function error(text)
    gma.gui.msgbox("Plugin trackshow ERREUR", text)
    feedback("Trackshow plugin ERROR : " .. text)
end

local function start(arg)

end

return start
