if ( SERVER ) then return end 

EblanskyQFM = EblanskyQFM or {}

local QFM = EblanskyQFM
local DATA_DIR = "eblansky_qfm"
local DATA_FILE = DATA_DIR .. "/folders.json"
local qfmEnabled = CreateClientConVar( "eblansky_qfm_enabled", "1", true, false, "Enable Eblansky QFM." )
local INSTALL_VERSION = 25

local COL = {
	bg = Color( 54, 54, 54 ),
	bg2 = Color( 69, 73, 80 ),
	bg3 = Color( 92, 92, 92 ),
	border = Color( 92, 92, 92 ),
	softBorder = Color( 55, 55, 55 ),
	text = Color( 235, 235, 235 ),
	muted = Color( 190, 190, 190 ),
	icon = Color( 217, 217, 217 ),
	iconStroke = Color( 148, 148, 148 ),
	cyan = Color( 45, 179, 186 ),
	red = Color( 232, 54, 54 ),
	menu = Color( 105, 105, 105 ),
	menuHover = Color( 134, 134, 134 )
}

local visibleText
local getFolder
local addMenuOption
local clearDragState
local dropDraggedTabOnFolder
local finishFolderDrag

local MAT = { 
	folder = Material( "eblansky_qfm/folder.png", "noclamp smooth" ),
	polygon = Material( "eblansky_qfm/polygon.png", "noclamp smooth" ),
	star = Material( "eblansky_qfm/star.png", "noclamp smooth" ),
	zakrep = Material( "eblansky_qfm/zakrep.png", "noclamp smooth" ),
	us = Material( "eblansky_qfm/us.png", "noclamp smooth" ),
	kz = Material( "eblansky_qfm/kz.png", "noclamp smooth" ),
	by = Material( "eblansky_qfm/by.png", "noclamp smooth" ),
	ua = Material( "eblansky_qfm/ua.png", "noclamp smooth" ),
	ru = Material( "eblansky_qfm/ru.png", "noclamp smooth" ),
	tabLine = Material( "eblansky_qfm/tabs/line.png", "noclamp smooth" ),
	tabStartLine = Material( "eblansky_qfm/tabs/startline.png", "noclamp smooth" ),
	tabEndLine = Material( "eblansky_qfm/tabs/endline.png", "noclamp smooth" ),
	tabStartEdge = Material( "eblansky_qfm/tabs/startedge.png", "noclamp smooth" ),
	tabEndEdge = Material( "eblansky_qfm/tabs/endedge.png", "noclamp smooth" ),
	arrow = Material( "eblansky_qfm/tabs/arrow.png", "noclamp smooth" )
}

local ICON_NATIVE = {
	all = { 24, 24 },
	fav = { 24, 23 },
	folder = { 30, 24 },
	pin = { 10, 10 }
}

surface.CreateFont( "EblanskyQFM.Small", {
	font = "Roboto",
	size = 10,
	weight = 500,
	antialias = true
} )

surface.CreateFont( "EblanskyQFM.Text", {
	font = "Roboto",
	size = 12,
	weight = 500,
	antialias = true
} )

surface.CreateFont( "EblanskyQFM.Bold", {
	font = "Roboto",
	size = 16,
	weight = 800,
	antialias = true
} )

surface.CreateFont( "EblanskyQFM.BigLabel", {
	font = "Roboto",
	size = 11,
	weight = 900,
	antialias = true
} )

QFM.Data = QFM.Data or {
	favorites = {},
	folders = {},
	selected = {},
	activePreset = "all",
	layoutBig = true
}

local LANG_PROMPT = "Language; Язык; Мова; тіл."
local LANG_ORDER = { "us", "kz", "by", "ua", "ru" }
local LANG = {
	us = {
		all = "All", favorites = "Favorites", folder = "Folder",
		createFolder = "Create folder", createNewFolder = "Create new folder",
		minimize = "Minimize", maximize = "Maximize", fade = LANG_PROMPT,
		addTab = "Add tab", configure = "Configure ", pin = "Pin ", unpin = "Unpin ", delete = "Delete ",
		copyName = "Copy name", addCategoryFavorite = "Add category to Favorites", addFavorite = "Add to Favorites",
		addTo = "Add to ", removeCurrent = "Remove from current",
		noFolders1 = "You have not created folders, create", noFolders2 = "one by right-clicking the field",
		done = "Done!", contains = "Contains:", description = "description....", newName = "New name",
		deleteFolderTitle = "Delete ", deleteButton = "Delete"
	},
	ru = {
		all = "Всё", favorites = "Избранное", folder = "Папка",
		createFolder = "Создать папку", createNewFolder = "Создать новую папку",
		minimize = "Минимизировать", maximize = "Максимизировать", fade = LANG_PROMPT,
		addTab = "Добавить вкладку", configure = "Настроить ", pin = "Закрепить ", unpin = "Открепить ", delete = "Удалить ",
		copyName = "Копировать имя", addCategoryFavorite = "Добавить категорию в Избранное", addFavorite = "Добавить в Избранное",
		addTo = "Добавить в ", removeCurrent = "Убрать из текущего",
		noFolders1 = "Вы не создавали папок, создайте", noFolders2 = "одну нажав ПКМ по полю",
		done = "Готово!", contains = "Содержит:", description = "описание....", newName = "Новое название",
		deleteFolderTitle = "Удалить ", deleteButton = "Удалить"
	},
	kz = {
		all = "Барлығы", favorites = "Таңдаулы", folder = "Қалта",
		createFolder = "Қалта жасау", createNewFolder = "Жаңа қалта жасау",
		minimize = "Кішірейту", maximize = "Үлкейту", fade = LANG_PROMPT,
		addTab = "Қойынды қосу", configure = "Баптау ", pin = "Бекіту ", unpin = "Бекітуден алу ", delete = "Жою ",
		copyName = "Атын көшіру", addCategoryFavorite = "Санатты таңдаулыға қосу", addFavorite = "Таңдаулыға қосу",
		addTo = "Қосу: ", removeCurrent = "Ағымдағыдан алып тастау",
		noFolders1 = "Сіз қалта жасамадыңыз, өрісті", noFolders2 = "ПКМ басып біреуін жасаңыз",
		done = "Дайын!", contains = "Ішінде:", description = "сипаттама....", newName = "Жаңа атау",
		deleteFolderTitle = "Жою ", deleteButton = "Жою"
	},
	ua = {
		all = "Усе", favorites = "Обране", folder = "Папка",
		createFolder = "Створити папку", createNewFolder = "Створити нову папку",
		minimize = "Мінімізувати", maximize = "Максимізувати", fade = LANG_PROMPT,
		addTab = "Додати вкладку", configure = "Налаштувати ", pin = "Закріпити ", unpin = "Відкріпити ", delete = "Видалити ",
		copyName = "Скопіювати ім'я", addCategoryFavorite = "Додати категорію в Обране", addFavorite = "Додати в Обране",
		addTo = "Додати до ", removeCurrent = "Прибрати з поточного",
		noFolders1 = "Ви не створювали папок, створіть", noFolders2 = "одну, натиснувши ПКМ по полю",
		done = "Готово!", contains = "Містить:", description = "опис....", newName = "Нова назва",
		deleteFolderTitle = "Видалити ", deleteButton = "Видалити"
	},
	by = {
		all = "Усё", favorites = "Абранае", folder = "Папка",
		createFolder = "Стварыць папку", createNewFolder = "Стварыць новую папку",
		minimize = "Мінімізаваць", maximize = "Максімізаваць", fade = LANG_PROMPT,
		addTab = "Дадаць укладку", configure = "Наладзіць ", pin = "Замацаваць ", unpin = "Адмацаваць ", delete = "Выдаліць ",
		copyName = "Скапіраваць імя", addCategoryFavorite = "Дадаць катэгорыю ў Абранае", addFavorite = "Дадаць у Абранае",
		addTo = "Дадаць у ", removeCurrent = "Прыбраць з бягучага",
		noFolders1 = "Вы не стваралі папак, стварыце", noFolders2 = "адну, націснуўшы ПКМ па полі",
		done = "Гатова!", contains = "Змяшчае:", description = "апісанне....", newName = "Новая назва",
		deleteFolderTitle = "Выдаліць ", deleteButton = "Выдаліць"
	}
}

local function hasLanguage()
	return LANG[ tostring( QFM.Data.language or "" ) ] != nil
end

local function tr( key )
	local lang = LANG[ tostring( QFM.Data.language or "" ) ] or LANG.ru
	return lang[ key ] or LANG.ru[ key ] or key
end

local function shuffledLanguages()
	local out = table.Copy( LANG_ORDER )
	for index = #out, 2, -1 do
		local swap = math.random( index )
		out[ index ], out[ swap ] = out[ swap ], out[ index ]
	end
	return out
end

local function normalizeData()
	QFM.Data.favorites = istable( QFM.Data.favorites ) and QFM.Data.favorites or {}
	QFM.Data.folders = istable( QFM.Data.folders ) and QFM.Data.folders or {}
	QFM.Data.selected = istable( QFM.Data.selected ) and QFM.Data.selected or {}
	QFM.Data.activePreset = tostring( QFM.Data.activePreset or "all" )
	QFM.Data.layoutBig = QFM.Data.layoutBig != false
	if ( QFM.Data.language != nil and !LANG[ tostring( QFM.Data.language ) ] ) then QFM.Data.language = nil end
	for tabId, value in pairs( QFM.Data.favorites ) do
		if ( value != true ) then QFM.Data.favorites[ tabId ] = nil end
	end

	for _, folder in ipairs( QFM.Data.folders ) do
		folder.id = folder.id or ( "folder_" .. util.CRC( SysTime() .. folder.name .. math.random() ) )
		folder.name = tostring( folder.name or tr( "folder" ) )
		folder.description = tostring( folder.description or "" )
		folder.entries = istable( folder.entries ) and folder.entries or {}
		folder.tabs = istable( folder.tabs ) and folder.tabs or {}
		folder.tabsOrder = istable( folder.tabsOrder ) and folder.tabsOrder or {}
		folder.pinned = folder.pinned == true
		for tabId, value in pairs( folder.tabs ) do
			if ( value != true ) then folder.tabs[ tabId ] = nil end
		end

		local present = {}
		local cleanOrder = {}
		for _, tabId in ipairs( folder.tabsOrder ) do
			tabId = tostring( tabId )
			if ( folder.tabs[ tabId ] and !present[ tabId ] ) then
				cleanOrder[ #cleanOrder + 1 ] = tabId
				present[ tabId ] = true
			end
		end
		for tabId in pairs( folder.tabs ) do
			tabId = tostring( tabId )
			if ( !present[ tabId ] and !tabId:StartsWith( "label:" ) and !tabId:StartsWith( "tab:" ) ) then
				cleanOrder[ #cleanOrder + 1 ] = tabId
				present[ tabId ] = true
			end
		end
		folder.tabsOrder = cleanOrder
	end
end

local function getTopTabs()
	local out = {}
	if ( !IsValid( g_SpawnMenu ) or !IsValid( g_SpawnMenu:GetToolMenu() ) ) then return out end

	local toolMenu = g_SpawnMenu:GetToolMenu()
	local used = {}

	for index, item in ipairs( toolMenu.Items or {} ) do
		item.EQFMOriginalIndex = item.EQFMOriginalIndex or index
		local panel = item.Panel
		local tab = item.Tab or ( IsValid( panel ) and panel.PropertySheetTab or nil )
		local rawId = IsValid( panel ) and panel.GetTabID and panel:GetTabID() or item.EQFMOriginalIndex
		local id = tostring( rawId or index )
		item.EQFMQTabID = item.EQFMQTabID or id
		local label = item.Name or ( IsValid( tab ) and tab.GetText and tab:GetText() ) or ( IsValid( panel ) and panel.TabName ) or id
		label = visibleText( label )
		used[ id ] = true
		local legacyKey = "label:" .. label:lower()
		out[ #out + 1 ] = {
			id = id,
			rawId = rawId,
			key = "tab:" .. label:lower() .. "@" .. tostring( item.EQFMOriginalIndex or index ),
			legacyKey = legacyKey,
			label = label,
			panel = panel,
			tab = tab
		}
	end

	for tabId, toolTable in ipairs( spawnmenu.GetTools() or {} ) do
		local id = tostring( tabId )
		if ( !used[ id ] ) then
			local panel = toolMenu:GetToolPanel( tabId )
			local label = toolTable.Label or toolTable.Name or id
			label = visibleText( label )
			local legacyKey = "label:" .. label:lower()
			out[ #out + 1 ] = {
				id = id,
				rawId = tabId,
				key = "tab:" .. label:lower() .. "@" .. tostring( tabId ),
				legacyKey = legacyKey,
				label = label,
				panel = panel,
				tab = IsValid( panel ) and panel.PropertySheetTab or nil
			}
		end
	end

	local labelCounts = {}
	for _, tab in ipairs( out ) do
		labelCounts[ tab.legacyKey ] = ( labelCounts[ tab.legacyKey ] or 0 ) + 1
	end
	for _, tab in ipairs( out ) do
		tab.ambiguousLabel = ( labelCounts[ tab.legacyKey ] or 0 ) > 1
	end

	return out
end

local function tabStorageIds( tabOrId )
	if ( istable( tabOrId ) ) then
		return tostring( tabOrId.id ), tabOrId.key and tostring( tabOrId.key ) or nil, tabOrId.legacyKey and tostring( tabOrId.legacyKey ) or nil
	end

	return tostring( tabOrId ), nil
end

local function hasStoredTab( storage, tab )
	return storage and ( storage[ tab.id ] == true or ( tab.key and storage[ tab.key ] == true ) or ( tab.legacyKey and !tab.ambiguousLabel and storage[ tab.legacyKey ] == true ) )
end

local function getTabByStoredId( tabId )
	tabId = tostring( tabId )
	for _, tab in ipairs( getTopTabs() ) do
		if ( tab.id == tabId or tab.key == tabId or tab.legacyKey == tabId ) then return tab end
	end
end

local function setStoredTab( storage, tabOrId, enabled )
	if ( !storage ) then return end

	local tab = istable( tabOrId ) and tabOrId or getTabByStoredId( tabOrId )
	local tabId, tabKey, legacyKey = tabStorageIds( tab or tabOrId )
	local value = enabled == true and true or nil
	storage[ tabId ] = value
	if ( tabKey ) then storage[ tabKey ] = value end
	if ( legacyKey ) then storage[ legacyKey ] = value end
end

local function syncFolderTabs( folder )
	if ( !folder ) then return false end

	local topTabs = getTopTabs()
	if ( #topTabs == 0 ) then return false end

	folder.tabsOrder = istable( folder.tabsOrder ) and folder.tabsOrder or {}
	local cleanOrder = {}
	local present = {}
	local changed = false

	for _, tabId in ipairs( folder.tabsOrder ) do
		tabId = tostring( tabId )
		local tab = getTabByStoredId( tabId )
		local canonical = tab and tab.id or tabId
		if ( !canonical:StartsWith( "label:" ) and !canonical:StartsWith( "tab:" ) and !present[ canonical ] ) then
			cleanOrder[ #cleanOrder + 1 ] = canonical
			present[ canonical ] = true
			if ( canonical != tabId ) then changed = true end
		else
			changed = true
		end
	end

	local cleanTabs = {}
	for _, tabId in ipairs( cleanOrder ) do
		local tab = getTabByStoredId( tabId )
		if ( tab ) then
			setStoredTab( cleanTabs, tab, true )
		else
			cleanTabs[ tabId ] = true
		end
	end

	for key, value in pairs( folder.tabs or {} ) do
		if ( cleanTabs[ key ] != value ) then
			changed = true
			break
		end
	end
	for key, value in pairs( cleanTabs ) do
		if ( folder.tabs[ key ] != value ) then
			changed = true
			break
		end
	end

	folder.tabsOrder = cleanOrder
	folder.tabs = cleanTabs
	return changed
end

local function migrateTabStorage()
	local changed = false
	local topTabs = getTopTabs()

	for _, tab in ipairs( topTabs ) do
		if ( hasStoredTab( QFM.Data.favorites, tab ) and tab.key and QFM.Data.favorites[ tab.key ] != true ) then
			QFM.Data.favorites[ tab.key ] = true
			changed = true
		end
	end

	for _, folder in ipairs( QFM.Data.folders or {} ) do
		if ( syncFolderTabs( folder ) ) then changed = true end
		for _, tab in ipairs( topTabs ) do
			if ( hasStoredTab( folder.tabs, tab ) and tab.key and folder.tabs[ tab.key ] != true ) then
				folder.tabs[ tab.key ] = true
				changed = true
			end
		end
	end

	if ( changed ) then QFM.Save() end
end

local function addOrderedTab( folder, tabOrId )
	local tabId = tabStorageIds( tabOrId )
	setStoredTab( folder.tabs, tabOrId, true )
	folder.tabsOrder = istable( folder.tabsOrder ) and folder.tabsOrder or {}

	for _, existing in ipairs( folder.tabsOrder ) do
		if ( tostring( existing ) == tabId ) then return end
	end

	folder.tabsOrder[ #folder.tabsOrder + 1 ] = tabId
	syncFolderTabs( folder )
end

local function tabLabelById( tabId )
	tabId = tostring( tabId )
	for _, tab in ipairs( getTopTabs() ) do
		if ( tab.id == tabId or tab.key == tabId or tab.legacyKey == tabId ) then return tab.label end
	end
	return tabId
end

local function removeOrderedTab( folder, tabId )
	tabId = tostring( tabId )
	local tab = getTabByStoredId( tabId )
	setStoredTab( folder.tabs, tab or tabId, false )
	for index = #folder.tabsOrder, 1, -1 do
		local existing = tostring( folder.tabsOrder[ index ] )
		if ( existing == tabId or ( tab and ( existing == tab.id or existing == tab.key or existing == tab.legacyKey ) ) ) then
			table.remove( folder.tabsOrder, index )
		end
	end
	syncFolderTabs( folder )
end

local function moveOrderedTab( folder, tabId, targetTabId, placeAfter )
	tabId = tostring( tabId )
	targetTabId = targetTabId and tostring( targetTabId ) or nil
	local tab = getTabByStoredId( tabId )
	local targetTab = targetTabId and getTabByStoredId( targetTabId ) or nil
	local canonicalTabId = tab and tab.id or tabId
	folder.tabsOrder = istable( folder.tabsOrder ) and folder.tabsOrder or {}

	for index = #folder.tabsOrder, 1, -1 do
		local existing = tostring( folder.tabsOrder[ index ] )
		if ( existing == tabId or ( tab and ( existing == tab.id or existing == tab.key or existing == tab.legacyKey ) ) ) then
			table.remove( folder.tabsOrder, index )
		end
	end

	local insertAt = #folder.tabsOrder + 1
	if ( targetTabId ) then
		for index, existing in ipairs( folder.tabsOrder ) do
			existing = tostring( existing )
			if ( existing == targetTabId or ( targetTab and ( existing == targetTab.id or existing == targetTab.key or existing == targetTab.legacyKey ) ) ) then
				insertAt = index + ( placeAfter and 1 or 0 )
				break
			end
		end
	end

	table.insert( folder.tabsOrder, insertAt, canonicalTabId )
	setStoredTab( folder.tabs, tab or tabId, true )
	syncFolderTabs( folder )
end

local function moveFolderTo( folder, targetFolder, placeAfter )
	if ( !folder or folder == targetFolder ) then return end
	if ( targetFolder and folder.pinned != targetFolder.pinned ) then return end

	for index = #QFM.Data.folders, 1, -1 do
		if ( QFM.Data.folders[ index ] == folder ) then
			table.remove( QFM.Data.folders, index )
			break
		end
	end

	local insertAt = #QFM.Data.folders + 1
	if ( targetFolder ) then
		for index, candidate in ipairs( QFM.Data.folders ) do
			if ( candidate == targetFolder ) then
				insertAt = index + ( placeAfter and 1 or 0 )
				break
			end
		end
	end

	table.insert( QFM.Data.folders, insertAt, folder )
	QFM.Save()
	QFM.Refresh()
end

local function moveFolderBefore( folder, beforeFolder )
	moveFolderTo( folder, beforeFolder, false )
end

local function tabIdFromSheetItem( item )
	if ( !item ) then return "" end
	if ( item.EQFMQTabID ) then return tostring( item.EQFMQTabID ) end
	if ( IsValid( item.Panel ) and item.Panel.GetTabID ) then return tostring( item.Panel:GetTabID() or "" ) end
	return tostring( item.EQFMOriginalIndex or "" )
end

local function applyToolMenuTabOrder( toolMenu, preferredOrder )
	if ( !IsValid( toolMenu ) or !istable( toolMenu.Items ) ) then return end

	for index, item in ipairs( toolMenu.Items ) do
		item.EQFMOriginalIndex = item.EQFMOriginalIndex or index
		item.EQFMQTabID = item.EQFMQTabID or tostring( IsValid( item.Panel ) and item.Panel.GetTabID and item.Panel:GetTabID() or item.EQFMOriginalIndex )
	end

	local rank = {}
	if ( istable( preferredOrder ) ) then
		for index, tabId in ipairs( preferredOrder ) do
			rank[ tostring( tabId ) ] = index
		end
	end

	table.sort( toolMenu.Items, function( a, b )
		local ar = rank[ tabIdFromSheetItem( a ) ]
		local br = rank[ tabIdFromSheetItem( b ) ]

		if ( ar and br ) then return ar < br end
		if ( ar ) then return true end
		if ( br ) then return false end

		return ( a.EQFMOriginalIndex or 9999 ) < ( b.EQFMOriginalIndex or 9999 )
	end )

	if ( IsValid( toolMenu.tabScroller ) and istable( toolMenu.tabScroller.Panels ) ) then
		toolMenu.tabScroller.Panels = {}
		for _, item in ipairs( toolMenu.Items ) do
			if ( IsValid( item.Tab ) ) then
				toolMenu.tabScroller.Panels[ #toolMenu.tabScroller.Panels + 1 ] = item.Tab
			end
		end
		toolMenu.tabScroller:InvalidateLayout( true )
	end

	toolMenu:InvalidateLayout( true )
end

local function addTabListMenu( menu, targetTable, afterAdd )
	migrateTabStorage()
	for _, tab in ipairs( getTopTabs() ) do
		local enabled = hasStoredTab( targetTable, tab )
		addMenuOption( menu, enabled and ( tab.label .. " - V" ) or tab.label, function()
			setStoredTab( targetTable, tab, !enabled )
			QFM.Save()
			QFM.ApplyToolTabs()
			QFM.Refresh()
			if ( afterAdd ) then afterAdd( tab ) end
		end )
	end
end

function QFM.GetActivePreset()
	return QFM.Data.activePreset or "all"
end

function QFM.SetActivePreset( presetId )
	QFM.Data.activePreset = presetId or "all"
	QFM.Save()
	QFM.ApplyToolTabs( true )
	QFM.Refresh()
end

function QFM.ApplyToolTabs( resetScroll )
	if ( !IsValid( g_SpawnMenu ) or !IsValid( g_SpawnMenu:GetToolMenu() ) ) then return end
	migrateTabStorage()

	local presetId = QFM.GetActivePreset()
	local allowed
	local preferredOrder

	if ( presetId == "favorites" ) then
		allowed = QFM.Data.favorites
	elseif ( presetId and presetId:StartsWith( "folder:" ) ) then
		local folder = getFolder( presetId:sub( 8 ) )
		allowed = folder and folder.tabs or nil
		preferredOrder = folder and folder.tabsOrder or nil
	end

	local firstAllowed
	local activeStillVisible = false
	local orderIndex = {}

	if ( presetId == "favorites" ) then
		local index = 1
		for _, tab in ipairs( getTopTabs() ) do
			if ( hasStoredTab( QFM.Data.favorites, tab ) ) then
				orderIndex[ tab.id ] = index
				index = index + 1
			end
		end
	elseif ( presetId and presetId:StartsWith( "folder:" ) ) then
		local folder = getFolder( presetId:sub( 8 ) )
		if ( folder ) then
			for index, tabId in ipairs( folder.tabsOrder or {} ) do
				orderIndex[ tostring( tabId ) ] = index
			end
		end
	end

	for _, tab in ipairs( getTopTabs() ) do
		local visible = !allowed or hasStoredTab( allowed, tab )
		if ( IsValid( tab.tab ) ) then
			tab.tab:SetVisible( visible )
			tab.tab:SetMouseInputEnabled( visible )
			tab.tab:SetZPos( orderIndex[ tab.id ] or tonumber( tab.id ) or 999 )
			if ( tab.tab.EQFMDragWrapped and tab.tab.EQFMDragWrapVersion != INSTALL_VERSION ) then
				if ( tab.tab.EQFMOldPressed ) then tab.tab.OnMousePressed = tab.tab.EQFMOldPressed end
				if ( tab.tab.EQFMOldReleased ) then tab.tab.OnMouseReleased = tab.tab.EQFMOldReleased end
				tab.tab.EQFMDragWrapped = nil
				tab.tab.EQFMOldPressed = nil
				tab.tab.EQFMOldReleased = nil
				tab.tab.EQFMDragWrapVersion = nil
			end
			if ( !tab.tab.EQFMDragWrapped ) then
				tab.tab.EQFMDragWrapped = true
				tab.tab.EQFMDragWrapVersion = INSTALL_VERSION
				local oldPressed = tab.tab.OnMousePressed
				local oldReleased = tab.tab.OnMouseReleased
				tab.tab.EQFMOldPressed = oldPressed
				tab.tab.EQFMOldReleased = oldReleased
				tab.tab.OnMousePressed = function( s, code )
					if ( code == MOUSE_LEFT ) then
						QFM.DragTab = { id = tab.id, key = tab.key, label = tab.label }
						QFM.DragText = tab.label
						QFM.DragKind = "tab"
						s:MouseCapture( true )
					end
					if ( oldPressed ) then return oldPressed( s, code ) end
				end
				tab.tab.OnMouseReleased = function( s, code )
					s:MouseCapture( false )
					if ( code == MOUSE_LEFT and QFM.DragTab and QFM.DragTab.id == tab.id and dropDraggedTabOnFolder and dropDraggedTabOnFolder() ) then
						clearDragState()
						return
					end
					timer.Simple( 0.1, function()
						if ( QFM.DragTab and QFM.DragTab.id == tab.id ) then
							clearDragState()
						end
					end )
					if ( oldReleased ) then return oldReleased( s, code ) end
				end
			end
		end

		if ( visible and !firstAllowed ) then firstAllowed = tab end
		if ( visible and IsValid( tab.panel ) and tab.panel:IsVisible() ) then activeStillVisible = true end
		if ( IsValid( tab.panel ) and !visible ) then tab.panel:SetVisible( false ) end
	end

	if ( !activeStillVisible and firstAllowed and IsValid( firstAllowed.tab ) ) then
		timer.Simple( 0, function()
			if ( IsValid( firstAllowed.tab ) ) then firstAllowed.tab:DoClick() end
		end )
	end

	local toolMenu = g_SpawnMenu:GetToolMenu()
	if ( IsValid( toolMenu ) ) then
		applyToolMenuTabOrder( toolMenu, preferredOrder )
		toolMenu:InvalidateLayout( true )
		if ( resetScroll and IsValid( toolMenu.tabScroller ) ) then
			if ( toolMenu.tabScroller.SetScroll ) then toolMenu.tabScroller:SetScroll( 0 ) end
			toolMenu.tabScroller:InvalidateLayout( true )
		end
		for _, child in ipairs( toolMenu:GetChildren() ) do
			child:InvalidateLayout( true )
		end
	end
end

function QFM.Load()
	local raw = file.Exists( DATA_FILE, "DATA" ) and file.Read( DATA_FILE, "DATA" ) or nil
	local decoded = raw and util.JSONToTable( raw ) or nil

	if ( istable( decoded ) ) then
		QFM.Data = decoded
	end

	normalizeData()
end

function QFM.Save()
	if ( !file.Exists( DATA_DIR, "DATA" ) ) then file.CreateDir( DATA_DIR ) end
	file.Write( DATA_FILE, util.TableToJSON( QFM.Data, true ) )
end

local function trimName( value )
	value = tostring( value or "" ):Trim()
	return value == "" and nil or value
end

local function entryId( tabId, categoryName, itemName )
	if ( itemName and itemName != "" ) then
		return tostring( tabId ) .. "\t" .. tostring( categoryName ) .. "\t" .. tostring( itemName )
	end

	return tostring( tabId ) .. "\t" .. tostring( categoryName )
end

visibleText = function( value )
	value = tostring( value or "" )
	if ( value:StartsWith( "#" ) ) then value = value:sub( 2 ) end
	return language.GetPhrase( value )
end

getFolder = function( id )
	for _, folder in ipairs( QFM.Data.folders ) do
		if ( folder.id == id ) then return folder end
	end
end

local function activeEntries( presetId )
	if ( presetId == "favorites" ) then return QFM.Data.favorites end
	if ( presetId and presetId:StartsWith( "folder:" ) ) then
		local folder = getFolder( presetId:sub( 8 ) )
		return folder and folder.entries or {}
	end
end

local function addEntry( presetId, id )
	local entries = activeEntries( presetId )
	if ( !entries ) then return end

	entries[ id ] = true
	QFM.Save()
end

local function removeEntry( presetId, id )
	local entries = activeEntries( presetId )
	if ( !entries ) then return end

	entries[ id ] = nil
	QFM.Save()
end

local function createFolder( callback )
	local name = tr( "folder" ) .. " " .. tostring( #QFM.Data.folders + 1 )
	local folder = {
		id = "folder_" .. util.CRC( name .. SysTime() .. math.random() ),
		name = name,
		description = "",
		entries = {},
		tabs = {},
		tabsOrder = {},
		pinned = false
	}

	table.insert( QFM.Data.folders, folder )
	QFM.Save()
	QFM.Refresh()

	if ( callback ) then callback( folder ) end
end

local function renameFolder( folder )
	Derma_StringRequest( "Q-Folder's menu", tr( "newName" ), folder.name or "", function( text )
		text = trimName( text )
		if ( !text ) then return end

		folder.name = text
		QFM.Save()
		QFM.Refresh()
	end )
end

local function deleteFolder( folder )
	Derma_Query( tr( "deleteFolderTitle" ) .. folder.name .. "?", "Q-Folder's menu", tr( "deleteButton" ), function()
		for index, candidate in ipairs( QFM.Data.folders ) do
			if ( candidate == folder ) then
				table.remove( QFM.Data.folders, index )
				break
			end
		end

		for tabId, selected in pairs( QFM.Data.selected ) do
			if ( selected == "folder:" .. folder.id ) then QFM.Data.selected[ tabId ] = "all" end
		end
		if ( QFM.Data.activePreset == "folder:" .. folder.id ) then
			QFM.Data.activePreset = "all"
		end

		QFM.Save()
		QFM.ApplyToolTabs()
		QFM.Refresh()
	end, "Отмена" )
end

local function drawArrowIcon( x, y, size, expanded )
	surface.SetMaterial( MAT.arrow )
	surface.SetDrawColor( color_white )
	surface.DrawTexturedRectRotated( x + size / 2, y + size / 2, size, size, expanded and 180 or 0 )
end

local function drawDiamond( x, y, size, color )
	draw.NoTexture()
	surface.SetDrawColor( color )
	surface.DrawPoly( {
		{ x = x + size / 2, y = y },
		{ x = x + size, y = y + size / 2 },
		{ x = x + size / 2, y = y + size },
		{ x = x, y = y + size / 2 }
	} )
end

local function drawStar( cx, cy, radius, color )
	local points = {}
	for i = 0, 9 do
		local ang = math.rad( -90 + i * 36 )
		local r = ( i % 2 == 0 ) and radius or radius * 0.45
		points[ #points + 1 ] = { x = cx + math.cos( ang ) * r, y = cy + math.sin( ang ) * r }
	end

	draw.NoTexture()
	surface.SetDrawColor( color )
	surface.DrawPoly( points )
end

local function drawFolder( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawRect( x, y + h * 0.28, w, h * 0.72 )
	surface.DrawRect( x + 1, y + 1, w * 0.42, h * 0.35 )
	surface.SetDrawColor( COL.iconStroke )
	surface.DrawOutlinedRect( x, y + h * 0.28, w, h * 0.72 )
end

local function drawMaterialAspect( mat, x, y, maxW, maxH, nativeW, nativeH )
	local scale = math.min( maxW / nativeW, maxH / nativeH )
	local w = math.floor( nativeW * scale )
	local h = math.floor( nativeH * scale )
	surface.SetMaterial( mat )
	surface.SetDrawColor( color_white )
	surface.DrawTexturedRect( math.floor( x + ( maxW - w ) / 2 ), math.floor( y + ( maxH - h ) / 2 ), w, h )
	return w, h
end

local function drawQFMTabSkin( x, y, w, h )
	draw.RoundedBox( 0, x, y, w, h, Color( 75, 75, 75 ) )
	surface.SetDrawColor( COL.softBorder )
	surface.DrawOutlinedRect( x, y, w, h )
end

local function marqueeOffset( overflow )
	if ( overflow <= 0 ) then return 0 end

	local hold = 2.5
	local move = math.Clamp( overflow / 28, 0.8, 2.4 )
	local cycle = hold * 2 + move * 2
	local t = CurTime() % cycle

	if ( t < hold ) then return 0 end
	t = t - hold
	if ( t < move ) then return -overflow * math.ease.InOutSine( t / move ) end
	t = t - move
	if ( t < hold ) then return -overflow end
	t = t - hold

	return -overflow + overflow * math.ease.InOutSine( math.Clamp( t / move, 0, 1 ) )
end

local function drawMarqueeText( panel, text, font, x, y, w, color, shadowColor )
	text = tostring( text or "" )
	surface.SetFont( font )
	local tw = surface.GetTextSize( text )
	local overflow = math.max( 0, tw - w )
	local offset = marqueeOffset( overflow )

	if ( overflow <= 0 ) then
		if ( shadowColor ) then
			draw.SimpleText( text, font, x + w / 2 + 1, y + 1, shadowColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		draw.SimpleText( text, font, x + w / 2, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		return
	end

	local sx, sy = panel:LocalToScreen( x, y - 10 )
	render.SetScissorRect( sx, sy, sx + w, sy + 20, true )
	if ( shadowColor ) then
		draw.SimpleText( text, font, x + offset + 1, y + 1, shadowColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	draw.SimpleText( text, font, x + offset, y, color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	render.SetScissorRect( 0, 0, 0, 0, false )
end

clearDragState = function()
	QFM.DragTab = nil
	QFM.DragFolder = nil
	QFM.DragText = nil
	QFM.DragKind = nil

	if ( IsValid( QFM.DragGhost ) ) then
		QFM.DragGhost:Remove()
	end
	QFM.DragGhost = nil
end

local function pointInPanel( panel, x, y )
	if ( !IsValid( panel ) ) then return false end

	local px, py = panel:LocalToScreen( 0, 0 )
	return x >= px and y >= py and x <= px + panel:GetWide() and y <= py + panel:GetTall()
end

local function getFolderButtonAtCursor()
	local x, y = input.GetCursorPos()
	local checked = {}

	local function scanBar( bar )
		if ( !IsValid( bar ) or checked[ bar ] ) then return end
		checked[ bar ] = true

		for _, button in ipairs( bar.Buttons or {} ) do
			if ( IsValid( button ) and button.Folder and pointInPanel( button, x, y ) ) then
				return button
			end
		end
	end

	if ( IsValid( g_SpawnMenu ) and IsValid( g_SpawnMenu:GetToolMenu() ) ) then
		local toolMenu = g_SpawnMenu:GetToolMenu()
		for _, panel in pairs( toolMenu.ToolPanels or {} ) do
			local found = IsValid( panel ) and scanBar( panel.EQFMBar )
			if ( found ) then return found end
		end
		for _, tab in ipairs( getTopTabs() ) do
			local found = IsValid( tab.panel ) and scanBar( tab.panel.EQFMBar )
			if ( found ) then return found end
		end
	end
end

dropDraggedTabOnFolder = function()
	if ( !QFM.DragTab ) then return false end

	local button = getFolderButtonAtCursor()
	if ( !IsValid( button ) or !button.Folder ) then return false end

	addOrderedTab( button.Folder, QFM.DragTab )
	QFM.Save()
	QFM.ApplyToolTabs()
	QFM.Refresh()
	return true
end

finishFolderDrag = function()
	local drag = QFM.DragFolder
	if ( !drag or !drag.folder or !IsValid( drag.bar ) ) then return false end

	local mx, my = input.GetCursorPos()
	local sx, sy = drag.startX or mx, drag.startY or my
	if ( math.abs( mx - sx ) <= 8 and math.abs( my - sy ) <= 8 ) then return false end

	local best
	local bestDistance = math.huge
	for _, other in ipairs( drag.bar.Buttons or {} ) do
		if ( IsValid( other ) and other.Folder and other.Folder != drag.folder and other.Folder.pinned == drag.folder.pinned ) then
			local ox, oy = other:LocalToScreen( 0, 0 )
			local cx = ox + other:GetWide() / 2
			local cy = oy + other:GetTall() / 2
			local distance = math.abs( mx - cx ) + math.abs( my - cy ) * 2
			if ( distance < bestDistance ) then
				best = other
				bestDistance = distance
			end
		end
	end

	if ( IsValid( best ) ) then
		local bx = best:LocalToScreen( 0, 0 )
		moveFolderTo( drag.folder, best.Folder, mx > bx + best:GetWide() / 2 )
	else
		moveFolderTo( drag.folder, nil, false )
	end

	return true
end

local function updateDragGhost()
	if ( !QFM.DragText or !input.IsMouseDown( MOUSE_LEFT ) ) then return end
	if ( !IsValid( g_SpawnMenu ) ) then return end

	if ( !IsValid( QFM.DragGhost ) ) then
		local ghost = vgui.Create( "DPanel", g_SpawnMenu )
		ghost:SetMouseInputEnabled( false )
		ghost:SetKeyboardInputEnabled( false )
		ghost:SetZPos( 32767 )
		ghost.Paint = function( s, w, h )
			drawQFMTabSkin( 0, 0, w, h )
			local textX = s.Kind == "folder" and 8 or 22
			if ( s.Kind == "folder" ) then
				drawMaterialAspect( MAT.folder, 5, 3, 14, 14, ICON_NATIVE.folder[ 1 ], ICON_NATIVE.folder[ 2 ] )
				textX = 23
			else
				draw.SimpleText( "+", "EblanskyQFM.Text", 10, h / 2, Color( 180, 220, 180 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			draw.SimpleText( s.Label or "", "EblanskyQFM.Text", textX, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
		QFM.DragGhost = ghost
	end

	local ghost = QFM.DragGhost
	ghost.Label = tostring( QFM.DragText or "" )
	ghost.Kind = QFM.DragKind or ( QFM.DragFolder and "folder" or "tab" )

	surface.SetFont( "EblanskyQFM.Text" )
	local tw = surface.GetTextSize( ghost.Label )
	ghost:SetSize( math.Clamp( tw + ( ghost.Kind == "folder" and 34 or 30 ), 74, 190 ), 20 )

	local sx, sy = input.GetCursorPos()
	local px, py = g_SpawnMenu:LocalToScreen( 0, 0 )
	ghost:SetPos( sx - px + 12, sy - py + 12 )
	ghost:MoveToFront()
end

local function drawBang( x, y )
	draw.RoundedBox( 0, x, y, 34, 38, COL.cyan )
	draw.SimpleText( "!", "DermaLarge", x + 17, y + 16, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
end

local function makeMenu()
	local menu = DermaMenu()
	menu.Paint = function( self, w, h )
		draw.RoundedBox( 2, 0, 0, w, h, COL.menu )
		surface.SetDrawColor( COL.softBorder )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	return menu
end

addMenuOption = function( menu, label, func )
	local option = menu:AddOption( label, func )
	option:SetTextColor( color_white )
	option.Paint = function( self, w, h )
		if ( self.Hovered ) then
			surface.SetDrawColor( COL.menuHover )
			surface.DrawRect( 0, 0, w, h )
		end
	end
	return option
end

local function setLanguage( langId )
	if ( !LANG[ langId ] ) then return end

	QFM.Data.language = langId
	QFM.Save()
	QFM.Refresh()
end

local function openLanguageMenu()
	local x, y = input.GetCursorPos()
	timer.Simple( 0, function()
		local menu = makeMenu()
		for _, langId in ipairs( shuffledLanguages() ) do
			addMenuOption( menu, langId:upper(), function()
				setLanguage( langId )
			end )
		end
		menu:Open( x, y )
	end )
end

local function openGlobalMenu( panel )
	local menu = makeMenu()
	if ( !hasLanguage() ) then
		addMenuOption( menu, LANG_PROMPT, openLanguageMenu )
		menu:Open()
		return
	end
	addMenuOption( menu, tr( "createFolder" ), function()
		createFolder( function( folder )
			if ( IsValid( panel ) ) then panel:SetPreset( "folder:" .. folder.id ) end
		end )
	end )
	addMenuOption( menu, QFM.Data.layoutBig and tr( "minimize" ) or tr( "maximize" ), function()
		if ( IsValid( panel ) ) then
			QFM.Data.layoutBig = !QFM.Data.layoutBig
			QFM.Save()
			QFM.Refresh()
		end
	end )
	addMenuOption( menu, LANG_PROMPT, openLanguageMenu )
	menu:Open()
end

local function openAllMenu( panel )
	local menu = makeMenu()
	addMenuOption( menu, tr( "createFolder" ), function()
		createFolder( function( folder )
			if ( IsValid( panel ) ) then panel:SetPreset( "folder:" .. folder.id ) end
		end )
	end )
	menu:Open()
end

local function openFavoritesMenu()
	local menu = makeMenu()
	addMenuOption( menu, tr( "addTab" ), function()
		local submenu = makeMenu()
		addTabListMenu( submenu, QFM.Data.favorites )
		submenu:Open()
	end )
	addTabListMenu( menu, QFM.Data.favorites )
	menu:Open()
end

local function openFolderMenu( panel, folder )
	local menu = makeMenu()
	addMenuOption( menu, tr( "createNewFolder" ), function() createFolder() end )
	addMenuOption( menu, tr( "configure" ) .. folder.name, function()
		if ( IsValid( panel ) ) then panel:OpenEditor( folder ) end
	end )
	addMenuOption( menu, ( folder.pinned and tr( "unpin" ) or tr( "pin" ) ) .. folder.name, function()
		folder.pinned = !folder.pinned
		QFM.Save()
		QFM.Refresh()
	end )
	addMenuOption( menu, tr( "delete" ) .. folder.name, function() deleteFolder( folder ) end )
	menu:Open()
end

local function findToolPanel( tabId )
	if ( !IsValid( g_SpawnMenu ) or !IsValid( g_SpawnMenu:GetToolMenu() ) ) then return end

	local toolMenu = g_SpawnMenu:GetToolMenu()
	local direct = toolMenu:GetToolPanel( tabId )
	if ( IsValid( direct ) ) then return direct end

	for id, panel in pairs( toolMenu.ToolPanels or {} ) do
		if ( tostring( id ) == tostring( tabId ) ) then return panel end
	end
end

function QFM.Apply( panel )
	if ( !IsValid( panel ) or !IsValid( panel.List ) or !IsValid( panel.List.pnlCanvas ) ) then return end

	local search = IsValid( panel.SearchBar ) and panel.SearchBar:GetValue():Trim():lower() or ""

	for _, category in ipairs( panel.List.pnlCanvas:GetChildren() ) do
		local categoryName = category.EQFMName or ""
		local categorySearch = search == "" or ( IsValid( category.Header ) and string.find( visibleText( category.Header:GetText() ):lower(), search, nil, true ) )
		local count = 0

		for _, item in ipairs( category:GetChildren() ) do
			if ( item == category.Header ) then continue end

			local text = visibleText( item.Text or item:GetText() or item.Name ):lower()
			local itemSearch = search == "" or categorySearch or string.find( text, search, nil, true )
			local visible = itemSearch

			item:SetVisible( visible )
			item:InvalidateLayout()
			if ( visible ) then count = count + 1 end
		end

		local categoryVisible = count > 0 or categorySearch
		category:SetVisible( categoryVisible )
		if ( search != "" ) then category:SetExpanded( categoryVisible ) end
		category:InvalidateLayout()
	end

	panel.List.pnlCanvas:InvalidateLayout()
	panel.List:InvalidateLayout()
end

local function installEntryMenus( panel )
	local tabId = tostring( panel:GetTabID() or "" )

	for _, category in ipairs( panel.List.pnlCanvas:GetChildren() ) do
		local categoryName = category.EQFMName or ""

		if ( IsValid( category.Header ) and !category.Header.EQFMWrapped ) then
			category.Header.EQFMWrapped = true
			category.Header.DoRightClick = function()
				local id = entryId( tabId, categoryName )
				local menu = makeMenu()
				addMenuOption( menu, tr( "addCategoryFavorite" ), function() addEntry( "favorites", id ) end )
				for _, folder in ipairs( QFM.Data.folders ) do
					addMenuOption( menu, tr( "addTo" ) .. folder.name, function() addEntry( "folder:" .. folder.id, id ) end )
				end
				addMenuOption( menu, tr( "createFolder" ), function()
					createFolder( function( folder ) addEntry( "folder:" .. folder.id, id ) end )
				end )
				menu:Open()
			end
		end

		for _, item in ipairs( category:GetChildren() ) do
			if ( item == category.Header or item.EQFMWrapped ) then continue end

			item.EQFMWrapped = true
			item.DoRightClick = function( button )
				local id = entryId( tabId, categoryName, button.Name )
				local menu = makeMenu()
				addMenuOption( menu, tr( "copyName" ), function() SetClipboardText( button.Name ) end )
				addMenuOption( menu, tr( "addFavorite" ), function() addEntry( "favorites", id ) end )
				for _, folder in ipairs( QFM.Data.folders ) do
					addMenuOption( menu, tr( "addTo" ) .. folder.name, function() addEntry( "folder:" .. folder.id, id ) end )
				end
				addMenuOption( menu, tr( "removeCurrent" ), function()
					removeEntry( QFM.Data.selected[ tabId ] or "all", id )
					QFM.Apply( panel )
				end )
				menu:Open()
			end
		end
	end
end

local function markCategories( panel, toolTable )
	local children = panel.List.pnlCanvas:GetChildren()
	local index = 1

	for _, source in ipairs( toolTable.Items or {} ) do
		if ( istable( source ) and IsValid( children[ index ] ) ) then
			children[ index ].EQFMName = source.ItemName or source.Text or tostring( index )
			index = index + 1
		end
	end
end

local PANEL = {}

function PANEL:Init()
	self:SetTall( 60 )
	self.Buttons = {}
	self.Selected = "all"
end

function PANEL:SetToolPanel( panel )
	self.ToolPanel = panel
	self.TabID = tostring( panel:GetTabID() or "" )
	self.Selected = QFM.GetActivePreset()
	self:Rebuild()
end

function PANEL:SetPreset( presetId )
	QFM.SetActivePreset( presetId or "all" )
end

function PANEL:OnMousePressed( code )
	if ( code == MOUSE_RIGHT ) then openGlobalMenu( self ) end
end

function PANEL:Paint( w, h )
	draw.RoundedBox( 0, 0, 0, w, h, self.Faded and Color( 54, 54, 54, 190 ) or COL.bg )
	surface.SetDrawColor( COL.border )
	surface.DrawOutlinedRect( 0, 0, w, h )

	if ( self.PaintLanguage ) then
		draw.SimpleText( LANG_PROMPT, QFM.Data.layoutBig and "EblanskyQFM.Bold" or "EblanskyQFM.Text", QFM.Data.layoutBig and 14 or 5, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
end

function PANEL:ClearButtons()
	for _, child in ipairs( self:GetChildren() ) do child:Remove() end
	self.Buttons = {}
end

function PANEL:AddLanguageButton( langId, x, y, size )
	local button = vgui.Create( "DButton", self )
	button:SetText( "" )
	button:SetPos( x, y )
	button:SetSize( size, size )
	button.OnMouseWheeled = function( _, delta ) return self:OnMouseWheeled( delta ) end
	button.DoClick = function()
		setLanguage( langId )
	end
	button.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, s.Hovered and Color( 104, 104, 104 ) or COL.bg3 )
		local mat = MAT[ langId ]
		if ( mat ) then
			drawMaterialAspect( mat, 3, 3, w - 6, h - 6, 24, 24 )
		else
			draw.SimpleText( langId:upper(), "EblanskyQFM.Text", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
	end
	return button
end

function PANEL:RebuildLanguage()
	self:ClearButtons()
	local big = QFM.Data.layoutBig
	self:SetTall( big and 60 or 25 )

	local h = self:GetTall()
	local textX = big and 14 or 5
	local buttonSize = big and 32 or 18
	local gap = 2
	local textW = math.min( big and 170 or 118, math.max( 80, self:GetWide() - ( buttonSize + gap ) * #LANG_ORDER - 8 ) )
	local x = textX + textW + 4
	local y = math.floor( ( h - buttonSize ) / 2 )

	self.LanguageOrder = self.LanguageOrder or shuffledLanguages()
	for _, langId in ipairs( self.LanguageOrder ) do
		if ( x + buttonSize <= self:GetWide() - 1 ) then
			self:AddLanguageButton( langId, x, y, buttonSize )
		end
		x = x + buttonSize + gap
	end

	self.PaintLanguage = true
	self:InvalidateParent( true )
end

function PANEL:AddPresetButton( presetId, label, icon, x, y, w, h, big, folder )
	local button = vgui.Create( "DButton", self )
	button:SetText( "" )
	button:SetPos( x, y )
	button:SetSize( w, h )
	button.PresetID = presetId
	button.Label = label
	button.Icon = icon
	button.Big = big
	button.Folder = folder
	button.OnMouseWheeled = function( _, delta )
		return self:OnMouseWheeled( delta )
	end
	button.OnMousePressed = function( s, code )
		if ( code == MOUSE_LEFT and folder ) then
			s.DragStartX, s.DragStartY = input.GetCursorPos()
			s.MouseDown = true
			QFM.DragFolder = { folder = folder, label = label, bar = self, startX = s.DragStartX, startY = s.DragStartY }
			QFM.DragText = label
			QFM.DragKind = "folder"
			s:MouseCapture( true )
		end
	end
	button.OnMouseReleased = function( s, code )
		s:MouseCapture( false )
		local sx, sy = s.DragStartX or 0, s.DragStartY or 0
		local mx, my = input.GetCursorPos()
		s.MouseDown = nil

		if ( code == MOUSE_LEFT and folder and QFM.DragTab and !QFM.DragTab.sourceFolder ) then
			addOrderedTab( folder, QFM.DragTab )
			QFM.Save()
			QFM.ApplyToolTabs()
			QFM.Refresh()
			clearDragState()
			return
		end

		if ( code == MOUSE_LEFT and folder and ( math.abs( mx - sx ) > 8 or math.abs( my - sy ) > 8 ) ) then
			finishFolderDrag()
			clearDragState()
			return
		end

		if ( QFM.DragFolder and QFM.DragFolder.folder == folder ) then
			clearDragState()
		end
		if ( code == MOUSE_LEFT and s.DoClick ) then s:DoClick() end
		if ( code == MOUSE_RIGHT and s.DoRightClick ) then s:DoRightClick() end
	end
	button.DoClick = function() self:SetPreset( presetId ) end
	button.DoRightClick = function()
		if ( presetId == "all" ) then
			openAllMenu( self )
		elseif ( presetId == "favorites" ) then
			openFavoritesMenu()
		elseif ( folder ) then
			openFolderMenu( self, folder )
		else
			openGlobalMenu( self )
		end
	end
	button.Paint = function( s, bw, bh )
		local selected = QFM.GetActivePreset() == s.PresetID
		draw.RoundedBox( 0, 0, 0, bw, bh, selected and COL.bg2 or ( s.Hovered and Color( 104, 104, 104 ) or COL.bg3 ) )

		if ( folder and QFM.DragTab and pointInPanel( s, input.GetCursorPos() ) ) then
			surface.SetDrawColor( 120, 190, 120, 70 )
			surface.DrawRect( 0, 0, bw, bh )
		end

		if ( selected ) then
			surface.SetDrawColor( 255, 153, 0 )
			surface.DrawRect( 0, bh - 2, bw, 2 )
		end

		local mat = s.Icon == "all" and MAT.polygon or s.Icon == "fav" and MAT.star or MAT.folder
		local native = s.Icon == "all" and ICON_NATIVE.all or s.Icon == "fav" and ICON_NATIVE.fav or ICON_NATIVE.folder
		local iw = big and 30 or 15
		local ih = big and 30 or 15
		local ix = bw / 2 - iw / 2
		local iy = big and 7 or bh / 2 - ih / 2
		drawMaterialAspect( mat, ix, iy, iw, ih, native[ 1 ], native[ 2 ] )

		if ( folder and folder.pinned ) then
			local ps = big and 11 or 7
			drawMaterialAspect( MAT.zakrep, 2, 2, ps, ps, ICON_NATIVE.pin[ 1 ], ICON_NATIVE.pin[ 2 ] )
		end

		if ( big ) then
			drawMarqueeText( s, s.Label, "EblanskyQFM.BigLabel", 4, bh - 9, bw - 8, COL.text, color_black )
		end
	end

	if ( !big ) then button:SetTooltip( label ) end
	self.Buttons[ #self.Buttons + 1 ] = button
	return button
end

function PANEL:AddMessage( x, y, w, h )
	local msg = vgui.Create( "DPanel", self )
	msg:SetPos( x, y )
	msg:SetSize( w, h )
	msg.OnMousePressed = function( _, code )
		if ( code == MOUSE_RIGHT ) then openGlobalMenu( self ) end
	end
	msg.Paint = function( _, mw, mh )
		drawBang( 0, 0 )
		draw.SimpleText( tr( "noFolders1" ), "EblanskyQFM.Bold", 44, 13, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( tr( "noFolders2" ), "EblanskyQFM.Bold", 44, 29, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
end

function PANEL:OnMouseWheeled( delta )
	self.ScrollX = math.Clamp( ( self.ScrollX or 0 ) - delta * 32, 0, self.MaxScrollX or 0 )
	self:Rebuild()
	return true
end

function PANEL:Rebuild()
	if ( !hasLanguage() ) then
		self:RebuildLanguage()
		return
	end

	self:ClearButtons()
	self.PaintLanguage = nil
	local folderCount = #QFM.Data.folders
	local big = QFM.Data.layoutBig
	self:SetTall( big and 60 or 25 )
	self.ScrollX = math.Clamp( self.ScrollX or 0, 0, self.MaxScrollX or 0 )

	if ( big ) then
		local x = 13
		local arrow = vgui.Create( "DButton", self )
		arrow:SetText( "" )
		arrow:SetPos( 1, 1 )
		arrow:SetSize( 10, 58 )
		arrow.DoClick = function()
			QFM.Data.layoutBig = false
			QFM.Save()
			QFM.Refresh()
		end
		arrow.Paint = function( _, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, COL.bg2 )
			drawArrowIcon( 1, 25, 8, true )
		end

		self:AddPresetButton( "all", tr( "all" ), "all", x, 3, 56, 54, true )
		x = x + 58
		self:AddPresetButton( "favorites", tr( "favorites" ), "fav", x, 3, 56, 54, true )
		x = x + 58

		for _, folder in ipairs( QFM.Data.folders ) do
			if ( folder.pinned ) then
				self:AddPresetButton( "folder:" .. folder.id, folder.name, "folder", x, 3, 56, 54, true, folder )
				x = x + 58
			end
		end

		local normalStart = x + 2
		x = normalStart - ( self.ScrollX or 0 )
		for _, folder in ipairs( QFM.Data.folders ) do
			if ( !folder.pinned ) then
				if ( x > normalStart - 60 and x < self:GetWide() - 2 ) then
					self:AddPresetButton( "folder:" .. folder.id, folder.name, "folder", x, 3, 56, 54, true, folder )
				end
				x = x + 58
			end
		end

		self.MaxScrollX = math.max( 0, x + ( self.ScrollX or 0 ) - self:GetWide() + 4 )

		if ( folderCount == 0 ) then self:AddMessage( x, 10, math.max( 0, self:GetWide() - x - 3 ), 38 ) end
	else
		local x = 1
		local arrow = vgui.Create( "DButton", self )
		arrow:SetText( "" )
		arrow:SetPos( x, 3 )
		arrow:SetSize( 12, 19 )
		arrow.DoClick = function()
			QFM.Data.layoutBig = true
			QFM.Save()
			QFM.Refresh()
		end
		arrow.Paint = function( _, w, h )
			draw.RoundedBox( 0, 0, 0, w, h, COL.bg2 )
			drawArrowIcon( 2, 6, 8, false )
		end
		x = x + 14

		self:AddPresetButton( "all", tr( "all" ), "all", x, 3, 19, 19, false )
		x = x + 21
		self:AddPresetButton( "favorites", tr( "favorites" ), "fav", x, 3, 19, 19, false )
		x = x + 21

		for _, folder in ipairs( QFM.Data.folders ) do
			if ( folder.pinned ) then
				self:AddPresetButton( "folder:" .. folder.id, folder.name, "folder", x, 3, 19, 19, false, folder )
				x = x + 21
			end
		end

		local normalStart = x + 2
		x = normalStart - ( self.ScrollX or 0 )
		for _, folder in ipairs( QFM.Data.folders ) do
			if ( !folder.pinned ) then
				if ( x > normalStart - 21 and x < self:GetWide() - 2 ) then
					self:AddPresetButton( "folder:" .. folder.id, folder.name, "folder", x, 3, 19, 19, false, folder )
				end
				x = x + 21
			end
		end

		self.MaxScrollX = math.max( 0, x + ( self.ScrollX or 0 ) - self:GetWide() + 4 )

		if ( folderCount == 0 ) then
			local msg = vgui.Create( "DPanel", self )
			msg:SetPos( x, 3 )
			msg:SetSize( math.max( 40, self:GetWide() - x - 3 ), 19 )
			msg.OnMousePressed = function( _, code ) if ( code == MOUSE_RIGHT ) then openGlobalMenu( self ) end end
			msg.Paint = function( _, w, h )
				draw.RoundedBox( 0, 0, 0, 19, h, COL.cyan )
				draw.SimpleText( "!", "EblanskyQFM.Bold", 9, 9, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( tr( "noFolders1" ) .. " " .. tr( "noFolders2" ), "EblanskyQFM.Text", 25, 9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			end
		end
	end

	self:InvalidateParent( true )
end

function PANEL:PerformLayout()
	if ( self.LastWide != self:GetWide() ) then
		self.LastWide = self:GetWide()
		timer.Simple( 0, function()
			if ( IsValid( self ) ) then self:Rebuild() end
		end )
	end
end

function PANEL:OpenEditor( folder )
	if ( !IsValid( self.ToolPanel ) or !IsValid( self.ToolPanel.Content ) ) then return end

	local content = self.ToolPanel.Content
	for _, child in ipairs( content:GetCanvas():GetChildren() ) do child:SetVisible( false ) end

	local editor = vgui.Create( "DPanel" )
	editor:SetTall( 405 )
	editor:Dock( TOP )
	editor.Folder = folder
	editor.Paint = function( _, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 52, 52, 52 ) )
		surface.SetDrawColor( COL.border )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	content:AddItem( editor )

	local icon = vgui.Create( "DButton", editor )
	icon:SetText( "" )
	icon:SetPos( 12, 32 )
	icon:SetSize( 82, 70 )
	icon.Paint = function( _, w, h )
		draw.RoundedBox( 3, 0, 0, w, h, Color( 170, 170, 170 ) )
		drawFolder( 8, 15, 48, 28, Color( 230, 230, 230 ) )
	end

	local name = vgui.Create( "DTextEntry", editor )
	name:SetPos( 104, 14 )
	name:SetSize( 228, 24 )
	name:SetFont( "EblanskyQFM.Bold" )
	name:SetText( folder.name )

	local close = vgui.Create( "DButton", editor )
	close:SetText( "D" )
	close:SetFont( "EblanskyQFM.Bold" )
	close:SetTextColor( color_white )
	close:SetPos( 336, 14 )
	close:SetSize( 20, 24 )
	close.DoClick = function()
		deleteFolder( folder )
		editor:Remove()
	end
	close.Paint = function( s, w, h ) draw.RoundedBox( 0, 0, 0, w, h, s.Hovered and Color( 255, 70, 70 ) or COL.red ) end

	local desc
	local function saveEditor()
		folder.name = trimName( name:GetValue() ) or folder.name
		folder.description = IsValid( desc ) and desc:GetValue() or folder.description or ""
		QFM.Save()
		QFM.Refresh()
	end
	name.OnEnter = saveEditor

	desc = vgui.Create( "DTextEntry", editor )
	desc:SetPos( 104, 44 )
	desc:SetSize( 250, 58 )
	desc:SetMultiline( true )
	desc:SetText( folder.description or "" )
	desc:SetPlaceholderText( tr( "description" ) )
	desc.OnLoseFocus = function( entry )
		folder.description = entry:GetValue()
		QFM.Save()
	end

	local contains = vgui.Create( "DPanel", editor )
	contains:SetPos( 12, 116 )
	contains:SetSize( 342, 198 )
	contains.Chips = {}
	contains.Paint = function( _, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 92, 92, 92 ) )
		surface.SetDrawColor( COL.softBorder )
		surface.DrawOutlinedRect( 0, 0, w, h )
		draw.SimpleText( tr( "contains" ), "EblanskyQFM.Text", 4, 9, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
	QFM.ActiveContains = contains
	editor.OnRemove = function()
		if ( QFM.ActiveContains == contains ) then QFM.ActiveContains = nil end
	end
	contains.FinishQFMDrag = function( pnl, force )
		if ( !QFM.DragTab ) then return false end

		local mx, my = input.GetCursorPos()
		local px, py = pnl:LocalToScreen( 0, 0 )
		local inside = mx >= px and my >= py and mx <= px + pnl:GetWide() and my <= py + pnl:GetTall()

		if ( inside or force ) then
			if ( QFM.DragTab.sourceFolder == folder ) then
				local localX = mx - px
				local localY = my - py
				local row = {}
				local nearestRowY
				local nearestRowDistance = math.huge

				for _, other in ipairs( pnl.Chips or {} ) do
					if ( IsValid( other ) ) then
						local ox, oy = other:GetPos()
						local centerY = oy + other:GetTall() / 2
						local rowDistance = math.abs( localY - centerY )
						if ( rowDistance < nearestRowDistance ) then
							nearestRowDistance = rowDistance
							nearestRowY = oy
						end
					end
				end

				for _, other in ipairs( pnl.Chips or {} ) do
					if ( IsValid( other ) ) then
						local ox, oy = other:GetPos()
						if ( nearestRowY and math.abs( oy - nearestRowY ) <= 2 ) then
							row[ #row + 1 ] = other
						end
					end
				end

				table.sort( row, function( a, b )
					local ax = a:GetPos()
					local bx = b:GetPos()
					return ax < bx
				end )

				local target
				local targetIndex
				local targetZoneRight
				for index, other in ipairs( row ) do
					local ox = other:GetPos()
					local nextChip = row[ index + 1 ]
					local zoneRight = pnl:GetWide() - 6
					if ( IsValid( nextChip ) ) then
						local nx = nextChip:GetPos()
						zoneRight = nx - 3
					end

					if ( localX < ox ) then
						target = other
						targetIndex = index
						targetZoneRight = zoneRight
						break
					end
					if ( localX <= zoneRight ) then
						target = other
						targetIndex = index
						targetZoneRight = zoneRight
						break
					end
				end

				if ( !IsValid( target ) and #row > 0 ) then
					target = row[ #row ]
					targetIndex = #row
					targetZoneRight = pnl:GetWide() - 6
				end

				local dragIndex
				for index, other in ipairs( row ) do
					if ( IsValid( other ) and other.TabID == QFM.DragTab.id ) then
						dragIndex = index
						break
					end
				end

				local placeAfter = true
				if ( dragIndex and targetIndex ) then
					placeAfter = dragIndex < targetIndex
				elseif ( IsValid( target ) ) then
					local tx = target:GetPos()
					placeAfter = targetIndex == #row and localX > math.max( tx + target:GetWide(), targetZoneRight or tx )
				end

				if ( IsValid( target ) and target.TabID == QFM.DragTab.id ) then
					local tx = target:GetPos()
					if ( dragIndex and localX < tx + target:GetWide() / 2 and IsValid( row[ dragIndex - 1 ] ) ) then
						target = row[ dragIndex - 1 ]
						placeAfter = false
					elseif ( dragIndex and IsValid( row[ dragIndex + 1 ] ) ) then
						target = row[ dragIndex + 1 ]
						placeAfter = true
					end
				end

				if ( IsValid( target ) and target.TabID != QFM.DragTab.id ) then
					moveOrderedTab( folder, QFM.DragTab.id, target.TabID, placeAfter )
				else
					moveOrderedTab( folder, QFM.DragTab.id )
				end
			else
				addOrderedTab( folder, QFM.DragTab )
			end
		elseif ( QFM.DragTab.sourceFolder == folder ) then
			removeOrderedTab( folder, QFM.DragTab.id )
		else
			return false
		end

		QFM.Save()
		QFM.ApplyToolTabs()
		QFM.Refresh()
		clearDragState()
		if ( IsValid( pnl ) ) then pnl:RebuildChips() end
		return true
	end
	contains.OnMouseReleased = function( pnl )
		pnl:FinishQFMDrag()
	end
	contains.Think = function( pnl )
		if ( !QFM.DragTab or input.IsMouseDown( MOUSE_LEFT ) ) then return end
		pnl:FinishQFMDrag()
	end
	contains.RebuildChips = function( pnl )
		syncFolderTabs( folder )
		for _, chip in ipairs( pnl.Chips or {} ) do
			if ( IsValid( chip ) ) then chip:Remove() end
		end
		pnl.Chips = {}

		local x = 6
		local y = 24
		for _, tabId in ipairs( folder.tabsOrder or {} ) do
			if ( folder.tabs[ tostring( tabId ) ] ) then
				local label = tabLabelById( tabId )
				surface.SetFont( "EblanskyQFM.Text" )
				local maxChipW = math.max( 96, pnl:GetWide() - 12 )
				local tw = math.Clamp( surface.GetTextSize( label ) + 34, 96, maxChipW )
				if ( x + tw > pnl:GetWide() - 6 ) then
					x = 6
					y = y + 24
				end

				local chip = vgui.Create( "DButton", pnl )
				chip:SetText( "" )
				chip:SetPos( x, y )
				chip:SetSize( tw, 20 )
				chip.TabID = tostring( tabId )
				chip.Label = label
				chip.Paint = function( s, w, h )
					drawQFMTabSkin( 0, 0, w, h )

					if ( s.Hovered ) then
						surface.SetDrawColor( 255, 255, 255, 24 )
						surface.DrawRect( 0, 0, w, h )
					end

					draw.SimpleText( s.Label, "EblanskyQFM.Text", 22, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				end
				local remove = vgui.Create( "DButton", chip )
				remove:SetText( "" )
				remove:SetPos( 4, 4 )
				remove:SetSize( 11, 11 )
				remove.DoClick = function()
					removeOrderedTab( folder, chip.TabID )
					QFM.Save()
					QFM.ApplyToolTabs()
					pnl:RebuildChips()
				end
				remove.Paint = function( s, w, h )
					draw.RoundedBox( 0, 0, 0, w, h, s.Hovered and COL.red or Color( 55, 55, 55 ) )
					draw.SimpleText( "x", "EblanskyQFM.Small", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				end
				chip.OnMousePressed = function( s, code )
					if ( code == MOUSE_LEFT ) then
						local mx, my = input.GetCursorPos()
						QFM.DragTab = { id = s.TabID, label = s.Label, sourceFolder = folder, sourcePanel = pnl, startX = mx, startY = my }
						QFM.DragText = s.Label
						QFM.DragKind = "tab"
						s:MouseCapture( true )
					end
				end
				chip.OnMouseReleased = function( s, code )
					s:MouseCapture( false )
					if ( code == MOUSE_LEFT and QFM.DragTab and QFM.DragTab.sourcePanel == pnl ) then
						pnl:FinishQFMDrag()
					end
				end
				pnl.Chips[ #pnl.Chips + 1 ] = chip
				x = x + tw + 6
			end
		end
	end
	contains:RebuildChips()

	local addTab = vgui.Create( "DButton", editor )
	addTab:SetText( tr( "addTab" ) )
	addTab:SetFont( "EblanskyQFM.Bold" )
	addTab:SetTextColor( color_white )
	addTab:SetPos( 12, 320 )
	addTab:SetSize( 342, 24 )
	addTab.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, s.Hovered and COL.menuHover or COL.bg3 )
		draw.SimpleText( "+", "EblanskyQFM.Bold", w - 12, h / 2 - 1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	addTab.DoClick = function()
		local menu = makeMenu()
		for _, tab in ipairs( getTopTabs() ) do
			addMenuOption( menu, tab.label, function()
				addOrderedTab( folder, tab )
				QFM.Save()
				QFM.ApplyToolTabs()
				if ( IsValid( contains ) ) then contains:RebuildChips() end
			end )
		end
		menu:Open()
	end

	local done = vgui.Create( "DButton", editor )
	done:SetText( tr( "done" ) )
	done:SetFont( "EblanskyQFM.Bold" )
	done:SetTextColor( color_white )
	done:SetPos( 12, 350 )
	done:SetSize( 342, 28 )
	done.Paint = function( s, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, s.Hovered and Color( 255, 172, 46 ) or Color( 255, 153, 0 ) )
	end
	done.DoClick = function()
		saveEditor()
		editor:Remove()
		if ( IsValid( self.ToolPanel ) and self.ToolPanel.ActiveCPName ) then
			local cp = controlpanel.Get( self.ToolPanel.ActiveCPName )
			if ( IsValid( cp ) ) then self.ToolPanel:SetActive( cp ) end
		end
	end

	editor.PerformLayout = function( pnl, w )
		local margin = 12
		local right = math.max( margin + 1, w - margin )
		local nameX = 104
		local deleteW = 20
		local fieldRight = right - deleteW - 4
		local fieldW = math.max( 80, fieldRight - nameX )
		local fullW = math.max( 80, right - margin )

		name:SetPos( nameX, 14 )
		name:SetSize( fieldW, 24 )
		close:SetPos( fieldRight + 4, 14 )
		close:SetSize( deleteW, 24 )

		desc:SetPos( nameX, 44 )
		desc:SetSize( math.max( 80, right - nameX ), 58 )

		contains:SetPos( margin, 116 )
		contains:SetSize( fullW, 198 )

		addTab:SetPos( margin, 320 )
		addTab:SetSize( fullW, 24 )
		done:SetPos( margin, 350 )
		done:SetSize( fullW, 28 )
	end

	editor:InvalidateLayout( true )
end

vgui.Register( "EblanskyQFMBar", PANEL, "DPanel" )

function QFM.InstallPanel( panel, toolTable )
	if ( !IsValid( panel ) or !IsValid( panel.SearchBar ) or !IsValid( panel.List ) ) then return false end

	if ( panel.EQFMInstalled and panel.EQFMInstallVersion == INSTALL_VERSION and IsValid( panel.EQFMBar ) ) then
		return false
	end

	if ( IsValid( panel.EQFMBar ) ) then
		panel.EQFMBar:Remove()
	end

	panel.EQFMInstalled = nil

	markCategories( panel, toolTable )

	local parent = panel
	if ( !IsValid( parent ) ) then return false end

	panel.EQFMInstalled = true
	panel.EQFMInstallVersion = INSTALL_VERSION

	local bar = vgui.Create( "EblanskyQFMBar", parent )
	bar:Dock( TOP )
	bar:DockMargin( 0, 0, 0, 5 )
	bar:SetZPos( -100 )
	bar:SetToolPanel( panel )
	panel.EQFMBar = bar

	if ( IsValid( panel.HorizontalDivider ) ) then
		panel.HorizontalDivider:SetZPos( 10 )
	end

	if ( panel.SearchBar.EQFMOldOnValueChange == nil ) then
		panel.SearchBar.EQFMOldOnValueChange = panel.SearchBar.OnValueChange or false
	end
	panel.SearchBar.OnValueChange = function( searchBar, value )
		local old = panel.SearchBar.EQFMOldOnValueChange
		if ( old ) then old( searchBar, value ) end
		QFM.Apply( panel )
	end

	QFM.Apply( panel )

	parent:InvalidateLayout( true )
	panel:InvalidateLayout( true )

	return true
end

function QFM.Install()
	if ( !qfmEnabled:GetBool() ) then return 0 end
	if ( !IsValid( g_SpawnMenu ) or !IsValid( g_SpawnMenu:GetToolMenu() ) ) then return 0 end

	local toolMenu = g_SpawnMenu:GetToolMenu()
	local installed = 0
	for tabId, toolTable in ipairs( spawnmenu.GetTools() ) do
		if ( QFM.InstallPanel( toolMenu:GetToolPanel( tabId ), toolTable ) ) then
			installed = installed + 1
		end
	end
	for _, item in ipairs( toolMenu.Items or {} ) do
		if ( IsValid( item.Panel ) and QFM.InstallPanel( item.Panel, { Items = {} } ) ) then
			installed = installed + 1
		end
	end

	QFM.ApplyToolTabs()

	return installed
end

function QFM.Refresh()
	if ( !qfmEnabled:GetBool() ) then return end
	if ( !IsValid( g_SpawnMenu ) or !IsValid( g_SpawnMenu:GetToolMenu() ) ) then return end

	for _, panel in pairs( g_SpawnMenu:GetToolMenu().ToolPanels or {} ) do
		if ( IsValid( panel.EQFMBar ) ) then panel.EQFMBar:Rebuild() end
		QFM.Apply( panel )
	end
	for _, tab in ipairs( getTopTabs() ) do
		local panel = tab.panel
		if ( IsValid( panel ) ) then
			if ( IsValid( panel.EQFMBar ) ) then panel.EQFMBar:Rebuild() end
			QFM.Apply( panel )
		end
	end
end

function QFM.InstallSoon()
	timer.Simple( 0, function()
		local installed = QFM.Install()
		if ( installed == 0 ) then
			timer.Simple( 0.25, QFM.Install )
		end
	end )
end

QFM.Load()

hook.Add( "SpawnMenuCreated", "EblanskyQFM.Install", function()
	QFM.InstallSoon()
end )

hook.Add( "PostReloadToolsMenu", "EblanskyQFM.Install", function()
	QFM.InstallSoon()
end )

hook.Remove( "Think", "EblanskyQFM.InstallMissingPanels" )

hook.Add( "Think", "EblanskyQFM.ClearStaleDragGhost", function()
	if ( !QFM.DragText ) then return end

	if ( input.IsMouseDown( MOUSE_LEFT ) ) then
		updateDragGhost()
		return
	end

	local contains = IsValid( QFM.DragTab and QFM.DragTab.sourcePanel ) and QFM.DragTab.sourcePanel or QFM.ActiveContains
	if ( QFM.DragTab and IsValid( contains ) and contains.FinishQFMDrag and contains:FinishQFMDrag() ) then
		return
	end

	if ( QFM.DragTab ) then
		if ( dropDraggedTabOnFolder() ) then
			clearDragState()
			return
		end
	end

	if ( QFM.DragFolder ) then
		finishFolderDrag()
	end
	clearDragState()
end )

hook.Remove( "HUDPaint", "EblanskyQFM.DragGhost" )

hook.Remove( "SpawnMenuOpened", "EblanskyQFM.Install" )

if ( concommand.Remove ) then
	concommand.Remove( "eblansky_qfm_reload" )
end

concommand.Add( "eblansky_qfm_reload", function()
	local activePreset = QFM.GetActivePreset()
	QFM.Load()
	if ( activePreset and activePreset != "" ) then
		QFM.Data.activePreset = activePreset
	end

	if ( IsValid( g_SpawnMenu ) and IsValid( g_SpawnMenu:GetToolMenu() ) ) then
		local toolMenu = g_SpawnMenu:GetToolMenu()
		local resetPanel = function( panel )
			if ( !IsValid( panel ) ) then return end
			if ( IsValid( panel.PropertySheetTab ) and panel.PropertySheetTab.EQFMDragWrapped ) then
				local tab = panel.PropertySheetTab
				if ( tab.EQFMOldPressed ) then tab.OnMousePressed = tab.EQFMOldPressed end
				if ( tab.EQFMOldReleased ) then tab.OnMouseReleased = tab.EQFMOldReleased end
				tab.EQFMDragWrapped = nil
				tab.EQFMOldPressed = nil
				tab.EQFMOldReleased = nil
				tab.EQFMDragWrapVersion = nil
			end
			if ( IsValid( panel.SearchBar ) and panel.SearchBar.EQFMOldOnValueChange != nil ) then
				panel.SearchBar.OnValueChange = panel.SearchBar.EQFMOldOnValueChange != false and panel.SearchBar.EQFMOldOnValueChange or nil
				panel.SearchBar.EQFMOldOnValueChange = nil
			end
			if ( IsValid( panel.EQFMBar ) ) then panel.EQFMBar:Remove() end
			panel.EQFMBar = nil
			panel.EQFMInstalled = nil
			panel.EQFMInstallVersion = nil
		end

		for _, panel in pairs( toolMenu.ToolPanels or {} ) do
			resetPanel( panel )
		end
		for _, tab in ipairs( getTopTabs() ) do
			resetPanel( tab.panel )
		end
	end

	local installed = QFM.Install()
	QFM.Refresh()
	QFM.ApplyToolTabs( true )
	MsgN( "[Eblansky QFM] installed panels: " .. tostring( installed ) )
end )

QFM.InstallSoon()
