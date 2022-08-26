-- Create new track
-- Bovin show de base
-- Par Gauthier Guerisse
-- Variable :
local speedMaster = 16
local mainExecId = 1
local layoutTrackID = 1
local execNbr = 1 -- Numero de l'exec principal
local macroNbrTrack = 2000

local startPageExec = 1
local startMacro = 2001
local startTimecode = 1
local startView = 2001

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
        gma.feedback("Plugin track Bovin : " .. text)
    else
        echo(text)
    end
end

local function echo(text)
    gma.echo("Plugin track Bovin : " .. text)
end

local function error(text)
    gma.gui.msgbox("Plugin track Bovin ERREUR", text)
    feedback("Plugin track Bovin ERREUR : " .. text)
end

local function blindEdit(mode)
    if mode then
        cmd('BlindEdit On')
    else
        cmd('BlindEdit Off')
    end
end

local function findAvailableMacro(first)
    while getobj.verify(getobj.handle('Macro ' .. first)) do
        first = first + 1
    end
    return first
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
    createMacroLine(macroId, 4,
        'Appearance Macro ' .. startMacro .. ' Thru ' .. startMacro + macroId .. ' /h=0 /s=100 /br=100')
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

local function updateMacroAppearance(trackId)
    local x = startMacro
    while x < (startMacro + trackId) do
        cmd('Store Macro 1.' .. x .. '.4 "Appearance Macro ' .. startMacro .. ' Thru ' .. startMacro + trackId .. ' /h=0 /s=100 /br=100"')
        x = x + 1
    end
end

local function start(arg)
    blindEdit(true)
    cmd('Clear All')

    local trackId = findAvailableMacro(startMacro) - startMacro
    local trackName = (textinput('Nom nouveau track ?', 'Ma bite'))

    if confirm('Confirmer la création', 'Confirmer la création d\'une nouvelle track avec l\'ID ' .. trackId + 1) then
        -- Creation de la macro
        createMacro(trackId, trackName)

        -- Update macro appearance
        updateMacroAppearance(trackId)

        -- Creation du TC
        cmd('Store Timecode ' .. startTimecode + trackId .. ' "' .. trackName .. '"')

        -- Assign dans layout view
        if not getobj.verify(getobj.handle('Layout ' .. layoutTrackID)) then -- creation layout view si existe pas
            cmd('Store Layout ' .. layoutTrackID .. ' "Tracklist"')
        end
        cmd('Assign Macro ' .. startMacro + trackId .. ' At Layout ' .. layoutTrackID .. '/m')

        -- Creation de la page
        if not getobj.verify(getobj.handle('Page ' .. startPageExec + trackId)) then
            cmd('Store Page ' .. startPageExec + trackId .. ' "' .. trackName .. '"')
        else
            if confirm('Page existant', 'Attention, une page existe déjà en ' .. startPageExec + trackId ..
                '.\nVoulez vous la renommer ?') then
                cmd('Label Page ' .. startPageExec + trackId .. ' "' .. trackName .. '"')
            end
        end

        -- Creation de l'exec principal
        if not getobj.verify(getobj.handle('Exec ' .. startPageExec + trackId .. '.' .. mainExecId)) then
            cmd('Store Exec ' .. startPageExec + trackId .. '.' .. mainExecId .. ' "' .. trackName .. ' MAIN"')
        else
            if confirm('Exec existant', 'Attention, un exec existe déjà en ' .. startPageExec + trackId .. '.' ..
                mainExecId .. '\nVoulez vous le delete ?') then
                cmd('Delete Exec ' .. startPageExec + trackId .. '.' .. mainExecId)
                cmd('Store Exec ' .. startPageExec + trackId .. '.' .. mainExecId .. ' "' .. trackName .. ' MAIN"')
            else
                feedback('Exec principal non crée')
            end
        end
    else
        msgbox('Création annulée', 'Création du track (' .. trackName .. ', ID ' .. trackId .. ') annulé')
    end
    blindEdit(false)
end

return start
