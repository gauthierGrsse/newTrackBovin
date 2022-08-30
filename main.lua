-- Create new track
-- Bovin show de base
-- Par Gauthier Guerisse
-- Variable :
local speedMaster = 16
local mainExecId = 1
local layoutTrackID = 1
local execNbr = 1 -- Numero de l'exec principal
local macroNbrTrack = 20

local startPageExec = 1
local startMacro = 2001
local startTimecode = 1
local startView = 20

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

local function createView(id, name)
    local viewXML =
        '<?xml version="1.0" encoding="utf-8"?><MA xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.malighting.de/grandma2/xml/MA" xsi:schemaLocation="http://schemas.malighting.de/grandma2/xml/MA http://schemas.malighting.de/grandma2/xml/3.9.60/MA.xsd" major_vers="1" minor_vers="0" stream_vers="00"><Info datetime="2022-08-30T22:23:31" showfile="bovin" /><View index="4" name="VIEW BASE" display_mask="2"><BitMap width="96" height="48"><Image></Image></BitMap><Widget index="0" type="4c41594f" display_nr="1" y="5" anz_rows="3" anz_cols="16"><Data><Data>0</Data><Data>0</Data><Data>0</Data><Data>0</Data></Data><Camera index="1"><Rotation rotation_x="0" rotation_y="0" rotation_z="0" /></Camera></Widget><Widget index="1" type="47524f55" display_nr="1" y="4" anz_rows="1" anz_cols="14" scroll_offset="' ..
            id * 100 + 100 .. '" scroll_index="' .. id * 100 + 100 ..
            '"><Data><Data>0</Data><Data>0</Data><Data>0</Data><Data>3</Data></Data></Widget><Widget index="2" type="454e4749" display_nr="1" anz_rows="4" anz_cols="14" scroll_offset="' ..
            id * 100 + 100 .. '" scroll_index="' .. id * 100 + 100 ..
            '"><Data><Data>0</Data><Data>1</Data><Data>0</Data><Data>3</Data></Data></Widget><Widget index="3" type="4d414352" display_nr="1" has_focus="true" has_scrollfocus="true" x="14" anz_rows="5" anz_cols="2" scroll_offset="64" scroll_index="64"><Data><Data>0</Data><Data>0</Data><Data>0</Data><Data>3</Data></Data></Widget></View></MA>'
    local fileName = 'tempfileview.xml'

    cmd('SelectDrive 1')

    local filePath = gma.show.getvar('PATH') .. '/importexport/' .. fileName
    local file = io.open(filePath, "w")
    file:write(viewXML) -- ecriture de l'xml généré dans le fichier .xml et import
    file:close()
    cmd("Import \"" .. fileName .. "\" View " .. startView + id)

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
    createMacroLine(macroId, 6, 'Copy View ' .. startView + id .. ' At View 301 /o')
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
        cmd('Store Macro 1.' .. x .. '.4 "Appearance Macro ' .. startMacro .. ' Thru ' .. startMacro + trackId ..
                ' /h=0 /s=100 /br=100"')
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

        -- Creation de la vue
        createView(trackId, trackName)

        -- Update macro appearance
        updateMacroAppearance(trackId)

        -- Creation du TC
        cmd('Store Timecode ' .. startTimecode + trackId .. ' "' .. trackName .. '"')
        cmd('Assign Timecode ' .. startTimecode + trackId .. ' /offset=' .. textinput('Offset TC ?', '0h0m0s'))

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
