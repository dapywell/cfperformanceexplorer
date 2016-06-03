// Once the document object model has finished loading, we
// are going to hook up all the click handlers for the file
// and directory links.
$(
    function () {

        // Make sure that all the links have void actions
        // so that the page doesn't change or jump around.
        $("a").attr(
            "href",
            "javascript:void( 0 );"
        );


        // Hook up the directory click handler.
        $("a.dir").click(
            function () {
                var jLink = $(this);
                var jSubDir = jLink.next("ul");

                // Toggle the sub-directory list.
                jSubDir.toggle();
            }
        );


        // Hoop up the file click handler.
        $("a.file").click(
            function () {
                var jLink = $(this);
                var jSelected = $("a.selected");

                // Remove the selected class.
                jSelected.removeClass("selected");

                // Set the selected status on new link.
                jLink.addClass("selected");

                // Show file name.
                $("span#filename").text(jLink.text());

                // Load file.
                ShowFile(jLink.attr("id"));
            }
        );


        // The file might start off with some default elements.
        // Show all the selected elements including all of the
        // parent directories.
        $("a.selected").each(
            function (intI) {
                var jLink = $(this);
                var jParents = jLink.parents("ul");
                var jSubDir = jLink.next("ul");

                // Show the current dir (this will only
                // work if this is a directory link).
                jSubDir.show();

                // Show all the parents to show them.
                jParents.show();

                // If this is the first one, then we want to load the file.
                if (intI == 0) {

                    // Show the file name.
                    $("span#filename").text(jLink.text());

                    // Load the file.
                    ShowFile(jLink.attr("id"));

                }
            }
        );

    }
);

// This will load the given file into the PRE element.
function ShowFile(strPath) {

    // Check to see if there is an AJAX request already in
    // progress that needs to be stopped.
    if (objHttpFileDataRequest) {

        // Abort the AJAX request.
        objHttpFileDataRequest.abort();

    }

    // Use AJAX to get the text of the file and store the
    // new AJAX request object into the global variable.
    objHttpFileDataRequest = $.get(
        "index.cfm",
        {
            getdata: 1,
            file: encodeURI(strPath)
        },
        function (strFileData) {
            var data = $(strFileData);
            $(data).each(function (k, v) {
                if ($(v).attr('id') !== undefined) {
                    $("#" + $(v).attr('id')).replaceWith(v);
                }
            });

            // Jump back to top.
            window.location.hash = "content";
        }
    );

    objHttpFileDataRequest = null;
}


// Store a global value to the HTTP request object that is going
// to be used in our AJAX file data calls. In order to make sure 
// that calls are not jumbled, we want to serialize our requests.
// Meaning, if one request goes out, it should abort any previously
// running request.
var objHttpFileDataRequest = null;