requirejs ["nwdrome/nwdrome"], (Nwdrome) ->
    requestAnimationFrame =
        window.requestAnimationFrame       ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame    ||
        window.oRequestAnimationFrame      ||
        window.msRequestAnimationFrame     ||
        (callback) ->
            window.setTimeout callback, 1000 / 60


    $window = $ window
    nwdrome = window.nwdrome = new Nwdrome()
    canvas = nwdrome.mixer.getDestination()


    # Bind events
    $window
        .on "resize", do ->
            timerId = null

            return ->
                if timerId isnt null
                    clearTimeout timerId

                timerId = setTimeout ->
                    if canvas.inExternal is true
                    else
                        nwdrome.notifyResize $window.width(), $window.height()
                        timerId = null
                , 100

        .on "keydown", (e) ->
            nwdrome.notifyKeydown e.originalEvent


    $ ->
        canvas.id = "nwdrome_dest";
        document.getElementById "nwdrome_container"
            .appendChild canvas

        $window.trigger "resize"

        # Running render process
        renderProcess = ->
            nwdrome.mixer.render()
            requestAnimationFrame renderProcess

        renderProcess()

        ################
        # Load plugins
        plugins = document.getElementsByTagName "script";
        nwdromePlugins = []

        for i in [0...plugins.length]

            if plugins[i].type is "text/nwdrome-plugin"
                tmpEl = document.createElement "script"
                tmpEl.src = plugins[i].src
                tmpEl.type = "text/javascript"
                document.head.appendChild tmpEl

                nwdromePlugins.push plugins[i]

        for el in nwdromePlugins
            el.remove()

        console.info "Nwdrome plugin loaded"

    console.info "Nwdrome initialized"
