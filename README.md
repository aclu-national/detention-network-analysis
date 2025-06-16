# A Network-Based Examination of Detention Facility Movements


## Summary
This study applies network analysis methodologies to the examination of detainee movements within the U.S. immigration detention system over a x-month period from mid-November 2024 to mid-February 2025. Utilizing data obtained from the Deportation Data Project, we characterize the patterns and pathways of detainee transfers across 619 detention facilities. The analysis distinguishes between general movements between facilities and explicitly classified transfers. Key questions addressed include: What are the common pathways of detainee movement, and which facilities function as primary hubs for intake, transfer, or deportation?

## Introduction
The immigration detention system comprises a complex network of facilities that hold individuals under custody. Understanding the movement dynamics between these facilities is critical for holding them accountable - particularly as many are forced into a "Blackhole" of detention. This research leverages network analysis techniques to explore detainee "movements"—defined as changes in facility bookings within a single detention episode—and to identify systemic patterns and facility roles.

## Data & Methods
To construct the immigration detention network, we first downloaded detention data spanning mid-November 2024 to mid-February 2025 from the Deportation Data Project. The full cleaning process is documented in `analysis.R`. Key steps include:  
1. Removing invalid unique identifiers.  
2. Creating a combined stay/unique identifier variable.  
3. Excluding instances with identical book-in times within a single stay.  
4. Counting the order of facility entries per stay.  
5. Creating a `moved` variable to flag whether an individual moved to another facility during their stay.  
6. Categorizing movement types (e.g., transfer, removal).  
7. Identifying destinations for each movement and excluding records without a defined movement type.

### Networks  
We constructed two distinct networks: a broad `movement` network and a more specific `transfer` network. The movement network captures any relocation between facilities during a single stay, regardless of reason. The transfer network includes only those moves explicitly classified as transfers. Movements are defined by a sequence of detention book-in dates within one stay—for example, if an individual was initially booked into Alexandria Staging Facility and subsequently booked into Pine Prairie Detention Facility during the same stay, this counts as a movement. If the `Detention Release Reason` for that move was "Transferred," it is classified as a transfer.  Using facility pairs (origin and destination), we created two directed graphs representing facility-to-facility transfers. Each graph includes all 619 detention facilities as nodes, with edges weighted by the frequency of transfers between them. 

### Paths  
Beyond aggregate networks, we mapped the detention pathway of each individual stay. For each stay, we generated a graph tracing their sequence of detention facilities—from the initial facility, through intermediate stops, to the final facility.

## Results

### Dataset Overview
After cleaning, our dataset includes 368,668 individuals and 381,907 unique stays. *Note that one person may have multiple unique stays.* On average, each stay involves 2.00 detention events (book-ins). Detention release reasons vary across the 763,286 detention events. The most common reason is `Transferred` (386,645 occurrences), followed by `Removed` (193,947), and then `NA` (42,418), which typically indicates ongoing cases. Most detention release reasons that result in "movements" are `Transferred` (375,499), followed by `Processing Disposition Changed Locally` (5,186), which often includes movements from a facility to itself, and `U.S. Marshals or other agency (explain in Detention Comments)` (533). However, there are cases where a detention release reason is marked as `Transferred`, but no actual movement or transfer occurs. Specifically, 11,146 detentions were recorded as transfers but never resulted in a transfer, possibly because those cases are still ongoing.

### Networks
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


## Discussion
Analyzing the paths of immigration detention, we can see what role each detention facility plays in the detention process. For example, some are primarily for deportation, whereas others are pathways between detention facilities. We can quantify this for each detention facicility by looking at stays that involve at least two detention facilities and looking at the proportion of detentions that are someone's first detention, a pathway before their last detention, and their last detention. 


