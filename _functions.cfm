<!--

 Copyright 2016 Intergral Information Solutions GmbH

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
-->

<!---
Based upon http://www.bennadel.com/projects/kinky-file-explorer.htm
The Kinky File Explorer is a totally free ColdFusion based file exploration system
designed to provide read-only access to a specific directory of files.
--->
<cffunction
        name="OutputDirectory"
        access="public"
        returntype="string"
        output="true"
        hint="Builds the directory structure.">

<!--- Define arguments. --->
    <cfargument
            name="FileQuery"
            type="query"
            required="true"
            hint="The recursive CFDirectory query of the root directory."/>

    <cfargument
            name="Directory"
            type="string"
            required="false"
            default=""
            hint="The directory that we are going to be recursing through on the given iteration."/>

    <cfargument
            name="TargetFile"
            type="string"
            required="false"
            default=""
            hint="The file that we are selecting in the tree structure (contains full path value)."/>

    <cfargument
            name="RootDirectory"
            type="string"
            required="true"
            hint="The root directory for this application."/>

    <cfargument
            name="Slash"
            type="string"
            required="true"
            hint="The system slash that we need for creating paths."/>

<!--- Define the local scope. --->
    <cfset var LOCAL = StructNew()/>


<!--- Remove any trailing slashes on path. --->
    <cfset ARGUMENTS.Directory = ARGUMENTS.Directory.ReplaceFirst(
        JavaCast("string", "[\\\/]+$"),
        JavaCast("string", "")
            )/>


<!--- Query for sub directories. --->
    <cfquery name="LOCAL.Directory" dbtype="query">
		SELECT
			directory,
			name
		FROM
			ARGUMENTS.FileQuery
		WHERE
			type = 'Dir'
		AND
			directory =
        <cfqueryparam value="#ARGUMENTS.Directory#" cfsqltype="cf_sql_varchar"/>
        ORDER BY
        name ASC
    </cfquery>


<!--- Query for files. --->
    <cfquery name="LOCAL.File" dbtype="query">
		SELECT
			directory,
			name
		FROM
			ARGUMENTS.FileQuery
		WHERE
			type = 'File'
		AND
			directory =
        <cfqueryparam value="#ARGUMENTS.Directory#" cfsqltype="cf_sql_varchar"/>
        ORDER BY
        name ASC
    </cfquery>


<!--- Output the tree structure. --->
    <cfsavecontent variable="LOCAL.Output">

<!---
    Check for file of directories. We will only need
    to output the data list if we have one or the other.
--->
        <cfif (
                LOCAL.Directory.RecordCount OR
                LOCAL.File.RecordCount
                )>

            <ul>
<!--- Check to see if there are any directories. --->
            <cfif LOCAL.Directory.RecordCount>

                <cfloop query="LOCAL.Directory">

                        <li>
                            <a class="dir">#LOCAL.Directory.name#</a>

<!---
    Since we are in a directory, we might need
    to output sub files and directories. Call this
    method recursively with the new base.
--->
                            #OutputDirectory(
                            ARGUMENTS.FileQuery,
                            (ARGUMENTS.Directory & ARGUMENTS.Slash & LOCAL.Directory.name),
                            ARGUMENTS.TargetFile,
                            ARGUMENTS.RootDirectory,
                            ARGUMENTS.Slash
                            )#
                        </li>

                </cfloop>

            </cfif>


<!--- Check to see if there are any files. --->
            <cfif LOCAL.File.RecordCount>

                <cfloop query="LOCAL.File">

<!--- Get full, expanded path of the current file. --->
                    <cfset LOCAL.FilePath = (LOCAL.File.directory & ARGUMENTS.Slash & LOCAL.File.name)/>

<!---
    Get relative file path. To do this, we are
    going to subtract the root directory from the
    full file path.
--->
                    <cfset LOCAL.RelativeFilePath = ReplaceNoCase(
                        LOCAL.FilePath,
                        ARGUMENTS.RootDirectory,
                            "",
                            "one"
                            )/>

                        <li>
                                <a
                                id="#LOCAL.RelativeFilePath#"
                                class="file<cfif (ARGUMENTS.TargetFile EQ LOCAL.FilePath)> selected</cfif>"
                    >#LOCAL.File.name#</a>
                    </li>
                </cfloop>

            </cfif>
            </ul>

        </cfif>

    </cfsavecontent>


<!--- Clean the output. --->
    <cfset LOCAL.Output = LOCAL.Output.ReplaceAll(
        JavaCast("string", "(?m)^\s+|\s+$|(?<=>)\s+|\s+(?=<)"),
        JavaCast("string", "")
            )/>

<!--- Return the file tree sub-output. --->
    <cfreturn Trim(LOCAL.Output)/>
</cffunction>

<cffunction
        name="getTotalLineCount"
        access="public"
        returntype="numeric"
        output="true"
        hint="Gets the number CFML lines in the file">

<!--- Define arguments. --->
    <cfargument
            name="filename"
            type="string"
            required="true"
            hint="The filename of the file"/>

    <cfset fragentClass = createObject("java", "com.intergral.fusionreactor.agent.Agent")>
    <cfreturn fragentClass.getAgentInstrumentation().get("cflpi").getSourceLineMetrics(filename).getTotalLineCount()>
</cffunction>

<cffunction
        name="getCodeCoverageLineCount"
        access="public"
        returntype="numeric"
        output="true"
        hint="Gets the number lines of code covered in the file">

<!--- Define arguments. --->
    <cfargument
            name="filename"
            type="string"
            required="true"
            hint="The filename of the file"/>

    <cfset fragentClass = createObject("java", "com.intergral.fusionreactor.agent.Agent")>
    <cfreturn fragentClass.getAgentInstrumentation().get("cflpi").getSourceLineMetrics(filename).getCodeCoverageLineCount()>
</cffunction>

<cffunction
        name="getCodeCoverage"
        access="public"
        returntype="numeric"
        output="true"
        hint="Gets the code coverage % for the file">

<!--- Define arguments. --->
    <cfargument
            name="filename"
            type="string"
            required="true"
            hint="The filename of the file"/>

    <cfset fragentClass = createObject("java", "com.intergral.fusionreactor.agent.Agent")>
    <cfreturn fragentClass.getAgentInstrumentation().get("cflpi").getSourceLineMetrics(filename).getCodeCoverage()>
</cffunction>

<cffunction
        name="getLineMets"
        access="public"
        returntype="struct"
        output="true"
        hint="Gets the total number of times the line has been visited.">

<!--- Define arguments. --->
    <cfargument
            name="url"
            type="string"
            required="true"
            hint="The URL that is being tracked."/>

    <cfargument
            name="lineNo"
            type="string"
            required="true"
            hint="The URL that is being tracked."/>
    <cfset emptyStruct = StructNew()>
    <cftry>
        <cfset fragentClass = createObject("java", "com.intergral.fusionreactor.agent.Agent")>
        <cfset lineMetric = createObject("java", "com.intergral.fusionreactor.plugin.coldfusion.lineperformance.LineMetric")>
        <cfset lineMetricMap = createObject("java", "java.util.Map")>
        <cfset lineMetricMap = fragentClass.getAgentInstrumentation().get("cflpi").getLineMetrics(url)>
        <cfset lineMets = StructNew()>
        <cfif lineMetricMap.containsKey(JavaCast("int",lineNo)) IS True>
            <cfset lineMetric = lineMetricMap.get(JavaCast("int",lineNo))>
            <cfset lineMets.count = lineMetric.getCount()>
            <cfset lineMets.time = NumberFormat(lineMetric.getLastLineExecutionNanoTime() / 1000000, "_________.___")>
            <cfif lineMets.count eq 0>
                <cfset count = 1>
            <cfelse>
                <cfset count = lineMets.count>
            </cfif>
            <cfset avgms = (lineMetric.getNanoTime() / count) / 1000000>
            <cfset totalms = lineMetric.getNanoTime() / 1000000>
            <cfset lineMets.avg = NumberFormat(avgms, "________.___")>
            <cfset lineMets.total = NumberFormat(totalms, "_________")>

            <cfreturn #lineMets#/>
        </cfif>
        <cfreturn #lineMets#/>
        <cfcatch>
            <cfreturn #emptyStruct#/>
        </cfcatch>
    </cftry>

</cffunction>