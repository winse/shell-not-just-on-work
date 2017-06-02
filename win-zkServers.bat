@echo off

setlocal
call "%~dp0zkEnv.cmd"

set ZOO_DEBUG=-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000 

set ZOOMAIN=org.apache.zookeeper.server.quorum.QuorumPeerMain
set FOURMAIN=org.apache.zookeeper.client.FourLetterWordMain

set ZOO_TEMP=%TEMP%
set USAGE="%~n0 [four|one|cluster] [args...]"

set CMD=%1
shift

if "%CMD%" == "four" (
	goto :four
) else if "%CMD%" == "one" (
	goto :start_one
) else if "%CMD%" == "cluster" (
	goto :start_cluster
) else (
	goto :usage 
)

:usage

echo %USAGE%
goto :end

:four
echo off

set host=%1
set port=%2
set cmd=%3

rem org.apache.zookeeper.server.ServerCnxn.cmd2String
rem conf cons crst dump envi gtmk ruok stmk srst *srvr *stat wchc wchp wchs mntr isro
java "-Dzookeeper.log.dir=%ZOO_LOG_DIR%" "-Dzookeeper.root.logger=%ZOO_LOG4J_PROP%" -cp "%CLASSPATH%" %FOURMAIN% %host% %port% %cmd%

goto :end

:start_one
echo on

set server_one=%1

start java "-Dzookeeper.log.dir=%ZOO_LOG_DIR%" "-Dzookeeper.root.logger=%ZOO_LOG4J_PROP%" -cp "%CLASSPATH%" %ZOOMAIN% "%ZOO_TEMP%\zkcluster\%server_one%\zoo.cfg"

goto :end

:start_cluster
echo on

set server_conf_n=%1
set server_start_n=%2

mkdir %ZOO_TEMP%\zkcluster
copy /Y %~dp0..\conf\zoo_sample.cfg  %ZOO_TEMP%\zkcluster\zoo_template.cfg

echo # >> %ZOO_TEMP%\zkcluster\zoo_template.cfg
for /L %%i in (1, 1, %server_conf_n%) do (
	echo server.%%i=localhost:%%i888:%%i999 >> %ZOO_TEMP%\zkcluster\zoo_template.cfg
)

for /L %%i in (1, 1, %server_conf_n%) do (
	mkdir %ZOO_TEMP%\zkcluster\%%i\
	copy /Y %ZOO_TEMP%\zkcluster\zoo_template.cfg %ZOO_TEMP%\zkcluster\%%i\zoo.cfg
	
	echo # >>  %ZOO_TEMP%\zkcluster\%%i\zoo.cfg
	rem echo dataDir=${zoo.tmp.dir}/zkcluster/%%i/ >>  %ZOO_TEMP%\zkcluster\%%i\zoo.cfg
	echo dataDir=%ZOO_TEMP:\=/%/zkcluster/%%i/>>  %ZOO_TEMP%\zkcluster\%%i\zoo.cfg
	
	echo # >>  %ZOO_TEMP%\zkcluster\%%i\zoo.cfg
	echo clientPort=218%%i>>  %ZOO_TEMP%\zkcluster\%%i\zoo.cfg
	
	echo %%i> %ZOO_TEMP%\zkcluster\%%i\myid
)

for /L %%i in (1, 1, %server_start_n%) do (
	start java "-Dzookeeper.log.dir=%ZOO_LOG_DIR%" "-Dzookeeper.root.logger=%ZOO_LOG4J_PROP%" -cp "%CLASSPATH%" %ZOOMAIN% "%ZOO_TEMP%\zkcluster\%%i\zoo.cfg"
)

goto :end

:end

endlocal
