# Analyzing the Immigration Detention Network

## Summary
This project applies network analysis to examine the "movements" of detained individuals across immigration detention facilities from mid-November 2024 to mid-February 2025, using data sourced from the Deportation Data Project. While many of these movements represent transfers between facilities, not all do. Our goal is to better understand the roles each facility plays within the broader immigration and deportation system and to address key questions such as: Where are people being sent and what are the common pathways?

### Cleaning  
To construct the immigration detention network, we first downloaded detention data spanning mid-November 2024 to mid-February 2025 from the Deportation Data Project. The full cleaning process is documented in `analysis.R`. Key steps include:  
1. Removing invalid unique identifiers.  
2. Creating a combined stay/unique identifier variable.  
3. Excluding instances with identical book-in times within a single stay.  
4. Counting the order of facility entries per stay.  
5. Creating a `moved` variable to flag whether an individual moved to another facility during their stay.  
6. Categorizing movement types (e.g., transfer, removal).  
7. Identifying destinations for each movement and excluding records without a defined movement type.

### Large Networks  
We constructed two distinct networks: a broad `movement` network and a more specific `transfer` network. The movement network captures any relocation between facilities during a single stay, regardless of reason. The transfer network includes only those moves explicitly classified as transfers. Movements are defined by a sequence of detention book-in dates within one stay—for example, if an individual was initially booked into Alexandria Staging Facility and subsequently booked into Pine Prairie Detention Facility during the same stay, this counts as a movement. If the `Detention Release Reason` for that move was "Transferred," it is classified as a transfer.  

Using facility pairs (origin and destination), we created two directed graphs representing facility-to-facility transfers. Each graph includes all 619 detention facilities as nodes, with edges weighted by the frequency of transfers between them. 

### Paths  
Beyond aggregate networks, we mapped the detention pathway of each individual stay. For each stay, we generated a graph tracing their sequence of detention facilities—from the initial facility, through intermediate stops, to the final facility.

## Analysis

### Overview
After cleaning, our dataset includes 368,668 individuals and 381,907 unique stays. *Note that one person may have multiple unique stays.* On average, each stay involves 2.00 detention events (book-ins). Detention release reasons vary across the 763,286 detention events. The most common reason is `Transferred` (386,645 occurrences), followed by `Removed` (193,947), and then `NA` (42,418), which typically indicates ongoing cases. Most detention release reasons that result in "movements" are `Transferred` (375,499), followed by `Processing Disposition Changed Locally` (5,186), which often includes movements from a facility to itself, and `U.S. Marshals or other agency (explain in Detention Comments)` (533). However, there are cases where a detention release reason is marked as `Transferred`, but no actual movement or transfer occurs. Specifically, 11,146 detentions were recorded as transfers but never resulted in a transfer, possibly because those cases are still ongoing.

### Large Networks
#### Movement
Analyzing the movement network, we see that the nodes with the highest in-degrees are Florence Staging Facility (20,998), Port Isabel Service Processing Center (19,877), and Adams County Correctional Center (16,639). This means that these detention facilities have the highest rate of detention movements going into them. One reason for this, is that many of these detention facilities transfer to themselves. Removing the "loops" in the graph, we see that the nodes with the highest in-degrees are Florence Staging Facility (18,884), Adams County Correctional Center (16,565), and Otay Mesa Detention Center (15,436). The nodes with the highest out degree (removing loops) are Alexandria Staging Facility (39,886), Pine Prairie ICE Processing Center (18,251), and Florida Service Processing Center (14,796). This means that these detention facilities move the most people to other detention facilities. Finally, the nodes with the highest total degrees (moving people in and out) are Alexandria Staging Facility (48,867), Florence Staging Facility (30,080), and Pine Prairie ICE Processing Center (29,083). You can find the detention facilities with the top fifty degrees below. 

| Facility | In Degree | Out Degree | Total Degree |
|---|---|---|---|
|ALEXANDRIA STAGING FACILITY|9031|39836|48867|
|FLORENCE STAGING FACILITY|18884|11196|30080|
|PINE PRAIRIE ICE PROCESSING CENTER|10875|18208|29083|
|ADAMS COUNTY DET CENTER|16565|11638|28203|
|FLORENCE SPC|12435|14609|27044|
|STEWART DETENTION CENTER|5813|11928|17741|
|OTAY MESA DETENTION CENTER|15436|1231|16667|
|JACKSON PARISH CORRECTIONAL CENTER|4552|12012|16564|
|PRAIRIELAND DETENTION CENTER|4494|12008|16502|
|WINN CORRECTIONAL CENTER|4435|11324|15759|
|MONTGOMERY PROCESSING CTR|3981|10691|14672|
|CENTRAL LOUISIANA ICE PROC CTR|4658|9970|14628|
|JOE CORLEY PROCESSING CTR|6410|6832|13242|
|PORT ISABEL SPC|9537|3675|13212|
|ELOY FED CTR FACILITY (CORE CIVIC)|10413|2395|12808|
|AZ REM OP COORD CENTER (AROCC)|5913|5837|11750|
|KROME HOLD ROOM|6290|4917|11207|
|MONTGOMERY HOLD RM|10305|682|10987|
|MOSHANNON VALLEY PROCESSING CENTER|4434|5804|10238|
|MIAMI STAGING FACILITY|3291|6491|9782|
|KROME NORTH SPC|5197|4520|9717|
|IAH SECURE ADULT DET. FACILITY|4509|5195|9704|
|DALLAS F.O. HOLD|6510|2720|9230|
|SOUTH TEXAS ICE PROCESSING CENTER|2317|6887|9204|
|BROWARD TRANSITIONAL CENTER|2877|6100|8977|

#### Transfer


### Paths



