# The Immigration Detention Network

## Summary
In this project, we used network analysis to understand the "movements" of detained people across detention facilities between Mid November 2024 and Mid February 2025, using detention data from the Deportation Data Project. Many of these "movements" are `transfers` between one facility and another, but not all. We conduct this analysis to better understand the function each detention facility is playing in the larger web of the immigration/deportation project, including in an attempt to answer three question: where are people being sent and what are the commons paths through detention.

## Analysis
After initial cleaning, we start with a dataset of 368,668 individual people and 381,907 unique stays, where unique stays are defined as unique stay book-in dates for unique people. This means that a single person may have multiple unique stays. Within a single stay a person may receive a number of detentions, where they are detained in detention facilities. On average, people experience 2.00 detentions per unique stay.

There are a number of reasons that people may be removed from their detention within and at the end of their detention. Out of all 763,286 detentions, the most common detention release reason is 386,645 `Transferred`, the second most common 193,947 `Removed`, and the third most common is 42,418, `NA` (this is generally the case when the case is still ongoing), the fourth most common is 41,920, `Paroled`, the fifth most com

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
Warning message:
In flat_str(content, breaks) : Coercing content to character
> df_clean %>%
+   tabyl(detention_release_reason) %>%
+   arrange(-n) %>%
+   df_2_MD(.)
|detention_release_reason|n|percent|valid_percent|
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


