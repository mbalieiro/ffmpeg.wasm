@echo off

SET MT_FLAGS=-sUSE_PTHREADS -pthread

SET DEV_ARGS=--progress=plain

SET DEV_CFLAGS=--profiling
SET DEV_MT_CFLAGS=%DEV_CFLAGS% %MT_FLAGS%
SET PROD_CFLAGS=-O3 -msimd128
SET PROD_MT_CFLAGS=%PROD_CFLAGS% %MT_FLAGS%

IF /I "%1"=="clean" GOTO clean
IF /I "%1"=="build" GOTO build
IF /I "%1"=="build-st" GOTO build-st
IF /I "%1"=="build-mt" GOTO build-mt
IF /I "%1"=="dev-st" GOTO dev-st
IF /I "%1"=="dev-mt" GOTO dev-mt
IF /I "%1"=="prd-st" GOTO prd-st
IF /I "%1"=="prd-mt" GOTO prd-mt
IF /I "%1"=="" GOTO all
GOTO error

:all
	GOTO :dev-st

:clean
	rmdir /s /q packages\core-st\dist
	rmdir /s /q packages\core-mt\dist
	GOTO :EOF

:build
	CALL make clean
	docker buildx build --build-arg EXTRA_CFLAGS="%EXTRA_CFLAGS%" --build-arg EXTRA_LDFLAGS="%EXTRA_LDFLAGS%" --build-arg FFMPEG_MT="%FFMPEG_MT%" --build-arg FFMPEG_ST="%FFMPEG_ST%" -o ./packages/core%PKG_SUFFIX% "%EXTRA_ARGS%" .
	GOTO :EOF

:build-st
	SET PKG_SUFFIX=-st
	SET FFMPEG_ST=yes
	SET FFMPEG_MT=
	CALL make build
	GOTO :EOF

:build-mt
	SET PKG_SUFFIX=-mt
	SET FFMPEG_ST=
	SET FFMPEG_MT=yes
	CALL make build
	GOTO :EOF

:dev-st
	SET EXTRA_CFLAGS=%DEV_CFLAGS%
	SET EXTRA_ARGS=%DEV_ARGS%
	CALL make build-st
	GOTO :EOF

:dev-mt
	SET EXTRA_CFLAGS=%DEV_MT_CFLAGS%
	SET EXTRA_ARGS=%DEV_ARGS%
	CALL make build-mt
	GOTO :EOF

:prd-st
	SET EXTRA_CFLAGS=%PROD_CFLAGS%
	CALL make build-st
	GOTO :EOF

:prd-mt
	SET EXTRA_CFLAGS=%PROD_MT_CFLAGS%
	CALL make build-mt
	GOTO :EOF

:error
    IF "%1"=="" (
        ECHO make: *** No targets specified and no makefile found.  Stop.
    ) ELSE (
        ECHO make: *** No rule to make target '%1%'. Stop.
    )
    GOTO :EOF
