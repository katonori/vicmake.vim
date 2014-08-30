vicmake.vim
----
Very simple CMakeCache.txt editor vim plugin.
This plugin aims ccmake for vim.

How to use
----

1. Run cmake at the first.

        $ make build && cd build && cmake ../ 

1. Run vicmake.vim in vim.

        $ vim
        :VicmakeStartEdit
You will see 3 pane variable editor. The left pane is _type pane_ which lists the type of variables.
The middle pane is _variable name_ pane which lists the name of variables. The right pane is _value pane_ which lists 
value of the variables.

3. Edit _value pane_ and save the _value pane_ and rerun cmake.

Note
----
vicmake.vim redraws the window everytime you change the line.
If you don't like this behavior set g:VicmakeRedraw to 0 like below.

        let g:VicmakeRedraw = 0
