<!--

(c) Copyright 2016 Intergral Information Solutions GmbH. All Rights Reserved

-->
<cfset fragentClass = createObject("java", "com.intergral.fusionreactor.agent.Agent")>
<cfset sourceFiles = fragentClass.getAgentInstrumentation().get("cflpi").getSourceFiles()>
<cfloop from=1 to=#arraylen(sourceFiles)# index="i">
    <cfset sourceLineMetrics = fragentClass.getAgentInstrumentation().get("cflpi").getSourceLineMetrics(sourceFiles[i])>
    <cfoutput>Source #sourceFiles[i]#: Code Coverage: #sourceLineMetrics.getCodeCoverage() * 100#%</cfoutput>
    <cfoutput> Lines covered: #sourceLineMetrics.getCodeCoverageLineCount()# of #sourceLineMetrics.getTotalLineCount()#
        <br></cfoutput>

    <cfset lineMetricMap = fragentClass.getAgentInstrumentation().get("cflpi").getLineMetrics(sourceFiles[i])>
    <cfset sortedKeys = createObject("java", "java.util.TreeSet").init(lineMetricMap.keySet()).iterator()>
    <cfloop condition="sortedKeys.hasNext()">
        <cfset entry = sortedKeys.next()>
        <cfset lineMetric = lineMetricMap.get(entry)>
        <cfset lineNumber = lineMetric.getLineNumber()>
        <cfset count = lineMetric.getCount()>
        <cfset nanoTime = lineMetric.getNanoTime()>
        <cfoutput>#sourceFiles[i]# #lineNumber#: Count: #count#, Time: #nanoTime#, Average: #nanoTime / (count eq 0 ? 1 : count)#
            <br></cfoutput>
    </cfloop>
</cfloop>
