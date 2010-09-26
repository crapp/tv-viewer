# de.msg
namespace import -force msgcat::mcset

### ../data/agrep.tcl ###


### ../data/chan_zapper.tcl ###


### ../data/colorm.tcl ###

mcset de {Brightness} {Helligkeit}
mcset de {Contrast} {Kontrast}
mcset de {Hue} {Farbton}
mcset de {Saturation} {Sättigung}
mcset de {Apply} {Anwenden}
mcset de {Default} {Default}
mcset de {Cancel} {Abbrechen}
mcset de {Color Management} {Farbverwaltung}
mcset de {Set brightness, this is a global value} {Helligkeit festlegen, betrifft alle Sender}
mcset de {Set contrast, this is a global value} {Kontrast festlegen, betrifft alle Sender}
mcset de {Set hue, this is a global value} {Farbton festlegen, betrifft alle Sender}
mcset de {Set saturation, this is a global value} {Sättigung festlegen, betrifft alle Sender}
mcset de {Save values and close color management} {Werte speichern und Farbverwaltung verlassen}
mcset de {Load default values} {Standardwerte laden}
mcset de {Close color management without saving changes} {Farbverwaltung beenden ohne die Änderungen zu übernehmen}

### ../data/command_socket.tcl ###


### ../data/config_advanced.tcl ###

mcset de {Advanced} {Erweitert}
mcset de {Manage aspect ratio} {Seitenverhältnis überwachen}
mcset de {Keep video aspect ratio} {Video Seitenverhältnis beibehalten}
mcset de {Monitor aspect} {Monitor Seitenverhältnis}
mcset de {Monitor pixel aspect} {Monitor pixel aspect}
mcset de {Screenshot} {Screenshot}
mcset de {Activate screenshot feature} {Screenshot Feature aktivieren}
mcset de {MPlayer config file} {Player Konfigurationsdatei}
mcset de {Do not process MPlayer config files} {MPlayer Konfigurationsdateien ignorieren}
mcset de {Default settings} {Standardeinstellungen}
mcset de {Reset} {Zurücksetzen}
mcset de {Additional options for MPlayer} {Optionen für MPlayer}
mcset de {Additional MPlayer options} {Zusätzliche MPlayer Optionen}
mcset de {Additional video filter options} {Zusätzliche Angaben für Videofilter}
mcset de {Additional audio filter options} {Zusätzliche Angaben für Audiofilter}
mcset de {Logs} {Logs}
mcset de {Enable Logging} {Logging aktivieren}
mcset de {MPlayer logfile size in kBytes} {MPlayer Logfile Größe in kBytes}
mcset de {Scheduler logfile size in kBytes} {Scheduler Logfile Größe in kBytes}
mcset de {TV-Viewer logfile size in kBytes} {TV-Viewer Logfile Größe in kBytes}
mcset de {Let TV-Viewer manage video aspect ratio (recommended)} {TV-Viewer das Video Seitenverhältnis steuern lassen (Empfohlen)}
mcset de {Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality.} {Wählen zwischen Monitor Seitenverhältnis oder
Monitor Pixel Verhältnis.
Das kann die Bildqualität verbessern.}
mcset de {Activate or deactive the screenshot feature.
Screenshots will be stored in the users home directory.} {Die Möglichkeit Screenshots machen zu können
an- oder abschalten.
Die Screenshots werden im Home-Verzeichnis gespeichert.}
mcset de {If enabled MPlayer will ignore all existing config files.
This will ensure only values set by TV-Viewer will be used.} {Wenn aktiviert wird MPlayer alle existierenden 
Konfigurationdateien ignorieren.
Damit wird sichergestellt, dass nur die Werte die TV-viewer
setzt verwendet werden.}
mcset de {Reset all configuration options} {Alle Einstellungen zurücksetzen}
mcset de {Here you may provide additional command line options for MPlayer.
Separate the different options with spaces.
See the MPlayer man pages for more informations.} {Hier kann man zusätzliche Optionen für MPlayer eintragen.
Die einzelnen Optionen werden durch Leerzeichen getrennt.
Mehr Infos findet im Handbuch von MPlayer.}
mcset de {Additional video filter options must be separated with commas.
E.g. scale=512:-2,eq2=1.1
See the MPlayer man pages for more informations.} {Zusätzliche Videofilter müssen durch Kommas getrennt werden.
Z.B. scale=512:-2,eq2=1.1
Das Handbuch von MPlayer bietet weitere Infos.}
mcset de {Additional audio filter options must be separated with commas.
E.g. resample=44100:0:0,volnorm
See the MPlayer man pages for more informations.} {Zusätzliche Audiofilter müssen durch Kommas getrennt werden.
Z.B. resample=44100:0:0,volnorm
Das Handbuch von MPlayer bietet weitere Infos.}
mcset de {Check this to enable logging of TV-Viewer, Scheduler and MPlayer events.
You can find the three logfiles in %/log/
Refer to the 'Help' section of the main interface for the log viewers.} {TV-Viewer, Scheduler und MPlayer Ausgaben protokollieren.
Die drei Logfiles kann man in %s/log/ finden.
Unter „Hilfe“ befinden sich die Log Viewer.}
mcset de {Specify the amount of space in kBytes the MPlayer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb} {Legt fest, wie groß das Logfile für MPlayer werden darf.
Wenn die Größe erreicht ist wird die Datei gelöscht und eine
neue angelegt.
Minimum: 10kb Maximum: 100kb}
mcset de {Specify the amount of space in kBytes the TV-Viewer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb} {Legt fest, wie groß das Logfile für TV-Viewer werden darf.
Wenn die Größe erreicht ist wird die Datei gelöscht und eine
neue angelegt.
Minimum: 10kb Maximum: 100kb}
mcset de {Specify the amount of space in kBytes the Scheduler logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb} {Legt fest, wie groß das Logfile für den Scheduler werden darf.
Wenn die Größe erreicht ist wird die Datei gelöscht und eine
neue angelegt.
Minimum: 10kb Maximum: 100kb}

### ../data/config_analog.tcl ###

mcset de {Analog Settings} {Einstellung für Analog}
mcset de {Video Device Node} {Video Device}
mcset de {Video Standard} {Video Standard}
mcset de {Frequency Table} {Frequenztabelle}
mcset de {Force Standard} {Standard erzwingen}
mcset de {Video Input} {Video Eingang}
mcset de {Analog Stream Settings} {Videostream}
mcset de {Stream Bitrate} {Bitrate}
mcset de {Video Bitrate} {Videobitrate}
mcset de {Video Peak Bitrate} {Videobitrate (Peak)}
mcset de {Temporal Filter} {Temporal Filter}
mcset de {Hardware volume level} {Hardware Lautstärke}
mcset de {Volume} {Volume}
mcset de {Error} {Fehler}
mcset de {Missing requirements} {Fehlende Abhängigkeiten}
mcset de {Could not detect all necessary tools to run TV-Viewer} {Konnte nicht alle Tools finden die von TV-Viewer benötigt werden}
mcset de {ivtv-tune} {ivtv-tune}
mcset de {v4l2-ctl} {v4l2-ctl}
mcset de {Disabled} {Deaktiviert}
mcset de {Analog settings are disabled,
while running a recording or timeshift} {Die Einstellungen Analog sind deaktiviert
während eine Aufnahme oder Timeshift läuft}
mcset de {Choose the video device node.
See "dmesg | grep ivtv || pvrusb2 || cx18"} {Wähle das Video Device.
Siehe "dmesg | grep ivtv || pvrusb2 || cx18"}
mcset de {Constrain setting of the video standard.
Choose this if the driver selects the wrong one.} {Video Standard erzwingen.
Notwendig falls der Treiber den falschen Standard wählt.}
mcset de {Define the way of color transmission.
Depends on where you are located.} {Definiere die Art der Farbübertragung.
Hängt davon ab wo man sich befindet.}
mcset de {The frequency table provides informations about the 
frequency band that should be used to search for tv stations.} {Die Frequenztabelle sagt TV-Viewer in welchem Frequenzband nach
Fernsehsender gesucht werden soll.}
mcset de {Choose the video input} {Video Eingang wählen}
mcset de {Check this if you want to alter the videobitrate} {Auswählen falls man die Videobitrate anpassen will}
mcset de {Define the videobitrate. Don't set the
videobitrate to a higher value than videobitrate (peak)!
Standard values are recommended.
Data in kb/sec.} {Setze die Videobitrate fest. Ein höherer Wert als
Videobitrate (Peak) ist nicht möglich!
Die Standard-Einstellung wird empfohlen.
Angaben in kb/sec.}
mcset de {Define the videobitrate (peak). Don't set the 
videobitrate (peak) to a lower value than videobitrate.
Standard values are recommended.
Data in kb/sec.} {Setze die Videobitrate (Peak) fest. Ein niedriger Wert,
als Videobitrate ist nicht erlaubt.
Die Standard-Einstellung wird empfohlen.
Angaben in kb/sec.}
mcset de {Check this if you want to change the temporal filter.
This option can help if you have a blurred picture.} {Wähle diese Option wenn du den Temporal Filter anpassen
willst. Dies kann helfen wenn das Bild verwaschen ist.}
mcset de {Choose level of temporal filtering} {Wähle einen Wert für den Temporal Filter}
mcset de {Enable this option if you want to change the hardware volume level.} {Enable this option if you want to change the hardware volume level.}
mcset de {Specify the hardware volume level.
This applies to all stations and it is not recommended
to change this value.} {Hardware Lautstärke festlegen.
Dieser Wert betrifft alle Kanäle und es wird nicht
empfohlen diesen Wert zu ändern.}

### ../data/config_audio.tcl ###

mcset de {Audio Settings} {Audio Einstellungen}
mcset de {Audio output driver} {Audio Ausgabetreiber}
mcset de {Audio channels} {Audio Kanäle}
mcset de {Use software mixer} {Software Mixer verwenden}
mcset de {Remember volume level} {Volume Level merken}
mcset de {Audio synchronization} {Audio Synchronisation}
mcset de {Auto synchronization} {Automatische Synchronisation}
mcset de {Audio/Video sync correction} {Audio/Video Sync-Korrektur}
mcset de {Choose an audio output driver, alsa is recommended.} {Wähle einen Audio Ausgabetreiber, alsa wird empfohlen.}
mcset de {Check this option to use the software mixer,
instead of the hardware mixer.} {Mit dieser Option verwendet das Programm den Software
Mixer anstatt des Hardware Mixers.}
mcset de {This option tells MPlayer to decode
audio to the chosen value} {Mplayer versucht den Ton in
die angegebenen Kanäle zu decodieren}
mcset de {Remeber volume level} {Lautstärke merken}
mcset de {Gradually adjusts the A/V sync based on audio delay measurements} {Justiert stufenweise die A/V Synchronisation, basierend auf der
Messung der Audioverzögerung}
mcset de {Audio/Video sync correction per frame in seconds} {Audio/Video Synchronisation pro Bild in Sekunden}

### ../data/config_dvb.tcl ###

mcset de {DVB Settings} {DVB Einstellungen}
mcset de {Expect more soon} {Bald mehr}

### ../data/config_general.tcl ###

mcset de {General Settings} {Allgemeines}
mcset de {Language} {Sprache}
mcset de {Autodetect} {Automatisch}
mcset de {English (en)} {Englisch (en)}
mcset de {German (de)} {Deutsch (de)}
mcset de {Start TV on startup} {Fernsehwiedergabe beim Programmstart}
mcset de {Enable} {Aktivieren}
mcset de {Newsreader} {Newsreader}
mcset de {Time interval in days} {Zeitintervall in Tagen}
mcset de {Electronic Program Guide} {Electronic Program Guide}
mcset de {Choose a program} {Programm auswählen}
mcset de {Choose an EPG application} {EPG Programm auswählen}
mcset de {Choose your language.
You'll need to restart TV-Viewer for changes to take effect.} {Sprache auswählen.
TV-Viewer muss neu gestartet werden.}
mcset de {Autostart tv playback on program start} {Fernsehwiedergabe beim Programmstart}
mcset de {Activate Newsreader.
The Newsreader will check for news about TV-Viewer.} {Newsreader aktivieren.
Der Newsreader sucht nach Neuigkeiten über TV-Viewer auf der Homepage.}
mcset de {Choose time intervall in days for Newsreader (1-30)} {Zeitintervall in Tagen (1-30)}
mcset de {Specify a program to retrieve the television program} {Gebe ein Programm an, mit dem das Fernsehprogramm abgerufen werden soll}

### ../data/config_interface.tcl ###

mcset de {Interface Settings} {Interface Einstellungen}
mcset de {Theme} {Thema}
mcset de {Enable Tooltips} {Tooltips aktivieren}
mcset de {Main Gui} {Hauptfenster}
mcset de {Preferences} {Einstellungen}
mcset de {Station Editor} {Sender Editor}
mcset de {Record Wizard} {Aufnahme Assistent}
mcset de {Splash Screen} {Splash Screen}
mcset de {Show Splash Screen on initialization} {Splash Screen beim Programmstart zeigen}
mcset de {Window Properties} {Fenstereigenschaften}
mcset de {Main window} {Hauptfenster}
mcset de {Start in full-screen mode} {Im Vollbild-Modus starten}
mcset de {Remember size and position} {Größe und Position merken}
mcset de {Floating control} {Schwebendes Kontrollelement}
mcset de {Main toolbar} {Hauptwerkzeugleiste}
mcset de {Station list} {Senderliste}
mcset de {Control toolbar} {Steuerungsleiste}
mcset de {System Tray} {System Tray}
mcset de {Show icon in system tray} {Icon im System Tran anzeigen}
mcset de {Minimize to tray} {In den Tray minimieren}
mcset de {Close to tray} {In den Tray schließen}
mcset de {Resize system tray icon} {Größe des Tray Icons ändern}
mcset de {System tray icon size} {System Tray Icon Größe}
mcset de {On screen Display} {On screen Display}
mcset de {Station} {Sender}
mcset de {Windowed mode} {Fenstermodus}
mcset de {Full-screen mode} {Vollbildmodus}
mcset de {Volume | Video input | Pan&Scan} {Volume | Video input | Pan&Scan}
mcset de {Key Input} {Tasteneingabe}
mcset de {OSD Station list lirc} {OSD Senderliste lirc}
mcset de {Choose your preferred theme} {Bevorzugtes Thema auswählen}
mcset de {Check this if you want to see tooltips} {Tooltips anzeigen}
mcset de {Tooltips for the main Interface} {Tooltips für das Hauptfenster}
mcset de {Tooltips for the preferences} {Tooltips für die Einstellungen}
mcset de {Tooltips for the Station Editor} {Tooltips für den Sendereditor}
mcset de {Tooltips for the Color Management} {Tooltips für die Farbverwaltung}
mcset de {Tooltips for the Record Wizard} {Tooltips für den Aufnahme-Assistent}
mcset de {Check this if you want to see the splash screen at the start of TV-Viewer} {Auswählen falls man beim Programmstart den Splash Screen sehen will}
mcset de {Start TV-Viewer in full-screen mode} {Im Vollbild-Modus starten}
mcset de {Remember window size and position} {Fenstergröße und Position merken}
mcset de {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "top", of the screen.} {Das schwebende Kontrollelement erscheint im Vollbildmodus
und wird aktiviert, wenn der Mauszeiger am oberen Ende des
Bildschirms ist.}
mcset de {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "left side", of the screen.} {Das schwebende Kontrollelement erscheint im Vollbildmodus
und wird aktiviert, wenn der Mauszeiger auf der linken Seite des
Bildschirms ist.}
mcset de {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "bottom", of the screen.} {Das schwebende Kontrollelement erscheint im Vollbildmodus
und wird aktiviert, wenn der Mauszeiger am unteren Ende des
Bildschirms ist.}
mcset de {Activate integration to system tray} {Integration in den System Tray aktivieren}
mcset de {Automatically resize system tray icon if the size of the tray 
itself is changed. Be careful with this option.} {Größe des System Tray icons automatisch anpassen wenn sich
das Tray ändert. Diese Option ist mit Vorsicht zu genießen}
mcset de {Choose the size for the system tray icon} {Größe des Icons wählen}
mcset de {OSD for station name in windowed mode} {OSD Sendername im Fenstermodus}
mcset de {OSD for station name in full-screen mode} {OSD Sendername im Vollbildmodus}
mcset de {Change font, color and alignment} {Schrift, Farbe, Ausrichtung wählen}
mcset de {OSD for Volume; Pan&Scan; Video input in windowed mode} {OSD Volume; Pan&Scan; Video input im Fenstermodus}
mcset de {OSD for Volume; Pan&Scan; Video input in full-screen mode} {OSD Volume; Pan&Scan; Video input im Vollbildmodus}
mcset de {OSD for change stations via numbers input in windowed mode} {OSD Senderwahl über Ziffern im Fenstermodus}
mcset de {OSD for change stations via numbers input in full-screen mode} {OSD Senderwahl über Ziffern im Vollbildmodus}

### ../data/config_radio.tcl ###

mcset de {Radio Settings} {Radio Einstellungen}

### ../data/config_record.tcl ###

mcset de {Record Settings} {Aufnahme Einstellungen}
mcset de {Standard folder} {Standardpfad}
mcset de {Default record duration} {Standard Aufnahmedauer}
mcset de {Allow station change while recording} {Senderwechsel während einer Aufnahme erlauben}
mcset de {Autostart scheduler} {Scheduler automatisch starten}
mcset de {Hours format} {Stunden-Format}
mcset de {24-hour clock} {24-Stunden-Format}
mcset de {12-hour clock} {12-Stunden-Format}
mcset de {Timeshift} {Timeshift}
mcset de {Timeshift folder} {Timeshift Ordner}
mcset de {Space to be left free} {Platz der freigelassen werden soll}
mcset de {Choose a directory} {Verzeichnis wählen}
mcset de {Set the default directory for all recordings} {Standardpfad für Aufnahmen festlegen}
mcset de {Define the default duration for recordings (Hours)} {Standard Dauer für Aufnahmen (Stunden)}
mcset de {Define the default duration for recordings (Minutes)} {Standard Dauer für Aufnahmen (Minuten)}
mcset de {Define the default duration for recordings (Seconds)} {Standard Dauer für Aufnahmen (Sekunden)}
mcset de {Choose if you want to use a 24-hour clock or 12-hour clock to schedule recordings} {Wählen ob man im 12-Stunden- oder 24-Stunden-Format Aufnahmen planen will.}
mcset de {Allow station change during recording} {Senderwechsel während einer Aufnahme erlauben}
mcset de {Autostart the scheduler.
This is necessary for scheduled recordings.} {Scheduler automatisch starten.
Dies ist notwendig für geplante Aufnahmen.}
mcset de {Choose path where Timeshift events will be cached} {Pfad wählen wo Timeshift-Dateien zwischengespeichert werden sollen}
mcset de {Define the minimum free disk space.
If free disk space is falling below this value
timeshift will automatically be stopped.
A value of 0 deactivates this feature.} {Festlegen wieviel Platz auf der Festplatte
mindestens frei bleiben soll.
Wenn der freie Platz unter den angegeben Wert
fällt, wird Timeshift automatisch angehalten.
Der Wert 0 deaktiviert dieses Feature.}

### ../data/config_video.tcl ###

mcset de {Video Settings} {Video Einstellungen}
mcset de {Video} {Video}
mcset de {Video output driver} {Video Ausgabetreiber}
mcset de {Deinterlacing filter} {Deinterlacing Filter}
mcset de {Postprocessing level} {Nachbearbeitung}
mcset de {Cache size (kB)} {Cache Größe (kB)}
mcset de {Threads for decoding} {Threads zur Dekodierung}
mcset de {Direct Rendering} {Direktes Rendern}
mcset de {Double Buffering} {Doppelpufferung}
mcset de {Slice Mode} {Modus Slices}
mcset de {Framedrop} {Bilder überspringen}
mcset de {Hard Framedrop} {Verstärktes Bilder überspringen}
mcset de {Disable Screensaver} {Bildschirmschoner deaktivieren}
mcset de {Use MPlayer} {Verwende MPlayer}
mcset de {Use Heartbeat function} {Verwende Heartbeat Funktion}
mcset de {Select the video ouput driver.
xv should provide the best performance.} {Wähle den Video Ausgabetreiber.
xv sollte die beste Leistung bieten.}
mcset de {Select the deinterlace filter} {Deinterlace Filter auswählen}
mcset de {Changes the level of postprocesseing.
A value of 0 deactivates postprocessing.} {Niveau der Nachbearbeitung.
Der Wert 0 deaktiviert die Nachbearbeitung.}
mcset de {Specify how much memory (in kBytes) should be used for TV playback.
The lower this value is the faster you may switch between stations.
But a low value could cause other problems.
A value of 0 will deactivate cache use.} {Gib an wieviel Speicher (in kBytes) für die Fernsehwiedergabe
verwendet werden soll.
Je niedriger dieser Wert, desto schneller kann man zwischen zwei
Sendern umschalten. Aber ein niedriger Wert kann andere Probleme
verursachen. Der Wert 0 deaktiviert precaching.}
mcset de {Sets the number of threads for decoding} {Legt die Anzahl der Threads zur Dekodierung fest}
mcset de {If checked, enables direct rendering. This is not supported
for all video ouput drivers.} {Aktiviert direktes Rendern. Funktioniert nicht mit allen
Video Ausgabetreibern.}
mcset de {Double buffering fixes flicker by storing two frames in memory
and displaying one, while decoding another.} {Doppelbufferung verhindert Flackern durch das speichern von
zwei Frames im Speicher. Einer wird angezeigt, während der andere
dekodiert wird.}
mcset de {Enable / Disable drawing video by 16-pixel height slices/bands.
May help in better video playback.} {Ein- Ausschalten des Modus - Slices. Wenn deaktiviert wird
das Bild in einem Durchgang angezeigt. Abhängig von Grafikkarte
und Cache kann dieser Modus langsamer oder schneller sein.}
mcset de {Skip displaying some frames to maintain A/V sync} {Überspringen von Einzelbildern um A/V Syncronisation
zu gewährleisten.}
mcset de {More intense frame dropping. May lead to image distortion.} {Verstärktes Überspringen von Einzelbildern. Kann zu
Bildverzerrungen führen.}
mcset de {Enable / Disable screensaver while playback} {Bildschirmschoner während der Fernsehwiedergabe deaktivieren}
mcset de {Use MPlayer to deactivate the screensaver} {Use MPlayer to deactivate the screensaver}
mcset de {If MPlayer can't deactivate your screensaver, use this heartbeat hack} {Sollte MPLayer nicht in der Lage sein den Bildschirmschoner zu
deaktivieren, verwende diesen Heartbeat hack}

### ../data/config_wizard.tcl ###

mcset de {General} {Allgemein}
mcset de {Analog} {Analog}
mcset de {DVB} {DVB}
mcset de {Audio} {Audio}
mcset de {Radio} {Radio}
mcset de {Interface} {Interface}
mcset de {Record} {Aufnahme}
mcset de {Apply your changes and exit preferences dialog} {Änderungen übernehmen und Einstellungen verlassen}
mcset de {Load default values, for the corresponding section} {Standardwerte laden für den entsprechenden Abschnitt}
mcset de {Discard changes and close preferences dialog} {Änderungen verwerfen und Einstellungen verlassen}

### ../data/create_icons.tcl ###


### ../data/diag_frontend.tcl ###

mcset de {Diagnostic Routine is checking your system.
Please wait...} {Diagnostic Routine is checking your system.
Please wait...}
mcset de {Exit} {Exit}
mcset de {Diagnostic Routine} {Diagnoseprogramm}
mcset de {Diagnostic Routine finished} {Diagnoseprogramm beenden}
mcset de {Generated file:} {Ausgabedatei:}
mcset de {Create a bug report on } {Erstelle einen Fehlerbericht auf }
mcset de {and attach the generated file.} {und hänge die Ausgabedatei an.}
mcset de {Diagnostic Routine crashed} {Diagnoseprogramm ist abgestürzt}

### ../data/diag_runtime.tcl ###


### ../data/difftime.tcl ###


### ../data/error_interp.tcl ###

mcset de {Skip further error messages} {Weitere Fehlermeldungen überspringen}
mcset de {OK} {OK}
mcset de {File bug report} {Fehlerbericht erstellen}
mcset de {Save to disk} {Speichern}
mcset de {Error: %} {Fehler: %s}
mcset de {Select everything} {Alles markieren}
mcset de {Copy to clipboard} {In die Zwischenablage kopieren}
mcset de {TV-Viewer crashed} {TV-Viewer crashed}
mcset de {Choose name and location} {Name und Ort wählen}

### ../data/event_bind.tcl ###


### ../data/font_chooser.tcl ###

mcset de {Family:} {Familie:}
mcset de {Style:} {Stil:}
mcset de {Size:} {Größe:}
mcset de {Font color:} {Schriftfarbe:}
mcset de {Display:} {Anzeigen:}
mcset de {Preview:} {Vorschau:}
mcset de {top left} {Oben links}
mcset de {top} {Oben}
mcset de {top right} {Oben rechts}
mcset de {left} {Links}
mcset de {center} {Mitte}
mcset de {right} {Rechts}
mcset de {bottom left} {Unten links}
mcset de {bottom} {Unten}
mcset de {bottom right} {Unten rechts}
mcset de {Choose a font} {Wähle eine Schrift}
mcset de {Choose font style} {Schriftstil auswählen}
mcset de {Choose font size} {Schriftgröße auswählen}
mcset de {Choose font color} {Schriftfarbe auswählen}
mcset de {Specify where the message box should be
displayed in the video frame} {Festlegen wo die Benachrichtigungsbox im
Videoframe erscheinen soll}
mcset de {Choose font} {Wähle eine Schrift}
mcset de {Choose color} {Schriftfarbe auswählen}

### ../data/info_help.tcl ###

mcset de {TV-Viewer % Build %} {TV-Viewer %s Build %s}
mcset de {Info} {Info}
mcset de {A small and simple frontend to watch and record television} {Ein kleines und einfaches Programm zum Fernsehen und Aufnehmen}
mcset de {Homepage} {Homepage}
mcset de {Forum} {Forum}
mcset de {IRC channel} {IRC Kanal}
mcset de {© Copyright 2007 - 2010
Christian Rapp} {© Copyright 2007 - 2010
Christian Rapp}
mcset de {Credits} {Credits}
mcset de {License} {Lizenz}
mcset de {Changelog} {Changelog}
mcset de {About TV-Viewer} {Über TV-Viewer}

### ../data/key_sequences.tcl ###

mcset de {Available Key Sequences} {Verfügbare Tastenkombinationen}
mcset de {Change shortcut} {Change shortcut}
mcset de {Key Sequences} {Tastenkombinationen}
mcset de {Action} {Aktion}
mcset de {Key Sequence} {Tastenkombination}
mcset de {Television} {Fernsehen}
mcset de {Window management} {Fenstermanagement}
mcset de {Recording / File playback} {Aufnahme / Datei Wiedergabe}
mcset de {Do you really want to load default values for all key sequences?

This will happen instantly and can not be undone!} {Wirklich Standardwerte für alle Tastenkombinationen laden?

Dies wird sofort passieren und kann nicht mehr rückgängig gemacht werden!}
mcset de {Set shortcuts to default values} {Tastenkombinationen auf Standardwerte zurücksetzen}
mcset de {Press the key combination you want to assign} {Tastenkombination die man zuweisen will betätigen}
mcset de {Clear} {Löschen}
mcset de {Modify shortcut} {Shortcut bearbeiten}
mcset de {It is not possible to edit this shortcut} {Es ist nicht möglich diesen Shortcut zu bearbeiten}
mcset de {Conflict detected with station by number "0-9"} {Konflikt mit Senderwahl über Zifferntasten "0-9"}
mcset de {Conflict detected with %} {Konflikt mit %s}

### ../data/launch_splash.tcl ###


### ../data/lirc_emitter.tcl ###


### ../data/log_viewer.tcl ###

mcset de {Choose output file} {Choose output file}
mcset de {$ident(name($handler)) Log} {$ident(name($handler)) Log}
mcset de {Save logfile to disk} {Logfile speichern}
mcset de {Send logfile by e-mail to the authors} {Logdatei per E-Mail an die Entwickler schicken}
mcset de {Show/hide Debug messages} {Debug-Meldungen anzeigen / verbergen}
mcset de {Show/hide Warning messages} {Warnmeldungen anzeigen / verbergen}
mcset de {Show/hide Error messages} {Fehlermeldungen anzeigen / verbergen}

### ../data/main_command_line_options.tcl ###


### ../data/main_frontend.tcl ###

mcset de {Name} {Name}
mcset de {No} {Nr}
mcset de {Navigation} {Navigation}
mcset de {View} {Ansicht}
mcset de {Help} {Hilfe}
mcset de {Welcome to TV-Viewer} {Willkommen bei TV-Viewer}
mcset de {TV-Viewer %} {TV-Viewer %s}
mcset de {TV-Viewer idle} {TV-Viewer inaktiv}

### ../data/main_menu.tcl ###

mcset de {EPG} {EPG}
mcset de {TV} {TV}
mcset de {Prior Station} {Vorheriger Sender}
mcset de {Next Station} {Nächster Sender}
mcset de {Station jumper} {Senderswitch}
mcset de {Play} {Play}
mcset de {Pause} {Pause}
mcset de {Stop} {Stop}
mcset de {Rewind} {Zurück}
mcset de {-10 seconds} {-10 Sekunden}
mcset de {-1 minute} {-1 Minute}
mcset de {-10 minutes} {-10 Minuten}
mcset de {File beginning} {Dateistart}
mcset de {Forward} {Vorwärts}
mcset de {+10 seconds} {+10 Sekunden}
mcset de {+1 minute} {+1 Minute}
mcset de {+10 minutes} {+10 Minuten}
mcset de {File end} {Dateiende}
mcset de {Pan&Scan} {Pan&Scan}
mcset de {Zoom +} {Zoom +}
mcset de {Zoom -} {Zoom -}
mcset de {Pan&Scan (16:9 / 4:3)} {Pan&Scan (16:9 / 4:3)}
mcset de {Move up} {Nach oben bewegen}
mcset de {Move down} {Nach unten bewegen}
mcset de {Move left} {Nach links bewegen}
mcset de {Move right} {Nach rechts bewegen}
mcset de {Center video} {Video zentrieren}
mcset de {Size} {Größe}
mcset de {Stay on top} {Im Vordergrund bleiben}
mcset de {Never} {Nie}
mcset de {Always} {Immer}
mcset de {While playback} {Während der Wiedergabe}
mcset de {Toolbars} {Toolbars}
mcset de {Statusbar} {Statusbar}
mcset de {Show status messages} {Statusmeldungen zeigen}
mcset de {Show playback time} {Zeitinformationen zeigen}
mcset de {Compact mode} {Kompaktmodus}
mcset de {Fullscreen} {Vollbild}
mcset de {Volume +} {Volume +}
mcset de {Volume -} {Volume -}
mcset de {Mute} {Stumm}
mcset de {Delay +} {Delay +}
mcset de {Delay -} {Delay -}
mcset de {User Guide} {Handbuch}
mcset de {MPlayer Log} {MPlayer Log}
mcset de {Scheduler Log} {Scheduler Log}
mcset de {TV-Viewer Log} {TV-Viewer Log}

### ../data/main_newsreader.tcl ###


### ../data/main_picqual_stream.tcl ###


### ../data/monitor.tcl ###


### ../data/process_config.tcl ###


### ../data/process_config_wizard.tcl ###


### ../data/process_key_file.tcl ###

mcset de {TV-Viewer Menu} {TV-Viewer Menü}
mcset de {Navigation Menu} {Navigation Menü}
mcset de {View Menu} {Ansichts Menü}
mcset de {Audio Menu} {Audio Menü}
mcset de {Help Menu} {Hilfe Menü}
mcset de {Exit TV-Viewer} {TV-Viewer beenden}
mcset de {Toggle TV playback} {Fernsehwiedergabe an oder aus}
mcset de {Station by number} {Senderwahl durch Zifferntasten}
mcset de {Next video input} {Nächster Videoeingang}
mcset de {Previous video input} {Vorheriger Videoeingang}
mcset de {Increase Volume} {Lautstärke erhöhen}
mcset de {Decrease Volume} {Lautstärke verringern}
mcset de {Increase audio delay} {Audioverzögerung erhöhen}
mcset de {Decrease audio delay} {Audioverzögerung verringern}
mcset de {Toggle mute} {Stummschalten}
mcset de {Toggle Fullscreen} {In den Vollbildmodus wechseln}
mcset de {Increase Zoom} {Zoom vergrößern}
mcset de {Decrease Zoom} {Zoom verringern}
mcset de {Move video up} {Video nach oben bewegen}
mcset de {Move video down} {Video nach unten bewegen}
mcset de {Move video right} {Video nach rechts bewegen}
mcset de {Move video left} {Video nach links bewegen}
mcset de {Original window size} {Fenster Ausgangsgröße}
mcset de {Double window size} {Doppelte Fenstergröße}
mcset de {Take a screenshot} {Screenshot machen}
mcset de {Record wizard} {Aufnahmeassistent}
mcset de {Toggle pause} {Pause}
mcset de {Start playback} {Wiedergabe starten}
mcset de {Stop playback} {Wiedergabe stoppen}

### ../data/process_station_file.tcl ###


### ../data/radio.tcl ###


### ../data/record_add_edit.tcl ###

mcset de {Record options} {Aufnahme Optionen}
mcset de {Time:} {Zeit:}
mcset de {Date:} {Datum:}
mcset de {Duration:} {Dauer:}
mcset de {Resolution:} {Auflösung:}
mcset de {Output file} {Ausgabedatei}
mcset de {Add a new recording} {Eine neue Aufnahme hinzufügen}
mcset de {Edit recording} {Aufnahme bearbeiten}
mcset de {Choose station to record} {Sender wählen der aufgenommen werden soll}
mcset de {Time when recording should start (Hour)} {Uhrzeit, wann die Aufnahme beginnen soll (Stunde)}
mcset de {Time when recording should start (Minute)} {Uhrzeit, wann die Aufnahme beginnen soll (Minute)}
mcset de {Choose between before or after midday.
You may change hour format in the preferences (Record).} {Zwischen am und pm wählen.
Das Stunden-Format kann in den Einstellungen (Aufnahme)
geändert werden.}
mcset de {Choose date on which recording should occur} {Wähle das Datum, wann die Aufnahme stattfinden soll}
mcset de {Duration for the recording (Hours)} {Dauer der Aufnahme (Stunden)}
mcset de {Duration for the recording (Minutes)} {Dauer der Aufnahme (Minuten)}
mcset de {Duration for the recording (Seconds)} {Dauer der Aufnahme (Sekunden)}
mcset de {Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.} {Auflösung (Weite) in der die Aufnahme gemacht
werden soll. Es ist meist nicht sinnvoll
diese zu ändern, da Aufnahmen auch später
noch entsprechend bearbeitet werden können.}
mcset de {Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.} {Auflösung (Höhe) in der die Aufnahme gemacht
werden soll. Es ist meist nicht sinnvoll
diese zu ändern, da Aufnahmen auch später
noch entsprechend bearbeitet werden können.}
mcset de {Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path.} {Ausgabe Datei für die Aufnahme. Wenn
keine Datei angegeben wird, bestimmt TV-Viewer
einen Namen und speichert die Datei im Standardpfad
für Aufnahmen.}
mcset de {Do you really want to delete the selected recording(s)?} {Die gewählte(n) Aufnahme(n) wirklich löschen?}
mcset de {Don't ask next time} {Das nächste mal nicht mehr fragen}
mcset de {Delete} {Löschen}
mcset de {Delete recordings} {Aufnahmen löschen}
mcset de {Choose date} {Datum wählen}
mcset de {Previous year} {Vorheriges Jahr}
mcset de {Previous month} {Vorheriger Monat}
mcset de {Next month} {Nächster Monat}
mcset de {Next year} {Nächstes Jahr}

### ../data/record_external.tcl ###


### ../data/record_handler.tcl ###

mcset de {Time format incorrect (%-hour clock)!} {Zeit Format falsch (%s-Stunden-Format)!}
mcset de {Time format incorrect (min)!} {Zeit Format falsch (Minute)!}
mcset de {Chosen date is in the past!} {Gewähltes Datum liegt in der Vergangenheit!}
mcset de {Time is in the past!} {Gewählte Zeit ist vergangen!}
mcset de {Duration not specified correctly (hour)!} {Dauer nicht korrekt angegeben (Stunde)!}
mcset de {Duration not specified correctly (min)!} {Dauer nicht korrekt angegeben (Minute)!}
mcset de {Duration not specified correctly (sec)!} {Dauer nicht korrekt angegeben (Sekunde)!}
mcset de {Resolution format incorrect!} {Format der Auflösung falsch!}

### ../data/record_linker.tcl ###

mcset de {Currently recording %
Started at %} {Aufnahme von %s läuft.
Gestarted um %s}
mcset de {Timeshift %} {Timeshift %s}
mcset de {Recording % - Ends at % %} {Aufnahme %s - Endet am %s um %s}
mcset de {% -- ends % at %} {%s -- endet am %s um %s}
mcset de {Playing file: %} {Dateiwiedergabe: %s}
mcset de {Save timeshift video file
File size %} {Timeshift Videodatei speichern
Dateigröße %s}

### ../data/record_wizard.tcl ###

mcset de {Running} {Läuft}
mcset de {Stop Scheduler} {Scheduler anhalten}
mcset de {Stopped} {Angehalten}
mcset de {Start Scheduler} {Scheduler starten}
mcset de {New recording} {Neue Aufnahme}
mcset de {Edit} {Bearbeiten}
mcset de {Status} {Status}
mcset de {Scheduler status:} {Scheduler Status:}
mcset de {Currently recording:} {Aktuelle Aufnahme:}
mcset de {Stop recording} {Aufnahme anhalten}
mcset de {Job ID} {Job ID}
mcset de {Time} {Zeit}
mcset de {Date} {Datum}
mcset de {Duration} {Dauer}
mcset de {Resolution} {Auflösung}
mcset de {Add a scheduled recording or
start recording immediately.} {Eine geplante Aufnahme hinzufügen,
oder eine Aufnahme sofort starten.}
mcset de {Delete selected recordings} {Ausgewählte Aufnahme(n) löschen}
mcset de {Edit selected recording} {Gewählte Aufnahme bearbeiten}
mcset de {Indicates whether the Scheduler is running or not} {Zeigt ob der Scheduler läuft oder nicht}
mcset de {Provides informations about the current recording} {Zeigt Informationen über eine laufende Aufnahme}
mcset de {If there is a running recording, click here to stop it} {Beendet eine Aufnahme}
mcset de {Exit Record Wizard} {Aufnahme Assistent beenden}

### ../data/recorder.tcl ###


### ../data/release_version.tcl ###


### ../data/scheduler.tcl ###


### ../data/station_after_msg.tcl ###

mcset de {Now playing %} {Jetzt läuft %s}
mcset de {TV-Viewer playing - %} {TV-Viewer Wiedergabe - %s}

### ../data/station_edit.tcl ###

mcset de {Station search} {Sendersuchlauf}
mcset de {Add} {Hinzufügen}
mcset de {Lock} {Sperren}
mcset de {Up} {Nach oben}
mcset de {Down} {Nach unten}
mcset de {Preview} {Vorschau}
mcset de {Unlock} {Entsperren}
mcset de {Frequency} {Fequenz}
mcset de {Video input} {Videoeingang}
mcset de {External Tuner} {Externer Tuner}
mcset de {Perform an automatic station search} {Automatische Sendersuche durchführen}
mcset de {Add a new television station} {Einen neuen Sender hinzufügen}
mcset de {Delete selected television station} {Den gewählten Kanal entfernen}
mcset de {Lock or unlock selected station(s).
Locked stations will be displayed in red.} {Sender sperren oder entsperren.
Gesperrte Sender werden in rot dargestellt.}
mcset de {Edit selected station} {Gewählten Sender bearbeiten}
mcset de {Move selected item up} {Ausgewählte(s) Element(e) nach oben verschieben}
mcset de {Move selected item down} {Ausgewählte(s) Element(e) nach unten verschieben}
mcset de {Preview for selected tv station} {Vorschau für gewählten Sender}
mcset de {Save station list and exit editor} {Senderliste speichern und Sendereditor verlassen}
mcset de {Exit editor without any changes} {Editor verlassen ohne Änderungen}

### ../data/station_item.tcl ###

mcset de {Do you really want to delete the selected station(s)?} {Sollen die die ausgewählten Sender wirklich gelöscht werden?}
mcset de {Delete stations} {Sender löschen}
mcset de {Station:} {Sender:}
mcset de {Frequency:} {Frequenz:}
mcset de {Video input:} {Videoeingang:}
mcset de {Add a new station} {Neuen Sender hinzufügen}
mcset de {Edit Station / Frequency} {Sender / Frequenz bearbeiten}
mcset de {Provide a name for the television station} {Einen Namen für den Sender angeben}
mcset de {Frequency for the station, E.g. 175.250} {Frequency for the station, E.g. 175.250}
mcset de {Video input for this station. 
Normally you want television input.} {Videoeingang für diesen Sender. 
Im Normalfall ist dies der TV-Eingang.}
mcset de {Use an external tuner} {Einen externen Tuner verwenden}
mcset de {Specify a command for the external tuner.
You may use this substitutions:

%%F  Frequency
%%S  Station name
e.g. externalTune %%F %%S} {Einen Befehl für den externen Tuner angeben.
Man kann Stellvertreter verwenden:

%%F  Frequenz
%%S  Sendername
z.B. externalTune %%F %%S}
mcset de {Please specify name and frequency for each station} {Name und Frequenz für Sender angeben}

### ../data/station_search.tcl ###

mcset de {Station search options} {Optionen - Sendersuche}
mcset de {Append stations} {Sender hinzufügen}
mcset de {Perform a full frequency sweep} {Gesamten Frequenzbereich absuchen}
mcset de {Start} {Starten}
mcset de {Append stations, or overwrite existing list} {Sender hinzufügen, oder vorhandene Liste überschreiben}
mcset de {Perform a full frequency sweep, or check all channels
defined by the frequency table.
Note: A full frequency sweep may find many duplicates.} {Gesamten Frequenzbereich absuchen, oder alle Kanäle
überprüfen die durch die Frequenztabelle definiert sind.
Achtung: Wird der gesamte Frequenzbereich durchsucht,
können viele Duplikate gefunden werden.}
mcset de {Choose the frequency increase factor for full frequency sweep.
Note: The lower this factor the more duplicates will be found and
the search takes more time.} {Frequenzsteigerungs Faktor für das Absuchen des gesamten
Frequenzbereichs wählen.
Achtung: Desto niedriger dieser Wert desto mehr Duplikate eines
Senders werden gefunden und die Sendersuche dauert länger.}
mcset de {Time in milliseconds to wait for the driver to respond.
The lower this value the faster the full frequency sweep will be.
Note: If this value is too small the driver won't have
enough time to report if there is a signal on the current frequency.
As a result not all stations will be found.} {Zeit in Millisekunden die auf den Treiber gewartet wird.
Je niedriger diesert Wert ist, desto schneller wird die Suche
abgeschlossen sein.
Achtung: Wenn dieser Wert zu gering ist hat der Treiber möglicherweise
nicht mehr genug Zeit für eine Rückmeldung ob auf der aktuellen
Frequenz ein Signal liegt. Dies führt dazu, dass nicht alle Sender
gefunden werden.}
mcset de {Start station search} {Sendersuche starten}
mcset de {Station search in progress.
Please wait...} {Sendersuche läuft.
Bitte warten...}
mcset de {Channel: %} {Kanal: %s}
mcset de {Station search finished!} {Station search finished!}
mcset de {Frequency: %} {Frequenz: %s}

### ../data/system_tray.tcl ###

mcset de {Hide} {Verstecken}
mcset de {Restore} {Wiederherstellen}

### ../data/timeshift.tcl ###

mcset de {Copying timeshift video file.
Please wait...} {Kopiere Timeshift Videofile.
Bitte warten...}
mcset de {Copying...       %%%} {Kopiere...       %s%%}
mcset de {Copying...       finished} {Kopiere...       beendet}

### ../data/tooltip.tcl ###

mcset de {Tune up} {Vorheriger Sender}
mcset de {Tune down} {Nächster Sender}
mcset de {Zap among the last two stations} {Zwischen den letzten beiden Sendern hin- und herzappen}
mcset de {Alter volume} {Lautstärke anpassen}
mcset de {Start/Stop timeshift} {Timeshift starten/stoppen}
mcset de {Start/Stop record} {Aufnahme starten/beenden}
mcset de {Execute the selected EPG application} {Die ausgewählte EPG Applikation starten}
mcset de {Switch to radio mode} {In den Radio-Modus wechseln}
mcset de {Start/Stop TV playback} {Fernsehwiedergabe starten/stoppen}
mcset de {Pause playback} {Wiedergabe pausieren}
mcset de {Jump to the beginning} {Zum Anfang springen}
mcset de {Seek back} {Zurück}
mcset de {Choose amount of seek back} {Wählen wie weit zurückgesprungen werden soll}
mcset de {Seek forward} {Vorwärts}
mcset de {Choose amount of seek forward} {Wählen wie weit vorgesprungen werden soll}
mcset de {Jump to the end} {Zum Ende springen}
mcset de {Toggle fullscreen} {Vollbild-, Fenstermodus}
mcset de {Current position / File length} {Aktuelle Position / Länge der Aufnahme}

### ../data/tv-viewer_main.tcl ###


### ../data/vid_audio.tcl ###


### ../data/vid_callback.tcl ###

mcset de {idle} {inaktiv}

### ../data/vid_file_calc.tcl ###


### ../data/vid_osd.tcl ###


### ../data/vid_playback.tcl ###


### ../data/vid_pmhandler.tcl ###


### ../data/vid_seek.tcl ###


### ../data/vid_slist.tcl ###


### ../data/vid_wm.tcl ###

mcset de {Move x=%} {Bild bewegen x=%s}
mcset de {Move y=%} {Bild bewegen y=%s}
mcset de {Centering video} {Video zentrieren}

### ../callib/callib.tcl ###

mcset de {Sun} {So}
mcset de {Mon} {Mo}
mcset de {Tue} {Di}
mcset de {Wed} {Mi}
mcset de {Thu} {Do}
mcset de {Fri} {Fr}
mcset de {Sat} {Sa}


