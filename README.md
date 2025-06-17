# A Network-Based Examination of Detention Facility Movements


## Summary
This study applies network analysis methodologies to the examination of detainee movements within the U.S. immigration detention system from mid-November 2023 to mid-February 2025. Utilizing data obtained from the [Deportation Data Project](https://deportationdata.org/data/ice.html), we characterize the patterns and pathways of detainee transfers across [617 detention facilities](/detention_facilities.csv). The analysis distinguishes between general movements between facilities and explicitly classified transfers. The purpose of this research is to answer: 

- What are the common pathways of detainee movement?
- Which facilities/states function as primary hubs for intake, transfer, or deportation?

## Purpose
The immigration detention system comprises a complex network of facilities that hold individuals under custody. Understanding the movement dynamics between these facilities is critical for holding them accountable - particularly as many are forced into a ["Blackhole"](https://www.aclu.org/documents/inside-the-black-hole) of detention. This research leverages network analysis techniques to explore detainee "movements", defined as changes in facility bookings within a single detention episode, and to identify systemic patterns and facility roles.

## File Structure
- **`data_cleaning.R`**: This script cleans the data downloaded from the Deportation Data Project.
- **`network_scripts/`**: This folder holds `facility_analysis.R` and `state_analysis.R`, both of which conduct network/path analyses of their respective locations.
- **`location_scripts/`**: This folder holds `location_analysis.R` and `location_scraper.R`. In `location_analysis.R` we use a number of look-up tables creating by the Vera Institute, Marshall Project, TRAC, and others to create a condensed `code_lookup.csv`.
- **`location_input/`**: This folder holds the data used in `location_analysis.R` in three folders `monthly`, `yearly`, and `lookup`. 
- **`output/`**: This folder holds the output of the scripts.

## Data & Methods

### Cleaning
To construct the immigration detention network, we first downloaded detention data spanning mid-November 2023 to mid-February 2025 from the [Deportation Data Project](https://deportationdata.org/data/ice.html). The full cleaning process is documented in `analysis.R`. Key steps include:  
1. Removing invalid unique identifiers.  
2. Creating a combined stay/unique identifier variable.  
3. Excluding instances with identical book-in times within a single stay.  
4. Counting the order of facility entries per stay.  
5. Creating a `moved` variable to flag whether an individual moved to another facility during their stay.  
6. Categorizing movement types (e.g., transfer, removal).  
7. Identifying destinations for each movement and excluding records without a defined movement type.

### Networks  
We constructed two distinct networks: a broad [`movement`](/movement_adjacency_matrix.csv) network and a more specific [`transfer`](/transfer_adjacency_matrix.csv) network (weighted directed graphs). The movement network captures any relocation between facilities during a single stay, regardless of reason. The transfer network includes only those moves explicitly classified as transfers. Movements are defined by a sequence of detention book-in dates within one stay—for example, if an individual was initially booked into Alexandria Staging Facility and subsequently booked into Pine Prairie Detention Facility during the same stay, this counts as a movement. If the `Detention Release Reason` for that move was "Transferred," it is classified as a transfer.  Using facility pairs (origin and destination), we created two directed graphs representing facility-to-facility transfers. Each graph includes all 617 detention facilities as nodes, with edges weighted by the frequency of transfers between them. 

We also similarly created two distinct networks: [`movement`](/movement_adjacency_matrix.csv) and [`transfer`](/transfer_adjacency_matrix.csv), by state, rather than detention facility. We did so by mapping each detention facility to its corresponding state.

### Paths  
Beyond aggregate networks, we mapped the detention pathway of each individual stay. For each stay, we generated a graph tracing their sequence of detention facilities—from the initial facility, through intermediate stops, to the final facility. We created a similar analysis mapping the state pathways.

## Dataset Overview
After cleaning, our dataset includes 368,668 individuals and 381,907 unique stays. *Note that one person may have multiple unique stays.* On average, each stay involves 2.00 detention events (book-ins). Detention release reasons vary across the 763,286 detention events. The most common reason is `Transferred` (386,645 occurrences), followed by `Removed` (193,947), and then `NA` (42,418), which typically indicates ongoing cases. Most detention release reasons that result in "movements" are `Transferred` (375,499), followed by `Processing Disposition Changed Locally` (5,186), which often includes movements from a facility to itself, and `U.S. Marshals or other agency (explain in Detention Comments)` (533). However, there are cases where a detention release reason is marked as `Transferred`, but no actual movement or transfer occurs. Specifically, 11,146 detentions were recorded as transfers but never resulted in a transfer, possibly because those cases are still ongoing.

## Facility Results

### Network
Analyzing the movement network, we find that the detention facilities with the highest in-degrees are Florence Staging Facility (20,998), Port Isabel Service Processing Center (19,877), and Adams County Correctional Center (16,639). This indicates that these facilities receive the greatest number of incoming detainees. A significant factor contributing to these high values is that many facilities transfer detainees to themselves. After removing these self-transfers (loops) from the analysis, the top facilities by in-degree are Florence Staging Facility (18,884), Adams County Correctional Center (16,565), and Otay Mesa Detention Center (15,436).

Regarding out-degree (also excluding loops), the detention facilities with the highest values are Alexandria Staging Facility (39,886), Pine Prairie ICE Processing Center (18,251), and Florida Service Processing Center (14,796), meaning these locations move the most detainees to other facilities.

Finally, when considering total degree—the sum of in-degree and out-degree—the leading facilities are Alexandria Staging Facility (48,867), Florence Staging Facility (30,080), and Pine Prairie ICE Processing Center (29,083). We observe very similar patterns in the transfer network. Below is a table showing the top 10 detention facilities ranked by degree measures.

|Facility|Transfer In-Degree|Transfer Out-Degree|Transfer Total-Degree|Movement In-Degree|Movement Out-Degree|Movement Total-Degree|
|---|---|---|---|---|---|---|
|ALEXANDRIA STAGING FACILITY|9030|39836|48866|9031|39836|48867|
|FLORENCE STAGING FACILITY|18880|11189|30069|18884|11196|30080|
|PINE PRAIRIE ICE PROCESSING CENTER|10875|18192|29067|10875|18208|29083|
|ADAMS COUNTY DET CENTER|16565|11638|28203|16565|11638|28203|
|FLORENCE SPC|12428|14609|27037|12435|14609|27044|
|STEWART DETENTION CENTER|5809|11928|17737|5813|11928|17741|
|OTAY MESA DETENTION CENTER|15434|1231|16665|15436|1231|16667|
|JACKSON PARISH CORRECTIONAL CENTER|4552|12012|16564|4552|12012|16564|
|PRAIRIELAND DETENTION CENTER|4490|12008|16498|4494|12008|16502|
|WINN CORRECTIONAL CENTER|4434|11323|15757|4435|11324|15759|

### Paths

Analysis of detainee pathways reveals distinct functional roles among detention facilities. By examining stays involving multiple facilities, we quantify the proportions of initial intake locations (the first facility in a detainee’s stay), intermediate facilities (those occupied between the first and last), and final detention or release points (the last facility in the stay). The results below focus on the ten most represented detention facilities. Notably, Alexandria Staging Facility is primarily used as a final detention site, Florence Staging Facility serves mostly as an initial and intermediate location, and Otay Mesa Detention Center is overwhelmingly skewed toward initial intakes.

| Detention Facility                 | % Initial | % Intermediate | % Final |
| ---------------------------------- | --------------- | -------------------- | ------------- |
|ALEXANDRIA STAGING FACILITY|0.47%|22.19%|77.34%|
|JACKSON PARISH CORRECTIONAL CENTER|10.91%|24%|65.09%|
|FLORENCE SPC|2.48%|80.7%|16.81%|
|PINE PRAIRIE ICE PROCESSING CENTER|2.73%|55.46%|41.81%|
|ADAMS COUNTY DET CENTER|35.7%|55.65%|8.65%|
|FLORENCE STAGING FACILITY|47.15%|36.23%|16.62%|
|PORT ISABEL SPC|52.7%|14.37%|32.92%|
|ELOY FED CTR FACILITY (CORE CIVIC)|75.07%|6.19%|18.74%|
|STEWART DETENTION CENTER|8.57%|36.15%|55.29%|
|OTAY MESA DETENTION CENTER|91.92%|3.96%|4.13%|

We can also look at the most common paths and subpaths through immigration detention networks. The most common individual paths include from Port Isabel Service Processing Center to itself (7,434), Montgomery Holding Room to Montgomery Holding Center (6,853), and Dallas Field Office Holding Room to Praireland Detention Center (2,480). Many of the most common individual paths are either from the facility to itself or from a holding room to the detention facility. 

Looking at the most common subpaths through immigration detention we see that the most common subpaths of length 2 (i.e, between two detention facilities in a single stay) are, similar to above, Florence Staging Facility to Florence Service Processing Center (12,802), Port Isabel Service Processing Center to itself (10,340), and Montgomery Holding Room to Montgomery Holding Center (9,980). Looking at most common subpaths of length 3 (i.e, between two detention facilities with a third in the middle) are Florence Staging Facility to Florence Service Processing Center to Folkston ICE Processing Center (Main) (1,905), Dallas County Jail Lew Sterrett to Dallas Field Office Holding Room to Praireland Detention Center (1,457), and Florence Staging Facility to Florence Service Processing Center and back to Florence Staging Facility, a loop (1,405). You can find the most common subpaths of length 4, 5, and 6 below. 

|Subpaths| Count | Subpath Length |
|---|---|---|
|PHOENIX DIST OFFICE->FLORENCE STAGING FACILITY->FLORENCE STAGING FACILITY->CCA, FLORENCE CORRECTIONAL CENTER|488|4|
|FLORENCE STAGING FACILITY->FLORENCE SPC->PINE PRAIRIE ICE PROCESSING CENTER->ALEXANDRIA STAGING FACILITY|476|4|
|FLORENCE STAGING FACILITY->FLORENCE STAGING FACILITY->CCA, FLORENCE CORRECTIONAL CENTER->FLORENCE STAGING FACILITY|431|4|
|FLORENCE STAGING FACILITY->FLORENCE SPC->FOLKSTON MAIN IPC->STEWART DETENTION CENTER|407|4|
|KNOXVILLE HOLD ROOM->KNOX COUNTY DETENTION FACILITY->PICKENS COUNTY DET CTR->CENTRAL LOUISIANA ICE PROC CTR|401|4|
|PHOENIX DIST OFFICE->FLORENCE STAGING FACILITY->FLORENCE STAGING FACILITY->CCA, FLORENCE CORRECTIONAL CENTER->FLORENCE STAGING FACILITY|233|5|
|PORT ISABEL SPC->PORT ISABEL SPC->SOUTH TEXAS ICE PROCESSING CENTER->PORT ISABEL SPC->PORT ISABEL SPC|197|5|
|PORT ISABEL SPC->PORT ISABEL SPC->RIO GRANDE DETENTION CENTER->PORT ISABEL SPC->PORT ISABEL SPC|178|5|
|PHOENIX DIST OFFICE->FLORENCE STAGING FACILITY->FLORENCE STAGING FACILITY->CCA, FLORENCE CORRECTIONAL CENTER->FLORENCE SPC|153|5|
|DALLAS COUNTY JAIL-LEW STERRETT->DALLAS F.O. HOLD->BLUEBONNET DET FCLTY->PRAIRIELAND DETENTION CENTER->ALEXANDRIA STAGING FACILITY|144|5|
|ORLANDO HOLD ROOM->ORANGE COUNTY JAIL->ORLANDO HOLD ROOM->BAKER COUNTY SHERIFF DEPT.->KROME HOLD ROOM->MIAMI STAGING FACILITY|55|6|
|MOSHANNON VALLEY PROCESSING CENTER->PINE PRAIRIE ICE PROCESSING CENTER->ALEXANDRIA STAGING FACILITY->KROME/MIAMI HUB->KROME NORTH SPC->MIAMI STAGING FACILITY|45|6|
|ORLANDO HOLD ROOM->BAKER COUNTY SHERIFF DEPT.->KROME HOLD ROOM->MIAMI STAGING FACILITY->PINE PRAIRIE ICE PROCESSING CENTER->ALEXANDRIA STAGING FACILITY|42|6|
|KROME NORTH SPC->MIAMI STAGING FACILITY->EL VALLE DETENTION FACILITY->FLORENCE STAGING FACILITY->FLORENCE SPC->NW ICE PROCESSING CTR|37|6|
|PHOENIX DIST OFFICE->FLORENCE STAGING FACILITY->PHOENIX DIST OFFICE->FLORENCE STAGING FACILITY->PHOENIX DIST OFFICE->FLORENCE STAGING FACILITY|37|6|

From the analysis, it appears that there are several detention facilities that are the stage of transfers. We can ask this more explicitly by looking at the percentage of stays that include at least one stay in the detention facility. Doing this analysis, we can see that 10.10% of all stays include a detention in Alexandria Staging Facility, 7.44% include detention in Florence Staging Facility, and 6.41% include detention in Port Isabel Service Processing Center. You can find more findings below. 

| Detention Facility | Stays Count | % of All Stays |
|---|---|---|
|ALEXANDRIA STAGING FACILITY|38639|10.12%|
|FLORENCE STAGING FACILITY|28428|7.44%|
|PORT ISABEL SPC|24477|6.41%|
|OTAY MESA DETENTION CENTER|21125|5.53%|
|ELOY FED CTR FACILITY (CORE CIVIC)|19274|5.05%|
|ADAMS COUNTY DET CENTER|18963|4.97%|
|PINE PRAIRIE ICE PROCESSING CENTER|18818|4.93%|
|SOUTH TEXAS ICE PROCESSING CENTER|16523|4.33%|
|OTERO CO PROCESSING CENTER|15837|4.15%|
|JACKSON PARISH CORRECTIONAL CENTER|15421|4.04%|

## State Analysis
*note*: our state look-up sheet only contains 4,262 distinct detention facilities, but out of the 617 detention facilities in our dataset, it only contains 472 of these facilities. This means that there are 145 detention facilities that we do not have the state for. We mark these states as "Unknown". Luckily, only 3.40% of all detentions include have unknown states. 

### Network
Analyzing the movement network, we find that the states with the highest in-degrees are Louisiana (81,835), Texas (19,071), and Georgia (14,133). We see that Louisiana has, by far, the highest number of detainees transferred to it. The states with the highest out-degrees are Arizona (30,313), Texas (30,175), and California (18,117). The states with the highest total degree are Louisiana (92,700), Texas (49,246), and Arizona (41,019). Below is a table showing the top 10 detention facilities ranked by degree measures.

|State|Transfer In-Degree|Transfer Out-Degree|Transfer Total-Degree|Movement In-Degree|Movement Out-Degree|Movement Total-Degree|
|---|---|---|---|---|---|---|
|LA|81835|10865|92700|81818|10864|92682|
|TX|19071|30175|49246|19061|30157|49218|
|AZ|10706|30313|41019|10706|30312|41018|
|MS|11672|17488|29160|11672|17488|29160|
|Unknown|8628|14535|23163|8627|14528|23155|
|CA|3001|18117|21118|2998|18116|21114|
|GA|14133|6049|20182|14131|6046|20177|
|FL|5091|4546|9637|5091|4546|9637|
|NM|2068|4195|6263|2068|4192|6260|
|NJ|1792|4270|6062|1791|4269|6060|

### Paths
We analyze the proportion of initial intake states (the first state in a detainee’s stay), intermediate states (those occupied between the first and last), and final states or release points (the last state in the stay). The results below focus on the ten most represented detention facilities.

| State                 | % Initial | % Intermediate | % Final |
|---|---|---|---|
|HI|13.91%|5.22%|80.87%|
|LA|4.42%|29.55%|66.04%|
|WA|26.02%|18.07%|55.9%|
|CO|30.78%|18.22%|50.99%|
|NV|23.42%|29.18%|47.4%|
|GA|16.64%|36.82%|46.54%|
|IL|23.66%|35.32%|41.02%|
|TX|43.88%|19.63%|36.49%|
|GU|0%|66.67%|33.33%|
|NE|12.05%|55.33%|32.62%|

Looking at the most common subpaths through immigration detention we see that the most common subpaths of length 2 are Texas to Texas (65,190), Arizona to Arizona (31,484), and Louisiana to Louisiana (28,246). The most common subpaths of length 2 between different states are Texas to Louisiana (20,531), Arizona to Louisiana (13,573), and Mississipi to Louisana (11,140). Below are the most common paths by subpath length (including between the same state).

|Subpaths| Count | Subpath Length |
|---|---|---|
|TX->TX->TX|14652|3|
|FL->FL->FL|13172|3|
|AZ->AZ->AZ|11839|3|
|TX->TX->LA|7871|3|
|TX->LA->LA|4181|3|
|FL->FL->FL->FL|5976|4|
|AZ->AZ->AZ->AZ|5229|4|
|TX->TX->TX->TX|3942|4|
|TX->TX->TX->LA|2281|4|
|FL->FL->FL->LA|1874|4|
|FL->FL->FL->FL->FL|2572|5|
|AZ->AZ->AZ->AZ->AZ|2188|5|
|TX->TX->TX->TX->TX|1197|5|
|FL->FL->FL->FL->LA|941|5|
|FL->FL->FL->LA->LA|713|5|
|FL->FL->FL->FL->FL->FL|1131|6|
|AZ->AZ->AZ->AZ->AZ->AZ|904|6|
|FL->FL->FL->FL->FL->LA|379|6|
|FL->FL->FL->FL->LA->LA|362|6|
|TX->TX->TX->TX->TX->TX|197|6|

Looking at the percentage of stays that include at least one stay in the state, we can see that 43.49% of stays included detention in Texas, 25.31% stays included detention in Louisiana, and 15.55% stays included detention in Arizona. You can find more findings below. 

| Detention Facility | Stays Count | % of All Stays |
|---|---|---|
|TX|166085|43.49%|
|LA|96682|25.32%|
|AZ|59397|15.55%|
|CA|41474|10.86%|
|Unknown|24681|6.46%|
|GA|20814|5.45%|
|NM|20563|5.38%|
|MS|19908|5.21%|
|FL|18843|4.93%|
|NY|10313|2.7%|

## Further Analysis Necessary
- [ ] Analysis of loops.
- [x] State by state analysis, including state networks.
- [ ] Analysis of how far people are transferred.
- [ ] Visualization of `movement` and `transferred` graphs.
