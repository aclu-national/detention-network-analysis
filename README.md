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

### Individual Networks  
Beyond aggregate networks, we mapped the detention pathway of each individual stay. For each stay, we generated a graph tracing their sequence of detention facilities—from the initial facility, through intermediate stops, to the final facility.

## Analysis

### Overview
After cleaning, our dataset includes 368,668 individuals and 381,907 unique stays. *Note that one person may have multiple unique stays*. On average, each stay involves 2.00 detention events (book-ins). Additionally, detention release reasons vary: across the 763,286 detention events, the most common reason is `Transferred` (386,645 occurrences), followed by `Removed` (193,947), and then `NA` (42,418), which typically indicates ongoing cases. Other reasons are less frequent and detailed below.

|Detention Release Reason| Count | Percent | Valid Percent|
|---|---|---|---|
|Transferred|386645|0.506553244786358|0.536360332266101|
|Removed|193947|0.254094795397793|0.269046482851229|
|NA|42418|0.0555728783182189|NA|
|Paroled|41920|0.0549204361143791|0.0581521166149697|
|Order of recognizance|23834|0.0312255170407947|0.0330629185925856|
|Paroled - Fear Found|20799|0.0272492879471129|0.028852716447394|
|Bonded Out - IJ|9856|0.0129125910864342|0.0136724060438249|
|Paroled - Humanitarian|9454|0.0123859208736961|0.0131147450018589|
|U.S. Marshals or other agency (explain in Detention Comments)|8549|0.0112002578325818|0.0118593140491741|
|Order of supervision|5980|0.0078345469457058|0.00829555480337593|
|Processing Disposition Changed Locally|5203|0.00681657989272697|0.00721768756554598|
|Order of Recognizance - Humanitarian|3640|0.00476885466260353|0.00504946814118535|
|Bonded Out - Field Office|2618|0.00342990700733408|0.003631732855391|
|Order of Supervision - No SLRRFF|2015|0.00263990168822696|0.00279524129244189|
|Relief Granted by IJ|1565|0.00205034547993806|0.00217099385740524|
|Proceedings Terminated|1333|0.00174639650144245|0.00184915962423079|
|Voluntary departure|1093|0.00143196652368837|0.00151622765887791|
|Paroled - Public Benefit|928|0.00121579591398244|0.0012873369326978|
|Order of Supervision - Humanitarian|876|0.00114766941880239|0.00121520167353801|
|Voluntary Return|330|0.000432341219411859|0.00045778145236021|
|Order of Supervision - Re-Release|151|0.000197828861003608|0.000209469694867854|
|Withdrawal|102|0.000133632740545484|0.000141496085274974|
|Died|17|2.22721234242473e-05|2.35826808791623e-05|
|Escaped|11|1.44113739803953e-05|1.52593817453403e-05|
|Title 42 Return|2|2.62024981461733e-06|2.77443304460733e-06|

### Large Networks
#### Movement


#### Transfer


