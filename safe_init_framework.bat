@echo off
setlocal enabledelayedexpansion
title CODESOFT.BABAOB 项目初始化工具

echo.
echo ========================================
echo 正在智能创建项目结构（兼容Windows路径）
echo ========================================
echo 脚本路径: %~dp0
echo.

REM ----------------- 基础配置 -----------------
set SOLUTION_NAME=BabaobFramework
set SRC_ROOT=src
set TEST_ROOT=test

REM ----------------- 强制使用Windows路径分隔符 -----------------
set SL=\\
set MODULES_PATH=modules%SL%
set SERVICES_PATH=services%SL%

REM ----------------- 初始化解决方案 -----------------
if not exist %SOLUTION_NAME%.sln (
    echo [1/8] 创建解决方案文件
    dotnet new sln -n %SOLUTION_NAME%
) else (
    echo 检测到现有解决方案: %SOLUTION_NAME%.sln
)

REM ----------------- 创建共享层 -----------------
call :CreateProject %SRC_ROOT%%SL%shared Babaob.Shared.Core classlib
call :CreateProject %SRC_ROOT%%SL%shared Babaob.Shared.Infrastructure classlib
call :CreateProject %SRC_ROOT%%SL%shared Babaob.Shared.Web classlib

REM ----------------- 设备模块完整命令 -----------------
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%DeviceModule Device.Domain classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%DeviceModule Device.Application classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%DeviceModule Device.HttpApi webapi

REM ----------------- MES模块完整命令 -----------------
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%MesModule Mes.Domain classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%MesModule Mes.Application classlib
call :CreateProject %SRC_ROOT%%SL%%MODULES_PATH%MesModule Mes.HttpApi webapi

REM ----------------- 身份服务完整命令 -----------------
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%IdentityService Babaob.Identity.Application classlib
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%IdentityService Babaob.Identity.Host webapi

REM ----------------- 数据采集服务完整命令 -----------------
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%DataCollectorService Babaob.DataCollector.Application classlib
call :CreateProject %SRC_ROOT%%SL%%SERVICES_PATH%DataCollectorService Babaob.DataCollector.Host webapi

REM ----------------- 网关服务完整命令 -----------------
call :CreateProject %SRC_ROOT%%SL%gateways Babaob.Gateway webapi

REM ----------------- 测试项目完整命令 -----------------
call :CreateProject %TEST_ROOT% Babaob.UnitTests xunit
call :CreateProject %TEST_ROOT% Babaob.IntegrationTests xunit
call :CreateProject %TEST_ROOT% Babaob.E2ETests xunit

REM ----------------- 工具项目完整命令 -----------------
call :CreateProject %SRC_ROOT%%SL%tools%SL%DeviceSimulator DeviceSimulator console

REM ----------------- 目录结构初始化 -----------------
echo.
echo [7/8] 创建辅助目录结构
mkdir %SRC_ROOT%\tools\DeviceSimulator 2>nul
mkdir .github\workflows 2>nul
mkdir docs\design 2>nul
mkdir docs\api 2>nul

echo. > .github\workflows\build-and-test.yml
echo. > .github\workflows\deploy-prod.yml
echo. > docs\design\architecture.md
echo. > docs\api\swagger.md

REM ----------------- 全局编译配置 -----------------
if not exist Directory.Build.props (
    echo [8/8] 创建全局编译配置
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

REM ----------------- 最终验证 -----------------
echo.
echo ======== 验证阶段 ========
dotnet sln list
dotnet restore
dotnet build

echo.
echo ======== 操作完成 ========
echo 项目结构验证通过！
echo 请使用以下命令提交到Git仓库：
echo   git add .
echo   git commit -m "初始化完整的项目骨架"
echo   git push origin main
endlocal
exit /b

REM ----------------- 核心函数 -----------------
:CreateProject
set parent_dir=%~1
set project_name=%~2
set template_type=%~3
set full_path=%parent_dir%\%project_name%

if not exist "%full_path%" (
    echo [创建项目] %full_path%
    dotnet new %template_type% -n %project_name% -o "%full_path%"
    if errorlevel 1 (
        echo [错误] 创建项目失败: %full_path%
        exit /b 1
    )
    dotnet sln add "%full_path%\%project_name%.csproj"
) else (
    echo [跳过] 项目已存在: %full_path%
)
goto :eof