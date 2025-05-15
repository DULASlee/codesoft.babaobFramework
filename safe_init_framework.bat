@echo off
setlocal enabledelayedexpansion
title CODESOFT.BABAOB ��Ŀ��ʼ������

echo.
echo ========================================
echo �������ܴ�����Ŀ�ṹ������Windows·����
echo ========================================
echo �ű�·��: %~dp0
echo.

REM ----------------- �������� -----------------
set SOLUTION_NAME=BabaobFramework
set SRC_ROOT=src
set TEST_ROOT=test

REM ----------------- ǿ��ʹ��Windows·���ָ��� -----------------
set SL=\\
set MODULES_PATH=modules%SL%
set SERVICES_PATH=services%SL%

REM ----------------- ��ʼ��������� -----------------
if not exist %SOLUTION_NAME%.sln (
    echo [1/8] ������������ļ�
    dotnet new sln -n %SOLUTION_NAME%
) else (
    echo ��⵽���н������: %SOLUTION_NAME%.sln
)

REM ----------------- ��������� -----------------
call :CreateProject %SRC_ROOT%%SL%shared Babaob.Shared.Core classlib
call :CreateProject %SRC_ROOT%%SL%shared Babaob.Shared.Infrastructure classlib
call :CreateProject %SRC_ROOT%%SL%shared Babaob.Shared.Web classlib

REM ----------------- �豸ģ���������� -----------------
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%DeviceModule Device.Domain classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%DeviceModule Device.Application classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%DeviceModule Device.HttpApi webapi

REM ----------------- MESģ���������� -----------------
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%MesModule Mes.Domain classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%MesModule Mes.Application classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%MesModule Mes.HttpApi webapi

REM ----------------- ��ݷ����������� -----------------
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%IdentityService Babaob.Identity.Application classlib
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%IdentityService Babaob.Identity.Host webapi

REM ----------------- ���ݲɼ������������� -----------------
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%DataCollectorService Babaob.DataCollector.Application classlib
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%DataCollectorService Babaob.DataCollector.Host webapi

REM ----------------- ���ط����������� -----------------
call :CreateProject %SRC_ROOT%%SL%gateways Babaob.Gateway webapi

REM ----------------- ������Ŀ�������� -----------------
call :CreateProject %TEST_ROOT% Babaob.UnitTests xunit
call :CreateProject %TEST_ROOT% Babaob.IntegrationTests xunit
call :CreateProject %TEST_ROOT% Babaob.E2ETests xunit

REM ----------------- ������Ŀ�������� -----------------
call :CreateProject %SRC_ROOT%%SL%tools%SL%DeviceSimulator DeviceSimulator console

REM ----------------- Ŀ¼�ṹ��ʼ�� -----------------
echo.
echo [7/8] ��������Ŀ¼�ṹ
mkdir %SRC_ROOT%\tools\DeviceSimulator 2>nul
mkdir .github\workflows 2>nul
mkdir docs\design 2>nul
mkdir docs\api 2>nul

echo. > .github\workflows\build-and-test.yml
echo. > .github\workflows\deploy-prod.yml
echo. > docs\design\architecture.md
echo. > docs\api\swagger.md

REM ----------------- ȫ�ֱ������� -----------------
if not exist Directory.Build.props (
    echo [8/8] ����ȫ�ֱ�������
    (
        echo ^<Project^>
        echo   ^<PropertyGroup^>
        echo     ^<Version^>1.0.0-dev^</Version^>
        echo     ^<LangVersion^>latest^</LangVersion^>
        echo     ^<Nullable^>enable^</Nullable^>
        echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
        echo   ^</PropertyGroup^>
        echo ^</Project^>
    ) > Directory.Build.props
)

REM ----------------- ������֤ -----------------
echo.
echo ======== ��֤�׶� ========
dotnet sln list
dotnet restore
dotnet build

echo.
echo ======== ������� ========
echo ��Ŀ�ṹ��֤ͨ����
echo ��ʹ�����������ύ��Git�ֿ⣺
echo   git add .
echo   git commit -m "��ʼ����������Ŀ�Ǽ�"
echo   git push origin main
endlocal
exit /b

REM ----------------- ���ĺ��� -----------------
:CreateProject
set parent_dir=%~1
set project_name=%~2
set template_type=%~3
set full_path=%parent_dir%\%project_name%

if not exist "%full_path%" (
    echo [������Ŀ] %full_path%
    dotnet new %template_type% -n %project_name% -o "%full_path%"
    if errorlevel 1 (
        echo [����] ������Ŀʧ��: %full_path%
        exit /b 1
    )
    dotnet sln add "%full_path%\%project_name%.csproj"
) else (
    echo [����] ��Ŀ�Ѵ���: %full_path%
)
goto :eof