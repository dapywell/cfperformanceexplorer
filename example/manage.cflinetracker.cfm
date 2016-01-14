<!--

(c) Copyright 2016 Intergral Information Solutions GmbH. All Rights Reserved

-->
<cfparam name="URL.track" default="true">

<cfset fragentClass = createObject("java", "com.intergral.fusionreactor.agent.Agent")>

<cfif URL.track is "true">
    <cfoutput>#fragentClass.getAgentInstrumentation().get("cflpi").addTransformer()#</cfoutput>
<cfelse>
    <cfoutput>#fragentClass.getAgentInstrumentation().get("cflpi").removeTransformer()#</cfoutput>
</cfif>

<cfdump var=#fragentClass.getAgentInstrumentation().get("cflpi").dump()#> 