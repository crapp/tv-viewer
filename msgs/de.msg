# de.msg
namespace import -force msgcat::mcset

# /home/saedelaere/Projekte/tv-viewer/data/agrep.tcl


# /home/saedelaere/Projekte/tv-viewer/data/chan_zapper.tcl


# /home/saedelaere/Projekte/tv-viewer/data/colorm.tcl

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
mcset de {Load default values} {Standard Werte laden}
mcset de {Close color management without saving changes} {Farbverwaltung beenden ohne die Änderungen zu übernehmen}

# /home/saedelaere/Projekte/tv-viewer/data/command_socket.tcl


# /home/saedelaere/Projekte/tv-viewer/data/config_advanced.tcl

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

# /home/saedelaere/Projekte/tv-viewer/data/config_analog.tcl

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

# /home/saedelaere/Projekte/tv-viewer/data/config_audio.tcl

mcset de {Audio Settings} {Audio Einstellungen}
mcset de {Audio output driver} {Audio Ausgabetreiber}
mcset de {Audio channels} {Audio Kanäle}
mcset de {Use software mixer} {Software Mixer verwenden}
mcset de {Remember volume level} {Remember volume level}
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

# /home/saedelaere/Projekte/tv-viewer/data/config_dvb.tcl

mcset de {DVB Settings} {DVB Einstellungen}
mcset de {Expect more soon} {Bald mehr}

# /home/saedelaere/Projekte/tv-viewer/data/config_general.tcl

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

# /home/saedelaere/Projekte/tv-viewer/data/config_interface.tcl

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

# /home/saedelaere/Projekte/tv-viewer/data/config_radio.tcl

mcset de {Radio Settings} {Radio Einstellungen}

# /home/saedelaere/Projekte/tv-viewer/data/config_record.tcl

mcset de {Record Settings} {Record Settings}
mcset de {Standard folder} {Standard folder}
mcset de {Default record duration} {Default record duration}
mcset de {Allow station change while recording} {Allow station change while recording}
mcset de {Autostart scheduler} {Autostart scheduler}
mcset de {Hours format} {Hours format}
mcset de {24-hour clock} {24-hour clock}
mcset de {12-hour clock} {12-hour clock}
mcset de {Timeshift} {Timeshift}
mcset de {Timeshift folder} {Timeshift folder}
mcset de {Space to be left free} {Space to be left free}
mcset de {Choose a directory} {Choose a directory}
mcset de {Set the default directory for all recordings.} {Set the default directory for all recordings.}
mcset de {Define the default duration for recordings (Hours).} {Define the default duration for recordings (Hours).}
mcset de {Define the default duration for recordings (Minutes).} {Define the default duration for recordings (Minutes).}
mcset de {Define the default duration for recordings (Seconds).} {Define the default duration for recordings (Seconds).}
mcset de {Choose if you want to use a 24-hour clock or 12-hour clock to schedule recordings} {Choose if you want to use a 24-hour clock or 12-hour clock to schedule recordings}
mcset de {Allow station change during recording.} {Allow station change during recording.}
mcset de {Autostart the scheduler.
This is necessary for scheduled recordings.} {Autostart the scheduler.
This is necessary for scheduled recordings.}
mcset de {Choose path where Timeshift events will be cached.} {Choose path where Timeshift events will be cached.}
mcset de {Define the minimum free disk space.
If free disk space is falling below this value
timeshift will automatically be stopped.
A value of 0 deactivates this feature.} {Define the minimum free disk space.
If free disk space is falling below this value
timeshift will automatically be stopped.
A value of 0 deactivates this feature.}

# /home/saedelaere/Projekte/tv-viewer/data/config_video.tcl

mcset de {Video Settings} {Video Settings}
mcset de {Video} {Video}
mcset de {Video output driver} {Video output driver}
mcset de {Deinterlacing filter} {Deinterlacing filter}
mcset de {Postprocessing level} {Postprocessing level}
mcset de {Cache size (kb)} {Cache size (kb)}
mcset de {Threads for decoding} {Threads for decoding}
mcset de {Direct Rendering} {Direct Rendering}
mcset de {Double Buffering} {Double Buffering}
mcset de {Slice Mode} {Slice Mode}
mcset de {Framedrop} {Framedrop}
mcset de {Hard Framedrop} {Hard Framedrop}
mcset de {Disable Screensaver} {Disable Screensaver}
mcset de {Use MPlayer} {Use MPlayer}
mcset de {Use Heartbeat function} {Use Heartbeat function}
mcset de {Select the video ouput driver.
xv should provide the best performance.} {Select the video ouput driver.
xv should provide the best performance.}
mcset de {Select the deinterlace filter.} {Select the deinterlace filter.}
mcset de {Changes the level of postprocesseing.
A value of 0 deactivates postprocessing.} {Changes the level of postprocesseing.
A value of 0 deactivates postprocessing.}
mcset de {Specify how much memory (in kBytes) should be used for TV playback.
The lower this value is the faster you may switch between stations.
But a low value could cause other problems.
A value of 0 will deactivate cache use.} {Specify how much memory (in kBytes) should be used for TV playback.
The lower this value is the faster you may switch between stations.
But a low value could cause other problems.
A value of 0 will deactivate cache use.}
mcset de {Sets the number of threads for decoding.} {Sets the number of threads for decoding.}
mcset de {If checked, enables direct rendering. This is not supported
for all video ouput drivers.} {If checked, enables direct rendering. This is not supported
for all video ouput drivers.}
mcset de {Double buffering fixes flicker by storing two frames in memory
and displaying one, while decoding another.} {Double buffering fixes flicker by storing two frames in memory
and displaying one, while decoding another.}
mcset de {Enable / Disable drawing video by 16-pixel height slices/bands.
May help in better video playback.} {Enable / Disable drawing video by 16-pixel height slices/bands.
May help in better video playback.}
mcset de {Skip displaying some frames to maintain A/V sync.} {Skip displaying some frames to maintain A/V sync.}
mcset de {More intense frame dropping. May lead to image distortion.} {More intense frame dropping. May lead to image distortion.}
mcset de {Enable / Disable screensaver while playback.} {Enable / Disable screensaver while playback.}
mcset de {Use MPlayer to deactivate the screensaver.} {Use MPlayer to deactivate the screensaver.}
mcset de {If MPlayer can't deactivate your screensaver, use this heartbeat hack.} {If MPlayer can't deactivate your screensaver, use this heartbeat hack.}

# /home/saedelaere/Projekte/tv-viewer/data/config_wizard.tcl

mcset de {General} {General}
mcset de {Analog} {Analog}
mcset de {DVB} {DVB}
mcset de {Audio} {Audio}
mcset de {Radio} {Radio}
mcset de {Interface} {Interface}
mcset de {Record} {Record}
mcset de {Apply your changes and exit preferences dialog.} {Apply your changes and exit preferences dialog.}
mcset de {Load default values, for the corresponding section.} {Load default values, for the corresponding section.}
mcset de {Discard changes and close preferences dialog.} {Discard changes and close preferences dialog.}

# /home/saedelaere/Projekte/tv-viewer/data/create_icons.tcl


# /home/saedelaere/Projekte/tv-viewer/data/diag_frontend.tcl

mcset de {Diagnostic Routine is checking your system.
Please wait...} {Diagnostic Routine is checking your system.
Please wait...}
mcset de {Exit} {Exit}
mcset de {Diagnostic Routine} {Diagnostic Routine}
mcset de {Diagnostic Routine finished} {Diagnostic Routine finished}
mcset de {Generated file:} {Generated file:}
mcset de {Create a bug report on } {Create a bug report on }
mcset de {and attach the generated file.} {and attach the generated file.}
mcset de {Diagnostic Routine crashed} {Diagnostic Routine crashed}

# /home/saedelaere/Projekte/tv-viewer/data/diag_runtime.tcl


# /home/saedelaere/Projekte/tv-viewer/data/difftime.tcl


# /home/saedelaere/Projekte/tv-viewer/data/error_interp.tcl

mcset de {Skip further error messages} {Skip further error messages}
mcset de {OK} {OK}
mcset de {File bug report} {File bug report}
mcset de {Save to disk} {Save to disk}
mcset de {Error: %} {Error: %s}
mcset de {Select everything} {Select everything}
mcset de {Copy to clipboard} {Copy to clipboard}
mcset de {TV-Viewer crashed} {TV-Viewer crashed}
mcset de {Choose name and location} {Choose name and location}

# /home/saedelaere/Projekte/tv-viewer/data/event_bind.tcl


# /home/saedelaere/Projekte/tv-viewer/data/font_chooser.tcl

mcset de {Family:} {Family:}
mcset de {Style:} {Style:}
mcset de {Size:} {Size:}
mcset de {Font color:} {Font color:}
mcset de {Display:} {Display:}
mcset de {Preview:} {Preview:}
mcset de {top left} {top left}
mcset de {top} {top}
mcset de {top right} {top right}
mcset de {left} {left}
mcset de {center} {center}
mcset de {right} {right}
mcset de {bottom left} {bottom left}
mcset de {bottom} {bottom}
mcset de {bottom right} {bottom right}
mcset de {Choose a font} {Choose a font}
mcset de {Choose font style} {Choose font style}
mcset de {Choose font size} {Choose font size}
mcset de {Choose font color} {Choose font color}
mcset de {Specify where the message box should be
displayed in the video frame} {Specify where the message box should be
displayed in the video frame}
mcset de {Choose font} {Choose font}
mcset de {Choose color} {Choose color}

# /home/saedelaere/Projekte/tv-viewer/data/info_help.tcl

mcset de {TV-Viewer % Build %} {TV-Viewer %s Build %s}
mcset de {Info} {Info}
mcset de {A small and simple frontend to watch and record television.} {A small and simple frontend to watch and record television.}
mcset de {Homepage} {Homepage}
mcset de {http://tv-viewer.sourceforge.net} {http://tv-viewer.sourceforge.net}
mcset de {Forum} {Forum}
mcset de {http://sourceforge.net/.../forums} {http://sourceforge.net/.../forums}
mcset de {IRC channel} {IRC channel}
mcset de {http://webchat.freenode.net/} {http://webchat.freenode.net/}
mcset de {© Copyright 2007 - 2010
Christian Rapp} {© Copyright 2007 - 2010
Christian Rapp}
mcset de {Credits} {Credits}
mcset de {License} {License}
mcset de {Changelog} {Changelog}
mcset de {About TV-Viewer} {About TV-Viewer}

# /home/saedelaere/Projekte/tv-viewer/data/key_sequences.tcl

mcset de {Available Key Sequences} {Available Key Sequences}
mcset de {Change shortcut} {Change shortcut}
mcset de {Key Sequences} {Key Sequences}
mcset de {Action} {Action}
mcset de {Key Sequence} {Key Sequence}
mcset de {Television} {Television}
mcset de {Window management} {Window management}
mcset de {Recording / File playback} {Recording / File playback}
mcset de {Do you really want to load default values for all key sequences?

This will happen instantly and can not be undone!} {Do you really want to load default values for all key sequences?

This will happen instantly and can not be undone!}
mcset de {Set shortcuts to default values} {Set shortcuts to default values}
mcset de {Press the key combination you want to assign} {Press the key combination you want to assign}
mcset de {Clear} {Clear}
mcset de {Modify shortcut} {Modify shortcut}
mcset de {It is not possible to edit this shortcut} {It is not possible to edit this shortcut}
mcset de {Conflict detected with station by number "0-9"} {Conflict detected with station by number "0-9"}
mcset de {Conflict detected with %} {Conflict detected with %s}

# /home/saedelaere/Projekte/tv-viewer/data/launch_splash.tcl


# /home/saedelaere/Projekte/tv-viewer/data/lirc_emitter.tcl


# /home/saedelaere/Projekte/tv-viewer/data/log_viewer.tcl

mcset de {Choose output file} {Choose output file}
mcset de {$ident(name($handler)) Log} {$ident(name($handler)) Log}
mcset de {Save logfile to disk} {Save logfile to disk}
mcset de {Send logfile by e-mail to the authors} {Send logfile by e-mail to the authors}
mcset de {Show/hide Debug messages} {Show/hide Debug messages}
mcset de {Show/hide Warning messages} {Show/hide Warning messages}
mcset de {Show/hide Error messages} {Show/hide Error messages}

# /home/saedelaere/Projekte/tv-viewer/data/main_command_line_options.tcl


# /home/saedelaere/Projekte/tv-viewer/data/main_frontend.tcl

mcset de {Name} {Name}
mcset de {No} {No}
mcset de {Navigation} {Navigation}
mcset de {View} {View}
mcset de {Welcome to TV-Viewer} {Welcome to TV-Viewer}
mcset de {TV-Viewer %} {TV-Viewer %s}
mcset de {TV-Viewer idle} {TV-Viewer idle}

# /home/saedelaere/Projekte/tv-viewer/data/main_menu.tcl

mcset de {EPG} {EPG}
mcset de {TV} {TV}
mcset de {Prior station} {Prior station}
mcset de {Next station} {Next station}
mcset de {Station jumper} {Station jumper}
mcset de {Play} {Play}
mcset de {Pause} {Pause}
mcset de {Stop} {Stop}
mcset de {Rewind} {Rewind}
mcset de {-10 seconds} {-10 seconds}
mcset de {-1 minute} {-1 minute}
mcset de {-10 minute} {-10 minute}
mcset de {File beginning} {File beginning}
mcset de {Forward} {Forward}
mcset de {+10 seconds} {+10 seconds}
mcset de {+1 minute} {+1 minute}
mcset de {+10 minutes} {+10 minutes}
mcset de {File end} {File end}
mcset de {Pan&Scan} {Pan&Scan}
mcset de {Zoom +} {Zoom +}
mcset de {Zoom -} {Zoom -}
mcset de {Pan&Scan (16:9 / 4:3)} {Pan&Scan (16:9 / 4:3)}
mcset de {Move up} {Move up}
mcset de {Move down} {Move down}
mcset de {Move left} {Move left}
mcset de {Move right} {Move right}
mcset de {Center video} {Center video}
mcset de {Size} {Size}
mcset de {Stay on top} {Stay on top}
mcset de {Never} {Never}
mcset de {Always} {Always}
mcset de {While playback} {While playback}
mcset de {Toolbars} {Toolbars}
mcset de {Main toolbar} {Main toolbar}
mcset de {Station list} {Senderliste}
mcset de {Statusbar} {Statusbar}
mcset de {Show status messages} {Show status messages}
mcset de {Show playback time} {Show playback time}
mcset de {Compact mode} {Compact mode}
mcset de {Fullscreen} {Fullscreen}
mcset de {Volume +} {Volume +}
mcset de {Volume -} {Volume -}
mcset de {Mute} {Mute}
mcset de {Delay +} {Delay +}
mcset de {Delay -} {Delay -}
mcset de {Help} {Help}
mcset de {User Guide} {User Guide}
mcset de {MPlayer Log} {MPlayer Log}
mcset de {Scheduler Log} {Scheduler Log}
mcset de {TV-Viewer Log} {TV-Viewer Log}
mcset de {-10 minutes} {-10 minutes}

# /home/saedelaere/Projekte/tv-viewer/data/main_newsreader.tcl


# /home/saedelaere/Projekte/tv-viewer/data/main_picqual_stream.tcl


# /home/saedelaere/Projekte/tv-viewer/data/monitor.tcl


# /home/saedelaere/Projekte/tv-viewer/data/process_config.tcl


# /home/saedelaere/Projekte/tv-viewer/data/process_config_wizard.tcl


# /home/saedelaere/Projekte/tv-viewer/data/process_key_file.tcl

mcset de {TV-Viewer Menu} {TV-Viewer Menu}
mcset de {Navigation Menu} {Navigation Menu}
mcset de {View Menu} {View Menu}
mcset de {Audio Menu} {Audio Menu}
mcset de {Help Menu} {Help Menu}
mcset de {Exit TV-Viewer} {Exit TV-Viewer}
mcset de {Toggle TV playback} {Toggle TV playback}
mcset de {Next Station} {Next Station}
mcset de {Prior Station} {Prior Station}
mcset de {Jump between the last two stations} {Jump between the last two stations}
mcset de {Station by number} {Station by number}
mcset de {Next video input} {Next video input}
mcset de {Previous video input} {Previous video input}
mcset de {Increase Volume} {Increase Volume}
mcset de {Decrease Volume} {Decrease Volume}
mcset de {Increase audio delay} {Increase audio delay}
mcset de {Decrease audio delay} {Decrease audio delay}
mcset de {Toggle mute} {Toggle mute}
mcset de {Toggle Fullscreen} {Toggle Fullscreen}
mcset de {Increase Zoom} {Increase Zoom}
mcset de {Decrease Zoom} {Decrease Zoom}
mcset de {Move video up} {Move video up}
mcset de {Move video down} {Move video down}
mcset de {Move video right} {Move video right}
mcset de {Move video left} {Move video left}
mcset de {Original window size} {Original window size}
mcset de {Double window size} {Double window size}
mcset de {Take a screenshot} {Take a screenshot}
mcset de {Record wizard} {Record wizard}
mcset de {Toggle pause} {Toggle pause}
mcset de {Start playback} {Start playback}
mcset de {Stop playback} {Stop playback}

# /home/saedelaere/Projekte/tv-viewer/data/process_station_file.tcl


# /home/saedelaere/Projekte/tv-viewer/data/radio.tcl


# /home/saedelaere/Projekte/tv-viewer/data/record_add_edit.tcl

mcset de {Record options} {Record options}
mcset de {Time:} {Time:}
mcset de {Date:} {Date:}
mcset de {Duration:} {Duration:}
mcset de {Resolution:} {Resolution:}
mcset de {Output file} {Output file}
mcset de {Add a new recording} {Add a new recording}
mcset de {Edit recording} {Edit recording}
mcset de {Choose station to record.} {Choose station to record.}
mcset de {Time when recording should start. (Hour)} {Time when recording should start. (Hour)}
mcset de {Time when recording should start. (Minute)} {Time when recording should start. (Minute)}
mcset de {Choose between before or after midday.
You may change hour format in the preferences (Record).} {Choose between before or after midday.
You may change hour format in the preferences (Record).}
mcset de {Choose date on which recording should occur.} {Choose date on which recording should occur.}
mcset de {Duration for the recording. (Hours)} {Duration for the recording. (Hours)}
mcset de {Duration for the recording. (Minutes)} {Duration for the recording. (Minutes)}
mcset de {Duration for the recording. (Seconds)} {Duration for the recording. (Seconds)}
mcset de {Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.} {Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.}
mcset de {Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.} {Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.}
mcset de {Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path.} {Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path.}
mcset de {Apply your changes and exit the dialogue.} {Apply your changes and exit the dialogue.}
mcset de {Exit the dialogue without changes.} {Exit the dialogue without changes.}
mcset de {Do you really want to delete the selected recording(s)?} {Do you really want to delete the selected recording(s)?}
mcset de {Don't ask next time} {Don't ask next time}
mcset de {Delete} {Delete}
mcset de {Delete recordings} {Delete recordings}
mcset de {Choose date} {Choose date}
mcset de {Previous year.} {Previous year.}
mcset de {Previous month.} {Previous month.}
mcset de {Next month.} {Next month.}
mcset de {Next year.} {Next year.}

# /home/saedelaere/Projekte/tv-viewer/data/record_external.tcl


# /home/saedelaere/Projekte/tv-viewer/data/record_handler.tcl

mcset de {Time format incorrect (%-hour clock)!} {Time format incorrect (%s-hour clock)!}
mcset de {Time format incorrect (min)!} {Time format incorrect (min)!}
mcset de {Chosen date is in the past!} {Chosen date is in the past!}
mcset de {Time is in the past!} {Time is in the past!}
mcset de {Duration not specified correctly (hour)!} {Duration not specified correctly (hour)!}
mcset de {Duration not specified correctly (min)!} {Duration not specified correctly (min)!}
mcset de {Duration not specified correctly (sec)!} {Duration not specified correctly (sec)!}
mcset de {Resolution format incorrect!} {Resolution format incorrect!}

# /home/saedelaere/Projekte/tv-viewer/data/record_linker.tcl

mcset de {Currently recording %
Started at %} {Currently recording %s
Started at %s}
mcset de {Timeshift %} {Timeshift %s}
mcset de {Recording % - Ends at % %} {Recording %s - Ends at %s %s}
mcset de {% -- ends % at %} {%s -- ends %s at %s}
mcset de {Playing file: %} {Playing file: %s}

# /home/saedelaere/Projekte/tv-viewer/data/record_wizard.tcl

mcset de {Running} {Running}
mcset de {Stop Scheduler} {Stop Scheduler}
mcset de {Stopped} {Stopped}
mcset de {Start Scheduler} {Start Scheduler}
mcset de {New recording} {New recording}
mcset de {Edit} {Edit}
mcset de {Status} {Status}
mcset de {Scheduler status:} {Scheduler status:}
mcset de {Currently recording:} {Currently recording:}
mcset de {Stop recording} {Stop recording}
mcset de {Job ID} {Job ID}
mcset de {Time} {Time}
mcset de {Date} {Date}
mcset de {Duration} {Duration}
mcset de {Resolution} {Resolution}
mcset de {Add a scheduled recording or
start recording immediately.} {Add a scheduled recording or
start recording immediately.}
mcset de {Delete selected recordings.} {Delete selected recordings.}
mcset de {Edit selected recording.} {Edit selected recording.}
mcset de {Indicates whether the Scheduler
is running or not.} {Indicates whether the Scheduler
is running or not.}
mcset de {Provides informations about the
current recording.} {Provides informations about the
current recording.}
mcset de {If there is a running recording,
click here to stop it.} {If there is a running recording,
click here to stop it.}
mcset de {Exit Record Wizard} {Exit Record Wizard}

# /home/saedelaere/Projekte/tv-viewer/data/recorder.tcl


# /home/saedelaere/Projekte/tv-viewer/data/release_version.tcl


# /home/saedelaere/Projekte/tv-viewer/data/scheduler.tcl


# /home/saedelaere/Projekte/tv-viewer/data/station_after_msg.tcl

mcset de {Now playing %} {Now playing %s}
mcset de {TV-Viewer playing - %} {TV-Viewer playing - %s}

# /home/saedelaere/Projekte/tv-viewer/data/station_edit.tcl

mcset de {Station search} {Station search}
mcset de {Add} {Add}
mcset de {Lock} {Lock}
mcset de {Prior} {Prior}
mcset de {Next} {Next}
mcset de {Preview} {Preview}
mcset de {Unlock} {Unlock}
mcset de {Frequency} {Frequency}
mcset de {Video input} {Video input}
mcset de {External Tuner} {External Tuner}
mcset de {Perform an automatic station search.
This will delete all stations currently in the list!} {Perform an automatic station search.
This will delete all stations currently in the list!}
mcset de {Add a new television station.} {Add a new television station.}
mcset de {Delete selected television station.} {Delete selected television station.}
mcset de {(De)Activate selected station.
Deactivated stations will be marked red.} {(De)Activate selected station.
Deactivated stations will be marked red.}
mcset de {Edit selected station.} {Edit selected station.}
mcset de {Move selected item up.} {Move selected item up.}
mcset de {Move selected item down.} {Move selected item down.}
mcset de {Preview for selected tv station.} {Preview for selected tv station.}
mcset de {Save station list and exit editor.} {Save station list and exit editor.}
mcset de {Exit editor without any changes.} {Exit editor without any changes.}

# /home/saedelaere/Projekte/tv-viewer/data/station_item.tcl

mcset de {Do you really want to delete the selected station(s)?} {Do you really want to delete the selected station(s)?}
mcset de {Delete stations} {Delete stations}
mcset de {Station:} {Station:}
mcset de {Frequency:} {Frequency:}
mcset de {Video input:} {Video input:}
mcset de {Add a new station} {Add a new station}
mcset de {Edit Station / Frequency} {Edit Station / Frequency}
mcset de {Provide a name for the television station.} {Provide a name for the television station.}
mcset de {Frequency for the station. E.g. 175.250} {Frequency for the station. E.g. 175.250}
mcset de {Video input for this station. 
Normally you want television input.} {Video input for this station. 
Normally you want television input.}
mcset de {Use an external tuner} {Use an external tuner}
mcset de {Specify a command for the external tuner.
You may use this substitutions:

%%F  Frequency
%%S  Station name
e.g. externalTune %%F %%S} {Specify a command for the external tuner.
You may use this substitutions:

%%F  Frequency
%%S  Station name
e.g. externalTune %%F %%S}
mcset de {Apply changes and close window.} {Apply changes and close window.}
mcset de {Exit without changes.} {Exit without changes.}
mcset de {Please specify name and frequency for each station} {Please specify name and frequency for each station}

# /home/saedelaere/Projekte/tv-viewer/data/station_search.tcl

mcset de {Station search options} {Station search options}
mcset de {Append stations to existing list} {Append stations to existing list}
mcset de {Perform a full frequency sweep} {Perform a full frequency sweep}
mcset de {Start} {Start}
mcset de {Append stations to existing list.
Otherwise the existing list will be deleted.} {Append stations to existing list.
Otherwise the existing list will be deleted.}
mcset de {Perform a full frequency sweep.
Otherwise TV-Viewer checks all channels for the chosen
frequency table.
Note: A full frequency sweep may find many duplicates.} {Perform a full frequency sweep.
Otherwise TV-Viewer checks all channels for the chosen
frequency table.
Note: A full frequency sweep may find many duplicates.}
mcset de {Choose the frequency increase factor for full frequency sweep.
Note: The lower this factor the more duplicates will be found and
the search takes more time.} {Choose the frequency increase factor for full frequency sweep.
Note: The lower this factor the more duplicates will be found and
the search takes more time.}
mcset de {Time in milliseconds to wait for the driver to respond.
The lower this value the faster the full frequency sweep will be.
Note: If this value is too small the driver will possibly not have
enough time to report if there is a signal on the current frequency.
As a result not all stations will be found.} {Time in milliseconds to wait for the driver to respond.
The lower this value the faster the full frequency sweep will be.
Note: If this value is too small the driver will possibly not have
enough time to report if there is a signal on the current frequency.
As a result not all stations will be found.}
mcset de {Start station search.} {Start station search.}
mcset de {Station search in progress.
Please wait...} {Station search in progress.
Please wait...}
mcset de {Channel: %} {Channel: %s}
mcset de {Station search finished!} {Station search finished!}
mcset de {Frequency: %} {Frequency: %s}

# /home/saedelaere/Projekte/tv-viewer/data/system_tray.tcl

mcset de {Hide} {Hide}
mcset de {Restore} {Restore}

# /home/saedelaere/Projekte/tv-viewer/data/timeshift.tcl

mcset de {Copying timeshift video file.
Please wait...} {Copying timeshift video file.
Please wait...}
mcset de {Copying...       %%%} {Copying...       %s%%}
mcset de {Copying...       finished} {Copying...       finished}

# /home/saedelaere/Projekte/tv-viewer/data/tooltip.tcl

mcset de {Tune up} {Tune up}
mcset de {Tune down} {Tune down}
mcset de {Zap among the last two stations} {Zap among the last two stations}
mcset de {Alter volume} {Alter volume}
mcset de {Start/Stop timeshift} {Start/Stop timeshift}
mcset de {Start/Stop record} {Start/Stop record}
mcset de {Execute the selected EPG application} {Execute the selected EPG application}
mcset de {Switch to radio mode} {Switch to radio mode}
mcset de {Start/Stop TV playback} {Start/Stop TV playback}
mcset de {Pause playback} {Pause playback}
mcset de {Jump to the beginning} {Jump to the beginning}
mcset de {Seek back} {Seek back}
mcset de {Choose amount of seek back} {Choose amount of seek back}
mcset de {Seek forward} {Seek forward}
mcset de {Choose amount of seek forward} {Choose amount of seek forward}
mcset de {Jump to the end} {Jump to the end}
mcset de {Toggle fullscreen} {Toggle fullscreen}
mcset de {Current position / File length} {Current position / File length}

# /home/saedelaere/Projekte/tv-viewer/data/tv-viewer_main.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_audio.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_callback.tcl

mcset de {idle} {idle}

# /home/saedelaere/Projekte/tv-viewer/data/vid_file_calc.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_osd.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_playback.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_pmhandler.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_seek.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_slist.tcl


# /home/saedelaere/Projekte/tv-viewer/data/vid_wm.tcl

mcset de {Move x=%} {Move x=%s}
mcset de {Move y=%} {Move y=%s}
mcset de {Centering video} {Centering video}

# /home/saedelaere/Projekte/tv-viewer/extensions/callib/callib.tcl

mcset de {Sun} {So}
mcset de {Mon} {Mo}
mcset de {Tue} {Di}
mcset de {Wed} {Mi}
mcset de {Thu} {Do}
mcset de {Fri} {Fr}
mcset de {Sat} {Sa}


