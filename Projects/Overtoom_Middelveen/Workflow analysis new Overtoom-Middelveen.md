---
title: "Workflow analysis new nature: Overtoom-Middelveen"
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

# Workflow analysis new Nature: Overtoom-Middelveen

This document is meant to support the setup and execution of various
hydrological measures in and around Overtoom–Middelveen. The planned
measures focus on lowering the surface level to remove nutrients left
behind from former grasslands and to bring the groundwater level closer
to the surface. After that, steps will be taken to reduce drainage
intensity in the area. Finally, the drainage level of the surrounding
grasslands will be raised to 50 cm below ground level.

The measures are explained step by step, including instructions for GMS.

## Create a new local model

1.  Do the tutorial Steady State Regional to Local:![Regional to local
    GMS tutorial](images_workflow/image1.png)

2.  Convert the layer data of the regional model to scatter sets (as in
    the tutorial)

3.  Load the Overtoom-Middelveen shape file ("Overtoom-Middelveen.shp").

4.  Create a new coverage with "Specified heads CHD" and "Use to define
    model boundary (active area) checked

    a.  Digitize isohypses and flow lines(perpendicular to the
        isohypses) of about 1000 m away from the Overtoom-Middelveen
        (ZH)

    b.  Build the polygon being the domain of the new local model

5.  Create a new grid (50x50 m) with 5 layers

6.  Transfer the scatter data to the appropriate layers

## Convert 3D grid data to 2D grid

Creating a 2D grid based on the 3D grid can be very convenient to
manipulate several sources of data and assign them back to the model.

Examples are:

-   Transfering raster data to 2D grid

-   Assigning 2D grid data to the model

-   Calculating different (intermediate) results (groundwater height
    w.r.t. surface elevation)

1.  Select for example "Top" from the MODFLOW data in the data explorer

2.  Select the 3D grid data of the current model

3.  Right click and select Convert to \>2D grid![A screenshot of a
    computer AI-generated content may be
    incorrect.](images_workflow/image2.png){width="3.6703193350831147in"
    height="2.666599956255468in"}

4.  Agree with the "Default Z value" (will not be used)

5.  The 2D grid\|Default appears in the data explorer having the same
    size (in X and Y) as the original 3D grid

## Determine the groundwater depth and flow budget {#results}

The depth of the groundwater table w.r.t. the surface elevation is an
important abiotic condition for flora and therefore also fauna. In this
case the Overtoom-Middelveen should become shallow wetlands.

Next to the groundwater depth, the upward seepage from deeper layers is
also important condition for the nature area. It's serves as a water
source with a specific chemical signature and is responsible for wet
conditions.

Since you need to determine the groundwater depth for several
situations, it is important to name them differently so that you can
easily identify them.

### Groundwater depth

1.  Select the calculated Head (in the explorer window "3D Grid
    Data"\|Head (MODFLOW)

2.  Main menu\|Grid\|"3D data -\> 2D data"

3.  Select from the pull-down menu "Value from k layer"

![Data selection for a 2D
grid](images_workflow/image3.png){width="3.3329166666666667in"}

4.  Select the upper surface elevations in the data explorer:

![Select to Top
elevation](images_workflow/image4.png){width="1.7203652668416447in"}

5.  Repeat the steps 2,3,4 for the Top of the upper layer

6.  Select the data calculator

    a.  Subtract the surface elevation (Lay1_Top) from the head of the
        upper layer (Lay1_Head)

### Flow budget

The flow budget of the whole Overtoom-Middelveen can simply be
determined by selecting all Overtoom-Middelveen cells

1.  Make the Overtoom-Middelveen coverage active and select the
    Overtoom-Middelveen polygon

2.  Right click select "Select Intersecting Objects"

3.  Choose for "3D grid cells" resulting in selected Overtoom-Middelveen
    nodes/cells

4.  Run the "Flow Budget"

With the Flow Budget total water budget terms are shown. To analyse the
distribution of for example the upward seepage.

The upward seepage can easily be shown; right click on the "CCF" (just
below the "Head") and select for "CCF -\> Datasets". Select the upper
layer and the "FLOW LOWER FACE" term contains the upward seepage in
m^3^/d for each node.

## Removing top soil from Overtoom-Middelveen

Removing the topsoil on the new nature serves several purposes. Removing
40 cm of the top soil automatically removes all redundant nutrients (N,
P, K), allowing shallow wetlandds and other vegetation types to develop
without getting invaded by grasses (again). Seeds in the remaining
topsoil, deposited centuries ago, can now germinate. In removing the top
soil, the groundwater table automatically will rise w.r.t. the new
surface elevation.

For this purpose, the altered surface elevations of the
Overtoom-Middelveen is already prepared.

-   Load the raster "elevation_40.tif" into GMS

-   Right-click on these elevations and select "Interpolate to -\> 2D
    grid"

-   Select 3Dgrid-\>Modlfow-\>Global-\>Top and double click

-   With this, the Top elevations of the layers appear in a
    grid/spreadsheet fashion

-   Select "2D Dataset -\> Layer" and replace the current top elevations
    (of the first layer, since this is the surface elevation)![assing
    raster elevations to the top layer](images_workflow/image40.png)

-   Save the model with an appropriate name

## Rerun the model current

-   Rerun the current model and determine the groundwater table with
    respect to the surface elevation.

-   Also calculate the flow budget (Main menu: Modflow\|Flow budget) and
    determine the upward seepage.

-   For futher details see section "Determine the groundwater depth and
    flow budget"

## Adjust the land use of Overtoom-Middelveen

Next to removing the upper 40cm of the surface in the
Overtoom-Middelveen, its land use needs to be replaced as well.

Although evapotranspiration of the vegetation in the nature area will be
somewhat different than grasslands, the main adjustment will be the
drainage system of the nature area. Local drains/ditches will be partly
removed. Here, we used diffuse drainage systems, not assigning actual
drain locations and depths to the model. To mimic the removal of the
drains, the drain stage of grasslands (80 cm below surface) will be set
to the new surface elevation, which coincides with the raster files
"elevation_40.tif". The diffuse drainage resistance will also be
replaced with a resistance of 50 days, mimicking resistance to
predominantly vertical flow.

-   Create a new drain coverage in GMS for only the Overtoom-Middelveen

-   Assign the "elevation_40.tif" raster to this coverage

-   Map all drainage related coverages to the model

-   Check (e.g. by looking at the drain symbols, a green dot by default)
    if all drain coverages are mapped to the model.

-   Save the model with a new appropriate name

## Rerun the model and determine the groundwater depth and flow budget

-   Rerun the current model and determine the groundwater table with
    respect to the surface elevation.

-   Also calculate the flow budget (Main menu: Modflow\|Flow budget) and
    determine the upward seepage.

-   For futher details see the pervious section "Determine the
    groundwater depth and flow budget" on this .

## Adjust the drain stage for the surrounding area

In section "Adjust the land use of Overtoom-Middelveen" the drain stage
rose from 80 cm to the current surface elevation. This results in a 40cm
higher drain stage which makes it harder in the Overtoom-Middelveen to
get discharged through ditches/drains.

As a consequence, water will travel to the surrounding area to get
discharged into the drainage system with a deeper/lower drain stage.

To partially circumvent this, the grasslands in the surrounding area of
the Overtoom-Middelveen also need to be adjusted from 80 cm to 50 cm
below surface.

-   Replace the "elevation_80.tif" raster with "elevation_50.tif" in the
    "grassland" drainage coverage

-   Save this model (with a new name)

## Rerun the model and determine the groundwater depth and flow budget

-   Rerun the current model and determine the groundwater table with
    respect to the surface elevation.

-   Also calculate the flow budget (Main menu: Modflow\|Flow budget) and
    determine the upward seepage.

-   For futher details see section "Determine the groundwater depth and
    flow budget" on this .

## Analyse the effects of the different modeling stages and draw some conclusions

During these different modeling stages one can investigate the impact of
different measures to turn grass lands into the original habitat partly
centuries ago but most dominantly reclamed in the 1930"ies . Originally
Overtoom-Middelveen was a peat bog (Dutch: Hoogveen) till the 13th
centurie

-   Compare the groundwater tables between the different stages
    (sections 3,5,7,9)

-   How does the last stage "fit" the Gt's -\> expected abiotic
    conditions for nature

-   Compare upward seepage for the different stages, analyse the
    decrease/increase of upward seepage

a long time ago.. Even in the 12th and 13th century land reclamation
started turning Overtoom-Middelveen (and Overtoom-Middelveen) into
agricultural land
