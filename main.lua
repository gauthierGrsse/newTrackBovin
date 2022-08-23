-- Create new track
-- Bovin show de base
-- Par Gauthier Guerisse
-- Variable :
local speedMaster = 16
local mainExecId = 1

local startPageExec = 0
local startMacro = 76
local startTimecode = 0
local startView = 2000

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

local function createMacroLine(macro, line, command)
    cmd('Store Macro 1.' .. macro .. '.' .. line .. ' "' .. command .. '"')
end

local function createMacro(id, name)
    local macroId = startMacro + id
    cmd('Store Macro ' .. macroId .. ' "' .. name .. '"')
    createMacroLine(macroId, 1, "Page " .. startPageExec + id)
    createMacroLine(macroId, 2, 'Select Executor 1')
    createMacroLine(macroId, 3, 'Fader 1 At Full')
    createMacroLine(macroId, 4, 'Appearance Macro 77 Thru 106 /h=0 /s=100 /br=100')
    createMacroLine(macroId, 5, 'Appearance Macro ' .. macroId .. ' /h=120 /s=100 /br=100')
    createMacroLine(macroId, 6, 'Copy View 289 At View 301 /o')
    createMacroLine(macroId, 7, 'Kill 1')
    createMacroLine(macroId, 8, 'View 301')
    createMacroLine(macroId, 9, 'Macro 125')
    createMacroLine(macroId, 10, 'Fader 1 At Full')
    createMacroLine(macroId, 11, 'Go Executor 1 Cue 1')
    createMacroLine(macroId, 12, 'SpecialMaster 3.' .. speedMaster .. ' At ' .. (textinput('BPM Track ?', '120')))
    createMacroLine(macroId, 13, 'Off Timecode 1 Thru')
    createMacroLine(macroId, 14, 'Go Timecode ' .. startTimecode + id)
end

local function start(arg)
    local trackId = tonumber(textinput('ID nouveau track', '0'))
    local trackName = (textinput('Nom nouveau track ?', 'Ma bite'))
    if confirm('Confirmer la création', 'Confirmer la création d\'une nouvelle track avec l\'ID ' .. trackId) then
        createMacro(trackId, trackName)
        cmd('Store Timecode ' .. startTimecode + trackId .. ' "' .. trackName .. '"')
    else
        msgbox('Création annulée', 'Création du track (' .. trackName .. ', ID ' .. trackId .. ') annulé')
    end
end

return start
