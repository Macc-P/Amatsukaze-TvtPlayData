@echo off
rem ���ϐ�

rem �����̃^�C�~���O����
rem �l�����炷�i�}�C�i�X���ʂɂ���j���@���l�𑝂₷�i�v���X���ʂɂ���j
rem �@�@�@�@�@�@�@�@�@�����𑁂����適�@��������x������
rem �@�@�������f�����x��Ă���Ƃ����@���������f������ɏo��Ƃ�
set frame=-1200
rem �o�͌�Ɉꎞ�t�@�C�����폜
rem 1=�폜����
set delfile=0
rem psc��vtt���B���t�@�C���ɂ���
rem 1=�B���t�@�C���ɂ���
set hidefile=0

rem exe�ނ�ʂ̏ꏊ�Ɉړ������ꍇ�͕ύX
set exepath=bat\tvtdata\

echo --- ���^�f�[�^���� ---
set tsfile=%IN_PATH%

echo [���O�t�@�C������]
set LOG_PATH="%LOG_PATH:.log=.txt%"
rem ���O�t�@�C������ꎞ�t�H���_���擾
for /f "tokens=1,5-6 delims=:" %%A in ('findstr /n "�ꎞ�t�H���_" %LOG_PATH%') do (
if %%A == 7 (
set tempfolder=%%B:%%C
goto endtempfolder
)
)
:endtempfolder
set tempfolder=%tempfolder:~1%
set tempfolder=%tempfolder:/=\%

rem ���O�t�@�C������o�͐���擾
for /f "tokens=1,5-6 delims=:" %%A in ('findstr /n "�o��" %LOG_PATH%') do (
if %%A == 6 (
set mp4file=%%B:%%C
goto endmp4file
)
)
:endmp4file
set mp4file=%mp4file:~1%
set mp4file=%mp4file:/=\%

echo ���O�t�@�C�������I��

rem �ʏ�̏ꍇ�`���v�^�[�𐶐����Ȃ�
for /f "tokens=1,5-6 delims=:" %%A in ('findstr /n "�ʏ�" %LOG_PATH%') do (
if %%A == 12 (
echo �o�͑I�����ʏ탂�[�h�̂��߃`���v�^�[�������X�L�b�v

rem �`���v�^�[�X�L�b�v��
echo [�f�[�^�����E�ԑg���f�[�^����]
%exepath%psisiarc.exe -r arib-data "%tsfile%" "%mp4file%.psc"
echo �f�[�^�����E�ԑg���f�[�^��������

echo [�����f�[�^����]
%exepath%tsreadex.exe -n -1 -r - "%tsfile%" | %exepath%b24tovtt.exe -t vlc -d %frame% "%mp4file%.vtt"
echo �����f�[�^��������
rem �I�v�V����������
goto option
)
)


echo [���^�f�[�^�����p�`���v�^�[����]
rem Trim�t�@�C����keyframe�ɕϊ�
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

rem keyframe���`���v�^�[�ɕϊ�
call %exepath%chapter "%tempfolder%\data.keyframe"

rem �`���v�^�[���`
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
rem �����̏ꍇ�̓J�b�g�I���ʒu
echo CHAPTER!chapter!NAME=ox >> "%tempfolder%\data.chapter"
) else (
rem ��̏ꍇ�̓J�b�g�J�n�ʒu
echo CHAPTER!chapter!NAME=ix >> "%tempfolder%\data.chapter"
)
)
endlocal
echo ���^�f�[�^�����p�`���v�^�[��������

echo [�f�[�^�����E�ԑg���f�[�^����]
psisiarc.exe -r arib-data -c "%tempfolder%\data.chapter" "%tsfile%" "%mp4file%.psc"
echo �f�[�^�����E�ԑg���f�[�^��������


echo [�����f�[�^����]
tsreadex.exe -n -1 -r - "%tsfile%" | b24tovtt.exe -t vlc -d %frame%  -c "%tempfolder%\data.chapter" "%mp4file%.vtt"
echo �����f�[�^��������

:option
rem �I�v�V��������
if %delfile%==1 (
echo [�ꎞ�t�@�C���폜]
rd /s /q %tempfolder%
echo �ꎞ�t�@�C���폜����
)

if %hidefile%==1 (
echo [�B���t�@�C���ݒ�]
attrib +h "%mp4file%.psc"
attrib +h "%mp4file%.vtt"
echo �B���t�@�C���ݒ芮��
)

echo ���^�f�[�^�����I��