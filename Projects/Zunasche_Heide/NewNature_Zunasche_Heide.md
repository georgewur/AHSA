---
title: New nature Zunasche heide
output: 
  html_document: 
    toc: true
    toc_depth: 3
    toc_float: true
    number_sections: true
    theme: united
    df_print: paged
editor_options: 
  markdown: 
    wrap: 72
---

```{=html}
<img src="img_newnature/media/image1.png"
style="width:6.3in;height:3.59306in"
alt="Side view Zunasche Heide" />
```

# Introduction:

The Zunasche Heide is a recently restored nature reserve located on the
eastern edge of the Sallandse Heuvelrug in the province of Overijssel.
Covering about 130 hectares, the area forms a transition zone between
the dry sandy ridges of the Sallandse Heuvelrug and the wetter lowlands
connected to the Regge valley.

A defining characteristic of the Zunasche Heide is its groundwater
seepage. Rainwater that infiltrates the Sallandse Heuvelrug reappears
here as kwelwater (upward seepage), creating naturally moist conditions.
Restoration measures have focused on reinforcing this hydrology by:

-   removing drainage channels,

-   removing part of the topsoil containing many nutrients

# Research Question:

Have the implemented hydrological measures been sufficient to restore
the original seepage flow and high groundwater levels?

# Approach:

Your current model does not contain these measures yet.

-   Create a new model based on your current version of the Wierden
    area.

-   Carry out a thorough analysis of the effects of different measures
    for optimal restoration of the Zunasche heide

# Required data:

-   **Zunasche heide.shp** (+accompanying files)

    -   contains a polygon of the Zunasche heide

-   **elevation_wierden_zh_40.tif**

    -   surface elevations of the region where the surface elevation of
        the Zunasche heide is lowered by 40 cm

-   **elevation_50.tif**

    -   Drain stages 50cm below surface of the region

# Suggested approach:

## General approach

FIRST: Save your base model and rename a copy of your model for this
project

Do the tutorial on "Steady State Regional to Local" [aquaveo
website](https://aquaveo.com/software/gms/learning-tutorials)

### Analysis:

-   Determine the depth of the groundwater table (i.e. "top of the cell"
    – "head first layer")

-   Determine the amount and distribution of upward seepage (i.e. Flow
    Lower Face first layer)

-   Determine the origin of the seepage (use MODPATH, see tutorial for
    details)

    ### Measures:

1.  Remove the upper soil layer to a depth of 40 cm, adjusting the top
    of layer 1 accordingly. Use the "elevation_wierden_zh_40.tif" for
    this.

2.  Rise the drain stage to the new surface elevation in the Zunasche
    heide

3.  Rise the drainage stage to 50cm below surface in the grasslands
    surrounding the Zunasche heide.

Analyse the effects on groundwater table and flow budgets of the
Zunasche Heide for each of the above-mentioned measures.

Determine which "grondwatertrap" is realised after each undertaken
measure.

## Workflow

A detailed workflow description is available: "Workflow analysis new
Nature Zunasche heide.html"

# Helpful

[Grondwatertrap -
Wikipedia](https://nl.wikipedia.org/wiki/Grondwatertrap)

| **GVG (cm –mv)** | **Grondwaterklasse** | **Ecologische betekenis / mogelijke ecotopen** |
|------------------------|------------------------|------------------------|
| 0 – 25 | Zeer nat | Moeras, trilveen, zeggevegetaties |
| 25 – 50 | Nat | Dotterbloemhooiland, vochtige graslanden |
| 50 – 80 | Vochtig | Kamgrasland, blauwgrasland, vochtige heide |
| 80 – 120 | Matig droog | Droge graslanden, droge heide, jonge bosopslag |
| \> 120 | Droog | Zandverstuiving, droge heide, droge bossen |

| **GVG (cm below surface)** | **Groundwater class** | **Ecological meaning / possible ecotopes** |
|------------------------|------------------------|------------------------|
| 0 – 25 | Very wet | Marsh, quaking bog, sedge communities |
| 25 – 50 | Wet | Cuckoo flower meadows, wet grasslands |
| 50 – 80 | Moist | Meadow fescue grassland, bluegrass meadow, moist heath |
| 80 – 120 | Moderately dry | Dry grasslands, dry heath, young woodland |
| \> 120 | Dry | Sand drifts, dry heath, dry forests |
