# EdenBot
Code for managing my cyber greenhouse (timelapses, tweepy and sensor database)
It runs on a rasperry Py 3

### "Bifrost" - The rainbow that connects the worlds
This file parses the config and settings files.
It holds the connections beetween the differents modules.
Holds the system, the network, the hardware and software together.
Discuss with the user and input order to EdenBot.

### "Finna" - To discover, to find, to percieve
This file contains the classes used to get information from the world.
meteo data, camera shots, timelapses creation, hardware data input.
the classes shall save, interpret and store temporaly the data.
the classes shall act directly on the GPIO.

### "Geta" - To think, to deduce
This file contains the functions that need many modules aggregated.
it takes decisions, calculates and processes data.
it prepares actions on the long term.

### "Roeoa" - Conversation, to talk
This file contains the classes used to express to the world.
it will log through network accounts and post.
it will create the sentences of EdenBot.
it will send messages through lcd, led and buzzer.

### "Skutr" - The Memory, the back cabin
This file exchange with the SQLite database.
It handles its reading, writting, updates.
Ensure the integrity of the data.
