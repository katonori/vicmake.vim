"Copyright (c) 2014, katonori All rights reserved.
"
"Redistribution and use in source and binary forms, with or without modification, are
"permitted provided that the following conditions are met:
"
"  1. Redistributions of source code must retain the above copyright notice, this list
"     of conditions and the following disclaimer.
"  2. Redistributions in binary form must reproduce the above copyright notice, this
"     list of conditions and the following disclaimer in the documentation and/or other
"     materials provided with the distribution.
"  3. Neither the name of the katonori nor the names of its contributors may be used to
"     endorse or promote products derived from this software without specific prior
"     written permission.
"
"THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
"EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
"OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
"SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
"INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
"TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
"BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
"CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
"ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
"DAMAGE.

if !has('python')
    echo "Error: Required vim compiled with +python"
    finish
endif

if !exists("g:VicmakeRedraw")
    let g:VicmakeRedraw = 1
endif
if !exists("g:VicmakeShowType")
    let g:VicmakeShowType = 0
endif

let s:scriptName = expand('<sfile>:p')
let s:dirName = fnamemodify(s:scriptName, ":h") 

"
" define commands
"
command! -nargs=0 VicmakeRerunCmake :call <SID>VicmakeRerunCmake()
command! -nargs=1 VicmakeRunCmake :call <SID>VicmakeRunCmake("<args>")
command! -nargs=0 VicmakeStartEdit :call <SID>VicmakeStartEdit()
command! -nargs=0 VicmakeReloadCache :call <SID>VicmakeReloadCache()

"
" set keymaps
"
function! s:SetupBuff()
    autocmd BufWritePost <buffer> call <SID>VicmakeWriteback()
    autocmd CursorMoved <buffer> call <SID>UpdateCursor()
    hi CursorLine term=reverse cterm=reverse gui=reverse
endfunction

let s:prevLine = -1
function! s:UpdateCursor()
    if g:VicmakeRedraw == 0
        return
    endif
    let l:curLine = line(".")
    if s:prevLine == l:curLine
        return
    endif
    let s:prevLine = l:curLine
"    let l:origNr = winnr()
"    for l:i in range(1, winnr("$"))
"        exe l:i . "wincmd w"
"    endfor
"    exe l:origNr . "wincmd w"
    redraw!
endfunction

"
" writeback cahce
"
function! s:VicmakeWriteback()
python << EOF
# add script directory to search path
import vim, sys
sys.path.append(vim.eval("s:dirName"))
import vicmake

def func():
    cmake = vicmake.GetInstance()
    if cmake == None:
        vim.command(":echo \"ERROR: cache file could not found. run cmake at first\"")
        return
    if not cmake.WritebackCache():
        vim.command(":echo \"ERROR: the number of variable name, type and value are not match.\"")
        return

# run
func()

EOF
endfunction

"
" rerun cmake
"
function! s:VicmakeRerunCmake()
python << EOF
# add script directory to search path
import vim, sys
sys.path.append(vim.eval("s:dirName"))
import vicmake

def func():
    cmake = vicmake.GetInstance()
    if cmake == None:
        vim.command(":echo \"ERROR: cache file could not found. run cmake at first\"")
        return
    if not cmake.RerunCmake():
        vim.command(":echo \"ERROR: the number of variable name, type and value are not match.\"")
        return
    vim.command(":call s:VicmakeReloadCache()")

# run
func()

EOF
endfunction

"
" run cmake
"
function! s:VicmakeRunCmake(dir)
python << EOF
# add script directory to search path
import vim, sys
sys.path.append(vim.eval("s:dirName"))
import vicmake

def func():
    dir = vim.eval("a:dir")
    cmake = vicmake.GetInstance()
    if cmake == None:
        vim.command(":echo \"ERROR: cache file could not found. run cmake at first\"")
        return
    cmake.RunCmake(str(dir))

# run
func()

EOF
endfunction

"
" start edit
"
function! s:VicmakeStartEdit()
python << EOF
# add script directory to search path
import vim, sys
sys.path.append(vim.eval("s:dirName"))
import vicmake

def func():
    cmake = vicmake.GetInstance()
    if cmake == None:
        vim.command(":echo \"ERROR: cache file could not found. run cmake at first\"")
        return
    valFile = cmake.GetValCacheFilename()
    typeFile = cmake.GetTypeCacheFilename()
    nameFile = cmake.GetNameCacheFilename()
    cmake.LoadCache()
    vim.command(":e " + valFile)
    vim.command(":call s:SetupBuff()")
    vim.command(":set scb")
    vim.command(":set cursorbind")

    vim.command(":vnew " + nameFile)
    vim.command(":call s:SetupBuff()")
    vim.command(":set scb")
    vim.command(":set cursorbind")

    if int(vim.eval("g:VicmakeShowType")) != 0:
        vim.command(":vnew " + typeFile)
        vim.command(":call s:SetupBuff()")
        vim.command(":set scb")
        vim.command(":set cursorbind")
# run
func()

EOF
endfunction

"
" reload cache
"
function! s:VicmakeReloadCache()
python << EOF
# add script directory to search path
import vim, sys
sys.path.append(vim.eval("s:dirName"))
import vicmake

def func():
    cmake = vicmake.GetInstance()
    if cmake == None:
        vim.command(":echo \"ERROR: cache file could not found. run cmake at first\"")
        return
    cmake.LoadCache()
    vim.command(":windo e")
    #vim.current.buffer.append(

# run
func()

EOF
endfunction
