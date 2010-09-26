# en.msg
namespace import -force msgcat::mcset

### ../data/agrep.tcl ###


### ../data/chan_zapper.tcl ###


### ../data/colorm.tcl ###

mcset en {Brightness}
mcset en {Contrast}
mcset en {Hue}
mcset en {Saturation}
mcset en {Apply}
mcset en {Default}
mcset en {Cancel}
mcset en {Color Management}
mcset en {Set brightness, this is a global value}
mcset en {Set contrast, this is a global value}
mcset en {Set hue, this is a global value}
mcset en {Set saturation, this is a global value}
mcset en {Save values and close color management}
mcset en {Load default values}
mcset en {Close color management without saving changes}

### ../data/command_socket.tcl ###


### ../data/config_advanced.tcl ###

mcset en {Advanced}
mcset en {Manage aspect ratio}
mcset en {Keep video aspect ratio}
mcset en {Monitor aspect}
mcset en {Monitor pixel aspect}
mcset en {Screenshot}
mcset en {Activate screenshot feature}
mcset en {MPlayer config file}
mcset en {Do not process MPlayer config files}
mcset en {Default settings}
mcset en {Reset}
mcset en {Additional options for MPlayer}
mcset en {Additional MPlayer options}
mcset en {Additional video filter options}
mcset en {Additional audio filter options}
mcset en {Logs}
mcset en {Enable Logging}
mcset en {MPlayer logfile size in kBytes}
mcset en {Scheduler logfile size in kBytes}
mcset en {TV-Viewer logfile size in kBytes}
mcset en {Let TV-Viewer manage video aspect ratio (recommended)}
mcset en {Choose either monitor aspect ratio or monitor pixel aspect.
This may improve picture quality.}
mcset en {Activate or deactive the screenshot feature.
Screenshots will be stored in the users home directory.}
mcset en {If enabled MPlayer will ignore all existing config files.
This will ensure only values set by TV-Viewer will be used.}
mcset en {Reset all configuration options}
mcset en {Here you may provide additional command line options for MPlayer.
Separate the different options with spaces.
See the MPlayer man pages for more informations.}
mcset en {Additional video filter options must be separated with commas.
E.g. scale=512:-2,eq2=1.1
See the MPlayer man pages for more informations.}
mcset en {Additional audio filter options must be separated with commas.
E.g. resample=44100:0:0,volnorm
See the MPlayer man pages for more informations.}
mcset en {Check this to enable logging of TV-Viewer, Scheduler and MPlayer events.
You can find the three logfiles in %/log/
Refer to the 'Help' section of the main interface for the log viewers.} {Check this to enable logging of TV-Viewer, Scheduler and MPlayer events.
You can find the three logfiles in %s/log/
Refer to the 'Help' section of the main interface for the log viewers.}
mcset en {Specify the amount of space in kBytes the MPlayer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb}
mcset en {Specify the amount of space in kBytes the TV-Viewer logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb}
mcset en {Specify the amount of space in kBytes the Scheduler logfile can claim.
If this limit is reached, the file will be deleted and TV-Viewer
restarts the log cycle.
Minimum: 10kb Maximum: 100kb}

### ../data/config_analog.tcl ###

mcset en {Analog Settings}
mcset en {Video Device Node}
mcset en {Video Standard}
mcset en {Frequency Table}
mcset en {Force Standard}
mcset en {Video Input}
mcset en {Analog Stream Settings}
mcset en {Stream Bitrate}
mcset en {Video Bitrate}
mcset en {Video Peak Bitrate}
mcset en {Temporal Filter}
mcset en {Hardware volume level}
mcset en {Volume}
mcset en {Error}
mcset en {Missing requirements}
mcset en {Could not detect all necessary tools to run TV-Viewer}
mcset en {ivtv-tune}
mcset en {v4l2-ctl}
mcset en {Disabled}
mcset en {Analog settings are disabled,
while running a recording or timeshift}
mcset en {Choose the video device node.
See "dmesg | grep ivtv || pvrusb2 || cx18"}
mcset en {Constrain setting of the video standard.
Choose this if the driver selects the wrong one.}
mcset en {Define the way of color transmission.
Depends on where you are located.}
mcset en {The frequency table provides informations about the 
frequency band that should be used to search for tv stations.}
mcset en {Choose the video input}
mcset en {Check this if you want to alter the videobitrate}
mcset en {Define the videobitrate. Don't set the
videobitrate to a higher value than videobitrate (peak)!
Standard values are recommended.
Data in kb/sec.}
mcset en {Define the videobitrate (peak). Don't set the 
videobitrate (peak) to a lower value than videobitrate.
Standard values are recommended.
Data in kb/sec.}
mcset en {Check this if you want to change the temporal filter.
This option can help if you have a blurred picture.}
mcset en {Choose level of temporal filtering}
mcset en {Enable this option if you want to change the hardware volume level.}
mcset en {Specify the hardware volume level.
This applies to all stations and it is not recommended
to change this value.}

### ../data/config_audio.tcl ###

mcset en {Audio Settings}
mcset en {Audio output driver}
mcset en {Audio channels}
mcset en {Use software mixer}
mcset en {Remember volume level}
mcset en {Audio synchronization}
mcset en {Auto synchronization}
mcset en {Audio/Video sync correction}
mcset en {Choose an audio output driver, alsa is recommended.}
mcset en {Check this option to use the software mixer,
instead of the hardware mixer.}
mcset en {This option tells MPlayer to decode
audio to the chosen value}
mcset en {Remeber volume level}
mcset en {Gradually adjusts the A/V sync based on audio delay measurements}
mcset en {Audio/Video sync correction per frame in seconds}

### ../data/config_dvb.tcl ###

mcset en {DVB Settings}
mcset en {Expect more soon}

### ../data/config_general.tcl ###

mcset en {General Settings}
mcset en {Language}
mcset en {Autodetect}
mcset en {English (en)}
mcset en {German (de)}
mcset en {Start TV on startup}
mcset en {Enable}
mcset en {Newsreader}
mcset en {Time interval in days}
mcset en {Electronic Program Guide}
mcset en {Choose a program}
mcset en {Choose an EPG application}
mcset en {Choose your language.
You'll need to restart TV-Viewer for changes to take effect.}
mcset en {Autostart tv playback on program start}
mcset en {Activate Newsreader.
The Newsreader will check for news about TV-Viewer.}
mcset en {Choose time intervall in days for Newsreader (1-30)}
mcset en {Specify a program to retrieve the television program}

### ../data/config_interface.tcl ###

mcset en {Interface Settings}
mcset en {Theme}
mcset en {Enable Tooltips}
mcset en {Main Gui}
mcset en {Preferences}
mcset en {Station Editor}
mcset en {Record Wizard}
mcset en {Splash Screen}
mcset en {Show Splash Screen on initialization}
mcset en {Window Properties}
mcset en {Main window}
mcset en {Start in full-screen mode}
mcset en {Remember size and position}
mcset en {Floating control}
mcset en {Main toolbar}
mcset en {Station list}
mcset en {Control toolbar}
mcset en {System Tray}
mcset en {Show icon in system tray}
mcset en {Minimize to tray}
mcset en {Close to tray}
mcset en {Resize system tray icon}
mcset en {System tray icon size}
mcset en {On screen Display}
mcset en {Station}
mcset en {Windowed mode}
mcset en {Full-screen mode}
mcset en {Volume | Video input | Pan&Scan}
mcset en {Key Input}
mcset en {OSD Station list lirc}
mcset en {Choose your preferred theme}
mcset en {Check this if you want to see tooltips}
mcset en {Tooltips for the main Interface}
mcset en {Tooltips for the preferences}
mcset en {Tooltips for the Station Editor}
mcset en {Tooltips for the Color Management}
mcset en {Tooltips for the Record Wizard}
mcset en {Check this if you want to see the splash screen at the start of TV-Viewer}
mcset en {Start TV-Viewer in full-screen mode}
mcset en {Remember window size and position}
mcset en {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "top", of the screen.}
mcset en {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "left side", of the screen.}
mcset en {The floating control appears in fullscreen mode when the
mouse pointer is moved to the "bottom", of the screen.}
mcset en {Activate integration to system tray}
mcset en {Automatically resize system tray icon if the size of the tray 
itself is changed. Be careful with this option.}
mcset en {Choose the size for the system tray icon}
mcset en {OSD for station name in windowed mode}
mcset en {OSD for station name in full-screen mode}
mcset en {Change font, color and alignment}
mcset en {OSD for Volume; Pan&Scan; Video input in windowed mode}
mcset en {OSD for Volume; Pan&Scan; Video input in full-screen mode}
mcset en {OSD for change stations via numbers input in windowed mode}
mcset en {OSD for change stations via numbers input in full-screen mode}

### ../data/config_radio.tcl ###

mcset en {Radio Settings}

### ../data/config_record.tcl ###

mcset en {Record Settings}
mcset en {Standard folder}
mcset en {Default record duration}
mcset en {Allow station change while recording}
mcset en {Autostart scheduler}
mcset en {Hours format}
mcset en {24-hour clock}
mcset en {12-hour clock}
mcset en {Timeshift}
mcset en {Timeshift folder}
mcset en {Space to be left free}
mcset en {Choose a directory}
mcset en {Set the default directory for all recordings}
mcset en {Define the default duration for recordings (Hours)}
mcset en {Define the default duration for recordings (Minutes)}
mcset en {Define the default duration for recordings (Seconds)}
mcset en {Choose if you want to use a 24-hour clock or 12-hour clock to schedule recordings}
mcset en {Allow station change during recording}
mcset en {Autostart the scheduler.
This is necessary for scheduled recordings.}
mcset en {Choose path where Timeshift events will be cached}
mcset en {Define the minimum free disk space.
If free disk space is falling below this value
timeshift will automatically be stopped.
A value of 0 deactivates this feature.}

### ../data/config_video.tcl ###

mcset en {Video Settings}
mcset en {Video}
mcset en {Video output driver}
mcset en {Deinterlacing filter}
mcset en {Postprocessing level}
mcset en {Cache size (kB)}
mcset en {Threads for decoding}
mcset en {Direct Rendering}
mcset en {Double Buffering}
mcset en {Slice Mode}
mcset en {Framedrop}
mcset en {Hard Framedrop}
mcset en {Disable Screensaver}
mcset en {Use MPlayer}
mcset en {Use Heartbeat function}
mcset en {Select the video ouput driver.
xv should provide the best performance.}
mcset en {Select the deinterlace filter}
mcset en {Changes the level of postprocesseing.
A value of 0 deactivates postprocessing.}
mcset en {Specify how much memory (in kBytes) should be used for TV playback.
The lower this value is the faster you may switch between stations.
But a low value could cause other problems.
A value of 0 will deactivate cache use.}
mcset en {Sets the number of threads for decoding}
mcset en {If checked, enables direct rendering. This is not supported
for all video ouput drivers.}
mcset en {Double buffering fixes flicker by storing two frames in memory
and displaying one, while decoding another.}
mcset en {Enable / Disable drawing video by 16-pixel height slices/bands.
May help in better video playback.}
mcset en {Skip displaying some frames to maintain A/V sync}
mcset en {More intense frame dropping. May lead to image distortion.}
mcset en {Enable / Disable screensaver while playback}
mcset en {Use MPlayer to deactivate the screensaver}
mcset en {If MPlayer can't deactivate your screensaver, use this heartbeat hack}

### ../data/config_wizard.tcl ###

mcset en {General}
mcset en {Analog}
mcset en {DVB}
mcset en {Audio}
mcset en {Radio}
mcset en {Interface}
mcset en {Record}
mcset en {Apply your changes and exit preferences dialog}
mcset en {Load default values, for the corresponding section}
mcset en {Discard changes and close preferences dialog}

### ../data/create_icons.tcl ###


### ../data/diag_frontend.tcl ###

mcset en {Diagnostic Routine is checking your system.
Please wait...}
mcset en {Exit}
mcset en {Diagnostic Routine}
mcset en {Diagnostic Routine finished}
mcset en {Generated file:}
mcset en {Create a bug report on }
mcset en {and attach the generated file.}
mcset en {Diagnostic Routine crashed}

### ../data/diag_runtime.tcl ###


### ../data/difftime.tcl ###


### ../data/error_interp.tcl ###

mcset en {Skip further error messages}
mcset en {OK}
mcset en {File bug report}
mcset en {Save to disk}
mcset en {Error: %} {Error: %s}
mcset en {Select everything}
mcset en {Copy to clipboard}
mcset en {TV-Viewer crashed}
mcset en {Choose name and location}

### ../data/event_bind.tcl ###


### ../data/font_chooser.tcl ###

mcset en {Family:}
mcset en {Style:}
mcset en {Size:}
mcset en {Font color:}
mcset en {Display:}
mcset en {Preview:}
mcset en {top left}
mcset en {top}
mcset en {top right}
mcset en {left}
mcset en {center}
mcset en {right}
mcset en {bottom left}
mcset en {bottom}
mcset en {bottom right}
mcset en {Choose a font}
mcset en {Choose font style}
mcset en {Choose font size}
mcset en {Choose font color}
mcset en {Specify where the message box should be
displayed in the video frame}
mcset en {Choose font}
mcset en {Choose color}

### ../data/info_help.tcl ###

mcset en {TV-Viewer % Build %} {TV-Viewer %s Build %s}
mcset en {Info}
mcset en {A small and simple frontend to watch and record television}
mcset en {Homepage}
mcset en {Forum}
mcset en {IRC channel}
mcset en {© Copyright 2007 - 2010
Christian Rapp}
mcset en {Credits}
mcset en {License}
mcset en {Changelog}
mcset en {About TV-Viewer}

### ../data/key_sequences.tcl ###

mcset en {Available Key Sequences}
mcset en {Change shortcut}
mcset en {Key Sequences}
mcset en {Action}
mcset en {Key Sequence}
mcset en {Television}
mcset en {Window management}
mcset en {Recording / File playback}
mcset en {Do you really want to load default values for all key sequences?

This will happen instantly and can not be undone!}
mcset en {Set shortcuts to default values}
mcset en {Press the key combination you want to assign}
mcset en {Clear}
mcset en {Modify shortcut}
mcset en {It is not possible to edit this shortcut}
mcset en {Conflict detected with station by number "0-9"}
mcset en {Conflict detected with %} {Conflict detected with %s}

### ../data/launch_splash.tcl ###


### ../data/lirc_emitter.tcl ###


### ../data/log_viewer.tcl ###

mcset en {Choose output file}
mcset en {$ident(name($handler)) Log}
mcset en {Save logfile to disk}
mcset en {Send logfile by e-mail to the authors}
mcset en {Show/hide Debug messages}
mcset en {Show/hide Warning messages}
mcset en {Show/hide Error messages}

### ../data/main_command_line_options.tcl ###


### ../data/main_frontend.tcl ###

mcset en {Name}
mcset en {No}
mcset en {Navigation}
mcset en {View}
mcset en {Help}
mcset en {Welcome to TV-Viewer}
mcset en {TV-Viewer %} {TV-Viewer %s}
mcset en {TV-Viewer idle}

### ../data/main_menu.tcl ###

mcset en {EPG}
mcset en {TV}
mcset en {Prior Station}
mcset en {Next Station}
mcset en {Station jumper}
mcset en {Play}
mcset en {Pause}
mcset en {Stop}
mcset en {Rewind}
mcset en {-10 seconds}
mcset en {-1 minute}
mcset en {-10 minutes}
mcset en {File beginning}
mcset en {Forward}
mcset en {+10 seconds}
mcset en {+1 minute}
mcset en {+10 minutes}
mcset en {File end}
mcset en {Pan&Scan}
mcset en {Zoom +}
mcset en {Zoom -}
mcset en {Pan&Scan (16:9 / 4:3)}
mcset en {Move up}
mcset en {Move down}
mcset en {Move left}
mcset en {Move right}
mcset en {Center video}
mcset en {Size}
mcset en {Stay on top}
mcset en {Never}
mcset en {Always}
mcset en {While playback}
mcset en {Toolbars}
mcset en {Statusbar}
mcset en {Show status messages}
mcset en {Show playback time}
mcset en {Compact mode}
mcset en {Fullscreen}
mcset en {Volume +}
mcset en {Volume -}
mcset en {Mute}
mcset en {Delay +}
mcset en {Delay -}
mcset en {User Guide}
mcset en {MPlayer Log}
mcset en {Scheduler Log}
mcset en {TV-Viewer Log}

### ../data/main_newsreader.tcl ###


### ../data/main_picqual_stream.tcl ###


### ../data/monitor.tcl ###


### ../data/process_config.tcl ###


### ../data/process_config_wizard.tcl ###


### ../data/process_key_file.tcl ###

mcset en {TV-Viewer Menu}
mcset en {Navigation Menu}
mcset en {View Menu}
mcset en {Audio Menu}
mcset en {Help Menu}
mcset en {Exit TV-Viewer}
mcset en {Toggle TV playback}
mcset en {Station by number}
mcset en {Next video input}
mcset en {Previous video input}
mcset en {Increase Volume}
mcset en {Decrease Volume}
mcset en {Increase audio delay}
mcset en {Decrease audio delay}
mcset en {Toggle mute}
mcset en {Toggle Fullscreen}
mcset en {Increase Zoom}
mcset en {Decrease Zoom}
mcset en {Move video up}
mcset en {Move video down}
mcset en {Move video right}
mcset en {Move video left}
mcset en {Original window size}
mcset en {Double window size}
mcset en {Take a screenshot}
mcset en {Record wizard}
mcset en {Toggle pause}
mcset en {Start playback}
mcset en {Stop playback}

### ../data/process_station_file.tcl ###


### ../data/radio.tcl ###


### ../data/record_add_edit.tcl ###

mcset en {Record options}
mcset en {Time:}
mcset en {Date:}
mcset en {Duration:}
mcset en {Resolution:}
mcset en {Output file}
mcset en {Add a new recording}
mcset en {Edit recording}
mcset en {Choose station to record}
mcset en {Time when recording should start (Hour)}
mcset en {Time when recording should start (Minute)}
mcset en {Choose between before or after midday.
You may change hour format in the preferences (Record).}
mcset en {Choose date on which recording should occur}
mcset en {Duration for the recording (Hours)}
mcset en {Duration for the recording (Minutes)}
mcset en {Duration for the recording (Seconds)}
mcset en {Resolution (width) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.}
mcset en {Resolution (height) in which the recording
should be made. In most cases it doesn't
make sense to change this value. It is better
to convert the file afterwards.}
mcset en {Output file for recording. If you omit
this value TV-Viewer will determine a name
and store the file in the default record path.}
mcset en {Do you really want to delete the selected recording(s)?}
mcset en {Don't ask next time}
mcset en {Delete}
mcset en {Delete recordings}
mcset en {Choose date}
mcset en {Previous year}
mcset en {Previous month}
mcset en {Next month}
mcset en {Next year}

### ../data/record_external.tcl ###


### ../data/record_handler.tcl ###

mcset en {Time format incorrect (%-hour clock)!} {Time format incorrect (%s-hour clock)!}
mcset en {Time format incorrect (min)!}
mcset en {Chosen date is in the past!}
mcset en {Time is in the past!}
mcset en {Duration not specified correctly (hour)!}
mcset en {Duration not specified correctly (min)!}
mcset en {Duration not specified correctly (sec)!}
mcset en {Resolution format incorrect!}

### ../data/record_linker.tcl ###

mcset en {Currently recording %
Started at %} {Currently recording %s
Started at %s}
mcset en {Timeshift %} {Timeshift %s}
mcset en {Recording % - Ends at % %} {Recording %s - Ends at %s %s}
mcset en {% -- ends % at %} {%s -- ends %s at %s}
mcset en {Playing file: %} {Playing file: %s}
mcset en {Save timeshift video file
File size %} {Save timeshift video file
File size %s}

### ../data/record_wizard.tcl ###

mcset en {Running}
mcset en {Stop Scheduler}
mcset en {Stopped}
mcset en {Start Scheduler}
mcset en {New recording}
mcset en {Edit}
mcset en {Status}
mcset en {Scheduler status:}
mcset en {Currently recording:}
mcset en {Stop recording}
mcset en {Job ID}
mcset en {Time}
mcset en {Date}
mcset en {Duration}
mcset en {Resolution}
mcset en {Add a scheduled recording or
start recording immediately.}
mcset en {Delete selected recordings}
mcset en {Edit selected recording}
mcset en {Indicates whether the Scheduler is running or not}
mcset en {Provides informations about the current recording}
mcset en {If there is a running recording, click here to stop it}
mcset en {Exit Record Wizard}

### ../data/recorder.tcl ###


### ../data/release_version.tcl ###


### ../data/scheduler.tcl ###


### ../data/station_after_msg.tcl ###

mcset en {Now playing %} {Now playing %s}
mcset en {TV-Viewer playing - %} {TV-Viewer playing - %s}

### ../data/station_edit.tcl ###

mcset en {Station search}
mcset en {Add}
mcset en {Lock}
mcset en {Up}
mcset en {Down}
mcset en {Preview}
mcset en {Unlock}
mcset en {Frequency}
mcset en {Video input}
mcset en {External Tuner}
mcset en {Perform an automatic station search}
mcset en {Add a new television station}
mcset en {Delete selected television station}
mcset en {Lock or unlock selected station(s).
Locked stations will be displayed in red.}
mcset en {Edit selected station}
mcset en {Move selected item up}
mcset en {Move selected item down}
mcset en {Preview for selected tv station}
mcset en {Save station list and exit editor}
mcset en {Exit editor without any changes}

### ../data/station_item.tcl ###

mcset en {Do you really want to delete the selected station(s)?}
mcset en {Delete stations}
mcset en {Station:}
mcset en {Frequency:}
mcset en {Video input:}
mcset en {Add a new station}
mcset en {Edit Station / Frequency}
mcset en {Provide a name for the television station}
mcset en {Frequency for the station, E.g. 175.250}
mcset en {Video input for this station. 
Normally you want television input.}
mcset en {Use an external tuner}
mcset en {Specify a command for the external tuner.
You may use this substitutions:

%%F  Frequency
%%S  Station name
e.g. externalTune %%F %%S}
mcset en {Please specify name and frequency for each station}

### ../data/station_search.tcl ###

mcset en {Station search options}
mcset en {Append stations}
mcset en {Perform a full frequency sweep}
mcset en {Start}
mcset en {Append stations, or overwrite existing list}
mcset en {Perform a full frequency sweep, or check all channels
defined by the frequency table.
Note: A full frequency sweep may find many duplicates.}
mcset en {Choose the frequency increase factor for full frequency sweep.
Note: The lower this factor the more duplicates will be found and
the search takes more time.}
mcset en {Time in milliseconds to wait for the driver to respond.
The lower this value the faster the full frequency sweep will be.
Note: If this value is too small the driver won't have
enough time to report if there is a signal on the current frequency.
As a result not all stations will be found.}
mcset en {Start station search}
mcset en {Station search in progress.
Please wait...}
mcset en {Channel: %} {Channel: %s}
mcset en {Station search finished!}
mcset en {Frequency: %} {Frequency: %s}

### ../data/system_tray.tcl ###

mcset en {Hide}
mcset en {Restore}

### ../data/timeshift.tcl ###

mcset en {Copying timeshift video file.
Please wait...}
mcset en {Copying...       %%%} {Copying...       %s%%}
mcset en {Copying...       finished}

### ../data/tooltip.tcl ###

mcset en {Tune up}
mcset en {Tune down}
mcset en {Zap among the last two stations}
mcset en {Alter volume}
mcset en {Start/Stop timeshift}
mcset en {Start/Stop record}
mcset en {Execute the selected EPG application}
mcset en {Switch to radio mode}
mcset en {Start/Stop TV playback}
mcset en {Pause playback}
mcset en {Jump to the beginning}
mcset en {Seek back}
mcset en {Choose amount of seek back}
mcset en {Seek forward}
mcset en {Choose amount of seek forward}
mcset en {Jump to the end}
mcset en {Toggle fullscreen}
mcset en {Current position / File length}

### ../data/tv-viewer_main.tcl ###


### ../data/vid_audio.tcl ###


### ../data/vid_callback.tcl ###

mcset en {idle}

### ../data/vid_file_calc.tcl ###


### ../data/vid_osd.tcl ###


### ../data/vid_playback.tcl ###


### ../data/vid_pmhandler.tcl ###


### ../data/vid_seek.tcl ###


### ../data/vid_slist.tcl ###


### ../data/vid_wm.tcl ###

mcset en {Move x=%} {Move x=%s}
mcset en {Move y=%} {Move y=%s}
mcset en {Centering video}

### ../callib/callib.tcl ###

mcset en {Sun}
mcset en {Mon}
mcset en {Tue}
mcset en {Wed}
mcset en {Thu}
mcset en {Fri}
mcset en {Sat}

# Need to source msg files from fsdialog because this is an external project
source "$::option(root)/extensions/fsdialog/en.msg"
