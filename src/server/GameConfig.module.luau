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
    {name="Œuf Marin",weight=620,income=5,hatch=10,color=Color3.fromRGB(100,194,246)},
    {name="Œuf Corail",weight=245,income=30,hatch=20,color=Color3.fromRGB(255,135,146)},
    {name="Œuf Perle",weight=95,income=250,hatch=35,color=Color3.fromRGB(239,240,252)},
    {name="Œuf Abyssal",weight=30,income=2500,hatch=60,color=Color3.fromRGB(99,81,205)},
    {name="Œuf Légendaire",weight=9,income=25000,hatch=90,color=Color3.fromRGB(250,191,58)},
    {name="Œuf Secret",weight=1,income=500000,hatch=120,color=Color3.fromRGB(251,75,173)},
}
Config.BaseCosts = {0,25000,1000000,100000000,10000000000,1000000000000,100000000000000}
Config.BaseSlots = {6,8,10,12,14,16,20}
return Config
