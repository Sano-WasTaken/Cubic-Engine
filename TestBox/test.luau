-- Fonction pour vérifier l'utilisation des blocs de la palette
local function checkPaletteUsage(palette, section)
    -- Crée un tableau pour compter les occurrences de chaque bloc dans la palette
    local usageCount = {}
    for i = 1, #palette do
        usageCount[i] = 0  -- Initialisation à 0 pour chaque bloc de la palette
    end

    -- Parcourt la section des blocs pour compter les occurrences
    for _, blockIndex in ipairs(section) do
        if usageCount[blockIndex] then
            usageCount[blockIndex] = usageCount[blockIndex] + 1
        end
    end

    -- Vérifie si certains blocs de la palette ne sont pas utilisés
    local unusedBlocks = {}
    for index, count in pairs(usageCount) do
        if count == 0 then
            table.insert(unusedBlocks, palette[index])
        end
    end

    return unusedBlocks  -- Retourne les blocs qui ne sont plus utilisés
end

-- Exemple d'utilisation
local palette = {"stone", "dirt", "grass", "sand"}  -- Palette de blocs
local section = {1, 3, 1, 3}  -- Section des blocs encodée (index correspondant à la palette)

local unusedBlocks = checkPaletteUsage(palette, section)

-- Affichage des blocs inutilisés
if #unusedBlocks > 0 then
    print("Blocs non utilisés dans la section :")
    for _, block in ipairs(unusedBlocks) do
        print(block)
    end
else
    print("Tous les blocs de la palette sont utilisés.")
end