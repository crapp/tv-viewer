# da.msg
namespace import -force msgcat::mcset

### ../data/agrep.tcl ###


### ../data/chan_zapper.tcl ###

mcset da {Timeout for changing video input} {Timeout for at skifte video input}
mcset da {Video device % does not exist} {Video enhed %s existerer ikke}

### ../data/colorm.tcl ###

mcset da {Brightness} {Lysstyrke}
mcset da {Contrast} {Kontrast}
mcset da {Hue} {Tone}
mcset da {Saturation} {Mætning}
mcset da {Apply} {Anvend}
mcset da {Default} {Standard}
mcset da {Cancel} {Afbryd}
mcset da {Color Management} {Farvehåndtering}
mcset da {Set brightness, this is a global value} {Sæt lysstyrke, gælder alle stationer}
mcset da {Set contrast, this is a global value} {Sæt kontrast, gælder alle stationer}
mcset da {Set hue, this is a global value} {Sæt farvetone, gælder alle stationer}
mcset da {Set saturation, this is a global value} {Sæt mætning, gælder alle stationer}
mcset da {Save values and close color management} {Gem værdierne og forlad farvehåndtering}
mcset da {Load default values} {Indlæs standard værdier}
mcset da {Close color management without saving changes} {Luk farvehåndtering uden at gemme ændringer}

### ../data/command_socket.tcl ###


### ../data/config_advanced.tcl ###

mcset da {Advanced} {Avanceret}
mcset da {Manage aspect ratio} {Håndter højde-bredde forhold}
mcset da {Keep video aspect ratio} {Behold Video højde-bredde-forhold}
mcset da {Monitor aspect} {Monitorer aspekt}
mcset da {Monitor pixel aspect} {Monitorer pixel aspekt}
mcset da {Screenshot} {Skærmbillede}
mcset da {Activate screenshot feature} {Aktiver skærmbillede funktion}
mcset da {MPlayer config file} {MPlayer Konfigurationsfil}
mcset da {Do not process MPlayer config files} {Spring over MPlayer konfigurationsfil}
mcset da {Default settings} {Standard indstillinger}
mcset da {Reset} {Nulstil}
mcset da {Additional options for MPlayer} {Indstillinger for MPlayer}
mcset da {Additional MPlayer options} {Andre MPlayer indstillinger}
mcset da {Additional video filter options} {Andre indstillinger for Videofilter}
mcset da {Additional audio filter options} {Andre indstillinger for Audiofilter}
mcset da {Logs} {Logs}
mcset da {Enable Logging} {Aktiver Logging}
mcset da {MPlayer logfile size in kBytes} {MPlayer logfil størrelse i kBytes}
mcset da {Scheduler logfile size in kBytes} {Scheduler logfil størrelse i kBytes}
mcset da {TV-Viewer logfile size in kBytes} {TV-Viewer logfil størrelse i kBytes}
mcset da {Report errors} {Rapporter fejl}
mcset da {Popup dialogue box for errors} {Popup dialogboks for fejl}
mcset da {Let TV-Viewer manage video aspect ratio (recommended)} {Lad TV-Viewer styre Video højde-bredde-forhold (anbefalet)}
mcset da {Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality.} {Vælg enten monitor højde-bredde-forhold eller monitor pixel aspekt. 
Det kan forbedre billedkvaliteten.}
mcset da {Activate or deactive the screenshot feature.
Screenshots will be stored in the users home directory.} {Aktiver eller deaktiver skærmbilled-funktionen.
 Skærmbilleder gemmes i brugerens hjemmemappe.}
mcset da {If enabled MPlayer will ignore all existing config files.
This will ensure only values set by TV-Viewer will be used.} {Når aktiveret bliver alle Mplayers eksisterende konfigurationsfiler ignoreret.
Dermed sikres, at kun værdier sat af TV-viewer bliver brugt.}
mcset da {Reset all configuration options} {Nulstil alle konfigurationer til standardværdier}
mcset da {Here you may provide additional command line options for MPlayer.
Separate the different options with spaces.
See the MPlayer man pages for more informations.} {Her kan man tilføje ekstra kommandolinie-optioner for MPlayer.
Adskil de enkelte optioner med mellemrum.
Se manual ('man mplayer') for flere oplysninger.}
mcset da {Additional video filter options must be separated with commas.
E.g. scale=512:-2,eq2=1.1
See the MPlayer man pages for more informations.} {Ekstra Videofilter skal adskilles med kommaer.
fx. scale=512:-2,eq2=1.1
Se manual ('man mplayer') for flere oplysninger.}
mcset da {Additional audio filter options must be separated with commas.
E.g. resample=44100:0:0,volnorm
See the MPlayer man pages for more informations.} {Ekstra Audiofilter skal adskilles med kommaer.
fx. resample=44100:0:0,volnorm
Se manual ('man mplayer') for flere oplysninger.}
mcset da {Check this to enable logging of TV-Viewer, Scheduler and MPlayer events.
You can find the three logfiles in %/log/
Refer to the 'Help' section of the main interface for the log viewers.} {Aktiver denne for at starte logging af TV-Viewer, Scheduler og MPlayer.
De tre Logfiles kan man finde i %s/log/.
Se „Hjælp“-sectionen i hovedomtalen af log-viewers.}
mcset da {Specify the amount of space in kBytes the MPlayer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb} {Specificer max størrelse for MPlayers logfil i kbytes.
Når denne størrelse nås, vil filen blive slettet og en ny startet.
Minimum: 10kb Maximum: 100kb}
mcset da {Specify the amount of space in kBytes the TV-Viewer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb} {Specificer max størrelse i kbytes for TV-Viewers logfil.
Når denne størrelse nås, vil filen blive slettet og en ny startet.
Minimum: 10kb Maximum: 100kb}
mcset da {Specify the amount of space in kBytes the Scheduler logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb} {Specificer max størrelse i kbytes for Schedulers logfil.
Når denne størrelse nås, vil filen blive slettet og en ny startet..
Minimum: 10kb Maximum: 100kb}
mcset da {If activated a dialogue box will popup in case of serious errors} {Hvis aktiveret vil en dialogbox poppe op ved en alvorlig fejl}

### ../data/config_analog.tcl ###

mcset da {Analog Settings} {Analog Indstillinger}
mcset da {Video Device Node} {Videoenhed}
mcset da {Video Standard} {Video Standard}
mcset da {Frequency Table} {Frekvens Tabel}
mcset da {Force Standard} {Gennemtving Standard}
mcset da {Video Input} {Video Input}
mcset da {Analog Stream Settings} {Videostream}
mcset da {Stream Bitrate} {Bitrate}
mcset da {Video Bitrate} {Video Bitrate}
mcset da {Video Peak Bitrate} {Video Peak Bitrate}
mcset da {Temporal Filter} {Temporal Filter}
mcset da {Hardware volume level} {Hardware lydstyrke}
mcset da {Volume} {Lydstyrke}
mcset da {Error} {Fejl}
mcset da {Missing requirements} {Manglende systemkrav}
mcset da {Could not detect all necessary tools to run TV-Viewer} {Kunne ikke finde alle de værktøjer der er nødvendige for TV-Viewer}
mcset da {ivtv-tune} {ivtv-tune}
mcset da {v4l2-ctl} {v4l2-ctl}
mcset da {Disabled} {Deaktiveret}
mcset da {Analog settings are disabled,
while running a recording or timeshift} {Analog indstillinger er deaktiverede,
mens optagelse eller timeshift pågår}
mcset da {No video device nodes} {Ingen video enhed}
mcset da {Choose the video device node.
See "dmesg | grep ivtv || pvrusb2 || cx18"} {Vælg Videoenhed.
Se "dmesg | grep ivtv || pvrusb2 || cx18"}
mcset da {Constrain setting of the video standard.
Choose this if the driver selects the wrong one.} {Begræns Video Standard indstilling.
Vælg dette hvis driveren vælger den forkerte indstilling.}
mcset da {Define the way of color transmission.
Depends on where you are located.} {Definer måden for farvetransmission.
Afhæger af hvor man befinder sig.}
mcset da {The frequency table provides informations about the 
frequency band that should be used to search for tv stations.} {Frekvenstabellen fortæller TV-Viewer hvilket Frekvensbånd der skal bruges for at søge TV-stationer.}
mcset da {Choose the video input} {Vælg Video Indgang.}
mcset da {Check this if you want to alter the videobitrate} {Vælg dette hvis du vil ændre videobitrates.}
mcset da {Define the videobitrate. Don't set the
videobitrate to a higher value than videobitrate (peak)!
Standard values are recommended.
Data in kb/sec.} {Vælg Videobitrate. Sæt den ikke højere end
Videobitrate (Peak)!
Standard-indstillinger anbefales.
Værdi i kb/sec.}
mcset da {Define the videobitrate (peak). Don't set the 
videobitrate (peak) to a lower value than videobitrate.
Standard values are recommended.
Data in kb/sec.} {Vælg Videobitrate (Peak). sæt den ikke lavere end Videobitrate.
Standard-indstillingen anbefales.
Værdi i kb/sec.}
mcset da {Check this if you want to change the temporal filter.
This option can help if you have a blurred picture.} {Vælg dette hvis du vil tilpasse Temporal Filteret.
Dette kan hjælpe ved sløret billede.}
mcset da {Choose level of temporal filtering} {Sæt niveau for Temporal Filtrering}
mcset da {Enable this option if you want to change the hardware volume level.} {Aktiver denne indstilling hvis du vil ændre hardware lydstyrken.}
mcset da {Specify the hardware volume level.
This applies to all stations and it is not recommended
to change this value.} {Specificer Hardware Lydstyrke.
Denne værdi vil gælde for alle kanaler og
det anbefales ikke at ændre den.}

### ../data/config_audio.tcl ###

mcset da {Audio Settings} {Audio Indstillinger}
mcset da {Audio output driver} {Audio output driver}
mcset da {Audio channels} {Audio kanaler}
mcset da {Use software mixer} {Anvend software mixer}
mcset da {Remember volume level} {Husk lydstyrke}
mcset da {Audio synchronization} {Audio sync}
mcset da {Auto synchronization} {Auto sync}
mcset da {Audio/Video sync correction} {Audio/Video sync korrektion}
mcset da {Choose an audio output driver, alsa is recommended.} {Vælg en Audio output driver, alsa anbefales.}
mcset da {Check this option to use the software mixer,
instead of the hardware mixer.} {Vælg denne indstilling for at bruge software mixer i stedet for hardware mixer.}
mcset da {This option tells MPlayer to decode
audio to the chosen value} {Denne indstilling fortæller MPlayer at dekode audio til den valgte værdi.}
mcset da {Remeber volume level} {Husk lydstyrke}
mcset da {Gradually adjusts the A/V sync based on audio delay measurements} {Juster A/V sync gradvist baseret på audio delay målinger}
mcset da {Audio/Video sync correction per frame in seconds} {Audio/Video sync korrektion pr frame i sekundet}

### ../data/config_dvb.tcl ###

mcset da {DVB Settings} {DVB Indstillinger}
mcset da {Expect more soon} {Vent mere snart}

### ../data/config_general.tcl ###

mcset da {General Settings} {Generelle Indstillinger}
mcset da {Language} {Sprog}
mcset da {Start TV on startup} {Start TV ved programstart}
mcset da {Enable} {Aktiver}
mcset da {Newsreader} {Nyhedslæser}
mcset da {Time interval in days} {Tidsinterval i dage}
mcset da {Electronic Program Guide} {Elektronisk Program Guide}
mcset da {Choose a program} {Vælg program}
mcset da {Autodetect} {Find automatisk}
mcset da {Choose an EPG application} {Vælg EPG Program}
mcset da {Choose your language.
You'll need to restart TV-Viewer for changes to take effect.} {Vælg sprog.
Genstart TV-Viewer for at se ændringen.}
mcset da {Autostart tv playback on program start} {Autostart TV ved programstart.}
mcset da {Activate Newsreader.
The Newsreader will check for news about TV-Viewer.} {Aktiver nyhedslæser.
Nyhedslæseren søger efter nyheder om TV-Viewer.}
mcset da {Choose time intervall in days for Newsreader (1-30)} {Vælg tidsinterval i dage for nyhedslæser, (1-30)}
mcset da {Specify a program to retrieve the television program} {Specificer et program der kan hente TV-programmet}

### ../data/config_interface.tcl ###

mcset da {Interface} {Interface}
mcset da {Theme} {Tema}
mcset da {Enable Tooltips} {Aktiver Tooltips}
mcset da {Main Gui} {Hovedvindue}
mcset da {Preferences} {Indstillinger}
mcset da {Station Editor} {Stationseditor}
mcset da {Record Wizard} {Optage assistent}
mcset da {Splash Screen} {Splash Screen}
mcset da {Show Splash Screen on initialization} {Vis Splash Screen ved programstart}
mcset da {Window Properties} {Vindue egenskaber}
mcset da {Main window} {Hoved vindue}
mcset da {Start in full-screen mode} {Start i fuldskærms modus}
mcset da {Remember size and position} {Husk størrelse og position}
mcset da {Floating control} {Flydende Kontrol}
mcset da {Main toolbar} {Hoved værktøjslinie}
mcset da {Station list} {Stationliste}
mcset da {Control toolbar} {Kontrol værktøjslinie}
mcset da {System Tray} {Systembakke}
mcset da {Show icon in system tray} {Vis ikon i systembakken}
mcset da {Minimize to tray} {Minimer til bakke}
mcset da {Close to tray} {Luk til bakke}
mcset da {Resize system tray icon} {Ændre størrelse på ikon}
mcset da {System tray icon size} {Systembakke ikon størrelse}
mcset da {On screen Display} {On screen Display}
mcset da {Station} {Station}
mcset da {Windowed mode} {Vindue modus}
mcset da {Full-screen mode} {Fuldskærm modus}
mcset da {Volume | Video input | Pan&Scan} {Volumen | Video input | Pan&Scan}
mcset da {Key Input} {Tastatur Input}
mcset da {OSD Station list lirc} {OSD Stationliste lirc}
mcset da {Notifications} {Notifications} ;#Newline
mcset da {Notification Daemon} {Notification Daemon} ;#Newline
mcset da {Display:} {Display:} ;#Newline
mcset da {Display time:} {Display time:} ;#Newline
mcset da {top right} {top højre}
mcset da {bottom right} {bund højre}
mcset da {bottom left} {bund venstre}
mcset da {top left} {top venstre}
mcset da {Choose your preferred theme} {Vælg dit foretrukne Tema}
mcset da {Check this if you want to see tooltips} {Check for Vis Tooltips}
mcset da {Tooltips for the main Interface} {Tooltips for hovedvinduet}
mcset da {Tooltips for the preferences} {Tooltips for indstillinger}
mcset da {Tooltips for the Station Editor} {Tooltips for Stationseditor}
mcset da {Tooltips for the Color Management} {Tooltips for farvebehandling}
mcset da {Tooltips for the Record Wizard} {Tooltips for Optage-Assistenten}
mcset da {Check this if you want to see the splash screen at the start of TV-Viewer} {Check hvis du vil se splash screen ved programstart}
mcset da {Start TV-Viewer in full-screen mode} {Start TV-Viewer i fuldskærm modus}
mcset da {Remember window size and position} {Husk vindue størrelse og position}
mcset da {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "top", of the screen.} {Den flydende kontrol viser sig i fuldskærm modus når musen flyttes til "toppen" af skærmen}
mcset da {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "left side", of the screen.} {Den flydende kontrol viser sig i fuldskærm modus når musen flyttes til "venstre side" af skærmen}
mcset da {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "bottom", of the screen.} {Den flydende kontrol viser sig i fuldskærm modus når musen flyttes til "bunden" af skærmen}
mcset da {Activate integration to system tray} {Aktiver integration til systembakken}
mcset da {Automatically resize system tray icon if the size of the tray 
itself is changed. Be careful with this option.} {Ændrer automatisk størrelse på systembakkes ikoner hvis bakken selv ændres. Vær forsigtig med dette valg.}
mcset da {Choose the size for the system tray icon} {Vælg størrelse for systemsbakke ikoner}
mcset da {OSD for station name in windowed mode} {OSD for stationsnavn i vindue modus}
mcset da {OSD for station name in full-screen mode} {OSD for stationsnavn i fuldskærmsmodus}
mcset da {Change font, color and alignment} {Vælg font, farve og justering}
mcset da {OSD for Volume; Pan&Scan; Video input in windowed mode} {OSD for Volumen; Pan&Scan; Video input i vindue modus}
mcset da {OSD for Volume; Pan&Scan; Video input in full-screen mode} {OSD for Volumen; Pan&Scan; Video input i fuldskærm modus}
mcset da {OSD for change stations via numbers input in windowed mode} {OSD for at skifte station med tal i vindue modus}
mcset da {OSD for change stations via numbers input in full-screen mode} {OSD for at skifte station med tal i fuldskærm modus}

### ../data/config_radio.tcl ###

mcset da {Radio Settings} {Radio Indstillinger}

### ../data/config_record.tcl ###

mcset da {Record Settings} {Optage Indstillinger}
mcset da {Standard folder} {Standard mappe}
mcset da {Default record duration} {Standard optagetid}
mcset da {Allow station change while recording} {Tillad stationsskift under en optagelse}
mcset da {Autostart scheduler} {Start Scheduler automatisk}
mcset da {Hours format} {Tidsformat}
mcset da {24-hour clock} {24-timer ur}
mcset da {12-hour clock} {12-timer ur}
mcset da {Timeshift} {Timeshift}
mcset da {Timeshift folder} {Timeshift mappe}
mcset da {Space to be left free} {Min fri plads på harddisken}
mcset da {Choose a directory} {Vælg en mappe}
mcset da {Set the default directory for all recordings} {Vælg en standard mappe for alle optagelser}
mcset da {Define the default duration for recordings (Hours)} {Standard varighed for optagelser (timer)}
mcset da {Define the default duration for recordings (Minutes)} {Standard varighedfor optagelser (Minutter)}
mcset da {Define the default duration for recordings (Seconds)} {Standard varighed for optagelser (Sekunder)}
mcset da {Choose if you want to use a 24-hour clock or 12-hour clock to schedule recordings} {Vælg om du ønsker et 24-timer ur eller et 12-timer ur til at planlægge optagelser}
mcset da {Allow station change during recording} {Tillad Stationsskift under optagelse}
mcset da {Autostart the scheduler.
This is necessary for scheduled recordings.} {Start Scheduler automatisk.
Dette er nødvendigt for planlagte optagelser}
mcset da {Choose path where Timeshift events will be cached} {Vælg mappe hvor Timeshift-data kan lagres midlertidigt}
mcset da {Define the minimum free disk space.
If free disk space is falling below this value
timeshift will automatically be stopped.
A value of 0 deactivates this feature.} {Fastlæg hvor meget fri plads på harddisken der mindst skal være.
Hvis den ledige plads synker under dette tal, vil Timeshift automatisk afbrydes.
Værdien 0 deaktiverer denne feature}

### ../data/config_video.tcl ###

mcset da {Video Settings} {Video Indstillinger}
mcset da {Video} {Video}
mcset da {Video output driver} {Video output driver}
mcset da {Deinterlacing filter} {Deinterlacing filter}
mcset da {Postprocessing level} {Efterbearbejdning niveau}
mcset da {Cache size (kB)} {Cache størrelse (kB)}
mcset da {Threads for decoding} {Threads for decoding}
mcset da {Direct Rendering} {Direkte Rendering}
mcset da {Double Buffering} {Dobbelt Buffering}
mcset da {Slice Mode} {Slice Modus}
mcset da {Framedrop} {Framedrop}
mcset da {Hard Framedrop} {Hard Framedrop}
mcset da {Disable Screensaver} {Deaktiver pauseskærm}
mcset da {Use MPlayer} {Brug MPlayer}
mcset da {Use Heartbeat function} {Brug Heartbeat funktion}
mcset da {Select the video ouput driver.
xv should provide the best performance.} {Vælg Video ouput driver.
xv skulle give den bedste ydelse}
mcset da {Select the deinterlace filter} {Vælg the deinterlace filter}
mcset da {Changes the level of postprocesseing.
A value of 0 deactivates postprocessing.} {Ændrer niveau for efterbehandling.
Værdien 0 deaktiverer efterbehandling}
mcset da {Specify how much memory (in kBytes) should be used for TV playback.
The lower this value is the faster you may switch between stations.
But a low value could cause other problems.
A value of 0 will deactivate cache use.} {Angiv hvor meget hukommelse (in kBytes) der skal anvendes til TV-playback.
Jo mindre værdi, desto hurtigere stationsskift.
Men en for lav værdi kan give andre problemer.
Værdien 0 deaktiverer precaching}
mcset da {Sets the number of threads for decoding} {Fastlægger antal threads for decoding}
mcset da {If checked, enables direct rendering. This is not supported
for all video ouput drivers.} {Aktiverer direkte Rendering. Virker ikke med alle
Video ouput drivere.}
mcset da {Double buffering fixes flicker by storing two frames in memory
and displaying one, while decoding another.} {Dobbelt buffering forhindrer flimmer ved at lagre 2 rammer i hukommelsen.
 Den ene vises mens den anden decodes.}
mcset da {Enable / Disable drawing video by 16-pixel height slices/bands.
May help in better video playback.} {Til / Frakobler videotegning i 16-piksel bånd. Kan hjælpe med bedre video playback.}
mcset da {Skip displaying some frames to maintain A/V sync} {Springer enkeltbilleder over for at fastholde A/V sync}
mcset da {More intense frame dropping. May lead to image distortion.} {Forstærket overspring af enkeltbilleder. Kan føre til billedforringelse.}
mcset da {Enable / Disable screensaver while playback} {Aktiver / Deaktiver pauseskærm under videoplayback}
mcset da {Use MPlayer to deactivate the screensaver} {Lad MPlayer deaktivere pauseskærmen}
mcset da {If MPlayer can't deactivate your screensaver, use this heartbeat hack} {Hvis MPLayer ikke kan deaktivere pauseskærmen, brug dette Heartbeat hack}

### ../data/config_wizard.tcl ###

mcset da {General} {Generelt}
mcset da {Analog} {Analog}
mcset da {DVB} {DVB}
mcset da {Audio} {Audio}
mcset da {Radio} {Radio}
mcset da {Record} {Optage}
mcset da {Apply your changes and exit preferences dialog} {Anvend ændringer og afslut Indstillinger}
mcset da {Load default values, for the corresponding section} {Indlæs Standard værdierne for det tilsvarende afsnit}
mcset da {Discard changes and close preferences dialog} {Kasser ændringerne og forlad Indstillinger}

### ../data/create_icons.tcl ###


### ../data/dbus_interface.tcl ###

mcset da {Can not load shared library dbus-tcl} {Kan ikke indlæse det delte bibliotek dbus-tcl}

### ../data/diag_frontend.tcl ###

mcset da {Diagnostic Routine is checking your system.
Please wait...} {Diagnoseprogrammet checker systemet.
Vent venligst...}
mcset da {Exit} {Afslut}
mcset da {Diagnostic Routine} {Diagnoseprogram}
mcset da {Diagnostic Routine finished} {Diagnoseprogram færdigt}
mcset da {Generated file:} {Dannede fil:}
mcset da {Create a bug report on } {Lav en fejlrapport på }
mcset da {and attach the generated file.} {og vedhæft den dannede fil.}
mcset da {Diagnostic Routine crashed} {Diagnoseprogram gik ned}

### ../data/diag_runtime.tcl ###


### ../data/difftime.tcl ###


### ../data/error_interp.tcl ###

mcset da {Skip further error messages} {Spring over yderligere fejlmelding}
mcset da {OK} {OK}
mcset da {File bug report} {Rapporter fejl}
mcset da {Save to disk} {Gem på disk}
mcset da {Error: %} {Fejl: %s}
mcset da {Select everything} {Vælg alt}
mcset da {Copy to clipboard} {Kopier til klipbord}
mcset da {TV-Viewer crashed} {TV-Viewer gik ned}
mcset da {Choose name and location} {Vælg navn og sted}

### ../data/event_bind.tcl ###


### ../data/font_chooser.tcl ###

mcset da {Family:} {Familie:}
mcset da {Style:} {Stil:}
mcset da {Size:} {Størrelse:}
mcset da {Font color:} {Skriftfarve:}
mcset da {Preview:} {Forhåndsvisning:}
mcset da {top} {top}
mcset da {left} {venstre}
mcset da {center} {center}
mcset da {right} {højre}
mcset da {bottom} {bund}
mcset da {Font chooser Ui has finished unexpectedly} {Fontvælger er stoppet uventet}
mcset da {Choose a font} {Vælg en font}
mcset da {Choose font style} {Vælg font stil}
mcset da {Choose font size} {Vælg font størrelse}
mcset da {Choose font color} {Vælg skriftfarve}
mcset da {Specify where the message box should be
displayed in the video frame} {Fastlæg hvor Meddelelsesboksen skal være i Player-vinduet}
mcset da {Choose font} {Vælg font}
mcset da {Choose color} {Vælg farve}

### ../data/info_help.tcl ###

mcset da {TV-Viewer % Build %} {TV-Viewer %s Build %s}
mcset da {Info} {Info}
mcset da {A small and simple frontend to watch and record television} {Et lille og enkelt program til at se og optage fjersynsudsendelser}
mcset da {Homepage} {Hjemmeside}
mcset da {Forum} {Forum}
mcset da {IRC channel} {IRC channel}
mcset da {© Copyright 2007 - 2011
Christian Rapp} {© Copyright 2007 - 2011
Christian Rapp}
mcset da {Credits} {Bidragsydere}
mcset da {License} {Licens}
mcset da {Changelog} {Changelog}
mcset da {About TV-Viewer} {Om TV-Viewer}

### ../data/key_sequences.tcl ###

mcset da {Available Key Sequences} {Tilgængelige Tastekombinationer}
mcset da {Change shortcut} {Skift genvejstast}
mcset da {Key Sequences} {Tastekombinationer}
mcset da {Action} {Aktion}
mcset da {Key Sequence} {Tastekombinationer}
mcset da {Television} {Fjernsyn}
mcset da {Window management} {Vindueshåndtering}
mcset da {Recording / File playback} {Optage / Fil playback}
mcset da {Do you really want to load default values for all key sequences?

This will happen instantly and can not be undone!} {Ønsker du virkelig at indlæse standardværdier for alle genvejstaster?

Det vil ske straks og kan ikke fortrydes!}
mcset da {Set shortcuts to default values} {Sæt genveje til standardværdier}
mcset da {Press the key combination you want to assign} {Tryk tastekombinationen du ønsker at tildele}
mcset da {Clear} {Nulstil}
mcset da {Modify shortcut} {Ændre genvejstast}
mcset da {It is not possible to edit this shortcut} {Det er ikke muligt at redigere denne genvejstast}
mcset da {Conflict detected with station by number "0-9"} {Opdaget konflikt med station med ciffervalg "0-9"}
mcset da {Conflict detected with %} {Konflikt opdaget med %s}

### ../data/launch_splash.tcl ###


### ../data/lirc_emitter.tcl ###


### ../data/log_viewer.tcl ###

mcset da {Choose output file} {Vælg output fil}
mcset da {$ident(name($handler)) Log} {$ident(name($handler)) Log}
mcset da {Save logfile to disk} {Gem logfil på disk}
mcset da {Send logfile by e-mail to the authors} {Send logfil med e-mail til udviklerne}
mcset da {Show/hide Debug messages} {Vis/skjul debug meddelelser}
mcset da {Show/hide Warning messages} {Vis/skjul advarsler}
mcset da {Show/hide Error messages} {Vis/skjul fejlmeldinger}

### ../data/main_command_line_options.tcl ###


### ../data/main_frontend.tcl ###

mcset da {Name} {Navn}
mcset da {No} {Nr}
mcset da {Navigation} {Navigation}
mcset da {View} {View}
mcset da {Help} {Hjælp}
mcset da {Welcome to TV-Viewer %} {Velkommen til TV-Viewer %s}
mcset da {Could not detect MPlayer} {Kunne ikke finde MPlayer}
mcset da {TV-Viewer idle} {TV-Viewer ledig}

### ../data/main_menu.tcl ###

mcset da {EPG} {EPG}
mcset da {TV} {TV}
mcset da {Prior Station} {Forrige Station}
mcset da {Next Station} {Næste Station}
mcset da {Station jumper} {Station skifter}
mcset da {Play} {Afspil}
mcset da {Pause} {Pause}
mcset da {Stop} {Stop}
mcset da {Rewind} {Tilbage}
mcset da {-10 seconds} {-10 sekunder}
mcset da {-1 minute} {-1 minut}
mcset da {-10 minutes} {-10 minutter}
mcset da {File beginning} {Fil start}
mcset da {Forward} {Fremad}
mcset da {+10 seconds} {+10 sekunder}
mcset da {+1 minute} {+1 minut}
mcset da {+10 minutes} {+10 minutter}
mcset da {File end} {Fil slut}
mcset da {Pan&Scan} {Pan&Scan}
mcset da {Zoom +} {Zoom +}
mcset da {Zoom ++} {Zoom ++}
mcset da {Zoom -} {Zoom -}
mcset da {Zoom --} {Zoom --}
mcset da {Reset zoom} {Nulstil zoom}
mcset da {Pan&Scan (16:9 / 4:3)} {Pan&Scan (16:9 / 4:3)}
mcset da {Move up} {Flyt op}
mcset da {Move down} {Flyt ned}
mcset da {Move left} {Flyt til venstre}
mcset da {Move right} {Flyt til højre}
mcset da {Center video} {Centrer video}
mcset da {Size} {Størrelse}
mcset da {Stay on top} {Bliv i forgrund}
mcset da {Never} {Aldrig}
mcset da {Always} {Altid}
mcset da {While playback} {Under playback}
mcset da {Toolbars} {Værktøjslinier}
mcset da {Statusbar} {Statuslinie}
mcset da {Show status messages} {Vis status meddelser}
mcset da {Show playback time} {Vis playback tid}
mcset da {Compact mode} {Kompakt modus}
mcset da {Fullscreen} {Fuldskærm}
mcset da {Volume +} {Volumen +}
mcset da {Volume -} {Volumen -}
mcset da {Mute} {Mute}
mcset da {Delay +} {Delay +}
mcset da {Delay -} {Delay -}
mcset da {User Guide} {Bruger Guide}
mcset da {MPlayer Log} {MPlayer Log}
mcset da {Scheduler Log} {Scheduler Log}
mcset da {TV-Viewer Log} {TV-Viewer Log}

### ../data/main_newsreader.tcl ###


### ../data/monitor.tcl ###


### ../data/notifyd.tcl ###

mcset da {Start Newsreader} {Start Newsreader} ;#Newline
mcset da {News} {News} ;#Newline
mcset da {There are News about TV-Viewer} {There are News about TV-Viewer} ;#Newline
mcset da {Start TV-Viewer} {Start TV-Viewer} ;#Newline
mcset da {Recording started} {Recording started} ;#Newline
mcset da {Recording of job % started successfully} {Recording of job %s started successfully} ;#Newline
mcset da {Recording finished} {Recording finished} ;#Newline
mcset da {Recording of job % has been finished} {Recording of job %s has been finished} ;#Newline

### ../data/process_config.tcl ###


### ../data/process_config_wizard.tcl ###


### ../data/process_key_file.tcl ###

mcset da {TV-Viewer Menu} {TV-Viewer Menu}
mcset da {Navigation Menu} {Navigations Menu}
mcset da {View Menu} {View Menu}
mcset da {Audio Menu} {Audio Menu}
mcset da {Help Menu} {Hjælp Menu}
mcset da {Exit TV-Viewer} {Afslut TV-Viewer}
mcset da {Toggle TV playback} {TV playback til/fra}
mcset da {Station by number} {Station pr nummer}
mcset da {Next video input} {Næste video input}
mcset da {Previous video input} {Forrige video input}
mcset da {Increase Volume} {Forøg Volumen}
mcset da {Decrease Volume} {Nedsæt Volumen}
mcset da {Increase audio delay} {Forøg audio delay}
mcset da {Decrease audio delay} {Nedsæt audio delay}
mcset da {Toggle mute} {Mute til/fra}
mcset da {Toggle Fullscreen} {Fuldskærm til/fra}
mcset da {Increase Zoom small step} {Forøg Zoom lille trin}
mcset da {Increase Zoom big step} {Forøg Zoom stort trin}
mcset da {Decrease Zoom small step} {Nedsæt Zoom lille trin}
mcset da {Decrease Zoom big step} {Nedsæt Zoom stort trin}
mcset da {Move video up} {Flyt video op}
mcset da {Move video down} {Flyt video ned}
mcset da {Move video right} {Flyt video til højre}
mcset da {Move video left} {Flyt video til venstre}
mcset da {Original window size} {Original vindue størrelse}
mcset da {Double window size} {Dobbelt vindue størrelse}
mcset da {Show/hide main toolbar} {Vis/skjul hovedværktøjslinie}
mcset da {Show/hide station list} {Vis/skjul stationsliste}
mcset da {Show/hide control bar} {Vis/skjul Kontrolbjælke}
mcset da {Take a screenshot} {Tag et skærmbillede}
mcset da {Record wizard} {Optage assistent}
mcset da {Toggle pause} {Pause til/fra}
mcset da {Start playback} {Start playback}
mcset da {Stop playback} {Stop playback}

### ../data/process_station_file.tcl ###


### ../data/radio.tcl ###


### ../data/record_add_edit.tcl ###

mcset da {Record options} {Optage Indstillinger}
mcset da {Time:} {Tid:}
mcset da {Date:} {Dato:}
mcset da {Duration:} {Varighed:}
mcset da {Repeat:} {Gentag:}
mcset da {Repetitions:} {Gentagelser:}
mcset da {Resolution:} {Opløsning:}
mcset da {Output file} {Output fil}
mcset da {Add a new recording} {Tilføj ny optagelse}
mcset da {Edit recording} {Rediger optagelse}
mcset da {Daily} {Daglig}
mcset da {Weekday} {Ugedag}
mcset da {Weekly} {Ugentlig}
mcset da {Choose station to record} {Vælg station der skal optages fra}
mcset da {Time when recording should start (Hour)} {Tid for optagelsens start (Time)}
mcset da {Time when recording should start (Minute)} {Tid for optagelsens start (Minut)}
mcset da {Choose between before or after midday.
You may change hour format in the preferences (Record).} {Vælg mellem am eller pm.
Du kan ændre tidsformat i Indstillinger (Optage).}
mcset da {Choose date on which recording should occur} {Vælg dato for optagelsen}
mcset da {Duration for the recording (Hours)} {Optagelsens varighed (Timer)}
mcset da {Duration for the recording (Minutes)} {Optagelsens varighed (Minutter)}
mcset da {Duration for the recording (Seconds)} {Optagelsens varighed (Sekunder)}
mcset da {Choose between never, daily (Mo - Su),
weekday (Mo - Fr), weekly} {Vælg mellem Aldrig, Daglig, (Ma - Sø),
ugedag (Ma - Fr), ugentlig}
mcset da {Choose the quantity of repetitions} {Vælg antal repetitioner}
mcset da {Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.} {Opløsning (bredde) i hvilken optagelsen skal laves. For det meste giver det ingen mening at ændre denne værdi, da det er bedre at bearbejde optagelsen senere.}
mcset da {Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.} {Opløsning (Højde) i hvilken optagelsen skal laves. For det meste giver det ingen mening at ændre denne værdi, da det er bedre at bearbejde optagelsen senere.}
mcset da {Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path.} {Filnavn for optagelsen. Hvis der ikke opgives et filnavn, fastsætter TV-Viewer
et navn og lagrer filen i standard mappen for optagelser.}
mcset da {Do you really want to delete the selected recording(s)?} {Ønsker du virkelig at slette de valgte optagelser?}
mcset da {Don't ask next time} {Spørg ikke næste gang}
mcset da {Delete} {Slet}
mcset da {Delete recordings} {Slet Optagelser}
mcset da {Choose date} {Vælg dato}
mcset da {Previous year} {Sidste år}
mcset da {Previous month} {Sidste måned}
mcset da {Next month} {Næste måned}
mcset da {Next year} {Næste år}

### ../data/record_external.tcl ###


### ../data/record_handler.tcl ###

mcset da {Time format incorrect (%-hour clock)!} {Tidsformat forkert (%s-timer ur)!}
mcset da {Time format incorrect (min)!} {Tidsformat forkert (min)!}
mcset da {Chosen date is in the past!} {Den valgte dato er i fortiden!}
mcset da {Time is in the past!} {Den valgte tid er forbi!}
mcset da {Duration not specified correctly (hour)!} {Forkert angivet varighed (time)!}
mcset da {Duration not specified correctly (min)!} {Forkert angivet varighed (minut)!}
mcset da {Duration not specified correctly (sec)!} {Forkert angivet varighed (sekund)!}
mcset da {Resolution format incorrect!} {Forkert format for opløsning!}

### ../data/record_linker.tcl ###

mcset da {Station search running while a recording fired} {Stationssøging igang da en optagelse startede}
mcset da {Missing file ../.tv-viewer/config/current_rec.conf} {Manglende fil ../.tv-viewer/config/current_rec.conf}
mcset da {Currently recording %
Started at %} {Optager nu %s
Startede kl. %s}
mcset da {Timeshift %} {Timeshift %s}
mcset da {Recording % - Ends at % %} {Optager %s - Stopper %s %s}
mcset da {Station
%} {Station
%s}
mcset da {Started
% at %} {Startede
%s kl. %s}
mcset da {Ends
% at %} {Slutter
%s kl. %s}
mcset da {Playing file: %} {Afspiller fil: %s}
mcset da {Idle} {Klar}
mcset da {Save timeshift video file
File size %} {Gem timeshift videofil
Filstørrelse %s}
mcset da {Missing file $::option(timeshift_path)/timeshift.mpeg} {Manglende fil $::option(timeshift_path)/timeshift.mpeg}

### ../data/record_wizard.tcl ###

mcset da {Running} {Kører}
mcset da {Stop Scheduler} {Stop Scheduler}
mcset da {Stopped} {Stoppet}
mcset da {Start Scheduler} {Start Scheduler}
mcset da {New recording} {Ny optagelse}
mcset da {Edit} {Rediger}
mcset da {Repeat: 0 - Never; 1 - Daily; 2 - Weekday; 3 - Weekly} {Gentag: 0 - Aldrig; 1 - Daglig; 2 - Ugedag; 3 - Ugentlig}
mcset da {Status} {Status}
mcset da {Scheduler status:} {Scheduler status:}
mcset da {Currently recording:} {Optager:}
mcset da {Stop recording} {Stop optagelse}
mcset da {Job ID} {Job ID}
mcset da {Time} {Tid}
mcset da {Date} {Dato}
mcset da {Duration} {Varighed}
mcset da {Repeat} {Gentag}
mcset da {Repetitions} {Gentagelser}
mcset da {Resolution} {Opløsning}
mcset da {Add a scheduled recording or
start recording immediately.} {Tilføj en planlagt optagelse,
eller start optagelse med det samme.}
mcset da {Delete selected recordings} {Slet de valgte optagelser.}
mcset da {Edit selected recording} {Rediger den valgte optagelse.}
mcset da {Indicates whether the Scheduler is running or not} {Viser om Scheduler kører eller ikke}
mcset da {Provides informations about the current recording} {Viser informationer om den kørende optagelse}
mcset da {If there is a running recording, click here to stop it} {Stop en løbende optagelse ved at klikke her}
mcset da {Exit Record Wizard} {afslut optage assistent}

### ../data/recorder.tcl ###


### ../data/release_version.tcl ###


### ../data/scheduler.tcl ###


### ../data/station_after_msg.tcl ###

mcset da {Now playing %} {Afspiller %s}
mcset da {TV-Viewer playing - %} {TV-Viewer afspiller - %s}

### ../data/station_edit.tcl ###

mcset da {Station search} {Stationssøgning}
mcset da {Add} {Tilføj}
mcset da {Lock} {Lås}
mcset da {Up} {Op}
mcset da {Down} {Ned}
mcset da {Preview} {Forhåndsvisning}
mcset da {Unlock} {Lås op}
mcset da {Frequency} {Frekvens}
mcset da {Video input} {Videoindgang}
mcset da {External Tuner} {Extern Tuner}
mcset da {Int Frequency} {Int Frekvens}
mcset da {Perform an automatic station search} {Lav en automatisk stationssøgning}
mcset da {Add a new television station} {Tilføj ny TV-station}
mcset da {Delete selected television station} {Slet den valgte station}
mcset da {Lock or unlock selected station(s).
Locked stations will be displayed in red.} {Lås/lås op for valgte station(er).
Låste stationer er markeret med rødt.}
mcset da {Edit selected station} {Rediger valgte station}
mcset da {Move selected item up} {Flyt valgte emne op}
mcset da {Move selected item down} {Flyt valgte emne ned}
mcset da {Preview for selected tv station} {Forhåndsvisning for valgte TV-station}
mcset da {Save station list and exit editor} {Gem stationsliste og forlad stations-editor}
mcset da {Exit editor without any changes} {Afslut Editor uden ændringer}

### ../data/station_item.tcl ###

mcset da {Do you really want to delete the selected station(s)?} {Ønsker du virkelig at slette de valgte stationer?}
mcset da {Delete stations} {Slet stationer}
mcset da {Station:} {Station:}
mcset da {Frequency:} {Frekvens:}
mcset da {Video input:} {Videoindgang:}
mcset da {Command:} {Kommando:}
mcset da {Internal frequency:} {Intern frekvens:}
mcset da {Add a new station} {Tilføj ny station}
mcset da {Edit Station / Frequency} {Rediger Station / Frekvens}
mcset da {Provide a name for the television station} {Angiv et navn for TV-stationen}
mcset da {Frequency for the station, E.g. 175.250} {Frekvens for stationen, fx. 175.250}
mcset da {Video input for this station. 
Normally you want television input.} {Videoindgang for denne station. 
Normalt er dette TV-ingangen.}
mcset da {Use an external tuner} {Anvend en extern tuner}
mcset da {Specify a command for the external tuner.
You may use this substitutions:

%%F  Frequency
%%S  Station name
e.g. externalTune %%F %%S} {Angiv en kommando for den externe tuner.
Du kan anvende disse forkortelser:

%%F  Frekvens
%%S  Stationsnavn
fx. externalTune %%F %%S}
mcset da {If you use an external tuner that is connected to the TV input
of your device you may need to set the internal tuner to a
specific frequency.
Use a value of "0" if you do not need your internal tuner
(e.g. if you are using composite or s-video)} {Hvis du bruger en extern tuner som er tilsluttet TV-indgangen
kan det være nødvendigt at sætte den interne tuner til en bestemt frekvens. Brug værdien "0" hvis du ikke behøver den interne tuner (fx hvis du bruger komposit eller s-video)}
mcset da {Please specify name and frequency for each station} {Angiv navn og frekvens for hver station}

### ../data/station_search.tcl ###

mcset da {Station search options} {Indstillinger - Stationssøgning}
mcset da {Append stations} {Tilføj stationer}
mcset da {Perform a full frequency sweep} {Lav en fuld frekvenssøgning}
mcset da {Start} {Start}
mcset da {Append stations, or overwrite existing list} {Tilføj stationer eller overskriv eksisterende liste}
mcset da {Perform a full frequency sweep, or check all channels
defined by the frequency table.
Note: A full frequency sweep may find many duplicates.} {Lav en fuld frekvenssøgning, eller check alle Kanaler på den valgte frekvenstabel.
OBS: Ved den fulde frekvenssøgning kan finde mange gengangere.}
mcset da {Choose the frequency increase factor for full frequency sweep.
Note: The lower this factor the more duplicates will be found and
the search takes more time.} {Vælg stigningsfaktor for frekvense ved den fulde frekvenssøgning.
OBS: Desto mindre denne faktor er, desto flere gengangere af en 
Station vil blive fundet og søgningen varer længere.}
mcset da {Time in milliseconds to wait for the driver to respond.
The lower this value the faster the full frequency sweep will be.
Note: If this value is too small the driver won't have
enough time to report if there is a signal on the current frequency.
As a result not all stations will be found.} {Ventetid i millisekunder på at driveren svarer.
Jo mindre denne værdi er, desto hurtigere er søgningen.
OBS: Hvis værdien er for lille har driveren muligvis ikke tid nok til tilbagemelding om et signal på pågælde frekvens. Dette fører til at ikke alle stationer findes.}
mcset da {Start station search} {Start stationssøgning}
mcset da {Station search in progress.
Please wait...} {Stationssøgning kører.
Vent venligst...}
mcset da {Channel: %} {Kanal: %s}
mcset da {Station search finished!} {Stationssøgning færdig!}
mcset da {Frequency: %} {Frekvens: %s}

### ../data/status_feedb.tcl ###

mcset da {Show log} {Vis log}
mcset da {TV-Viewer Error} {TV-Viewer Fejl}

### ../data/stream.tcl ###

mcset da {Can not change video standard} {Kan ikke ændre videostandarden}

### ../data/system_tray.tcl ###

mcset da {Can not load shared library tktray} {Kan ikke indlæse delt bibliotek tktray}
mcset da {Can not create system tray icon} {Kan ikke danne ikon i systembakken}
mcset da {Hide} {Skjul}
mcset da {Restore} {Gendan}

### ../data/timeshift.tcl ###

mcset da {Copying timeshift video file.
Please wait...} {Kopierer timeshift video file.
Vent venligst...}
mcset da {Copying...       %%%} {Kopierer...       %s%%}
mcset da {Copying...       finished} {Kopierer...       færdig}

### ../data/tooltip.tcl ###

mcset da {Tune up} {Forrige station}
mcset da {Tune down} {Næste station}
mcset da {Zap among the last two stations} {Zap mellem de sidste 2 stationer}
mcset da {Alter volume} {Tilpas volumen}
mcset da {Start/Stop timeshift} {Start/Stop timeshift}
mcset da {Start/Stop record} {Start/Stop }
mcset da {Execute the selected EPG application} {Start det valgte EPG program}
mcset da {Switch to radio mode} {Skift til radio modus}
mcset da {Start/Stop TV playback} {Start/Stop TV playback}
mcset da {Pause playback} {Pause playback}
mcset da {Jump to the beginning} {Hop til begyndelsen}
mcset da {Seek back} {Baglæns}
mcset da {Choose amount of seek back} {Vælg længde af tid der skal søges baglæns}
mcset da {Seek forward} {Fremad}
mcset da {Choose amount of seek forward} {Vælg længde af tid der skal søges frem}
mcset da {Jump to the end} {Hop til slutning}
mcset da {Toggle fullscreen} {On/off fuldskærm}
mcset da {Current position / File length} {Nuværende position / Fil længde}

### ../data/tv-viewer_main.tcl ###


### ../data/vid_audio.tcl ###


### ../data/vid_callback.tcl ###

mcset da {MPlayer has finished unexpectedly} {MPlayer er stoppet uventet}
mcset da {idle} {klar}
mcset da {Can not read callback channel} {Kan ikke læse callback kanal}

### ../data/vid_file_calc.tcl ###


### ../data/vid_osd.tcl ###


### ../data/vid_playback.tcl ###

mcset da {Missing file for file playback} {Mangler fil til playback}

### ../data/vid_pmhandler.tcl ###


### ../data/vid_seek.tcl ###


### ../data/vid_slist.tcl ###


### ../data/vid_wm.tcl ###

mcset da {Move x=%} {Flyt x=%s}
mcset da {Move y=%} {Flyt y=%s}
mcset da {Centering video} {Centrer video}

### ../callib/callib.tcl ###

mcset da {Sun} {Sø}
mcset da {Mon} {Ma}
mcset da {Tue} {Ti}
mcset da {Wed} {On}
mcset da {Thu} {To}
mcset da {Fri} {Fr}
mcset da {Sat} {Lø}


