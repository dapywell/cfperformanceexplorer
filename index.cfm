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
<!--
Based upon http://www.bennadel.com/projects/kinky-file-explorer.htm
The Kinky File Explorer is a totally free ColdFusion based file exploration system
designed to provide read-only access to a specific directory of files.
-->

<!--- Kill extra output. --->
<cfsilent>

<!---
   Set the directory that we are going to be viewing.
   This is the ROOT directory. We will be able to view
   files that are in sub-directories of this one. Access
   above this directory will be highly restricted.
--->
    <cfset REQUEST.RootDirectory = ExpandPath("./")/>

<!---
   Set the list of valid file extensions. This way, you
   can limit the viewable files. This list is composed of
   space delimited values. If you don't want to restrict
   the file types, just put in * for entire string.
--->
    <cfset REQUEST.FileTypes = "cfc cfm"/>

<!---
   Param the URL file variable. This will be the root
   relevant path to the target file (does NOT start with a
   leading slash). If you want to start out with a default
   file, then put in a default attribute value.
--->
    <cfparam
            name="URL.file"
            type="string"
            default=""/>


<!--- Include helper functions. --->
    <cfinclude template="_functions.cfm">

<!---
   Make sure that our root directory is a driectory only
   and does not contain any file information.
--->
    <cfset REQUEST.RootDirectory = GetDirectoryFromPath(
        REQUEST.RootDirectory
            )/>

<!---
   Get the proper slash for this server environment.
   We will use the expanded path of the root directory
   to find the first file system slash.
--->
    <cfset REQUEST.Slash = Left(
        REQUEST.RootDirectory.ReplaceFirst(
            JavaCast("string", "^[^\\/]+"),
            JavaCast("string", "")
                ),
            1
            )/>


<!---
   Param the URL variable for file transfer. If this is
   not true, then the page will display the XHTML. If this
   is True, then it will return the binary output data.
--->
    <cftry>
        <cfparam
                name="URL.getdata"
                type="boolean"
                default="0"/>

        <cfcatch>
            <cfset URL.getdata = 0/>
        </cfcatch>
    </cftry>


<!---
   Now, we are going to clean the file value that was
   passed in. We need to make sure there are no security
   issues here or anything that might cause the system
   to break.
--->

<!---
   Remove any sneaky navigation hacks such as root
   directives or "up one" directives. This way, we
   will be able to stop people from navigating out of
   the root directory.
--->
    <cfset URL.file = URL.file.ReplaceAll(
        JavaCast("string", "(^[\\\/]+)|(\.\.[\\/]{1})|([\\/]{2,})|:"),
        JavaCast("string", "")
            )/>

<!--- Put in the proper slashes. --->
    <cfset URL.file = URL.file.ReplaceAll(
        JavaCast("string", "[\\\/]{1}"),
        JavaCast("string", "\#REQUEST.Slash#")
            )/>

<!--- Decode the URL. --->
    <cfset URL.file = UrlDecode(URL.file)/>


<!---
   ASSERT: At this point, our URL.file variable
   should contain a clean, root-relevent path.
--->


<!---
   Set a default target file. The target file is the
   full path (expanded path) for the file sent through
   URL.file. By default, it will be empty.
--->
    <cfset REQUEST.TargetFile = ""/>


<!---
   Check to see if any file is being requested / selected.
   We don't yet care about returning it to the browser -
   we only want to make sure that it is a valid path.
--->
    <cfif Len(URL.file)>

<!---
   Check to make sure the file has a file extension.
   Currently, we can only work with files that have
   extensions.
--->
        <cfif (
                    Len(URL.file) AND
                (NOT ListLen(GetFileFromPath(URL.file), "."))
                )>

<!---
   There was no file extension so we are to
   consider this not a valid file name. Clear
   the file value.
--->
            <cfset URL.file = ""/>

        </cfif>


<!---
   Get the target file by adding the root-relevant
   path to the root directory path. We are going to
   assume at this point that the root path always
   has a trailing slash.
--->
        <cfset REQUEST.TargetFile = (
            REQUEST.RootDirectory &
            URL.file
            )/>

<!--- Check to see if the file exists. --->
        <cfif NOT FileExists(REQUEST.TargetFile)>

<!--- Reset target file. --->
            <cfset REQUEST.TargetFile = ""/>

        </cfif>

    </cfif>


<!---
   ASSERT: At this point, we have cleaned the URL.file
   value and determined whether or not the file exists
   within the root directory (If it does not exist, then
   its value was cleared).
--->


<!---
   Check to see if we need to return any file data. The
   first call to this page should *never* do this. This
   will only be done on subsequent calls to the page that
   need to access and display file data.
--->
    <cfif URL.getdata>

<!---
   Check to see if the file exists and that it is a
   valid file type. We don't want people to open up
   just any old file type.
--->
        <cfif (
                    Len(REQUEST.TargetFile) AND
                (
                (REQUEST.FileTypes EQ "*") OR
                    ListFindNoCase(
                        REQUEST.FileTypes,
                        ListLast(REQUEST.TargetFile, "."),
                            " "
                            )
                ))>


<!--- Read in the file data. --->
            <cffile
                    action="READ"
                    file="#REQUEST.TargetFile#"
                    variable="REQUEST.FileData"/>

            <cfsetting enableCFoutputOnly="No">
            <cfsavecontent variable="FileContent">
                <cfoutput>
                    <cftry>
                        <cfset showDebug = "false">
                        <cfset totalCountOver = "0">
                        <cfset totalTimeOver = "0">
                        <cfset totalAvgOver = "0">
                        <cfset totalLines = getTotalLineCount(REQUEST.TargetFile)>
                        <cfset coveredLines = getCodeCoverageLineCount(REQUEST.TargetFile)>
                        <cfset codeCoverage = getCodeCoverage(REQUEST.TargetFile)>
                        <cfset i = 1>
                        <cfloop list="#REQUEST.FileData#" index="chars" delimiters="#chr(10)#">
                            <cfset metrics = getLineMets(REQUEST.TargetFile, i)>
                            <cfif not StructIsEmpty(metrics)>
                                <cfset showDebug = "true">
                                <cfif metrics.count lt 5000>
                                <cfelse>
                                    <cfset totalCountOver = totalCountOver + 1>
                                </cfif>
                                <cfif metrics.time gt 1>
                                    <cfset totalTimeOver = totalTimeOver + 1>
                                </cfif>
                                <cfif metrics.avg gt 1>
                                    <cfset totalAvgOver = totalAvgOver + 1>
                                </cfif>
                            </cfif>
                            <cfset i = i + 1>
                        </cfloop>

                        <cfcatch>
                            <cfset totalCountOver = 0>
                            <cfset totalTimeOver = 0>
                            <cfset totalAvgOver = 0>
                            <cfset coveredLines = 0>
                            <cfset totalLines = 0>
                            <cfset coveredLines = 0>
                            <cfset codeCoverage = 0>
                        </cfcatch>
                    </cftry>
                    <cfif URL.getdata>
                        <div id="fileoutput">
                        <div class="data type-coldfusion">
                        <table class="lines" border="0" cellpadding="0" cellspacing="0">
                        <thead>
                        <tr>
                        <cfif showDebug eq "false">
                                <th width="2%" class="center">Line</th>
                                <th width="98%">Code</th>
                        <cfelse>
                                <th width="1%" class="center">Count</th>
                                <th width="3%" class="center">Last Exec Time(ms)</th>
                                <th width="3%" class="center">Average Exec Time(ms)</th>
                                <th width="3%" class="center">total Time(ms)</th>
                                <th width="2%" class="center">Line</th>
                                <th width="88%">Code</th>
                        </cfif>
                        </tr>
                        </thead>
                        <tbody>
                        <cfset i = 1>
                        <cfloop list="#REQUEST.FileData#" index="chars" delimiters="#chr(10)#">
                            <cfset metrics = getLineMets(REQUEST.TargetFile, i)>
                            <cfif StructIsEmpty(metrics)>
                                <tr class="theline">
                                <cfif showDebug eq "true">
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                        <td></td>
                                </cfif>
                                <td class="line_number" id="L#i#" rel="##L#i#">#i#</td>
                                    <td class="highlight line full" id='LC#i#'>
                            <pre>#htmlEditFormat(chars)#</pre></td>
                            </tr>
                            <cfelse>
                                <tr class="theline">
                                <cfif showDebug eq "true">
                                    <cfif metrics.count lt 5000>
                                            <td class="line_count_few small" id='LCO#i#'>#htmlEditFormat(metrics.count)#</td>
                                    <cfelse>
                                            <td class="line_count_many small" id='LCO#i#'>#htmlEditFormat(metrics.count)#</td>
                                    </cfif>
                                    <cfif metrics.time gt 1>
                                            <td class="line_time long" id='LT#i#'>#htmlEditFormat(metrics.time)#</td>
                                    <cfelse>
                                            <td class="line_time short" id='LT#i#'>#htmlEditFormat(metrics.time)#</td>
                                    </cfif>
                                    <cfif metrics.avg gt 1>
                                            <td class="line_time long" id='LTA#i#'>#htmlEditFormat(metrics.avg)#</td>
                                    <cfelse>
                                            <td class="line_time short" id='LTA#i#'>#htmlEditFormat(metrics.avg)#</td>
                                    </cfif>
                                    <cfif metrics.total gt 1>
                                            <td class="line_time long" id='LTA#i#'>#htmlEditFormat(metrics.total)#</td>
                                    <cfelse>
                                            <td class="line_time short" id='LTA#i#'>#htmlEditFormat(metrics.total)#</td>
                                    </cfif>
                                </cfif>
                                <td class="line_number small" id="L#i#" rel="##L#i#">#i#</td>
                                    <td class="highlight line" id='LC#i#'>
                            <pre>#htmlEditFormat(chars)#</pre></td>
                            </tr>
                            </cfif>
                            <cfset i = i + 1>
                        </cfloop>
                        </tbody>
                        </table>
                        </div>
                        </div>
                        <div id="footerOutput">
                        <cftry>
                                <p>
                                    >Path: #REQUEST.TargetFile#<br>
                                >Total lines with a count over 5000: #totalCountOver#<br>
                                >Total lines with an execution time of over 1ms: #totalTimeOver#<br>
                                >Total lines with an average execution time of over 1ms: #totalAvgOver#<br>

                                <cfif coveredLines gt 0>
                                        >Code Coverage: #codeCoverage * 100#(#coveredLines# of #totalLines# lines)<br>
                                <cfelse>
                                        >Code Coverage: 0% (0 of #totalLines# lines)<br>
                                </cfif>
                                </p>
                            <cfcatch>
                                    <p>
                                        Fusion Explorer
                                    </p>
                            </cfcatch>
                        </cftry>
                        </div>
                    </cfif>
                </cfoutput>
            </cfsavecontent>
            <cfsetting enableCFoutputOnly="YES">
<!--- Stream the file content to the browser. --->
            <cfcontent
                    type="text/html"
                    variable="#ToBinary(ToBase64(FileContent))#"/>

<!---
   If the file was requested but it cannot be shown,
   then it was just not the proper type of file.
   Viewing it was restricted.
--->
            <cfelseif Len(REQUEST.TargetFile)>

<!--- Send back error message. --->
            <cfcontent
                    type="text/plain"
                    variable="#ToBinary(ToBase64('The requested file [ #URL.file# ] is not a readable text document.'))#"/>

<!---
   If we have gotten this far then the file simply
   couldn't be found at the given path.
--->
        <cfelse>

<!--- Send back error message. --->
            <cfcontent
                    type="text/plain"
                    variable="#ToBinary(ToBase64('The requested file [ #URL.file# ] could not be found.'))#"/>

        </cfif>

    </cfif>


<!---
   ASSERT: If we have made it this far, then we are going
   to be rendering the XHTML page (no file was returned).
--->


<!--- Get the files from the root directory. --->
    <cfdirectory
            action="list"
            directory="#REQUEST.RootDirectory#"
            sort="directory ASC"
            name="REQUEST.FileQuery"
            recurse="true"/>


<!--- Set page content type and clear buffer. --->
    <cfcontent
            type="text/html"
            reset="true"/>

</cfsilent>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
    <title>CF Line Performance Explorer</title>

    <!-- Linked files. -->
    <link rel="stylesheet" type="text/css" href="./style.css"/>
    <script type="text/javascript" src="jquery.js"></script>
    <script type="text/javascript" src="scripts.js"></script>
</head>
<body>

<cfoutput>

    <!-- BEGIN: Header. -->
    <div id="header">

        <h1>
            CF Line Performance Explorer
        </h1>

    </div>
    <!-- END: Header. -->


    <!-- BEGIN: File Frame. -->
    <div id="fileframe">

        <!-- BEGIN: File Tree. -->
    <div id="filetree">

<!---
   Output the file tree list. This will create an
   unordered list of unordered lists.
--->
            #OutputDirectory(
    REQUEST.FileQuery,
    REQUEST.RootDirectory,
    REQUEST.TargetFile,
    REQUEST.RootDirectory,
    REQUEST.Slash
        )#

    </div>
        <!-- END: File Tree. -->

    </div>
    <!-- END: File Frame. -->


    <!-- BEGIN: Content Frame. -->
    <div id="contentframe">

        <!-- BEGIN: Content. -->
    <div id="content">

        <h2>
            File: <span id="filename"></span>
        </h2>

<!--- Output file data. --->
        <div id="fileoutput"></div>

    </div>
        <!-- END: Content. -->

    </div>
    <!-- END: Content Frame. -->


    <!-- Clear floats. -->
    <div class="clear">
        <br clear="all"/>
    </div>


    <!-- BEGIN: Footer. -->
    <div id="footerOutput">
        <p>
            CF Line Performance Explorer
        </p>
    </div>
    <!-- END: Footer. -->

</cfoutput>

</body>
</html>
