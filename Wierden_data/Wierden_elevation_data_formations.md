---
title: "Hydrogeological formations in the Wierden area"
editor_options: 
  markdown: 
    wrap: 72
output: 
  html_document: 
    toc: true
    toc_depth: 3
    toc_float: true
    number_sections: true
    theme: united
    df_print: paged
---

# Introduction

To set up the modflow models in the Wierden area, different types of
data are required:

1.  Elevations of the different formations

2.  Hydraulic properties of the different formations

3.  Water management of the area

4.  Open water for discharging

    -   river dimensions (width, side slopes, length profiles(verhang))

    -   river bed resistance

    -   weir levels

    -   Discharge volumes of water

5.  Ditches and (tile)drains for draining agricultural and urban area's

6.  Recharge stationary and transient

7.  Boundary conditions at the perimeter of the models domain

Steps 3 until 7 will be described in other documents.

Here the focus will be on the elevation of the different formation
layers and the hydraulic properties (HK, HV or ratio) of these
(combined) formations.

These data are based on LHM (Landelijk Hydrologisch Model) version 4.3.
maintained at [web page LHM
data](https://nhi.nu/modellen/lhm/ "url LHM") .

## Elevations of the different formations

With the help of [sub soil models region
Wierden](https://www.broloket.nl/ondergrondmodellen/kaart "BRO models")
the following cross section was created:

![cross section Wierden area](images/X-section_Y483026.png)

As shown in 'grey' the ice pushed ridge is described being a "gestuwde
afzettingen, complexe eenheid". No hydraulic conductivity or resistance
is assigned to this formation.

To get proper elevations from LHM data is a bit tricky!

There are 8 layers in the LHM model .

The layers are defined with top_elevations and bottom_elevations.

[Top elevations are:]{.underline}

"top_impermeable_layer1",

"top_impermeable_layer2",

"top_impermeable_layer3"

till "top_impermeable_layer8"

[Bottom elevations are:]{.underline}

"base_impermeable_layer1",

"base_impermeable_layer2",

"base_impermeable_layer3",

till "base_impermeable_layer8"

One would expect that the top of impermeable layer 2 coincides with the
bottom of impermeable layer 1. This is in good agreement most of the
time. Some deviations were noticed. Top 3 vs base 2 do differ in the
middle somewhat about 3 to 5 m over a short range.

Most striking is the difference between "base_impermeable_layer8" and
"geohydrological base". Not the clip below:

![base vs bot last (8) layer](images/hydrogeol_base_vs_bot_layer8.png)

I have no idea why this is!

Also tried to overlay the cross-section of the elevations (Qgis) with
the formations from REGIS 2.3, see the clip below

![](images/profiles_formations_hardly_matching.png)

Now considering another approach.

### Complex gestuwde formatie becomes formation with low K's

-   Through the LHM data site; <https://data.nhi.nu/bekijk> downloaded
    the following sets:\
    horizontale_anisotropie_top.nc

-   horizontale_anisotropie_bot.nc

With this the ice pushed ridges can be simulated with relative low
conductivities mimicken the anisotropical nature of the tilted
formations. How derive a proper K is not that easy since the formations
are not only clayey deposits.

With knowing the position and depth of the ridges we can now determine
three formations to model within modflow using the following elevation
data sets:

1.  surface elevations -\> "Lagenmodel_LHM43-top_impermeable_layer_1"

2.  top_ridges -\> "horizontale_anisotropie_top"

3.  bot_ridges -\> "horizontale_anisotropie_bot"

4.  hydrogeological base -\> "Lagenmodel_LHM43_base_impermeable_layer_8

The elevation of the hydrogeological base nicely aligns with the top of
the Breda formations which are clay deposits.

See the following clip:

![](images/location_depth_ridges.png)

As shown in the above clip, the ridges are only very locally present.

### Building model layers

**MODFLOW-NWT, 2005**

This means that for models based on modflow nwt or 2005 that model
layers are continous in the whole domain. Basically in the domain all
model layers will be present.

Now still two options for layers where the ridges are not present;

1.  thin layers, pinching out till the perimeter

2.  evenly distributed thicknesses of the layers (standard option used
    till now)

option 1 can give problems being too thin but also issues can arise
dry-wet issues. For example too thin layers where RCH need to be
extracted can result in problems drying out all cells at that point.

option 2 is most rubost but miss partly ridges when the center of a
model not coincides with the ridge.

#### Creating solids

To create new solids for the creation of mf-nwt models the following
recipe could work

Required are all elevations; surface, top-ridge, bot-ridge,
geohydrological-base

1.  Create a TIN

    1.  new coverage, large polygon extending the surface_elevation.tif
        but keep in within avoiding interpolation issues later on

    2.  set vertices on the polygon arc to 100 m

    3.  create the TIN by following the steps in the clip: ![creating
        TIN for layer elevations](images/create_TIN_4_elevations.png)

    4.  Map the elevations (i.e. the raster files ) to the individual
        TINs

    5.  Make sure that the numbering of the TIN's (mandatory) counts
        from bottom to top. So geohydrological base receives TIN number
        1:![TIN numbering from bottom to
        top](images/TIN_numbering4Solids.png){width="200"}

    6.  The next TIN is not the bottom of the ice pushed ridges which is
        only partly present. TIN nr. 2. The distribution can be seen in
        "bot_ridges.tif"):![top and locations of ice pushed
        ridges](images/distribution_ridges_top_elevations.png)

    7.  The top of the ice pushed ridges ("top_ridges.tif")

    8.  The upper TIN is nr. 4 and is based on "surface_elevation.tif"

    9.  Create solids from these TIN (horizons):![TIN_horizons to
        Solids](images/TIN_horizons2Solids.png)

    10. Define the top and bottom TIN elevation for the solids:![define
        the top and bottom TIN for building the
        solids](images/top_bot_solids.png)

    11. The following choices were used:![options used for building the
        Solids](images/options4buildingSolids.png) Natural neigbor with
        constant nodal function to avoid strange elevations. "Intersect
        horizon surfaces" according to the Help; "Allows the solids to
        intersect with horizon surfaces". In this case hardly noticeable
        differences.

    12. The solids 3 in this case should appear:![cross sections of
        solids based on top bot
        ridges](images/cross_sections_solids_basedon_local_top-bot_ridges.png)

    13. As an alternative I tried to use the "top_imp_layer_5.tif" which
        coincides with the bottom of the ice pushed ridges. With this
        the idea is that one distinguishes the upper 4 and lower 4
        layers of LHM4.3. This resulted in the following solids:![Solids
        based on the top of impermeable layer 5 distinguishing the upper
        from the lower aquifer](images/solids_based_topimplyer5.png)

        Now the ice-pushed ridge formation is extended way too much.

        **MODFLOW 6**

Since modflow 6 is based on UGRIDs, it is not required to have model
layers continuous in the model domain.

## Hydraulic properties of the different formations

The Holterberg is a dominant (hydro)geological feature in the Wierden
area. This ice pushed ridge and other hillish-elevated areas, originates
from the "Saalien" iceage about 150.000-200.000 yeas ago.

During that time land ice coming from Scandinavia pushed forward the
formations which were deposited earlier. These mainly contain sandy,
gravely and clayey deposits. As a consequence these formation were
pushed forward and sideways resulting tilted formations. The tilted
clayey formation within the ice puschd ridge result in **anisotropical**
properties, which means that groundwater flow will encounter different
hydraulic conductivities based on the direction of the formation of
these ice pusched ridges.

As a consequence the Holterberg and south-eastern ridges from Holterberg
need anisotropical parameters for the model layers where they reside.

For the usual set up of a groundwater model in the Wierden we will
simply the effect of anisotropical features to a simple resistance.
