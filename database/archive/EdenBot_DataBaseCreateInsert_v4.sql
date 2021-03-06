/*---------------------------------------
--CREATION OF DOMAIN TABLE REFERENCE --
---------------------------------------*/

DROP TABLE IF EXISTS Reference;
CREATE TABLE Reference (
 StatusId INTEGER NOT NULL UNIQUE,
 RName TEXT NOT NULL,
 RDescription TEXT
);

/*-----------------------------------------------------------
--CREATION OF TABLES WITHOUT FOREIGN KEY EXCEPT REFERENCE --
-----------------------------------------------------------*/

DROP TABLE IF EXISTS Position;
CREATE TABLE Position (
    PName VARCHAR(512) NOT NULL
);

DROP TABLE IF EXISTS Plant;
CREATE TABLE Plant (
    PName varchar(512) NOT NULL,
    PDescription TEXT NULL,
    LowTemp INTEGER NULL,
    HighTemp INTEGER NULL,
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT
);

DROP TABLE IF EXISTS Shot;
CREATE TABLE Shot (
    SName VARCHAR(512) NOT NULL,
    TiltIn INTEGER NOT NULL,
    TiltOut INTEGER NOT NULL,
    PanIn INTEGER NOT NULL,
    PanOut INTEGER NOT NULL,
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT
);

/*--------------------------------------------------------
--CREATION OF TABLES WITH FOREIGN KEY  -------------------
---------------------------------------------------------*/

DROP TABLE IF EXISTS FamousTree;
CREATE TABLE FamousTree (
    FTName VARCHAR(512) NOT NULL,
    N3 VARCHAR(3) NOT NULL,
    Alias VARCHAR(512),
    Kind VARCHAR(512),
    PlantId INTEGER NULL DEFAULT NULL,
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT,
    FOREIGN KEY (PlantId)
        REFERENCES Plant (rowid)
            ON DELETE SET DEFAULT
);

DROP TABLE IF EXISTS Resident;
CREATE TABLE Resident (
    RName varchar(512) NOT NULL,
    PlantId INTEGER NOT NULL,
    DateIn DATE NOT NULL,
    DateOut DATE NOT NULL,
    FTreeId INTEGER NOT NULL, 
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT,
    FOREIGN KEY (PlantId)
        REFERENCES Plant (rowid),
    FOREIGN KEY (FTreeId)
        REFERENCES FamousTree (rowid)
);

DROP TABLE IF EXISTS VisualSample;
CREATE TABLE VisualSample (
    VSName VARCHAR(512) NOT NULL,
    DateIn DATE NOT NULL,
    DateOut DATE NOT NULL,
    ShotType INTEGER NOT NULL,
    GreenIn REAL NULL,
    GreenOut REAL NULL,
    Frame INTEGER NOT NULL,
    TotalFrame INTEGER NOT NULL,
    Duration INTEGER NOT NULL,
    UrlString TEXT NULL,
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT,
    FOREIGN KEY (ShotType)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE             
);

/*-----------------------------------------------------------
--CREATION OF EMPTY DATA TABLES -----------------------------
-----------------------------------------------------------*/

DROP TABLE IF EXISTS TextArchive;
CREATE TABLE TextArchive (
    TextData TEXT NOT NULL,
    UrlString TEXT NULL,
    CreationDate DATE NOT NULL,
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT
);

DROP TABLE IF EXISTS DataSample;
CREATE TABLE DataSample (
    SampleDate DATE NOT NULL,
    cpu_t REAL NULL,
    gh_t REAL NULL,
    p_t REAL NULL,
    hum REAL NULL,
    nox REAL NULL,
    no2 REAL NULL,
    o3 REAL NULL,
    atmo REAL NULL,
    lum REAL NULL,
    Status INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (Status)
        REFERENCES Reference (StatusId)
            ON UPDATE CASCADE 
            ON DELETE SET DEFAULT
);

/*-----------------------------------------------------------
--CREATION OF EMPTY JUNCTURE TABLES -------------------------
-----------------------------------------------------------*/


DROP TABLE IF EXISTS Shot_Position;
CREATE TABLE Shot_Position (
    SId INTEGER NOT NULL,
    PId INTEGER NOT NULL,
    FOREIGN KEY(SId)
        REFERENCES Shot(rowid)
            ON UPDATE CASCADE,
    FOREIGN KEY (PId)
        REFERENCES Position(rowid)
            ON UPDATE CASCADE
);

DROP TABLE IF EXISTS Resident_Position;
CREATE TABLE Resident_Position (
    RId INTEGER NOT NULL,
    PId INTEGER NOT NULL,
    DateIn DATE NOT NULL,
    FOREIGN KEY(SId)
        REFERENCES Resident(rowid)
            ON UPDATE CASCADE,
    FOREIGN KEY (PId)
        REFERENCES Position(rowid)
            ON UPDATE CASCADE
);

/*---------------
-- INSERTING --
---------------*/

/*-----------------------
-- INSERTING Reference --
------------------------*/

INSERT INTO Reference VALUES
    (0,'Inactive','This instance should not be used'),
    (1,'Active','This instance is good for use'),
    (2,'Complete','This instance is complete'),
    (3,'Incomplete','This instance is incomplete'),
    (4,'InProgress','This instance is incomplete and still in progress'),
    (9,'NeedCorrection','This instance should be corrected before use'),
    (10,'Duplicate','This is a duplicate of another instance'),
    (11,'Archive','This is an archive'),
    (100,'0DOF','Shot that doesn''t move'),
    (101,'0DOFh','Shot that doesn''t move, with horizontal mirror'),
    (102,'0DOFv','Shot that doesn''t move, with vertical mirror'),
    (103,'0DOFhv','Shot that doesn''t move with vertical and horizontal mirror'),
    (110,'1DOF','Shot that moves in one direction'),
    (111,'1DOFh','Shot that moves in one direction, with horizontal mirror'),
    (112,'1DOFv','Shot that moves in one direction, with vertical mirror'),
    (113,'1DOFhv','Shot that moves in one direction, with vertical and horizontal mirror'),
    (120,'2DOF','Shot that moves in two direction'),
    (121,'2DOFh','Shot that moves in one direction, with horizontal mirror'),
    (122,'2DOFv','Shot that moves in one direction, with vertical mirror'),
    (123,'2DOFhv','Shot that moves in one direction, with vertical and horizontal mirror'),
    (110,'ArchiveFonctional','Shot Timelapse still fonctunional but not used anymore'),
    (111,'Archive','Shot Timelapse not used anymore'),
    (112,'NeedCorrection','Shot Timelapse that cannot be used before changes'),
    (113,'NeedVerification','Shot Timelapse that should be tested and verified'),
    (114,'Buggy','Some bugs were spotted during the use of this timelapse'),
    (115,'Corrected','Shot Timelapse that have been corrected once'),
    (116,'Duplicate','Duplicate of another timelapse'),
    (200,'Completed','This visual sample has been shot, processed, saved and published'),
    (201,'InProgress','The visual sample is in shooting progress'),
    (202,'Paused','The shooting progress must wait before completion'),
    (211,'ShootStopped','The visual sample has been stopped during the shooting process'),
    (212,'ProcessStopped','The visual sample has been stopped during the encoding process'),
    (213,'PostStopped','The visual sample has been stopped during the post process'),
    (220,'Deleted','The visual sample has been deleted from internet and drive'),
    (230,'FinishEarly','The visual sample will stop shooting at the next image and finish the full process'),
    (300,'Current','Current resident of the greenhouse'),
    (301,'NoPlant','Current resident not germinated'),
    (302,'FirstPlant','Current with germination'),
    (310,'Old','Ancient resident, now out'),
    (311,'Dead','The resident did not survive the greenhouse experiment'),
    (312,'Alive','Ancient resident, now out giving fruit or flowers'),
    (400,'FullData','This data sample is complete'),
    (401,'Hardware','The data sample is done only from the hardware sensors'),
    (410,'Corrupted','The data is corrupted'),
    (500,'PostedArchive','This TexteArchive have been posted'),
    (501,'UnpostedArchive','This text has been generated and is waiting to be posted'),
    (999,'ToDelete','This saving should be deleted');

/*-----------
-- Plant --
-----------*/

INSERT INTO Plant (PName, PDescription, LowTemp, HighTemp) VALUES
    ('Acacia','Aboriginal Australians have traditionally harvested the seeds of some species, to be ground into flour and eaten as a paste or baked into a cake. Some species of acacia contain psychoactive alkaloids, and some contain potassium fluoroacetate, a rodent poison.',NULL,NULL),
    ('Amaranth','Love-lies-bleeding. Both leaves and seeds can be used. Excessive intake is not recommended. Harvest in 7-8 weeks. Compatible with : Onions, corn, peppers, egg plant, tomatoes',18,30),
    ('Angelica','The stems can be candied and used to decorate cakes and pastries. Pick the stems in the second year. Harvest in approximately 18 months. Angelica archangelica has slightly dull leaves, not shiny.. Compatible with : Any herbs that like damp, shady areas - mint, lemon balm',10,25),
    ('Apple tree','Apple trees are typically 4–12 m talI at maturity, with a dense, twiggy crown. The leaves are 3–10 cm long, alternate, simple, with a serrated margin. The flowers are borne in corymbs, and have five petals, which may be white, pink or red.',NULL,NULL),
    ('Artichokes (Globe)','Pick buds before scales develop brown tips. If you have lots of small buds, they can be fried in olive oil and eaten whole. Rinse in plenty of cold water to remove earwigs or other insects. Harvest in 42-57 weeks. Compatible with : Needs a lot of space. Best in separate bed',5,18),
    ('Ash','The tree''s common English name, "ash", traces back to the Old English æsc which relates to the Proto-Indo-European for the tree.',-20,NULL),
    ('Asparagus','Steaming is traditional, then coating with melted butter or hollandaise sauce. Alternatively break in short lengths, and cook quickly in hot oil in a wok and sprinkle with soy sauce or balsamic vinegar. NOTE: The asparagus berries are poisonous. Only the young shoots are edible. Harvest in 2-3 years. Plant ''crowns'' to harvest earlier . Compatible with : Parsley, Basil, Nasturtiums, Lettuce',20,30),
    ('Asparagus Pea','Winged bean. Cook quickly by steaming and serve with just a touch of butter and they are said to taste like their namesake . Harvest in 8-11 weeks. Pick early, pick often. Compatible with : Best grown in separate bed',10,30),
    ('Aspen','Aspen trees are all native to cold regions with cool summers, in the north of the Northern Hemisphere, extending south at high-altitude areas such as mountains or high plains. They are all medium-sized deciduous trees reaching 15–30 m tall. In North America, it is referred to as Quaking Aspen or Trembling Aspen because the leaves "quake" or tremble in the wind.',-45,NULL),
    ('Baobab','Baobabs reach heights of 5 to 30m and have trunk diameters of 7 to 11m. This tree is also known as the "upside down tree", a name that originates from several myths.',NULL,NULL),
    ('Basil','Basil is commonly used fresh in cooked recipes. It is generally added at the last moment, as cooking quickly destroys the flavour. Tear rather than chop. The fresh herb can be kept for a short time in plastic bags in the refrigerator, or for a longer period in the freezer, after being blanched quickly in boiling water. Harvest in 10-12 weeks. Pick before flowering. Compatible with : Tomato',8,30),
    ('Beech','Beech grows on a wide range of soil types, acidic or basic, provided they are not waterlogged. The tree canopy casts dense shade, and carpets the ground thickly with leaf litter. The beech most commonly grown as an ornamental tree is the European beech (Fagus sylvatica), widely cultivated in North America and its native Europe.',-30,NULL),
    ('Beetroot','Beets. Apart from boiling whole for salads, beetroot roast well, cut in wedges. They also make a tasty salad grated raw with carrot and a little fresh orange juice. Harvest in 7-10 weeks. Compatible with : Onions, Silverbeet (Swiss Chard), Lettuce, Cabbage, Dwarf Beans, Dill, Peas. Strawberries',15,30),
    ('Borage','Burrage, Bugloss. Has a slight cucumber taste which goes well in salads and when cooked with silver beet or cabbage. The flowers make a pretty drink decoration when frozen in an iceblock. Harvest in 8-10 weeks. Use leaves before flowers appear, otherwise they will be ''hairy''. . Compatible with : Strawberry, tomatoes, zucchini/squash. Deters pests from many plants.',7,25),
    ('Broad beans','Fava bean. The fresh beans are eaten steamed or boiled. As the beans mature it is better to remove their tough outer skins after cooking. The leafy top shoots of the adult plants can be picked and steamed after flowering. Small beans can be eaten whole in the pods. Harvest in 12-22 weeks. Pick frequently to encourage more pods. Compatible with : Dill, Potatoes',10,20),
    ('Broccoli','The stem (peeled), leaves, and flowerhead are all edible. Steam for best flavour. Peel large stalks, slice and steam. Goes well with blue cheese sauce. Harvest in 10-16 weeks. Cut flowerhead off with a knife.. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile, oregano)',21,35),
    ('Brussels sprouts','Remove any discoloured outer leaves. Cut in half and steam with other vegetables. They go well with a chopped tomato and onion mix. Traditionally served with roasted chestnuts for Xmas dinner in UK. Harvest in 14-28 weeks. Pick sprouts when small. . Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile)',15,18),
    ('Burdock','Gobo (Japanese Burdock). Harvest in the first year when the burdock root is very crisp and has a sweet, mild, and pungent flavour with a little muddy harshness that can be reduced by soaking julienne/shredded roots in water for five to ten minutes. Immature flower stalks may also be harvested in late spring, before flowers appear. It is a key ingredient in the traditional Dandelion and Burdock beer. Harvest in 17-18 weeks. ',16,30),
    ('Buxus','They are slow-growing evergreen shrubs and small trees, growing to 2–12 m (rarely 15 m) tall. Due to its high density, resistance to chipping, and relatively low cost, boxwood has been used to make parts for various stringed instruments since antiquity. It is mostly used to make tailpieces, chin rests and tuning pegs, but may be used for a variety of other parts as well. ',-15,NULL),
    ('Cabbage','Young spring cabbage can be chopped and added to salad greens. Steaming preserves the goodness and flavour of cabbage. Can also be used in stir-fry. Red cabbage chopped and cooked with brown sugar, red wine, onions, vinegar and stock is served with boiled bacon or pork. Harvest in 11-15 weeks. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile, thyme)',15,20),
    ('Cape Gooseberry','Golden Berry, Inca Berry. The berry is the size of a cherry tomato, is very aromatic and full of tiny seeds. They are delicious eaten fresh or can be made into jam. They can be added to salads, desserts and cooked dishes, they are delicious stewed with other fruit, especially apples. They also go well in savoury dishes with meat or seafood. Harvest in 14-16 weeks. Compatible with : Will happily grow in a flower border',18,35),
    ('Capsicum','Bell peppers, Sweet peppers. Can be sliced and seeded and used raw in salads. Or brush with olive oil, roast at a high temperature until the skin changes colour then put in a covered dish until cool and rub off the skin and remove seeds. Harvest in 10-12 weeks. Cut fruit off with sharp knife. Compatible with : Egg plant (Aubergine), Nasturtiums, Basil, Parsley, Amaranth',7,25),
    ('Cardoon','Cut off the base and leaves, then cut the stalks into pieces. Boil the stalks for around 20 minutes until tender: drain, and peel off the surface of the stalks. Add precooked cardoons to a variety of dishes, they go well with mushrooms. Harvest in 34-35 weeks. Compatible with : Best grown in separate bed.',10,25),
    ('Carrot','Steamed or raw carrots are tasty. Cook them in a small amount of water until nearly dry then add a pat of butter and teasp of brown sugar to glaze. They can be added to most casserole-type dishes. Grate raw carrots and add to salads Harvest in 12-18 weeks. Compatible with : Onions, Leeks, Lettuce, Sage, Peas, Radishes, Tomatoes, Beans, Celery, Rosemary',6,24),
    ('Cauliflower','Cauliflower can be steamed. Young ones can be broken into small pieces and added raw to salad. Cook briefly and add to curry mix. Traditionally served with cheese sauce. Add tomato slices for colour. Harvest in 15-22 weeks. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile)',7,30),
    ('Cedar','Cedrus (common English name cedar) is a genus of coniferous trees in the plant family Pinaceae (subfamily Abietoideae). They are native to the mountains of the western Himalayas and the Mediterranean region, occurring at altitudes of 1,500–3,200 m in the Himalayas and 1,000–2,200 m in the Mediterranean.',-20,NULL),
    ('Ceiba','The tree plays an important part in the mythologies of pre-Columbian Mesoamerican cultures. For example, several Amazonian tribes of eastern Peru believe deities live in Ceiba tree species throughout the jungle. The Ceiba, or ya’axché (in the Mopan Mayan language), symbolised to the Maya civilization an axis mundi which connects the planes of the Underworld (Xibalba) and the sky with that of the terrestrial realm.',-1,NULL),
    ('Celeriac','Cook whole, scrubbed and peeled. Or slice or dice.Tastes like celery. Harvest in 14-28 weeks. Compatible with : Beans, brassicas, carrots, leeks, lettuce, peas, sage, tomatoes, onions',7,30),
    ('Celery','Chop and use raw in salad or braised in hot dishes. Harvest in 17-18 weeks. Compatible with : Not applicable as celery needs to be close together to encourage blanching.',10,20),
    ('Cherry tree','Dried sour cherries are used in cooking including soups, pork dishes, cakes, tarts, and pies.  Sour cherries or sour cherry syrup are used in liqueurs and drinks, such as the portuguese ginjinha. In Iran, Turkey, Greece and Cyprus, sour cherries are especially prized for making spoon sweets.',NULL,NULL),
    ('Chestnut','Chestnut trees are of moderate growth rate (for the Chinese chestnut tree) to fast-growing for American and European species. Their mature heights vary from the smallest species of chinkapins, often shrubby, to the giant of past American forests, C. dentata that could reach 60 m.',-29,35),
    ('Chicory','Witloof, Belgian endive. Good in salads. Grill lightly with butter. Bake with ham and cheese. Harvest in 16-24 weeks. Will need forcing before final harvest. Compatible with : Carrots, onions, Florence fennel, tomatoes.',10,25),
    ('Chilli peppers','Hot peppers. Wash, dry, and free whole. Use them direct from the freezer (no need to defrost). Wear plastic gloves or wash your hands thoroughly after handling and cutting to avoid accidentally rubbing chilli juice onto your mouth or eyes! Harvest in 9-11 weeks. Wear gloves to pick ''hot'' chilies. Compatible with : Best grown in a separate bed as chillis need plenty of light and air circulation.',18,35),
    ('Chinese cabbage','Wong bok, wong nga pak. Use in stir-fry . Has a milder flavour than regular cabbage.Shred the inner leaves and stems to use in coleslaw salad. Harvest in 8-10 weeks. Harvest whole head or you can take a few leaves at a time. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile, coriander), lettuce, potatoes',10,20),
    ('Chives','Garden chives. Use raw in salads or as a mild onion flavour in cooked dishes. Harvest in 7-11 weeks. Compatible with : Carrots, Tomatoes, Parsley, Apples',10,20),
    ('Choko/Chayote','Chayote squash, christophene, chouchou, mirliton. Chokos can be peeled and chopped to use in stews, soup or as a stir fry vegetable. Cooked or raw, it has a very mild flavour and is commonly served with seasonings e.g., salt, butter and pepper or in a dish with other vegetables and/or flavourings. It can also be boiled, stuffed, mashed or pickled Harvest in approximately 17 weeks. Best when fruit is light green and not more than 6cm long. Compatible with : Cucumbers',16,30),
    ('Climbing beans','Pole beans, Runner beans, Scarlet Runners. Use young in salads - blanch and cool. Harvest in 9-11 weeks. Compatible with : Sweetcorn, spinach, lettuce, summer savory, dill, carrots, brassicas, beets, radish, strawberry, cucumbers, zucchini, tagates minuta (wild marigold)',24,32),
    ('Coconut tree','Mature, ripe coconuts can be used as edible seeds, or processed for oil and plant milk from the flesh, charcoal from the hard shell, and coir from the fibrous husk. They may grow but not fruit properly in areas with insufficient warmth.',12,37),
    ('Collards','Collard greens, Borekale. Slice and steam or use in stir-fry Harvest in 8-11 weeks. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile)',15,25),
    ('Coriander','Cilantro, Chinese parsley. Use the leaves to flavour hot meals or add fresh to salads. Harvest in 30-45 days. Compatible with : Dill, Chervil, Anise, Cabbages, Carrots',10,25),
    ('Corn Salad','Lamb''s lettuce or Mache. Pick individual leaves or harvest the whole plant as required Harvest in 5-8 weeks. Compatible with : Onions',10,25),
    ('Cowpeas','Black eye peas, Southern peas. Young leaves can be cooked and used like spinach and are very high in protein. The young pods are edible. Harvest in 11-14 weeks.',10,35),
    ('Cucumber','Pick frequently before the fruit become too big. Use raw in salads, peeled if preferred. Harvest in 8-10 weeks. Cut fruit off with scissors or sharp knife. Compatible with : Nasturtiums, Beans, Celery, Lettuce, Sweet Corn, Cabbages, Sunflowers, Coriander, Fennel, Dill, Sunflowers',10,25),
    ('Cypress','They are evergreen trees or large shrubs, growing to 5–40 m tall. The leaves are scale-like, 2–6 mm long, arranged in opposite decussate pairs, and persist for three to five years. Many of the species are adapted to forest fires, holding their seeds for many years in closed cones until the parent trees are killed by a fire; the seeds are then released to colonise the bare, burnt ground. In other species, the cones open at maturity to release the seeds. ',NULL,NULL),
    ('Daikon','Japanese radish, Lo Bok. Daikon radish can be eaten simmered, stir fried, grated, pickled or baked. Its leaves are also edible and can be used in recipes that call for turnip greens, and its seeds make sprouts to eat in salads or in sandwiches. Harvest in 8-10 weeks. Dig daikon carefully. They are rather brittle.. Compatible with : Chervil, cress,lettuce, leeks, spinach, strawberries, tomatoes',8,15),
    ('Date','There is archaeological evidence of date cultivation in Arabia from the 6th millennium BCE. The total annual world production of dates amounts to 8.5 million metric tons. Date trees typically reach about 21–23 metres in height, growing singly or forming a clump with several stems from a single root system.',-4,NULL),
    ('Dill','Dill leaves can be used fresh or dried in salads, meats, vegetable dishes and soups. Freshly cut leaves enhance the flavour of dips, herb butter, soups, salads, fish dishes, and salads. Both the flowering heads and seeds are used in flavoured vinegars and oils. Used whole or ground, the seeds add zest to bread, cheese, and salad dressing. Harvest in 8-12 weeks. Use leaves before flowering. Compatible with : Cabbage, Coriander, Fennel, tomatoes, broccoli',8,30),
    ('Dragon tree','When the bark or leaves are cut they secrete a reddish resin, one of several sources of substances known as dragon''s blood. Being a monocotyledon, it does not display any annual or growth rings so the age of the tree can only be estimated by the number of branching points before reaching the canopy.',25,NULL),
    ('Dwarf beans','French beans, Bush beans. Can be used in salads when young, blanched and cooled. Harvest in 7-10 weeks. Pick often to encourage more flower production. Compatible with : Sweetcorn, spinach, lettuce, summer savory, dill, carrots, brassicas, beets, radish, strawberry and cucumbers, tagates minuta (wild marigold)',8,30),
    ('Eggplant','Aubergine. Cut and use the same day if possible. Slice, no need to peel, and fry in olive oil. Brush with oil and grill or bake. Or microwave,plain, for about 4 minutes on high. Makes a good substitute for pasta in lasagne or moussaka. Can be smoked over a gas ring or barbecue, cooled and peeled and used to make dips. Harvest in 12-15 weeks. Cut fruit with scissors or sharp knife. Compatible with : Beans, capsicum, lettuce, amaranth, thyme',8,30),
    ('Elm','Elms are components of many kinds of natural forests. Moreover, during the 19th and early 20th centuries many species and cultivars were also planted as ornamental street, garden, and park trees. Some individual elms reached great size and age. However, in recent decades, most mature elms of European or North American origin have died from Dutch elm disease, caused by a microfungus dispersed by bark beetles. ',NULL,NULL),
    ('Endive','Very tasty topped with grated swiss cheese and grilled for a couple of minutes to crisp up the cheese and wilt the leaves. Can use in salads additional to lettuce, but needs a flavoursome dressing if you aren''t overly fond of bitterness. Harvest in 10-11 weeks. Compatible with : beans, brassicas, carrots, cucumbers, chervil, sage.',10,25),
    ('Eucalyptus','Eucalypts vary in size and habit from shrubs to tall trees. Trees usually have a single main stem or trunk but many eucalypts are mallees that are multistemmed from ground level and rarely taller than 10 metres. The oldest definitive Eucalyptus fossils are surprisingly from South America, where eucalypts are no longer endemic, though have been introduced from Australia. The fossils are from the early Eocene (51.9 Mya).',-5,NULL),
    ('Fennel','Bronze fennel. Cut off leaves as required Use leaves fresh or dried . Particularly good with fish. The seeds can be used in pickling mixes. Harvest in 14-15 weeks. Compatible with : Best grown away from vegetables',8,27),
    ('Ficus','Figs are keystone species in many tropical forest ecosystems. Their fruit are a key resource for some frugivores including fruit bats, and primates including: capuchin monkeys, langurs, gibbons and mangabeys. Figs are also of considerable cultural importance throughout the tropics, both as objects of worship and for their many practical uses. ',10,NULL),
    ('French tarragon','Tarragon goes well with fish, pork, beef, poultry, game, potatoes, tomatoes, carrots, and most vegetables.Â Tarragon can be used in cream sauces, herbed butters and vinegars, soups, sour creams, and yogurt. However, it can be overpowering in large amounts. Harvest in 30-40 days. Pick leaves when young for best flavour. Compatible with : Aubergine (Eggplant) and Capsicum (Peppers)',20,30),
    ('Garlic','Cut the growing shoots or use the entire young garlic plants as ''garlic greens'' in stirfry. Harvest in 17-25 weeks. Compatible with : Beets, Carrots, Cucumbers, Dill, Tomatoes, Parsnips',20,35),
    ('Ginger','Use in any recipes requiring fresh ginger. Widely used in Asian cooking, it is hot without the ''burn'' of chilli. Harvest in approximately 25 weeks. Reduce water as plant dies back to encourage rhizome growth. Compatible with : Grow in separate bed',21,24),
    ('Grapevines','Most Vitis varieties are wind-pollinated with hermaphroditic flowers containing both male and female reproductive structures. Grapevines usually only produce fruit on shoots that came from buds that were developed during the previous growing season. ',20,NULL),
    ('Haoma','The Haoma plant is a mythological tree kind in the legend surrounding the conception of Zoroaster. In the story, his father Pouroshaspa took a piece of the Haoma plant and mixed it with milk. He gave his wife Dugdhova one half of the mixture and he consumed the other. They then conceived Zoroaster who was instilled with the spirit of the plant. ',NULL,NULL),
    ('Hawthorn','The maples have easily recognizable palmate leaves and distinctive winged fruits. The oldest known fossil definitive representative of the genus Acer was described from a single leaf found in Alaska from the Lower Paleocene. Samaras have been found in rocks as old as 66.5 Ma.',-20,NULL),
    ('Hopea odorata','In Cambodia it is known as the koki and the legend of the founding of Wat Phnom in Cambodia refers to the finding of Buddha statues in a koki tree floating in the river. Valued for its wood, it is a threatened species in its natural habitat.',NULL,NULL),
    ('Horseradish','Strong, spicy flavour traditionally used with roast beef. Used grated for horseradish sauce or horseradish cream Harvest in 16-24 weeks. Some improvement in flavour if left till after frost.. Compatible with : Best kept separate',10,35),
    ('Iroko','Iroko (also known as ''uloho'' in the Urhobo language of Southern Nigeria, and as odum in the Kwa languages of Ghana) is a large hardwood tree from the west coast of tropical Africa that can live up to 500 years.',NULL,NULL),
    ('Jerusalem Artichokes','Sunchoke. Scrape clean or peel (add a tsp of lemon or vinegar to the water to stop the tubers browning). Steam, boil, or use in artichoke soup (make with artichokes and some stock). Caution - because they contain ''resistent starch'' Jerusalem Artichokes are a great promoter of flatulence in some individuals. Harvest in 15-20 weeks. Compatible with : Tomatoes, cucumbers',20,35),
    ('Juniper','Juniper plants thrive in a variety of environments. The junipers from Lahaul valley can be found in dry, rocky locations planted in stony soils. These plants are being rapidly used up by grazing animals and the villagers. There are several important features of the leaves and wood of this plant that cause villagers to cut down these trees and make use of them.',NULL,NULL),
    ('Kale','Borecole. Strong flavoured and nutritious vegetable. Wash well and chop finely then steam. A tomato or cheese sauce will mask the flavour if too strong. Harvest in 7-9 weeks. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, camomile)',8,30),
    ('Kohlrabi','Use when young. Scrub well, cut off leaf stalks, roots and woody parts. Young ones do not need peeling. Can be grated raw for salads or cut in pieces and steam. Use in casseroles. Harvest in 7-10 weeks. Compatible with : Beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile)',18,25),
    ('Leeks','Trim off the roots and any damaged leaves. Young ones can be used whole with some of the green leaves. Wash thoroughly as the earth tends to get inside. Chop and fry in butter (or olive oil) until tender. Can be added to casserole meals, allowing time to cook through. Leek and mushroom make a tasty combination for a tart filling. Harvest in 15-18 weeks. Loosen with a fork rather than pull by hand.. Compatible with : Carrots',21,30),
    ('Lemon Balm','Sweet balm. As a herb tea or added to fruit punch. Can be used to replace lemon, used sparingly, in desserts and with stewed fruit. Chop leaves into salad. Better used fresh than dried. Harvest in 8-10 weeks. Cut back tall stems to prevent flowering. Compatible with : Good to attract bees',10,30),
    ('Lettuce','Wash well, spin or shake dry and use in salads and sandwiches Harvest in 8-12 weeks. Compatible with : Carrots, Onions, Strawberries, Beets, Brassicas, Radish, Marigold, Borage, Chervil, Florence fennel, leeks.',6,21),
    ('Luffa','Loofah, plant sponge. The luffa flowers and fruits are soft and edible when young and are sometimes cooked and eaten like squash or okra. Loofah has been an important food source in many Asian cultures. The leaves and vines should not be eaten. Harvest in 11-12 weeks. Use as a back scratcher. Compatible with : Peas, Beans, Onions, Sweetcorn',8,24),
    ('Marrow','Good, cut in thick slices, seeds removed and stuffed with mince or spicy vegetable mix then baked in the oven Harvest in 12-17 weeks. Compatible with : Peas, Beans, Onions, Sweetcorn',10,30),
    ('Mint','Garden mint. Mint adds a fresh flavour if chopped and sprinkled over salads. And is traditionally used mixed with vinegar and sugar to make mint sauce for lamb. Harvest in 8-12 weeks. Cut leaves from top with scissors. Compatible with : Cabbages, Tomatoes',20,24),
    ('Mizuna','Japanese Greens, Mitzuna, Mibuna. Leaves used raw, stir-fried, in soups. Young flowering stems can be cooked like broccoli. Harvest in 35-50 days. Compatible with : Radish, lettuce',5,30),
    ('Mulberry','Mulberries are fast-growing when young, and can grow to24 m tall. The leaves are alternately arranged, simple, and often lobed and serrated on the margin.',NULL,NULL),
    ('Mustard','Gai choy. Use young leaves in salad for a ''spicy kick''. Add to stir fry. Harvest in 5-8 weeks. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, camomile)',13,35),
    ('Oak','Oak wood has a density of about 0.75 g/cm3 creating great strength and hardness. The wood is very resistant to insect and fungal attack because of its high tannin content. It also has very appealing grain markings, particularly when quartersawn. Oak planking was common on high status Viking longships in the 9th and 10th centuries.',-40,NULL),
    ('Okra','Ladyfinger, gumbo. Use pods fresh or dried in soups or casseroles or as a boiled vegetable. Harvest in 11-14 weeks. Compatible with : Peppers (Capsicum, Chili), Eggplant (Aubergine)',8,30),
    ('Olive','Olive oil has long been considered sacred. The olive branch was often a symbol of abundance, glory, and peace. The leafy branches of the olive tree were ritually offered to deities and powerful figures as emblems of benediction and purification, and they were used to crown the victors of friendly games and bloody wars. Today, olive oil is still used in many religious ceremonies. Over the years, the olive has also been used to symbolize wisdom, fertility, power, and purity. ',20,NULL),
    ('Onion','Brown onions roasted whole with other vegetables are delicious. Red onions add colour to salads or stir-fry. Harvest in 25-34 weeks. Allow onions to dry before storing. Compatible with : Lemon Balm, Borage, Carrots, Beets, Silverbeet, Lettuce, Amaranth',10,30),
    ('Oregano','Pot Marjoram. Used to flavour tomato dishes, soups, sauces and Greek dishes like moussaka Harvest in 6-8 weeks. When flowers appear. Compatible with : Broccoli',8,21),
    ('Pak Choy','Pak choi. You can treat Pak Choy as "cut and come again " or use the whole plant in one go, whichever suits your needs. Harvest in 6-11 weeks. Compatible with : Dwarf (bush) beans, beets, celery, cucumber, onions, marigold, nasturtium, rhubarb, aromatic herbs (sage, dill, chamomile, coriander), lettuce, potatoes',12,21),
    ('Parsley','Curly leaf parsley or flat leaf (Italian) parsley. Use the leaves and stems to add flavour and colour. Can be cooked in dishes such as ratatouille, Traditionally used in white sauce. Harvest in 9-19 weeks. Cut stalks from outer part of plant. Compatible with : Carrots, Chives, Tomatoes, Asparagus',10,20),
    ('Parsnip','Peel and roast with vegetables or meat. The sweetish flavour of parsnips enhances most other vegetables. Harvest in 17-20 weeks. Best flavour if harvested after a frost.. Compatible with : Swiss Chard (Silverbeet), Capsicum, Peas, Potatoes, Beans, Radishes, Garlic',18,35),
    ('Paulownia',' Paulownia needs much light and does not like high water tables. In China, it is popular for roadside planting and as an ornamental tree. ',-26,NULL),
    ('Peach tree','Peaches grow in a fairly limited range in dry, continental or temperate climates, since the trees have a chilling requirement that tropical or subtropical areas generally do not satisfy except at high altitudes. Peaches are not only a popular fruit, but are symbolic in many cultural.traditions, such as in art, paintings and folk tales.',-20,NULL),
    ('Pear tree','Pear wood is one of the preferred materials in the manufacture of high-quality woodwind instruments and furniture. About 3000 known varieties of pears are grown worldwide. The fruit is consumed fresh, canned, as juice, and dried.',NULL,NULL),
    ('Peas','Raw straight from the pod in the garden is best! Raw in salads. Steamed lightly. Small pods can be steamed whole. Harvest in 9-11 weeks. Pick the pods every day to increase production. Compatible with : Potatoes',10,20),
    ('Pine','Pine trees are evergreen, coniferous resinous trees (or, rarely, shrubs) growing 3–80 m tall. Pines grow well in acid soils, some also on calcareous soils; most require good soil drainage, preferring sandy soils.',NULL,NULL),
    ('Platanus','The tree is an important part of the literary scenery of Plato''s dialogue Phaedrus. Because of Plato, the tree also played an important role in the scenery of Cicero''s De Oratore. The plane tree has been a frequent motif featured in Classical Chinese poetry as an embodiment of sorrowful sentiments due to its autumnal shedding of leaves. ',NULL,NULL),
    ('Poplar','Interest exists in using poplar as an energy crop for biomass, in energy forestry systems, particularly in light of its high energy-in to energy-out ratio, large carbon mitigation potential, and fast growth. Poplar was the most common wood used in Italy for panel paintings; the Mona Lisa and most famous early renaissance Italian paintings are on poplar. The wood is generally white, often with a slightly yellowish colour. ',NULL,NULL),
    ('Potato','Peeled or unpeeled and scrubbed, potatoes can be boiled, baked, fried and roasted. - The only way they are not used is raw. Keep in a pot of cold water after peeling, otherwise they will discolour. Harvest in 15-20 weeks. Dig carefully, avoid damaging the potatoes. Compatible with : Peas, Beans, Brassicas, Sweetcorn, Broad Beans, Nasturtiums, Marigolds',10,30),
    ('Pumpkin','Cut up, remove the skin and roast with other vegetables or meat. Young crisp shoots with young leaves can be cooked and eaten - stewed in coconut milk they are popular in Melanesia. Remove any strings and tough parts and stew until tender, or cook as a vegetable in boiling water 3-5 minutes. Harvest in 15-20 weeks. Compatible with : Sweet Corn',16,30),
    ('Radish','Wash well and remove leaves and roots. Use raw in salads or on their own with bread and butter. Harvest in 5-7 weeks. Compatible with : Chervil, cress,lettuce, leeks, spinach, strawberries, tomatoes',8,30),
    ('Rhubarb','Pick stems about the thickness of your finger. Large stems will have tough ''strings'' down the length of them. Use in pies, crumbles, fools and jams. Rhubarb goes well with orange. Will usually need sweetener. Harvest in approximately 1 years. You will have a stronger plant if you leave it for about a year before using.. Compatible with : Brassicas (Cabbage, Broccoli, Cauliflower, etc)',5,30),
    ('Rocket','Arugula/Rucola. Use in salads and stir-fry Harvest in 21-35 days. Compatible with : Lettuce',10,25),
    ('Rockmelon','Canteloupe. Cut in half and scoop out and discard the seeds. Sprinkle with some ground ginger or serve plain. Harvest in 10-16 weeks. Compatible with : Sweetcorn, Sunflowers',20,33),
    ('Rosella','Queensland Jam Plant, Roselle. The large flowers produce a crimson enlarged calyx. Use the fleshy red calyx, without the green seed pod to make jam or jelly. Harvest in 21-25 weeks. Compatible with : Feverfew, Coriander, Nasturtium and Hyssop',20,35),
    ('Rosemary','Leaves sprinkled on roast potatoes, meat and barbeque food make them extra tasty. Rosemary can also be used to add flavour to vinegars and oils. Harvest in approximately 1 years. In warmer areas, harvest time might be shorter. Compatible with : Beans, Carrots, Cabbages, Sage',15,20),
    ('Rutabaga','Swedes. Use when about the size of a tennis ball. The leaves can be cooked like cabbage when young. Harvest in 10-14 weeks. Compatible with : Peas, Beans, Chives',8,25),
    ('Sacred fig','The Ficus religiosa tree is considered sacred by the followers of Hinduism, Jainism and Buddhism. In the Bhagavad Gita, Krishna says, "I am the Peepal tree among the trees, Narada among the sages, Chitraaratha among the Gandharvas, And sage Kapila among the Siddhas."',0,NULL),
    ('Sage','Common Sage. The leaves are used to flavour stuffing and meat dishes. Sage keeps well if dried. Harvest in approximately 18 months. Time reduced if grown from cuttings. Compatible with : Broccoli, Cauliflower, Rosemary, Cabbage and Carrots',10,25),
    ('Salsify','Vegetable oyster. Wash and scrape the roots then boil before frying or roasting. They can also be used to make a creamed soup. Harvest in 14-21 weeks. Compatible with : Beans, Brassicas, Carrots, Celeriac, Endive, Kohl-rabi, Leeks, Lettuce, Alliums, Spinach',10,30),
    ('Savory - summer savory','Bean Herb. Usually added to peas, beans or lentils. It has a slightly spicy flavour. Harvest in 6-10 weeks. Cut before flowers form for best flavour. Compatible with : Beans, Onions',18,30),
    ('Savory - winter savory','Savory. Can be used as seasoning for beans and other green vegetables. Harvest in 6-10 weeks. Use the leaves fresh.. Compatible with : Beans',18,30),
    ('Sequoia','The redwood species contains the largest and tallest trees in the world. These trees can live for thousands of years. This is an endangered subfamily due to habitat losses from fire ecology suppression, logging, and air pollution.',NULL,NULL),
    ('Shallots','Eschalots. Use in any recipe instead of onions. Can be cooked whole, braised gently with other vegetables. Harvest in 12-15 weeks. Keep a few for your next planting. Compatible with : Lemon Balm, Borage, Carrots, Beets, Silverbeet, Lettuce, Amaranth',8,30),
    ('Silverbeet','Swiss Chard or Mangold. Wash thoroughly and inspect the back of the leaves for insects. Chop and put in a saucepan with very little water ( or just what is on the leaves). Cover and cook over a low to medium heat until the leaves collapse. A small amount of nutmeg enhances the flavour. Harvest in 7-12 weeks. Compatible with : Beans, brassica sp. (cabbage, cauliflower, etc), tomato, allium sp. (onion, garlic, chives), lavender, parsnip',10,30),
    ('Sindora','The species is found growing in mixed forests, on mountain slopes and along riverbanks between sea level and 800 m. It grows to 8 to 20 metres tall and has a trunk diameter of 8 to 20 centimetres. Sindora glabra produces good quality wood used for building houses and making furniture.',NULL,NULL),
    ('Snow Peas','Sugar Peas, Mangetout, Chinese Peas. Cook whole or eat raw in salads Harvest in 12-14 weeks. Compatible with : Carrots, Endive, Florence fennel, Winter lettuce, Brassicas.',8,20),
    ('Spinach','English spinach. Use young leaves in salad. Steam and add to other vegetables. Harvest in 5-11 weeks. Compatible with : Broad beans (fava), cabbage, cauliflower, celery, eggplant (aubergine), onion, peas, strawberry, santolina',10,25),
    ('Spring onions','Scallions, Bunching onions, Welsh onion. Can be eaten raw in salads. Often used chopped and sprinkled on Asian stir-fry. Harvest in 8-12 weeks. Compatible with : Lemon Balm, Borage, Carrots, Beets, Silverbeet, Lettuce, Amaranth',10,20),
    ('Squash','Crookneck, Pattypan, Summer squash. Use whole or sliced. Steam or fry. Harvest in 7-8 weeks. Compatible with : Sweet corn',21,35),
    ('Strawberries Seeds)','Strawberries can be used in any dessert needing soft fruit or berries. Summer pudding with raspberries and blackberries or boysenberries, mousse, trifle, dipped in melted chocolate or just with cream. Straight from the garden, warmed by the sun is best. Harvest in approximately 1 years. Seedlings need to grow for about a year before fruiting. Remove first flowers. . Compatible with : Better in a bed on their own to allow good sun and air circulation',10,20),
    ('Strawberry Plants','Strawberries can be used in any dessert needing soft fruit or berries. Summer pudding which also has raspberries and blackberries or boysenberries, mousse, trifle, dipped in melted chocolate or just with cream. Harvest in approximately 11 weeks. Strawberries bruise easily when ripe, handle carefully. Pick with a small piece of stem attached.. Compatible with : Better in a bed on their own to allow good sun and air circulation',10,20),
    ('Sunflower','Use seeds fresh or toasted Harvest in 10-11 weeks. Compatible with : Cucumbers, Melons, Sweetcorn, Squash',10,30),
    ('Sweet corn','Maize. Piick and cook within an hour. Remove the silks and outer leaves. Best flavour if microwave about 4 minutes per cob. Can be barbequed wrapped in foil. Cook large amounts in a stock pot until test soft. Sprinkle with black pepper and dip in butter. Harvest in 11-14 weeks. Compatible with : All beans, cucumber, melons, peas, pumpkin, squash, amaranth',16,35),
    ('Sweet Marjoram','Knotted marjoram. Sweet Marjoram has a mild oregano flavor with a hint of balsam. Sweet Marjoram can be used as a substitute for oregano in sauces for mediterranean style pizza, lasagna, and eggplant parmigiana. Harvest in 8-10 weeks. Best flavour if picked before flowering. Compatible with : Peppers (Capsicums, Chilis), Sage,',10,25),
    ('Sweet Potato','Kumara. Use mashed, boiled, roasted, baked or fried. Or use in soups, pies, casseroles, curries and salads. Harvest in 15-17 weeks. Compatible with : Best in Separate bed',17,35),
    ('Taro','Dasheen, cocoyam. Taro can be cooked like potatoes, boiled, roasted, fried or steamed. It is not eaten raw. Harvest in approximately 28 weeks. When the leaves begin to die down. . Compatible with : Best in separate bed',20,35),
    ('Thyme','Common thyme. Common, lemon, orange and caraway thyme are used in cooking. Thyme is mainly used with meat and fish but also tastes good with vegetables such as mushrooms, beans and carrots. The flavour can be very intense so thyme is best used sparingly. Harvest in 42-52 weeks. Root divisions ready in 3 months. Compatible with : Dry-environment herbs (oregano,sage), Eggplant, Cabbage',15,25),
    ('Tomatillo','Use in spicy sauces with or to replace tomatoes. They are the base of salsa verde in Mexican cookery. Harvest in 10-14 weeks. Husk splits when fruit is ripe.. Compatible with : Will happily grow in a flower border',21,27),
    ('Tomato','Use in sauces, with fried meals, in sandwiches. Harvest in 8-17 weeks. Compatible with : Asparagus, Chervil,Carrot, Celery, Chives, Parsley, Marigold, Basil',16,35),
    ('Turnip','Grate young turnips and use raw in salads. Use older turnips in casseroles and stews. Harvest in 6-9 weeks. Compatible with : Peas, Beans, Chives, Spinach, Carrots, Chicory',12,30),
    ('Walnut','Tradition has it that a walnut tree should be beaten. This would have the benefit of removing dead wood and stimulating shoot formation.',-20,NULL),
    ('Watermelon','Cut up and eat in slices. Use to make fruit drinks. Use in fruit salads. Harvest in 12-17 weeks. Compatible with : Sweetcorn, Sunflowers',21,35),
    ('Weeping willow','Salix babylonica ''Pendula'', which was presumably spread along ancient trade routes in China. These distinctive trees were subsequently introduced into England from Aleppo in northern Syria in 1730, and have rapidly become naturalised, growing well along rivers and in parks.',10,NULL),
    ('Yacon','Sunroot. The large roots can be used raw in salads peel and chop. Sprinkle with lemon juice to prevent browning. In the Andes, they are grated and squeezed through a cloth to yield a sweet refreshing drink. The juice can also be boiled down to produce a syrup. Harvest in approximately 25 weeks. You can collect a few at a time without digging out the whole plant.. Compatible with : Best in separate bed',10,25),
    ('Yew','Yew wood is reddish brown (with whiter sapwood), and is very springy. It was traditionally used to make bows, especially the longbow. ',-10,NULL),
    ('Zucchini','Courgette/Marrow, Summer squash. Zucchini are best picked or cut off the stem at about 15cm / 6 inches.Pick frequently to keep the plant producing new flowers. Harvest in 6-9 weeks. Cut the fruit often to keep producing. Compatible with : Corn, beans, nasturtiums, parsley, Silverbeet, Tomatoes',21,35);

/*----------------
-- FamousTree --
----------------*/

INSERT INTO FamousTree (FTName, N3, Kind, Alias, PlantId) VALUES
    ('Abellio','Abe','Gallo-Roman god tree',NULL,4),
    ('Acherah','Ach','Sumerian sacred tree','"the mother goddess", "the queen of heaven"',59),
    ('Agaç Ana','Aga','Turkic world tree',NULL,NULL),
    ('Akshaya Vata','Aks','Hindu world tree','"The Eternal Banyan Tree"',102),
    ('Aldebaran','Ald','Redwood state park famous tree',NULL,107),
    ('Angel','Ang','USA famous tree',NULL,78),
    ('Aragorn','Ara','Redwood state park famous tree',NULL,107),
    ('Ashvattha','Ash','Hindu world tree','"that which remains tomorrow"',102),
    ('Ask','Ask','Norse sacred tree','"the ash tree", "Adam", "the first human male"',6),
    ('Atlas','Atl','Redwood state park famous tree',NULL,107),
    ('Austras koks','Aus','Latvian world tree','"tree of Dawn"',128),
    ('Baikushev''s pine','Bai','Bulgarian famous tree',NULL,90),
    ('Ballantines','Bal','Redwood state park famous tree',NULL,107),
    ('Banstokkr','Ban','Norse sacred tree','"the child trunk"',NULL),
    ('Bartek','Bar','Polish famous tree','"Bartholomew"',78),
    ('Bazyński Oak','Baz','Polish famous tree',NULL,78),
    ('Bell','Bel','Redwood state park famous tree',NULL,107),
    ('Bennett','Ben','USA famous tree',NULL,66),
    ('Beregond','Ber','Redwood state park famous tree',NULL,107),
    ('Bialbero di Casorzo','Bia','Italian famous tree','"the double tree of Casorzo"',76),
    ('Bodhi','Bod','Buddhism sacred tree','"the true nature of things", "the enlightenment", "the awakening"',102),
    ('Borjgali','Bor','Georgian tree of life','"strong shining", "the flow of time"',NULL),
    ('Boyington','Boy','USA famous tree','"the whispering tree"',78),
    ('Buxenus','Bux','Gallo-Roman god tree',NULL,19),
    ('Caesarsboom','Cae','Belgian famous tree','"Caesar''s Tree"',130),
    ('Castagno dei Cento Cavalli','Cas','Italian famous tree','"The Hundred-Horse Chestnut"',31),
    ('Celeborn','Cel','Tokien sacred tree','"the son of Galathilion", "the seeding of Telperion"',30),
    ('Centurion','Cen','Australian famous tree',NULL,53),
    ('Changi','Cha','Singaporean sacred tree','"the Time tree"',110),
    ('Chene chapelle','Chc','French sacred tree','"Our Lady of Peace", "Hermit''s room"',78),
    ('Chene des missions','Chm','French sacred tree',NULL,78),
    ('Craigends','Cra','Scotland famous tree',NULL,130),
    ('Datun Sahib','Dat','Hindu sacred tree',NULL,NULL),
    ('Davie','Dav','USA famous tree','"the general pleasant lunch", "the crumble of university"',92),
    ('Del Norte Titan','Del','Redwood state park famous tree',NULL,107),
    ('Donar','Don','Germanic sacred tree','"Jove''s Oak", "Thor''s Oak"',78),
    ('Drago Milenario','Dra','Spanish sacred tree','"the Thousand-Year-Old Dragon"',48),
    ('Duraosa','Dur','Zoroastrian sacred tree','"the beautiful man"',60),
    ('Earendil','Ear','Redwood state park famous tree',NULL,107),
    ('Egig érő fa','Egi','Hungarian world tree','"sky-high tree"',NULL),
    ('Eletfa','Ele','Hungarian world tree','"tree of life"',NULL),
    ('Elwing','Elw','Redwood state park famous tree',NULL,107),
    ('Embla','Emb','Norse sacred tree','"the elm tree", "Eve", "the first human female", "the busy woman"',51),
    ('Endicott','End','USA famous tree','"Endecott Pear", "the governor''s tree"',88),
    ('Etz Chaim','Etz','Hebrew tree of life','"tree of life", "the Torah", "the fruit of a righteous man", "a desire fulfilled", "healing tongue"',NULL),
    ('Fagus','Fag','Gallo-Roman god tree',NULL,12),
    ('Florence','Flo','Irish famous tree','"the oldest irish yew", "Florence Court Yew"',130),
    ('Fortingall','For','Scotland famous tree','"the oldest tree in Britain", "the cradle of Pontius Pilate"',130),
    ('Fusang','Fus','Chinese tree of life','"the origin of the sun"',76),
    ('Gaia','Gai','Redwood state park famous tree',NULL,107),
    ('Galathilion','Gal','Tokien sacred tree','"the son of Telperion", "the hearth of Tirion"',30),
    ('Gaokerena','Gao','Persian tree of life','"ox horn", "cow ear"',60),
    ('Gernikako Arbola','Ger','Biscayan sacred tree','"the Tree of Gernika"',78),
    ('Gilwell','Gil','British famous tree','"the moral of the acorn and the oak"',78),
    ('Glasir','Gla','Norse sacred tree','"the most beautiful among gods and men"',NULL),
    ('Glestonbury','Gle','Christian sacred tree','"the holy thorn"',61),
    ('Gog','Gog','Druidic sacred tree',NULL,78),
    ('Goshin','Gos','Japanese famous tree','"the protector of the spirit"',66),
    ('Hethel','Het','Christian sacred tree',NULL,61),
    ('Hibakujumoku','Hib','Japanese sacred tree','"the survivor tree", "the bombed tree", "the tree that survived the nuke"',NULL),
    ('Hippocrates','Hip','Greek famous tree','"the birthplace of medecine"',91),
    ('Hoddmímir','Hod','Norse sacred tree','"the treasure of Mimir"',NULL),
    ('Hyperion','Hyp','Redwood state park famous tree','"the tallest tree"',107),
    ('Iluvatar','Ilu','Redwood state park famous tree','"the creator of the universe"',107),
    ('Irminsul','Irm','Germanic world tree','"the mighty pillar", "the universal all-sustaining pillar"',NULL),
    ('Iroko','Iro','Yoruba world tree',NULL,64),
    ('Jagiełło','Jag','Polish famous tree','"The rest of king Wladyslaw"',78),
    ('Jaya Sri Maha Bodhi','Jay','Buddhism sacred tree',NULL,102),
    ('Jian-Mu','Jia','Chinese world tree','"the building tree", "the sword"',NULL),
    ('Jomon Sugi','Jom','Japanese sacred tree','"the cord marked tree"',44),
    ('Kalpavriksha','Kal','Hindu world tree','"wish-fulfilling tree", "tree of humanity"',38),
    ('Kien-Mu','Kie','Chinese world tree','"the standing tree"',NULL),
    ('Kiidk''yaas','Kii','Haida sacred tree','"the ancient tree"',90),
    ('Kongeegen','Kon','Famous danish tree','"the King Oak"',78),
    ('Kurrutherek','Kur','Persian legendary tree','"The Solitary Tree", "The Dry Tree"',91),
    ('Laeraor','Lae','Norse sacred tree','"the arranger of betrayal", "the giver of protection"',NULL),
    ('Laurelin','Lau','Tokien world tree','"the gold tree", "the tree that gave birth to the sun", "Malinalda", "Culúrien"',30),
    ('Lifprasir','Lif','Norse sacred tree','"lif''s lover", "the lover of life", "the zest for life"',NULL),
    ('Lignum scientiae','Lig','Christian tree of knoledge','"tree of knowledge of good and evil", "tree of knowledge"',4),
    ('Liph','Lip','Norse sacred tree','"the life", "the life of the body"',NULL),
    ('Lost Monarch','Los','Redwood state park famous tree',NULL,107),
    ('Luna','Lun','Redwood state park famous tree',NULL,107),
    ('Lusaaset','Lus','Egyptian tree of life','"the great one who comes forth"',1),
    ('Machya','Mac','Zoroastrian sacred tree','"the mortal man", "the first man"',NULL),
    ('Magog','Mag','Druidic sacred tree',NULL,78),
    ('Manidoo-giizhikens','Man','Ojibwa sacred tree','"the wich tree", "the little cedar spirit tree"',26),
    ('Mashyana','Mas','Zoroastrian sacred tree','"the mortal woman", "the first woman"',NULL),
    ('Matua Ngahere','Mat','Maori sacred tree','"Father of the Forest"',90),
    ('Merlin','Mer','British famous tree','"the birthplace of the magician"',78),
    ('Methuselah','Met','Hebrew sacred tree','"the oldest tree seed"',46),
    ('Mimameiðr','Mim','Norse sacred tree','"Mimi''s tree"',NULL),
    ('Modun','Mod','Mongolian world tree',NULL,NULL),
    ('Mudatao','Mud','Chinese tree of life','"the giant peach tree"',87),
    ('Nang Ta-khian','Nan','Thai sacred tree','"the lady of the tree"',62),
    ('Nimloth','Nim','Tokien sacred tree','"the White Tree of Númenor", "the son of Celeborn", "the seeding of Telperion", "the seed of the White Tree of Gondor", "the Fair of Númenor"',30),
    ('Oak','Oak','Finnish world tree','"the druid", "the king of woods", "the doorway to other worlds"',78),
    ('Pando','Pan','Utah famous tree','"the Trembling giant", "the oldest root"',9),
    ('Parijaat','Par','Hindu sacred tree',NULL,10),
    ('Pleiades','Ple','Redwood state park famous tree',NULL,107),
    ('Prometheus','Pro','Redwood state park famous tree',NULL,107),
    ('Rahmat','Rah','Iran sacred tree',NULL,91),
    ('Robur','Rob','Gallo-Roman god tree',NULL,78),
    ('Sacajawea','Sac','Redwood state park famous tree',NULL,107),
    ('Sang Kong','San','Chinese sacred tree','"the hollow mulberry"',76),
    ('Screaming Titans','Scr','Redwood state park famous tree',NULL,107),
    ('Sex Arbores','Sex','Gallo-Roman god tree',NULL,NULL),
    ('Shajarat alkhulud','Sha','Islamic tree of life','"the Tree of Immortality"',77),
    ('Sidraṫ al-Munṫahā','Sid','Islamic sacred tree','"the end of the seventh heaven"',26),
    ('Sisters','Sis','Christian sacred tree','"The Sisters Olive Trees of Noah"',80),
    ('Stara Maslina','Sta','Montenegro famous tree','"the old olive tree"',80),
    ('Stelmužė','Ste','Lithuanian famous tree',NULL,78),
    ('Tane Mahuta','Tan','Maori sacred tree','"Lord of the Forest"',90),
    ('Telperion','Tel','Tokien world tree','"the silver tree", "the tree that gave birth to the moon", "Silpion", "Ninquelótë", "Bansil", "Belthil"',30),
    ('Tenéré','Ten','Nigerian sacred tree','"the most isolated tree on earth"',1),
    ('Tetejetlen fa','Tet','Hungarian world tree','"tree without a top"',NULL),
    ('Thimmamma Marrimanu','Thi','Hindu sacred tree','"the Banyan tree"',55),
    ('Tjikko','Tji','Norway famous tree','"the world oldest tree"',90),
    ('Tong Kont','Ton','Chinese sacred tree','"the hollow paulownia"',86),
    ('Tooba','Too','Islamic sacred tree','"the blessedness"',126),
    ('Tres Branques','Tre','Spanish famous tree','"the three-branched pine",  "the unity of the three Catalan Countries"',90),
    ('Tule','Tul','Zapotec sacred tree','"the old man of the water", "the tree of life"',44),
    ('Uppsala','Upp','Norse sacred tree',NULL,130),
    ('Viejo del Norte','Vie','Redwood state park famous tree',NULL,107),
    ('Világfa','Vil','Hungarian world tree','"world tree"',NULL),
    ('Voror','Vor','Norse sacred tree','"the warden", "the watcher", "the caretaker"',51),
    ('Yax imix che','Yax','Maya world tree',NULL,27),
    ('Yggdrasil','Ygg','Norse world tree','"Odin''s horse"',6),
    ('Zapis','Zap','Serbian sacred tree','"the inscription"',78),
    ('Zaqqoom','Zaq','Islamic sacred tree','"the food of the people of Hell"',NULL),
    ('Zeus','Zeu','Redwood state park famous tree',NULL,107);


/*----------------
-- Position ------
----------------*/

INSERT INTO Position (PName) VALUES 
    ('Front Entrance'),
    ('Back Miror'),
    ('Left Side'),
    ('Right Power');

/*----------------
-- Shot ------
----------------*/

INSERT INTO Shot (SName, TiltIn, TiltOut, PanIn, PanOut, Status) VALUES 
    ('FrontStill_1', '1250', '1250', '1350', '1350', '102'),
    ('BackStill_1', '1450', '1450', '1350', '1350', '102'),
    ('RightStill_1', '1350', '1350', '1150', '1150', '102'),
    ('LeftStill_1', '1350', '1350', '1550', '1550', '102'),
    ('ZenithBackStill_1', '2000', '2000', '1350', '1350', '102'),
    ('ZenithLeftStill_1', '2000', '2000', '2100', '2100', '102'),
    ('ZenithRightStill_1', '2000', '2000', '600', '600', '102'),
    ('FrontPan_1', '1250', '1250', '1550', '1150', '112'),
    ('CentralPan_1', '1350', '1350', '1550', '1150', '112'),
    ('BackPan_1', '1450', '1450', '1550', '1150', '112'),
    ('ZenithPan_1', '2000', '2000', '2100', '600', '112'),
    ('LeftTilt_1', '1450', '1250', '1550', '1550', '112'),
    ('RightTilt_1', '1450', '1250', '1150', '1150', '112'),
    ('ZenithTilt_1', '1000', '2000', '1350', '1350', '112');

/*------------------------------------
-- Juncture Table Shot_Position ------
--------------------------------------*/

INSERT INTO Shot_Position (SId, PId) VALUES
    (1,1),
    (8,1),
    (9,1),
    (12,1),
    (13,1),
    (14,1),
    (2,2),
    (3,2),
    (4,2), 
    (5,2),
    (6,2),
    (7,2),
    (8,2),
    (9,2),
    (10,2),
    (11,2),
    (12,2),
    (13,2),
    (14,2),
    (1,3),
    (4,3),
    (6,3),
    (8,3),
    (9,3),
    (10,3),
    (11,3),
    (12,3),
    (14,3),
    (1,4),
    (3,4),
    (7,4),
    (8,4),
    (9,4),
    (10,4),
    (11,4),
    (13,4),
    (14,4);
