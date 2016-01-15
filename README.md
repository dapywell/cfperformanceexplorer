# cfperformanceexplorer

CF Performance Explorer is a simple tool written in CFML that allows you to examine the performance of your ColdFusion application code on a line by line basis. The tool requires that you have FusionReactor installed and have enabled Track CFML Line Execution Times in the FusionReactor ColdFusion Plugin.

## Deploy

The Performance explorer files should be copied into a folder (e.g. cfpe) under root directory of your application. The peformance explorer will automatically take the parent folder as the root of the application code. For example on a ColdFusion 11 installation under Windows:
1. Create C:\ColdFusion11\cfusion\wwwroot\cfpe
2. Copy the files from the ColdFusion Performance Explorer into the folder

## Running

Ensure that you have FusionReactor 6.0.4 or higher installed with Track CFML Line Execution Times enabled in the FusionReactor ColdFusion Plugin. To enable this setting:

1. Click on the FusionReactor menu at the top left corner of the FusionReactor page
2. Choose Active Plugins
3. On the Active Plugins page select the Configuration for the FusionReactor ColdFusion Plugin
4. Enable Track CFML Line Execution Times
5. Save the Configuration

**Enabling the Track CFML Line Execution Times** will cause ColdFusion to empty the CF Page and Component caches. This will mean that the pages and components will be recompiled when they run the next time. This may take longer than normal due to the instrumentation added to the page to capture performance data. Disabling Track CFML Line Execution Times will also cause the CF Page and Component caches to be cleared.

Once Track CFML Line Execution Times is enabled, every page and component run in ColdFusion will track performance metrics at a line level. Using the performance explorer you can see these metrics against the the application source code.

To open the performance explorer simple call the index.cfm page in the folder where you have deployed the ColdFusion Performance Explorer in a webbrowser. For example: [http://127.0.0.1/cfpe/index.cfm]

**Opening a large application may take a long time because the explorer scans recursively through the entire directory structure when first called**






