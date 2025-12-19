@echo off
set "FOLDER_NAME=TinyTorch"

echo.
echo === TinyTorch Environment Setup Script (Step 2 of 2) ===
echo.

:: --- Step 1: Create and Activate Environment ---
echo 1. Creating Python virtual environment...
python -m venv .venv

:: Check if venv creation was successful
if not exist ".\.venv\Scripts\activate.bat" (
    echo ERROR: Failed to create virtual environment. Ensure Python is installed and in your PATH.
    pause
    exit /b 1
)

echo Virtual environment created successfully.
echo Activating environment and installing dependencies...
call .\.venv\Scripts\activate.bat

:: --- Step 2: Install Dependencies ---
echo 2. Installing dependencies and TinyTorch in editable mode...
pip install -e .

:: --- Step 3: Verify Installation ---
echo.
echo 3. Running TinyTorch system diagnostics...
tito system doctor

:: --- Final Instructions ---
echo.
echo === Setup Complete! ===
echo.
echo To start building, please CLOSE this window and open a new Command Prompt (CMD) window.
echo You must navigate to the **%CD%** folder and activate the environment:
echo.
echo     cd %CD%
echo     .\.venv\Scripts\activate.bat
echo.
pause
