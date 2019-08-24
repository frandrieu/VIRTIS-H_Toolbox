; docformat = 'rst'
;+
; This is an example program to demontrate how to create a density scatter plot
; with Coyote Graphics routines.
;
; :Categories:
;    Graphics
;
; :Examples:
;    Save the program as "density_plot.pro" and run it like this::
;       IDL> .RUN density_plot
;
; :Author:
;    FANNING SOFTWARE CONSULTING::
;       David W. Fanning
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: david@idlcoyote.com
;       Coyote's Guide to IDL Programming: http://www.idlcoyote.com
;
; :History:
;     Change History::
;        Written, 23 January 2013 by David W. Fanning.
;
; :Copyright:
;     Copyright (c) 2013, Fanning Software Consulting, Inc.
;-
PRO Density_Plot

  ; Set up variables for the plot. Normally, these values would be
  ; passed into the program as positional and keyword parameters.
  x = cgScaleVector(Randomn(-3L, 100000)*2, -10, 10)
  y = cgScaleVector(Randomn(-5L, 100000)*5, 0, 100)
  xrange = [Min(x), Max(x)]
  yrange = [Min(y), Max(y)]
  xbinsize = 0.25
  ybinsize = 3.00

  ; Open a display window.
  cgDisplay

  ; Create the density plot by binning the data into a 2D histogram.
  density = Hist_2D(x, y, Min1=xrange[0], Max1=xrange[1], Bin1=xbinsize, $
    Min2=yrange[0], Max2=yrange[1], Bin2=ybinsize)

  maxDensity = Ceil(Max(density)/1e2) * 1e2
  scaledDensity = BytScl(density, Min=0, Max=maxDensity)

  ; Load the color table for the display. All zero values will be gray.
  cgLoadCT, 33
  TVLCT, cgColor('gray', /Triple), 0
  TVLCT, r, g, b, /Get
  palette = [ [r], [g], [b] ]

  ; Display the density plot.
  cgImage, scaledDensity, XRange=xrange, YRange=yrange, /Axes, Palette=palette, $
    XTitle='Concentration of X', YTitle='Concentration of Y', $
    Position=[0.125, 0.125, 0.9, 0.8]

  thick = (!D.Name EQ 'PS') ? 6 : 2
  cgContour, density, LEVELS=maxDensity*[0.25, 0.5, 0.75], /OnImage, $
    C_Colors=['Tan','Tan', 'Brown'], C_Annotation=['Low', 'Avg', 'High'], $
    C_Thick=thick, C_CharThick=thick

  ; Display a color bar.
  cgColorbar, Position=[0.125, 0.875, 0.9, 0.925], Title='Density', $
    Range=[0, maxDensity], NColors=254, Bottom=1, OOB_Low='gray', $
    TLocation='Top'
END ;*****************************************************************

; This main program shows how to call the program and produce
; various types of output.

; Display the plot in a graphics window.
Density_Plot

; Display the plot in a resizeable graphics window.
cgWindow, 'Density_Plot', Background='White', $
  WTitle='Density Plot in a Resizeable Graphics Window'

; Create a PostScript file.
cgPS_Open, 'density_plot.ps'
Density_Plot
cgPS_Close

; Create a PNG file with a width of 600 pixels.
cgPS2Raster, 'density_plot.ps', /PNG, Width=600

END