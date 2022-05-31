# lab_cali
This repository contains a few scripts produced by Zach Carpenter for his senior thesis on FOXSI detector calibraiton, during Spring 2022. These scripts were particularly tested for a FOXSI-3 CdTe detector, FEC07, though it should be potentially useful for other CdTe strip detectors as well. To run these scripts, you should add FOXSI calsoft collection to your IDL path. 

Here is a list of procedures/scripts:
* `calibration2022.pro`: loop through multiple data files for a selected source (this includes the information for selected data files and emission lines in this calibration process)
* `code_for_zach.pro`: procedure to obtain the energy-space and/or channel-space spectra for a selected data file (modified from Jessie's code). It searches and saves only the single-strip events.
* `eventdata_spectra.pro` and `eventdata_spectra_channel.pro`: (functions written by Athiray; used in code_for_zach.pro) Generate a data structure for all good events in energy space or channel space, which contains the all-strip energy/ADC information for each event. Also count the numbers of single-strip, double-strip, all, and CSA (double strip events summed) events.
* `makehist_from4file.pro`: combine spectra.
* `makeSAV.pro`: find peaks in the combined spectra and produce the calibration file `zackPeaks.sav`.
* `calspec2022.pro`: similar to `calspec.pro` in calsoft collection but uses cubic interpolation instead if spline.
