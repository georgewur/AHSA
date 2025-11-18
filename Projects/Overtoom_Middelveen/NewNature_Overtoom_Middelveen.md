---
title: New Nature Overtoom Middelveen
output: 
  html_document: 
    toc: true
    toc_depth: 3
    toc_float: false
    number_sections: true
    theme: united
    df_print: paged
editor_options: 
  markdown: 
    wrap: 72
---

# New Nature: Overtoom Middelveen

![Overtoom-Middelveen through the
years](Compilation_Overtoom_Middelveen.png)

## Introduction

------------------------------------------------------------------------

**Location and Background**

Overtoom--Middelveen is a newly developed nature reserve located between
Rijssen and Holten in the province of Overijssel. The area covers
approximately 150 hectares and connects surrounding nature areas such as
De Borkeld, Elsenerveen, and the Sallandse Heuvelrug.

The area was formerly used for agriculture---mostly maize fields and
pastures---but has recently been transformed into a rich wetland
landscape.

------------------------------------------------------------------------

**Unique Ecological Features**

One of the area's most striking features is its groundwater seepage
(*kwelwater*), which naturally brings water to the surface and creates
shallow wetlands, also called "plas-dras" zones.

These moist conditions support a range of rare and protected plant
species, including orchids, marsh gentians, grass-of-Parnassus, and saw
sedge. Because of its ecological richness, Overtoom--Middelveen has been
designated a core area for nature conservation.

------------------------------------------------------------------------

**Birdlife and Wildlife**

More than 140 bird species have been observed in Overtoom--Middelveen,
making it an important area for ornithology.

Key breeding and migratory species include lapwing, black-tailed godwit,
redshank, and oystercatcher. In spring, birds such as curlew,
bluethroat, reed bunting, and great reed warbler return from their
winter habitats. Rarer birds like the corncrake and little crake are
also seen regularly.

The area also supports mammals (such as hares and partridges),
amphibians, dragonflies, butterflies, and a variety of insects.

------------------------------------------------------------------------

## Objective

Restoring nature reserves through hydrological measures

### Research Questions

Have the implemented hydrological measures been sufficient to restore
the original seepage flow and high groundwater levels?

1.  What is the effect of lowering the surface elevation of the new
    nature by 40 cm on upward seepage and groundwater table

2.  What is the effect of partly removing the drainage system in the
    area on upward seepage and groundwater table

3.  What is the effect of raising the drainage stage in the direct
    surroundings of the new nature on upward seepage and groundwater
    table

### Approach (general)

The current state of your model does not contain the hydrological
adjustments to preserve/improve the upward seepage coming from the
Sallandse Heuvelrug

-   Create seperate models for the numbered research questions.

-   Calculate the depth of the groundwater table w.r.t. surface
    elevation of the Overtoom-Middelveen area.

-   Determine the drainage discharge and the upward seepage towards
    Overtoom-Middelveen

-   Use MODPATH to determine the origin of the upward seepage

# Required data:

-   **Overtoom_Middelveen.shp** (+accompanying files)

    -   contains a polygon of the Zunasche heide

-   **elevation_wierden_OM_40.tif**

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
    of layer 1 accordingly. Use the "elevation_wierden_OM_40.tif" for
    this.

2.  Raise the drain stage to the new surface elevation in the Zunasche
    heide

3.  Raise the drainage stage to 50cm below surface in the grasslands
    surrounding the Zunasche heide.

4.  Determine which "grondwatertrap" (see Helpful) is realised after
    each undertaken measure.

## Workflow

A detailed workflow description is available: "Workflow analysis new
Nature Overtoom-Middelveen.html"

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
