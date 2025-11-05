---
editor_options: 
  markdown: 
    wrap: 72
---

# Workflow analysis new Nature: Zunasche Heide (ZH)

1.  Create a new local model

2.  Convert 3D grid data to 2D grid

3.  Determine the current groundwater depth w.r.t. surface elevation

4.  Remove the 40cm topsoil from Zunasche heide (ZH)

5.  Rerun the model and determine the groundwater depth and flow budget

6.  Adjust the land use for ZH

7.  Rerun the model and determine the groundwater depth and flow budget

8.  Adjust the drain stage for the surrounding area

9.  Rerun the model and determine the groundwater depth and flow budget

10. Analyse the effects of the different modeling stages and draw some
    conclusions

## 1. Create a new local model

1.  Do the tutorial Steady State Regional to Local:![Regional to local
    GMS tutorial](images/image1.png)

2.  Convert the layer data of the regional model to scatter sets (as in
    the tutorial)

3.  Load the Zunasche Heide shape file ("Zunasche heide.shp").

4.  Create a new coverage with "Specified heads CHD" and "Use to define
    model boundary (active area) checked

    a.  Digitize two isohypses of about 1000 m away from the Zunasche
        heide (ZH)

    b.  Digitize two flow lines perpendicular to the isohypses

    c.  Build the polygon being the domain of the new local model

5.  Create a new grid (50x50 m) with 5 layers

6.  Transfer the scatter data to the appropriate layers

## Convert 3D grid data to 2D grid

Creating a 2D grid based on the 3D grid can be very convenient to
manipulate several sources of data and assign them back to the model.

Examples are

-   Transfering raster data to 2D grid

-   Assigning 2D grid data to the model (e.g. adjusted surface elevation

-   Calculating different (intermediate) results (groundwater height
    w.r.t. surface elevation

1.  Select for example "Top" from the MODFLOW data in the data explorer

2.  Select the 3D grid data of the current model

3.  Right click and select Convert to \>\|2D grid![A screenshot of a
    computer AI-generated content may be
    incorrect.](media=./images/media/image2.png){width="3.6703193350831147in"
    height="2.666599956255468in"}

4.  Agree with the "Default Z value" (will not be used)

5.  The 2D grid\|Default appears in the data explorer having the same
    size as the original 3D grid

## 3., 5., 9. Determine the groundwater depth and flow budget

The depth of the groundwater table w.r.t. is an important abiotic
condition for flora and therefore also fauna. In this case the Zunasche
heide should become a heather[^1] field where hopefully "korhoenders"
(black grouse) will reside again.

[^1]: In Dutch "heide" means heather

Next to the groundwater depth, the upward seepage from deeper layers is
also important condition for the nature area. It's serves as a water
source with a specific chemical signature.

Since you need to determine the groundwater depth for several
situations, it is important to name them differently so that you can
easily identify them.

### Groundwater depth

1.  Select the Head

2.  Main menu\|Grid\|"3D data -\> 2D data"

3.  Select from the pull down menu "Value from k layer"

![A screenshot of a computer AI-generated content may be
incorrect.](media=./images/media/image3.png){width="3.3329166666666667in"
height="1.7914424759405074in"}

4.  Select the upper surface elevations in the data explorer:

![A screenshot of a computer AI-generated content may be
incorrect.](media=./images/media/image4.png){width="1.7203652668416447in"
height="1.0997769028871391in"}

5.  Repeat the steps 2,3,4 for the Top of the upper layer

6.  Select the data calculator

    a.  Subtract the surface elevation (Lay1_Top) from the head of the
        upper layer (Lay1_Head)

### Flow budget

The flow budget of the whole ZH can simply be determined by selecting
all ZH cells

1.  Make the ZH coverage active and select the ZH polygon

2.  Right click select "Select Intersecting Objects"

3.  Choose for "3D grid cells" resulting in selected ZH nodes/cells

4.  Run the "Flow Budget"

With the Flow Budget total water budget terms are shown. To analyse the
distribution of for example the upward seepage.

The upward seepage can easily be shown; right click on the "CCF" (just
below the "Head") and select for "CCF -\> Datasets". Select the upper
layer and the "FLOW LOWER FACE" term contains the upward seepage in
m^3^/d for each node.

## Removing top soil from ZH

Removing the top soil on the new nature serves several purposes.
Removing 40 cm of the top soil automatically removes all redundant
nutrients (N, P, K), allowing heather and other vegetation types to
develop without getting invaded by grasses (again). Seeds in the
remaining top soil, deposited centuries ago, can now germinate. In
removing the top soil, the groundwater table automatically will rise
w.r.t. the new surface elevation.

For this purpose the altered surface elevations of the Zunasche heide is
already prepaired.

-   Load the raster "elevation_wierden_zh_40.tif" into GMS

-   Right click on these elevations and selectMap these elevations to
    the modflow model
