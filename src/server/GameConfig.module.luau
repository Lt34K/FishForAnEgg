local Config = {}

Config.Rods = {
    {name="Bois",price=0,distance=10,depth=5,color=Color3.fromRGB(133,83,44)},
    {name="Bambou",price=500,distance=20,depth=15,color=Color3.fromRGB(113,161,79)},
    {name="Fer",price=5000,distance=35,depth=30,color=Color3.fromRGB(130,140,150)},
    {name="Argent",price=50000,distance=55,depth=50,color=Color3.fromRGB(205,215,225)},
    {name="Or",price=500000,distance=80,depth=80,color=Color3.fromRGB(245,196,52)},
    {name="Diamant",price=5000000,distance=110,depth=120,color=Color3.fromRGB(56,222,243)},
    {name="Magma",price=50000000,distance=150,depth=170,color=Color3.fromRGB(245,85,37)},
    {name="Glaciale",price=500000000,distance=200,depth=230,color=Color3.fromRGB(128,225,255)},
    {name="Électrique",price=5000000000,distance=260,depth=300,color=Color3.fromRGB(251,227,51)},
    {name="Arc-en-ciel",price=50000000000,distance=330,depth=400,color=Color3.fromRGB(226,85,227)},
    {name="Galactique",price=500000000000,distance=420,depth=550,color=Color3.fromRGB(118,75,245)},
    {name="Void",price=5000000000000,distance=550,depth=750,color=Color3.fromRGB(57,34,89)},
    {name="Divine",price=100000000000000,distance=750,depth=1000,color=Color3.fromRGB(255,245,171)},
    {name="Oméga",price=5000000000000000,distance=1000,depth=1500,color=Color3.fromRGB(255,73,176)},
}

Config.Eggs = {
    {name="Œuf Forêt",weight=620,income=5,hatch=10,color=Color3.fromRGB(100,194,246)},
    {name="Œuf Montagne",weight=245,income=30,hatch=20,color=Color3.fromRGB(255,135,146)},
    {name="Œuf Désert",weight=95,income=250,hatch=35,color=Color3.fromRGB(239,240,252)},
    {name="Œuf Volcan",weight=30,income=2500,hatch=60,color=Color3.fromRGB(99,81,205)},
    {name="Œuf Océan",weight=9,income=25000,hatch=90,color=Color3.fromRGB(250,191,58)},
    {name="Œuf Banquise",weight=1,income=500000,hatch=120,color=Color3.fromRGB(251,75,173)},
}
-- Six themed habitats; each contains eight animals, including rare mythical creatures.
Config.Habitats = {
    {name="Forêt",minRod=1},
    {name="Montagne et pierre",minRod=3},
    {name="Désert",minRod=5},
    {name="Volcan",minRod=7},
    {name="Océan",minRod=9},
    {name="Banquise",minRod=11},
}
Config.Creatures = {
    {"Lapin", "Renard", "Écureuil", "Hérisson", "Cerf", "Sanglier", "Licorne sylvestre", "Esprit de la forêt"},
    {"Chèvre", "Marmotte", "Loup", "Ours", "Aigle", "Lynx", "Griffon", "Golem de pierre"},
    {"Fennec", "Suricate", "Scorpion", "Chameau", "Cobra", "Dromadaire blanc", "Sphinx", "Phénix des sables"},
    {"Salamandre", "Lézard", "Iguane", "Varan", "Dragon de Komodo", "Serpent de lave", "Phénix", "Dragon de magma"},
    {"Crabe", "Tortue marine", "Dauphin", "Requin", "Baleine", "Raie manta", "Kraken", "Léviathan"},
    {"Manchot", "Phoque", "Renard polaire", "Morse", "Ours polaire", "Harfang des neiges", "Yéti", "Dragon de glace"},
}
Config.CreatureRarities = {"Commun", "Commun", "Peu commun", "Rare", "Rare", "Épique", "Légendaire", "Divin"}
Config.CreatureWeights = {35,25,16,10,7,4,2,1}
Config.CreaturesPerHabitat = 8
Config.TotalCreatures = #Config.Creatures * Config.CreaturesPerHabitat
Config.AnimalColors = {
    {Color3.fromRGB(228,214,193),Color3.fromRGB(220,104,54),Color3.fromRGB(170,99,49),Color3.fromRGB(139,126,112),Color3.fromRGB(167,117,73)},
    {Color3.fromRGB(211,206,189),Color3.fromRGB(159,124,88),Color3.fromRGB(115,125,134),Color3.fromRGB(113,82,65),Color3.fromRGB(135,98,63)},
    {Color3.fromRGB(236,198,127),Color3.fromRGB(195,150,92),Color3.fromRGB(114,83,66),Color3.fromRGB(196,151,101),Color3.fromRGB(179,144,92)},
    {Color3.fromRGB(245,116,54),Color3.fromRGB(113,166,88),Color3.fromRGB(71,145,99),Color3.fromRGB(103,96,75),Color3.fromRGB(100,86,69)},
    {Color3.fromRGB(229,97,85),Color3.fromRGB(91,168,128),Color3.fromRGB(100,177,205),Color3.fromRGB(81,126,162),Color3.fromRGB(88,125,157)},
    {Color3.fromRGB(45,55,68),Color3.fromRGB(179,197,208),Color3.fromRGB(236,239,243),Color3.fromRGB(133,145,155),Color3.fromRGB(242,244,247)},
}
Config.Skins = {
    {name="Classique",required=0,color=Color3.fromRGB(204,222,235)},
    {name="Bois",required=5,color=Color3.fromRGB(157,105,66)},
    {name="Pierre",required=10,color=Color3.fromRGB(126,136,147)},
    {name="Corail",required=17,color=Color3.fromRGB(255,132,151)},
    {name="Océan",required=25,color=Color3.fromRGB(54,169,222)},
    {name="Magma",required=35,color=Color3.fromRGB(239,91,46)},
    {name="Galactique",required=48,color=Color3.fromRGB(124,76,235)},
}
Config.BaseCosts = {0,25000,1000000,100000000,10000000000,1000000000000,100000000000000}
Config.BaseSlots = {6,8,10,12,14,16,20}
return Config
