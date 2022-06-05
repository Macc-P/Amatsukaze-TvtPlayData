@echo off
rem 環境変数

rem 字幕のタイミング調整
rem 値を減らす（マイナス方面にする）←　→値を増やす（プラス方面にする）
rem 　　　　　　　　　字幕を早くする←　→字幕を遅くする
rem 　　字幕が映像より遅れているとき←　→字幕が映像より先に出るとき
set frame=-1200
rem 出力後に一時ファイルを削除
rem 1=削除する
set delfile=0
rem pscとvttを隠しファイルにする
rem 1=隠しファイルにする
set hidefile=0

rem exe類を別の場所に移動した場合は変更
set exepath=bat\tvtdata\

echo --- メタデータ処理 ---
set tsfile=%IN_PATH%

echo [ログファイル処理]
set LOG_PATH="%LOG_PATH:.log=.txt%"
rem ログファイルから一時フォルダを取得
for /f "tokens=1,5-6 delims=:" %%A in ('findstr /n "一時フォルダ" %LOG_PATH%') do (
if %%A == 7 (
set tempfolder=%%B:%%C
goto endtempfolder
)
)
:endtempfolder
set tempfolder=%tempfolder:~1%
set tempfolder=%tempfolder:/=\%

rem ログファイルから出力先を取得
for /f "tokens=1,5-6 delims=:" %%A in ('findstr /n "出力" %LOG_PATH%') do (
if %%A == 6 (
set mp4file=%%B:%%C
goto endmp4file
)
)
:endmp4file
set mp4file=%mp4file:~1%
set mp4file=%mp4file:/=\%

echo ログファイル処理終了

rem 通常の場合チャプターを生成しない
for /f "tokens=1,5-6 delims=:" %%A in ('findstr /n "通常" %LOG_PATH%') do (
if %%A == 12 (
echo 出力選択が通常モードのためチャプター生成をスキップ

rem チャプタースキップ時
echo [データ放送・番組情報データ生成]
%exepath%psisiarc.exe -r arib-data "%tsfile%" "%mp4file%.psc"
echo データ放送・番組情報データ生成完了

echo [字幕データ生成]
%exepath%tsreadex.exe -n -1 -r - "%tsfile%" | %exepath%b24tovtt.exe -t vlc -d %frame% "%mp4file%.vtt"
echo 字幕データ生成完了
rem オプション処理へ
goto option
)
)


echo [メタデータ生成用チャプター生成]
rem Trimファイルをkeyframeに変換
for /f "delims=" %%a in (%tempfolder%\trim0.avs) do (
  set trim=%%a
)
echo %trim%
set trim=%trim:Trim=%
set trim=%trim:) ++ (=,%
set trim=%trim:(=%
set trim=%trim:)=%

for %%a in (%trim%) do (
  echo %%a>>"%tempfolder%\data.keyframe"
)

rem keyframeをチャプターに変換
call %exepath%chapter "%tempfolder%\data.keyframe"

rem チャプター整形
setlocal EnableDelayedExpansion
for /f "tokens=1-6 delims=: " %%a in ('findstr /n ".*" %tempfolder%\data.chapters.txt') do (
if %%a leq 9 (
set chapter=0%%a
) else (
set chapter=%%a
)
set chaptername=%%e
set /a hantei=%%a%%2

echo CHAPTER!chapter!=%%b:%%c:%%d >> "%tempfolder%\data.chapter"

if !hantei!==0 (
rem 偶数の場合はカット終了位置
echo CHAPTER!chapter!NAME=ox >> "%tempfolder%\data.chapter"
) else (
rem 奇数の場合はカット開始位置
echo CHAPTER!chapter!NAME=ix >> "%tempfolder%\data.chapter"
)
)
endlocal
echo メタデータ生成用チャプター生成完了

echo [データ放送・番組情報データ生成]
psisiarc.exe -r arib-data -c "%tempfolder%\data.chapter" "%tsfile%" "%mp4file%.psc"
echo データ放送・番組情報データ生成完了


echo [字幕データ生成]
tsreadex.exe -n -1 -r - "%tsfile%" | b24tovtt.exe -t vlc -d %frame%  -c "%tempfolder%\data.chapter" "%mp4file%.vtt"
echo 字幕データ生成完了

:option
rem オプション処理
if %delfile%==1 (
echo [一時ファイル削除]
rd /s /q %tempfolder%
echo 一時ファイル削除完了
)

if %hidefile%==1 (
echo [隠しファイル設定]
attrib +h "%mp4file%.psc"
attrib +h "%mp4file%.vtt"
echo 隠しファイル設定完了
)

echo メタデータ処理終了