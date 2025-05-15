@echo off
color 0A
setlocal EnableDelayedExpansion
set count=0

for /f "tokens=2 delims=:" %%A in ('ipconfig ^| find "IPv4"') do (
    set /a count+=1
    set AUTOIP[!count!]=%%A
)
set /p user=Insira seu usuario: 

:menu
color 0A
cls
echo =================================================================
echo  Criado e Desenvolvido Por LUIS DAS ARTIMANHAS e PINGOBRAS S.A
echo   [1] Iniciar Server SSH        [2] Parar Server SSH
echo   [3] Conectar SSH Modo Client  [4] Auto Conectar SSH Modo Client
echo   [5] Trocar Usuario	     [6] Status do Servidor
echo                          [0] Sair
echo =================================================================
echo.
echo IP DEFINIDO DO SERVIDOR: %IP%
echo CLIENTE LOCAL DEFINIDO: %user%
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
	for /l %%i in (1,1,%count%) do (
		echo Conectando se ao IP[%%i]: !AUTOIP[%%i]:~1!
		ssh -X %user%@!AUTOIP[%%i]:~1!
	)

    	pause
	goto menu

) else if "%opcao%"=="5" (
	set /p user=Insira seu usuario: 
	echo ALTERADO COM SUCESSO!
    	pause
    	goto menu

)  else if "%opcao%"=="6" (
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