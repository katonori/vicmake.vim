vicmake.vim
----
これはCMakeCache.txt 編集を便利に行うためのvimのpluginです。
ccmakeのような使い勝手を目指しています。

使い方
----

1. cmakeを実行し、CMakeCache.txtを生成します。

        $ make build && cd build && cmake ../ 

1. vimでVicmakeStartEditコマンドを実行します。

        $ vim
        :VicmakeStartEdit
コマンドを実行すると3ペインの変数編集モードになります。
左のペインには変数の型、中心のペインには変数の名前、右のペインには値が表示されます。

3. 右ペインの値を編集し、ファイルをセーブし、再度cmakeを実行します。

設定
----
vicmake.vimは各ペインのカーソル位置を同期するため、
カーソルを動かすたびに再描画を行っています。
この挙動を止めるには g:VicmakeRedraw を 0 に設定します。

        let g:VicmakeRedraw = 0

