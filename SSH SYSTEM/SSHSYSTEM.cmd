@echo off
color 0A
setlocal EnableDelayedExpansion
set count=0

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| find "IPv4"') do (
    set /a count+=1
    set AUTOIP[!count!]=%%A
)

REM Filtra o IP local que começa com 192.168 (ajuste se sua rede for diferente)
for /f "tokens=2 delims=:" %%a in (
  'ipconfig ^| findstr /R "Endereço IPv4" ^| findstr "192.168."'
) do (
    set "ip=%%a"
    set "ip=!ip: =!"
    REM Define localIP com o valor extraído
    set "localIP=!ip!"
)

if "!localIP!"=="" (
    echo Nao foi possivel detectar IP local na rede 192.168.x.x.
    pause
    goto :eof
)

REM Exemplo de uso: extrair prefixo da rede 192.168.6 (primeiras 3 partes)
for /f "tokens=1-3 delims=." %%i in ("!localIP!") do (
    set "prefixoRede=%%i.%%j.%%k"
)


:: ======== FIM DAS FUNÇÕES AUTOMATICAS PARA SETS ==========
set /p user=Insira seu usuario: 

:menu
color 0A
cls
echo =================================================================
echo  Criado e Desenvolvido Por LUIS DAS ARTIMANHAS e PINGOBRAS S.A
echo   [1] Iniciar Server SSH        [2] Parar Server SSH
echo   [3] Conectar SSH Modo Client  [4] Auto Conectar SSH Modo Client
echo   [5] Trocar Usuario            [6] Escanear Rede
echo   [7] Status do Servidor
echo                          [0] Sair
echo =================================================================
echo.
echo IP DEFINIDO DO SERVIDOR: !IP!
echo IP local detectado: !localIP!
echo Prefixo da rede extraido: !prefixoRede!
echo CLIENTE LOCAL DEFINIDO: !user!
echo.

set /p opcao=Insira a opcao: 

if "%opcao%"=="1" (    
	net start sshd
	sc config sshd start=auto
	sc query sshd

	pause
    	goto menu

) else if "%opcao%"=="2" (
	net stop sshd
	sc query sshd

    	pause
    	goto menu

)else if "%opcao%"=="3" (
    	set /p IP=Insira o IP do servidor: 
	
	echo EXECUTANDO: ssh -X -vvv  -E ssh_debug.log -l "%user%" %IP% 
	ssh -X -vvv  -E ssh_debug.log -l "%user%" %IP%
    	pause
	goto menu

)else if "%opcao%"=="4" (
	set /a count=0
	
	echo Escaneando IPs ativos na rede !rede!.0/24 ...
	echo.
	
	REM Escaneia IPs de 1 a 254 dentro da rede extraída
	for /L %%i in (1,1,254) do (
	    set "ip_check=!prefixoRede!.%%i"

	    echo verificando: !ip_check!
	    ping -n 1 -w 60 !ip_check! >nul
	    echo.

    	if !errorlevel! == 0 (
        	set /a count+=1
        	REM Armazena IP no array sem ":" no início
    		set "AUTOIP[!count!]=!ip_check!"
		echo.
    	    	echo [+] IP ativo: !ip_check!
		echo.
	    )
	)

	echo.
	echo Total de IPs ativos: !count!
	echo.

	REM Agora conecta para cada IP ativo corretamente
	for /L %%i in (1,1,!count!) do (
	    set "current_ip=!AUTOIP[%%i]!"
	    echo Conectando-se ao IP[%%i]: !current_ip!
	    set "logfile=ssh_debug_!current_ip!.log"
	    ssh -X -vvv -E "!logfile!" -l "%user%" !current_ip!
	)

    	pause
    	goto menu

) else if "%opcao%"=="5" (
	set /p user=Insira seu usuario: 
	echo ALTERADO COM SUCESSO!
    	pause
    	goto menu

) else if "%opcao%"=="6" (
	set /a count=0

	echo Escaneando IPs ativos na rede !prefixoRede!.0/24 ...
	echo.

	REM Escaneia IPs de 1 a 254 dentro da rede extraída
	for /L %%i in (1,1,254) do (
	    set "ip_check=!prefixoRede!.%%i"

	    echo verificando: !ip_check!
	    ping -n 1 -w 60 !ip_check! >nul
	    echo.
	
	    if !errorlevel! == 0 (
	        set /a count+=1
	        REM Armazena IP no array sem ":" no início
	        set "AUTOIP[!count!]=!ip_check!"
		echo.
		echo [+] IP ativo: !ip_check!
		echo.
	    )
	)
	echo.
	echo Total de IPs ativos: !count!
	echo.


    	pause
    	goto menu

)   else if "%opcao%"=="7" (
	sc query sshd

    	pause
    	goto menu

) else if "%opcao%"=="0" (
	echo =================================================================
    	echo   Criado e Desenvolvido Por LUIS DAS ARTIMANHAS e PINGOBRAS S.A
	echo =================================================================
    	echo Saindo...

    	pause
	net stop sshd
    	exit

) else (
    	echo Opcao invalida. Tente novamente.

	pause
    	goto menu
)