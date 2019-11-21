# esx_gruppe6

Gruppe6 Security job for esx based FiveM servers

Suit up and take a job from the Office, ensure the trespasser is taken care of properly or you don't get paid, but the faster you get it the done, the more money you receive.

Configurable payouts, patrols zones, peds, and scnearios, as well as station, armory, and uniform configurations. (Note if anyone can get a list or do a PR for female clothing that looks good that would be wonderful)

If you happen to get stopped by Police, make sure to show them your Security Badge so they can easily verify you are a registered guard.

# Requirements
# Player management (boss actions, society use)
[esx_society](https://github.com/FXServer-ESX/fxserver-esx_society)
[esx_datastore](https://github.com/FXServer-ESX/fxserver-esx_datastore)

# ESX Identity Support
[esx_identity](https://github.com/ESX-Org/esx_identity)
  
Download esx_gruppe6-master.zip. Extract esx_gruppe6-master folder and rename to esx_gruppe6. Make sure to import esx_gruppe6.SQL into your main database table. Place the esx_gruppe6 folder into your server's \resources directory. Add "start esx_gruppe6" into your server.cfg, preferably around new resources, or around your jobs, but where ever you like honestly. Restart your server. Enjoy stopping trespassers.

If you want a few actual Gruppe6 cars you should go download this pack https://forum.fivem.net/t/release-gruppe6-security-cars-addon-pack/52574 and turn the Config.UseCarPack to true, it will replace the dilettante2 (Car), the contender (SUV), and bifta (Buggy) with vehicles that have active amber lights, slightly more versatility, and all around an amazing look.

# Controls
Holding 'W' and releasing 'E' while looking/aiming at an npc will force them to give up. While an entity has given up you may NOT force another entity to give up, this is cleared when the entity is released. You will then be able to use the 'Citizen Interaction' menu option and 'Softcuff', 'Escort', or 'Transport' the npc. You must have a cuffed entity to 'Escort' and you must be escorting an entity to 'Transport', as well as be very close to the vehicle you wish to use( preferably the back right door, this is the door the ped will always enter so make sure it is available ). You must 'Escort' npc's to take them out of a transported car. Selecting 'Escort' while escorting an npc will release the npc from the scripts control, as well holding 'S' and releasing 'E'( in case a ped gets stuck in a table or some weird stuff happens ).

# Upcoming
Regular 'Issue' adjustments
Personally made vehicle packs as well as ymap/mlo Gruppe6 building(s).

Please enjoy the script and make sure to open an 'Issue' if you notice anything arise. If you can fix it and would like to post a PR I will be checking for those regularly as well.
